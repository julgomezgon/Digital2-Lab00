// Ejercicio 3 (BONO) - Testbench

`timescale 1ns / 1ps



module tb_Transmisor_Serial;

    // Parámetros de prueba
    parameter CLKS_PER_BIT = 8;   // Duración de cada bit en ciclos de reloj
    parameter CLK_PERIOD   = 10;  // Período de reloj de 10ns (100 MHz)

    // Entradas
    reg       clk;      // Reloj del sistema
    reg       rst;      // Reset síncrono
    reg       start;    // Pulso de inicio de transmisión
    reg [7:0] data_in;  // Byte a transmitir

    // Salidas
    wire tx;    // Línea de salida serial
    wire busy;  // Indicador de transmisión en curso
    wire done;  // Pulso de finalización de transmisión

    // Instancia del Transmisor Serial
    Transmisor_Serial #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_in(data_in),
        .tx(tx),
        .busy(busy),
        .done(done)
    );

    // Invierte el estado del clk cada medio período (5ns)
    always #(CLK_PERIOD / 2) clk = ~clk;

    // Generación de VCD
    initial begin
        // Archivos de salida para simulación en GTKWave
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_Transmisor_Serial);

        // Inicialización de señales del sistema
        clk     = 0;
        rst     = 1;
        start   = 0;
        data_in = 8'h00;

        // Reset inicial del sistema durante 2 ciclos de reloj
        #(CLK_PERIOD * 2);
        rst = 0;  // Libera el reset
        #(CLK_PERIOD * 2);

        // --- Transmisión 1: 8'hA5 (10100101 en binario) ---
        $display("Iniciando Transmision 1: 0xA5");
        data_in = 8'hA5;  // Carga del primer byte de prueba
        
        // Generación del pulso de start de exactamente 1 ciclo de reloj
        start = 1;
        #(CLK_PERIOD);
        start = 0;

        // Espera activa (1) hasta que el módulo indique que terminó la transmisión
        @(posedge done);
        #(CLK_PERIOD * 5); 

        // --- Transmisión 2: 8'h3C (00111100 en binario) ---
        $display("Iniciando Transmision 2: 0x3C");
        data_in = 8'h3C;  // Carga del segundo byte de prueba
        
        // Generación del pulso de start de exactamente 1 ciclo de reloj
        start = 1;
        #(CLK_PERIOD);
        start = 0;

        // Espera activa hasta que el módulo indique que terminó la transmisión
        @(posedge done);
        #(CLK_PERIOD * 5); 

        
        $display("Termino la simulacion, todo salio bien :)");
        $finish;
    end

endmodule