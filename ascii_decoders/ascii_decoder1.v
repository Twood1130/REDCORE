module ascii_decoder1(
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
				bin_out = 20'h00001;
				error = 0;
			end			
			
			8'h32: begin
				bin_out = 20'h00002;
				error = 0;
			end
			
			8'h33: begin
				bin_out = 20'h00003;
				error = 0;
			end
			
			8'h34: begin
				bin_out = 20'h00004;
				error = 0;
			end
			
			8'h35: begin
				bin_out = 20'h00005;
				error = 0;
			end
			
			8'h36: begin
				bin_out = 20'h00006;
				error = 0;
			end
			
			8'h37: begin
				bin_out = 20'h00007;
				error = 0;
			end
			
			8'h38: begin
				bin_out = 20'h00008;
				error = 0;
			end
			
			8'h39: begin
				bin_out = 20'h00009;
				error = 0;
			end
			
			default: begin
				bin_out = 20'h00000;
				error = 1;
			end
			
		endcase
	
	end
endmodule