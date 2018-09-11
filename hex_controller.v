//DE10 Standard hex controller
//Tristan Woodrich
//9/11/2018



module hex_controller(

	input [7:0] data_0,
	input [7:0] data_1,
	input [7:0] data_2,
	
	output reg [6:0] hex_display_0,
	output reg [6:0] hex_display_1,
	output reg [6:0] hex_display_2,
	output reg [6:0] hex_display_3,
	output reg [6:0] hex_display_4,
	output reg [6:0] hex_display_5);
	
	always begin
	
		decode(data_0[3:0], hex_display_0);
		decode(data_0[7:4], hex_display_1);
		decode(data_1[3:0], hex_display_2);
		decode(data_1[7:4], hex_display_3);
		decode(data_2[3:0], hex_display_4);
		decode(data_2[7:4], hex_display_5);
		
	end
	
	task decode;
		input [3:0] binary;
		output [6:0] hex_out;
		begin
		
			case (binary)
			
				0: hex_out = 7'b1000000;
				1: hex_out = 7'b1111001;
				2: hex_out = 7'b0100100;
				3: hex_out = 7'b0110000;
				4: hex_out = 7'b0011001;
				5: hex_out = 7'b0010010;
				6: hex_out = 7'b0000010;
				7: hex_out = 7'b1111000;
				8: hex_out = 7'b0000000;
				9: hex_out = 7'b0010000;
				10: hex_out = 7'b0001000;
				11: hex_out = 7'b0000011;
				12: hex_out = 7'b1000110;
				13: hex_out = 7'b0100001;
				14: hex_out = 7'b0000110;
				15: hex_out = 7'b0001110;
				default hex_out = 7'b1111111;
			
			endcase
		end
	endtask
endmodule	