`timescale 1ns/1ps

module tb_semaforo;

    reg clk;
    reg rst;

    wire green;
    wire yellow;
    wire red;
    initial begin

    $dumpfile("semaforo.vcd");
    $dumpvars(0, tb_semaforo);

    clk = 0;
    rst = 1;

    #20;

    rst = 0;

    #150;

    $finish;

end

    // Instancia del semáforo
    semaforo dut (
        .clk(clk),
        .rst(rst),
        .green(green),
        .yellow(yellow),
        .red(red)
    );

    // Generación del reloj
    always #5 clk = ~clk;

    // Prueba
    initial begin

        clk = 0;
        rst = 1;

        // Mantener reset durante algunos ciclos
        #20;

        rst = 0;

        // Dejar correr la FSM
        #150;

        $finish;

    end

    // Mostrar señales en la terminal
    always @(posedge clk) begin
        $strobe("t=%0t | rst=%b | state=%b | counter=%d | G=%b Y=%b R=%b",
                $time, rst, dut.state, dut.counter,
                green, yellow, red);
    end

endmodule