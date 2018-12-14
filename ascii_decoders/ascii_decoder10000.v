module ascii_decoder10000(
	input [7:0] ascii_in,
	output reg[19:0] bin_out,
	output reg error);
	
	always begin
	
		case (ascii_in)
		
			8'h30: begin
				bin_out = 20'h0000;
				error = 0;
			end
			8'h31: begin
				bin_out = 20'h2710;
				error = 0;
			end			
			
			8'h32: begin
				bin_out = 20'h4E20;
				error = 0;
			end
			
			8'h33: begin
				bin_out = 20'h7530;
				error = 0;
			end
			
			8'h34: begin
				bin_out = 20'h9C40;
				error = 0;
			end
			
			8'h35: begin
				bin_out = 20'hC350;
				error = 0;
			end
			
			8'h36: begin
				bin_out = 20'hEA60;
				error = 0;
			end
			
			8'h37: begin
				bin_out = 20'h11170;
				error = 0;
			end
			
			8'h38: begin
				bin_out = 20'h13880;
				error = 0;
			end
			
			8'h39: begin
				bin_out = 20'h15F90;
				error = 0;
			end
			
			default: begin
				bin_out = 20'h00000;
				error = 1;
			end
			
		endcase
	
	end
endmodule