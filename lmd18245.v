module lmd18245(
	input [1:0] command,
	
	output reg [3:0] m, //output to DAC pins
	output reg brake, //output to brake pin
	output reg direction);
	
	always begin
		
		case (command)
			//set commands here
			0: begin 
				direction = 1;
				brake = 0;
				m = 4'h4;
				end
		
			1:	begin 
				direction = 0;
				brake = 0;
				m = 4'h4;
				end
		
			2: begin 
				direction = 1;
				brake = 1;
				m = 4'h4;
				end
		
			3: begin 
				direction = 1;
				brake = 1;
				m = 4'h4;
				end
	
			default: begin 
				direction = 1;
				brake = 1;
				m = 4'h4;
				end
		endcase
		
	end
	
endmodule