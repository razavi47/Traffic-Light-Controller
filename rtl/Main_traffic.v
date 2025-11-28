module Main_traffic(clk, reset, pause, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, SW);
	input clk, reset, pause; //clk for interal clock, reset for override and pause to hold the signals
	input [9:0] SW; //override options (SW 9 & 8 for reset values, SW 7-5 reps cross light, SW 2-0 reps main light in order RED, YELLOW, GREEN.
	// switches 7-0 are NOT functional, purely for display, only SW 9 & 8 are used for override conditions
	output reg [6:0] HEX2, HEX3, HEX4, HEX5; //HEX (5,4,3,2) for displaying written traffic instructions
	output [6:0] HEX0, HEX1; //HEX (1,0) for displaying timer values in tens and ones column
	output reg [9:0] LEDR;  // LEDS for displaying signal state

	parameter D = 32'd50000000;  //clk parameters
	parameter one_sec = D - 1; // 1 second counter
	reg [31:0] count;
	reg [5:0] seconds, s;
	reg paused, pause_prev, reset_prev, switch;
	reg [1:0] text;

	reg [23:0] blink_count; // for SLO blinking
	wire blink;

	assign blink = blink_count[23];  // slow blink iteration

	initial begin
		s <= 0; // state variable: 0 = STOP, 1 = HOLD, 2 = GO, 3 = SLOW
		switch <= 0; // toggle variable for time assignment
		count <= 0; // main clock counter
		seconds <= 20; // initial time for STOP
		paused <= 0; // paused state
		pause_prev <= 0; // previous pause state
		reset_prev <= 0; // previous reset state
		blink_count <= 0; // blink counter initialization for "SLO" state
	end

	always @(posedge clk) begin
		blink_count <= blink_count + 1;

		if (!reset_prev && reset) begin //override condition
			paused <= 0;
			count <= 0;
			if (SW[8] && !SW[9]) begin //overrides reset to "HOLd"
				seconds <= 5;
				s <= 1;
				switch <= 1;
			end else if (SW[9] && !SW[8]) begin //overrides reset to "GO"
				seconds <= 20;
				s <= 2;
				switch <= 0;
			end else if (SW[8] && SW[9]) begin //overrides reset to "SLO"
				seconds <= 5;
				s <= 3;
				switch <=1;
			end else begin //overrides reset to "StOP" (default condition)
				seconds <= 20;
				s <= 0;
				switch <= 0;
			end
			end else if (!pause_prev && pause) begin
				paused <= ~paused;
			end

			if (seconds == 0) begin // normal behavior (no override)
				s <= s + 1;
				switch <= ~switch;        // toggle StOP/HOLd/GO/SLO cycle flow
				seconds <= switch ? 20 : 5; // StOP,GO=20, SLO,HOLd=5
			end

			reset_prev <= reset;
			pause_prev <= pause;

		if (!paused) begin // main countdown start
				if (seconds > 0) begin
					if (count >= one_sec) begin
						count <= 0;
						seconds <= seconds - 1;
					end else begin
						count <= count + 1;
					end
				end
			end
	end

	reg [3:0] tens, ones;
	always @(*) begin
		tens = seconds / 10;
		ones = seconds % 10;
		text = s % 4;

		if (text == 0) begin // StOP (20s)
			HEX5 <= 'b0010010; // S
			HEX4 <= 'b0000111; // t
			HEX3 <= 'b1000000; // O
			HEX2 <= 'b0001100; // P
		end else if (text == 1) begin // HOLd (20s)
			HEX5 <= 'b0001001; // H
			HEX4 <= 'b1000000; // O
			HEX3 <= 'b1000111; // L
			HEX2 <= 'b0100001; // d
		end else if (text == 2) begin // GO (20s)
			HEX5 <= 'b1111111; // off
			HEX4 <= 'b0000010; // G
			HEX3 <= 'b1000000; // O
			HEX2 <= 'b1111111; // off
		end else if (text == 3) begin // SLO (5s)
			HEX5 <= 'b0010010; // S
			HEX4 <= 'b1000111; // L
			HEX3 <= 'b1000000; // O
			HEX2 <= 'b1111111; // off
		end
	end

	Seg7dec s0 (ones, HEX0); // ones column
	Seg7dec s1 (tens, HEX1); // tens column

	always @(*) begin
		LEDR[9:0] = 10'b0; // clear all LEDs first, all are off

		case(text)
			0: begin // STOP (main light stop, cross light go)
				LEDR[2] = 1;   // main light is red
            	LEDR[5] = 1;   // cross light is green
			end
			1: begin // HOLD (waiting to turn green, still red. cross is blinking)
				LEDR[2] = 1; // main light is red, will turn green when slow timer is done
				LEDR[6] = blink; // cross light is yellow
			end
			2: begin // GO (main light go, cross light stop)
				LEDR[0] = 1;   // main light is green
            	LEDR[7] = 1;   // cross light is red
			end
			3: begin // SLOW (main is blinking)
            	LEDR[1] = blink; // main light is yellow
            	LEDR[7] = 1; // cross light is red, will turn green when slow timer is done
			end

		endcase
	end

endmodule
