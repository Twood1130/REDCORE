//This version of the module will oversample the incoming data stream to improve accuracy
//This module only operates at 9600 baud, to make programming at this stage easier

module uart_rx(

	input clk, //this clock should be 1.8432 Mhz for proper operation
	input serial_in,
	output reg [7:0] data_out,
	output reg data_valid);
	
	reg [2:0] state;
	reg [2:0] bit_count;
	reg [7:0] data; //data buffer to abstract the output from the input
	reg [1:0] meta_buffer;
	
	reg [7:0] os_shift_reg;
	reg oversample_out;
	int os_count;
	
	initial begin
		state = 0;
		count = 0;
		bit_count = 0;
		meta_buffer = 2'b11;
		data_valid = 0;
	end
	
	always @(posedge clk)
		meta_buffer[1] <= meta_buffer[0];
		meta_buffer[0] <= serial_in;
	end
	
	always @(posedge clk) begin //oversampler code, retains 8 evenly spaced samples.
		
		if (count == 23) begin //(192/8) - 1 = 23
			//move all the bits in the shift register over each 24 clocks
			os_shift_reg[7] <= os_shift_reg [6];
			os_shift_reg[6] <= os_shift_reg [5];
			os_shift_reg[5] <= os_shift_reg [4];
			os_shift_reg[4] <= os_shift_reg [3];
			os_shift_reg[3] <= os_shift_reg [2];
			os_shift_reg[2] <= os_shift_reg [1];
			os_shift_reg[1] <= os_shift_reg [0];
			os_shift_reg[0] <= meta_buffer[1];
			
			os_count = 0;//
		end
		else os_count = os_count + 1;
	end
	
	always @(posedge clk) begin
		
		case(state)
			
			0: begin //idle_state
				count = 0;
				bit_count <= 0;
				if (meta_buffer[1] == 0) state = 1;
			end
			
			1: begin //synchronizer state
				if (count == 191) begin
					
					check_oversampler();
					count = 0;
					
					if (oversample_out == 1) state = 2;
					else state = 0;
					
				end
				else count = count + 1;
			end
			
			2: begin //data rx state
				if (count == 191) begin
					check_oversampler();
					data[bit_count] <= oversample_out;
					bit_count <= bit_count + 1;
					count = 0;
					
					if (bit_count == 7) begin //prepare to transition to stop state
						data_valid <= 1'b1;
						data_out <= data;
						state = 3;
					end
					
				end
				else count = count + 1;
			end
			
			3: begin //stop state
				if (count == 0) data_valid = 1'b0; //ensure data valid is only active for one clock cycle
				
				if (count >= 383) begin
					count = 0;
					bit_count = 0;
					if (meta_buffer[1] == 0) state = 2; //if after 2 bit times away from the last bit recieved a start bit is found, proceed to DATA_RX
					else state = 0;//else return to IDLE
				end
				count = count + 1;
			end
			
			default state = 0;
		endcase
	end
	
	task check_oversampler;
		integer hit,index;
		hit = 0;
		
		for(index = 1; index < 7;index = index + 1) begin
			if (os_shift_reg[index] == 1) hit = hit + 1;
		end
		
		if (hit > 3) oversample_out = 1;
		else if (hit <= 3) oversample_out = 0;
	endtask
	
endmodule 