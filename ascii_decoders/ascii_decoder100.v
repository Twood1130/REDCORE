module ascii_decoder100(
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
				bin_out = 20'h00064;
				error = 0;
			end			
			
			8'h32: begin
				bin_out = 20'h000C8;
				error = 0;
			end
			
			8'h33: begin
				bin_out = 20'h0012C;
				error = 0;
			end
			
			8'h34: begin
				bin_out = 20'h00190;
				error = 0;
			end
			
			8'h35: begin
				bin_out = 20'h001F4;
				error = 0;
			end
			
			8'h36: begin
				bin_out = 20'h00258;
				error = 0;
			end
			
			8'h37: begin
				bin_out = 20'h002BC;
				error = 0;
			end
			
			8'h38: begin
				bin_out = 20'h00320;
				error = 0;
			end
			
			8'h39: begin
				bin_out = 20'h00384;
				error = 0;
			end
			
			default: begin
				bin_out = 20'h00000;
				error = 1;
			end
			
		endcase
	
	end
endmodule