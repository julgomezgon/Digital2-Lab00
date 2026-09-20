module semaforo (
    input clk,
    input rst,
    output reg green,
    output reg yellow,
    output reg red
);

    // Estados
    parameter S0 = 2'b00;
    parameter S1 = 2'b01;
    parameter S2 = 2'b10;
    parameter S3 = 2'b11;

    // Estado actual
    reg [1:0] state;

    // Contador de ciclos
    reg [2:0] counter;


    // Registro de estado + contador + reset
    always @(posedge clk) begin

        if (rst) begin
            state <= S0;
            counter <= 0;
        end

        else begin

            case (state)

                S0: begin
                    if (counter == 4) begin
                        state <= S1;
                        counter <= 0;
                    end
                    else begin
                        counter <= counter + 1;
                    end
                end

                S1: begin
                    if (counter == 1) begin
                        state <= S2;
                        counter <= 0;
                    end
                    else begin
                        counter <= counter + 1;
                    end
                end

                S2: begin
                    if (counter == 3) begin
                        state <= S3;
                        counter <= 0;
                    end
                    else begin
                        counter <= counter + 1;
                    end
                end

                S3: begin
                    if (counter == 1) begin
                        state <= S0;
                        counter <= 0;
                    end
                    else begin
                        counter <= counter + 1;
                    end
                end

                default: begin
                    state <= S0;
                    counter <= 0;
                end

            endcase

        end

    end


    // Lógica de salidas
    always @(*) begin

        green = 0;
        yellow = 0;
        red = 0;

        case (state)

            S0:
                green = 1;

            S1:
                yellow = 1;

            S2:
                red = 1;

            S3:
                yellow = 1;

        endcase

    end

endmodule