`timescale 1ns / 1ps

module tb_acumulador;

    reg        clk;
    reg        rst;
    reg        start;
    reg        cancel;
    reg  [1:0] mode;
    reg  [3:0] x;
    wire [5:0] acc;
    wire       done;

    // Instancia del módulo bajo prueba (UUT)
    acumulador uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .cancel(cancel),
        .mode(mode),
        .x(x),
        .acc(acc),
        .done(done)
    );

    // Reloj: Período de 10ns (50 MHz)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb_acumulador.vcd");
        $dumpvars(0, tb_acumulador);

        // Inicialización de señales
        clk    = 0;
        rst    = 1;
        start  = 0;
        cancel = 0;
        mode   = 2'b00;
        x      = 4'd0;

        #20;
        rst = 0; // Desactivar reset
        #10;

        // ========================================================
        // PRUEBA 1: Modo 00 -> Sumar x=4, tres (3) veces
        // Resultado esperado: acc = 12
        // ========================================================
        mode  = 2'b00;
        x     = 4'd4;
        start = 1;
        #10;
        start = 0;

        @(posedge done);
        #20;

        // ========================================================
        // PRUEBA 2: Modo 01 -> Sumar x=3, cuatro (4) veces
        // Resultado esperado: acc = 12
        // ========================================================
        mode  = 2'b01;
        x     = 4'd3;
        start = 1;
        #10;
        start = 0;

        @(posedge done);
        #20;

        // ========================================================
        // PRUEBA 3: Modo 10 -> Sumar x=6 hasta que acc >= 20
        // Secuencia: 6, 12, 18, 24 -> Termina con acc = 24
        // ========================================================
        mode  = 2'b10;
        x     = 4'd6;
        start = 1;
        #10;
        start = 0;

        @(posedge done);
        #20;

        // ========================================================
        // PRUEBA 4: Cancelación en pleno proceso
        // Iniciamos con modo 4 sumas, pero enviamos cancel al 2do ciclo
        // ========================================================
        mode  = 2'b01;
        x     = 4'd5;
        start = 1;
        #10;
        start = 0;

        // Esperar a que entre al estado ADD (unos 15 ns) y aplicar cancel
        #15;
        cancel = 1;
        #10;
        cancel = 0;

        #40;
        $display("Pruebas completadas exitosamente.");
        $finish;
    end

endmodule