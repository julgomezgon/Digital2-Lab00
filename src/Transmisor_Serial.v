// Ejercicio 3 (BONO) Transmisor Serial

module Transmisor_Serial #(
    parameter CLKS_PER_BIT = 8 // Numero de ciclos de reloj por cada bit transmitido
)(
    input  wire       clk,      // Reloj del sistema
    input  wire       rst,      // Reset síncrono
    input  wire       start,    // Pulso de inicio de transmisión
    input  wire [7:0] data_in,  // Byte a transmitir
    output reg        tx,       // Línea de salida serial
    output reg        busy,     // Muestra que la transmisión está en curso
    output reg        done      // Pulso de 1 ciclo al finalizar la transmisión
);

    // Codificación de Estados de 3 bits para representar los 5 estados de la máquina
    localparam STATE_IDLE       = 3'b000;
    localparam STATE_LOAD       = 3'b001;
    localparam STATE_BIT_HOLD   = 3'b010;
    localparam STATE_SHIFT_NEXT = 3'b011;
    localparam STATE_DONE       = 3'b100;

    // Registros del Datapath y Control
    reg [2:0] state;       // Registro de Estado de la FSM (Unidad de Control)
    reg [7:0] shift_reg;   // Registro de Desplazamiento
    reg [2:0] bit_count;   // Contador de Bits Transmitidos
    reg [$clog2(CLKS_PER_BIT)-1:0] tick_cnt;  // Temporizador de Ancho de Bit

    // FSM y Lógica Secuencial
    always @(posedge clk) begin
        if (rst) begin
            state     <= STATE_IDLE;
            shift_reg <= 8'h00;
            bit_count <= 3'd0;
            tick_cnt  <= 0;
            tx        <= 1'b1;  // Línea serial en reposo (High)
            busy      <= 1'b0;
            done      <= 1'b0;  // Reset de la señal de finalización 
        end else begin
            // Pulso predeterminado para done (1 solo ciclo)
            done <= 1'b0;

            case (state)
                STATE_IDLE: begin
                    tx   <= 1'b1;  // Mantiene la línea serial en alto durante el reposo
                    busy <= 1'b0;  // Indica que el transmisor está libre
                    if (start) begin
                        state <= STATE_LOAD;  // Transición al estado de carga al detectar pulso de inicio
                    end
                end

                STATE_LOAD: begin
                    shift_reg <= data_in; // Carga el byte de entrada
                    bit_count <= 3'd0;    // Reinicia contador de bits
                    tick_cnt  <= 0;       // Reinicia temporizador
                    busy      <= 1'b1;    // Activa la señal de ocupado
                    state     <= STATE_BIT_HOLD;  // Pasa a sostener el primer bit
                end

                STATE_BIT_HOLD: begin
                    tx   <= shift_reg[0]; // Salida LSB primero
                    busy <= 1'b1;         // Mantiene la señal de transmisión en curso

                    if (tick_cnt == CLKS_PER_BIT - 1) begin
                        tick_cnt <= 0;    // Reinicia el contador del temporizador de bit
                        state    <= STATE_SHIFT_NEXT;  // Transiciona para desplazar al siguiente bit
                    end else begin
                        tick_cnt <= tick_cnt + 1'b1;  // Incrementa el temporizador de tiempo por bit
                    end
                end

                STATE_SHIFT_NEXT: begin
                    busy <= 1'b1;  // Mantiene ocupado durante la preparación del bit
                    if (bit_count == 3'd7) begin
                        state <= STATE_DONE;  // Transiciona a estado final al completar los 8 bits
                    end else begin
                        shift_reg <= shift_reg >> 1; // Desplaza 1 bit a la derecha
                        bit_count <= bit_count + 1'b1; // Incrementa el contador de bits transmitidos
                        state     <= STATE_BIT_HOLD;  // Retorna a sostener el nuevo bit
                    end
                end

                STATE_DONE: begin
                    busy  <= 1'b0;  // Desactiva la señal de ocupado
                    done  <= 1'b1;  // Genera el pulso de finalización
                    tx    <= 1'b1;  // Restablece la línea serial a reposo
                    state <= STATE_IDLE;  // Retorna al estado inicial para aguardar un nuevo start
                end

                default: state <= STATE_IDLE;  // Recuperación ante estado no válido
            endcase
        end
    end

endmodule