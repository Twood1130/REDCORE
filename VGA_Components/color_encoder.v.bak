//version 2
//compatible with the DE2-115 boards VGA DAC
//1-bit color version

module color_encoder(

	input wire data,
	output [7:0] red,
	output [7:0] green,
	output [7:0] blue);
	
	//use 8 bit color codes to choose your colors 
	//color layout: RRRGGGBB
	//basic colors:
	//Red: 	11100000		hex: E0
	//Green: 00011100		hex: 1C
	//Blue:	00000011		hex: 03
	//Black: 00000000		hex: 00
	//White: 11111111		hex: FF
	parameter color_0 = 8'h1C; 
	parameter color_1 = 8'hFF;
	reg [7:0] color_data;
	
	assign red = 32 * color_data[7:5];

	assign green = 32 * color_data[4:2];

	assign blue = 64 * color_data[1:0];
	
	always begin
		if (data == 1'b0) begin
			color_data <= color_0;
		end else begin
			color_data <= color_1;
		end
	end 
endmodule
