`timescale 1ns / 1ps

module acumulador (
    input  wire       clk,
    input  wire       rst,      // Reset síncrono general
    input  wire       start,    // Pulso de inicio (1 ciclo)
    input  wire       cancel,   // Señal de cancelación inmediata
    input  wire [1:0] mode,     // Selector de modo de operación
    input  wire [3:0] x,        // Valor de entrada
    output reg  [5:0] acc,      // Acumulador (6 bits soporta hasta 63)
    output reg        done      // Pulso de 1 ciclo al completar exitosamente
);

    // Codificación de Estados
    localparam IDLE = 2'b00;
    localparam LOAD = 2'b01;
    localparam ADD  = 2'b10;
    localparam DONE = 2'b11;

    reg [1:0] state, next_state;
    reg [2:0] count; // Contador de iteraciones (hasta 7)

    // 1. Registro de Estado (Secuencial sincrónico)
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // 2. Lógica Combinacional de Siguiente Estado
    always @(*) begin
        next_state = state;

        case (state)
            IDLE: begin
                if (start && !cancel)
                    next_state = LOAD;
                else
                    next_state = IDLE;
            end

            LOAD: begin
                if (cancel)
                    next_state = IDLE;
                else
                    next_state = ADD;
            end

            ADD: begin
                if (cancel) begin
                    next_state = IDLE; // Aborta inmediatamente
                end else begin
                    case (mode)
                        // Modo 0: Sumar 3 veces (cuenta: 0, 1, 2 -> termina en 2)
                        2'b00: begin
                            if (count == 3'd2)
                                next_state = DONE;
                            else
                                next_state = ADD;
                        end

                        // Modo 1: Sumar 4 veces (cuenta: 0, 1, 2, 3 -> termina en 3)
                        2'b01: begin
                            if (count == 3'd3)
                                next_state = DONE;
                            else
                                next_state = ADD;
                        end

                        // Modo 2: Sumar hasta que acc + x >= 20
                        2'b10: begin
                            if ((acc + x) >= 6'd20)
                                next_state = DONE;
                            else
                                next_state = ADD;
                        end

                        default: next_state = IDLE;
                    endcase
                end
            end

            DONE: begin
                next_state = IDLE; // Permanece 1 ciclo en DONE y retorna
            end

            default: next_state = IDLE;
        endcase
    end

    // 3. Datapath y Salidas (Secuencial sincrónico)
    always @(posedge clk) begin
        if (rst || cancel) begin
            acc   <= 6'd0;
            count <= 3'd0;
            done  <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    done  <= 1'b0;
                    count <= 3'd0;
                end

                LOAD: begin
                    acc   <= 6'd0; // Limpia el acumulador para la nueva operación
                    count <= 3'd0;
                    done  <= 1'b0;
                end

                ADD: begin
                    acc   <= acc + x;       // Suma el valor actual de x
                    count <= count + 1'b1;  // Incrementa contador de ciclos
                    done  <= 1'b0;
                end

                DONE: begin
                    done  <= 1'b1; // Señal activa solo durante el estado DONE
                end
            endcase
        end
    end

endmodule