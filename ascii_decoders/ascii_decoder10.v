module ascii_decoder10(
	input [7:0] ascii_in,
	output reg[19:0] bin_out,
	output reg error);
	
	always begin
	
		case (ascii_in)
		
			8'h30: begin
				bin_out = 20'h00000;
				error = 0;
			end
			8'h31: begin
				bin_out = 20'h0000A;
				error = 0;
			end			
			
			8'h32: begin
				bin_out = 20'h00014;
				error = 0;
			end
			
			8'h33: begin
				bin_out = 20'h0001E;
				error = 0;
			end
			
			8'h34: begin
				bin_out = 20'h00028;
				error = 0;
			end
			
			8'h35: begin
				bin_out = 20'h00032;
				error = 0;
			end
			
			8'h36: begin
				bin_out = 20'h0003C;
				error = 0;
			end
			
			8'h37: begin
				bin_out = 20'h00046;
				error = 0;
			end
			
			8'h38: begin
				bin_out = 20'h00050;
				error = 0;
			end
			
			8'h39: begin
				bin_out = 20'h0005A;
				error = 0;
			end
			
			default: begin
				bin_out = 20'h00000;
				error = 1;
			end
			
		endcase
	
	end
endmodule