module ascii_decoder1000(
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
				bin_out = 20'h003E8;
				error = 0;
			end			
			
			8'h32: begin
				bin_out = 20'h007D0;
				error = 0;
			end
			
			8'h33: begin
				bin_out = 20'h00BB8;
				error = 0;
			end
			
			8'h34: begin
				bin_out = 20'h00FA0;
				error = 0;
			end
			
			8'h35: begin
				bin_out = 20'h01388;
				error = 0;
			end
			
			8'h36: begin
				bin_out = 20'h01770;
				error = 0;
			end
			
			8'h37: begin
				bin_out = 20'h01B58;
				error = 0;
			end
			
			8'h38: begin
				bin_out = 20'h01F40;
				error = 0;
			end
			
			8'h39: begin
				bin_out = 20'h02328;
				error = 0;
			end
			
			default: begin
				bin_out = 20'h00000;
				error = 1;
			end
			
		endcase
	
	end
endmodule