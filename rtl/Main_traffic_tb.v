`timescale 1ns/1ns

module Main_traffic_tb();

    reg clk, reset, pause;
    reg [9:0] SW;
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    wire [9:0] LEDR;

    Main_traffic DUT(
        .clk(clk),
        .reset(reset),
        .pause(pause),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5),
        .LEDR(LEDR),
        .SW(SW)
    );
  
    always #5 clk = ~clk;
                       
    
    initial begin
        clk = 0; reset = 0; pause = 0; SW = 10'b0;
        $display("\n Testbench start \n");

        reset = 1;  #20;
        reset = 0;  #200;

        $display("pause engaged"); // pause
        pause = 1; #20; pause = 0;
        #200;

        
        $display("resume"); // unpause
        pause = 1; #20; pause = 0;
        #200;

        $display("reset to hold"); // SW8 = 1, SW9 = 0
        SW[8]=1; SW[9]=0;
        reset = 1; #20; reset = 0;
        #200;
        SW=0;

        $display("reset to go"); // SW8 = 0, SW9 = 1
        SW[9]=1; SW[8]=0;
        reset = 1; #20; reset = 0;
        #300;
        SW=0;

        $display("reset to slow"); // SW8 = 1, SW9 = 1
        SW[9]=1; SW[8]=1;
        reset = 1; #20; reset = 0;
        #300;
        SW=0;

      
        $display("reset to stop"); // SW8 = 1, SW9 = 0
        reset = 1; #20; reset = 0;
        #300;

        $display("\n Testbench over \n");
        $stop;
    end

endmodule
