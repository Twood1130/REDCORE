module ascii_decoder100000(
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
				bin_out = 20'h186A0;
				error = 0;
			end			
			
			8'h32: begin
				bin_out = 20'h30D40;
				error = 0;
			end
			
			8'h33: begin
				bin_out = 20'h493E0;
				error = 0;
			end
			
			8'h34: begin
				bin_out = 20'h61A80;
				error = 0;
			end
			
			8'h35: begin
				bin_out = 20'h7A120;
				error = 0;
			end
			
			8'h36: begin
				bin_out = 20'h927C0;
				error = 0;
			end
			
			8'h37: begin
				bin_out = 20'hAAE60;
				error = 0;
			end
			
			8'h38: begin
				bin_out = 20'hC3500;
				error = 0;
			end
			
			8'h39: begin
				bin_out = 20'hDBBA0;
				error = 0;
			end
			
			default: begin
				bin_out = 20'h00000;
				error = 1;
			end
			
		endcase
	
	end
endmodule