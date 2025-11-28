`timescale 1ns/1ps

module Seg7dec_tb();

    reg  [3:0] x;
    wire [6:0] y;

    Seg7dec uut (
        .x(x),
        .y(y)
    );

    initial begin
        $display(" x | y ");
        $display("--");

        for (integer i = 0; i < 16; i = i + 1) begin
            x = i;  
            #10;
            $display("%4b | %7b", x, y);
        end

        $stop;
    end

endmodule
