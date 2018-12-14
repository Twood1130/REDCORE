module uart_rx(

	input clk,
	input serial_in,
	output reg [7:0] data_out,
	output reg data_valid);
	
	parameter clk_count = 192; //set this to the clock speed divided by the baud rate
	//default clock = 1.8432 mhz
	//default baud = 9600
	//default clk_count = 192;
	
	reg [1:0] state; 
	reg [9:0] count;
	reg [2:0] bit_count;
	reg [2:0] meta_buffer; //buffer for meta-stability, 3-stages as recommended by altera
	
	always @(posedge clk) begin //fill the meta_buffer from serial_in
		meta_buffer[2] <= meta_buffer[1];
		meta_buffer[1] <= meta_buffer[0];
		meta_buffer[0] <= serial_in;
	end
	
	always @(posedge clk) begin
		
		case(state)
			
			0: begin //idle_state
				count <= 0;
				bit_count <= 0;
				if (meta_buffer[2] == 0) state <= 1;
			end
			
			1: begin //synchronizer state
				if (count == (clk_count / 2) - 1) begin
					count <= 0;
					if (meta_buffer[2] == 0) state <= 2; //middle start bit found, move to data rx state
					else state <= 0;
				end
				else count <= count + 1;
			end
			
			2: begin //data rx state
				
				if (count == clk_count - 1) begin
					data_out[bit_count] <= meta_buffer[2];
					bit_count <= bit_count + 1;
					count <= 0;
					
					if (bit_count == 7) begin //prepare to transition to stop state
						data_valid <= 1'b1;
						state <= 3;
						bit_count <= 0;
						count <= 0;
					end
					
				end
				else count <= count + 1;
			end
			
			3: begin //stop state
					data_valid <= 1'b0; //ensure data valid is only active for one clock cycle
					state <= 0;
					count <= count + 1;
			end
			
			default: state <= 0;
		
		endcase
	
	end

endmodule