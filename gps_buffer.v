module gps_buffer(
	
	input clock_50mhz,
	input data_valid,
	input [7:0] data,
	input [3:0] address_in,
	
	output reg [31:0] buffer_data);
	
	reg [1:0] state;
	reg [2:0] meta_buffer;
	
	reg [7:0] buff_count;
	
	reg [7:0] buffer [63:0]; //register for holding UART output
	
	wire [5:0] address;
	
	assign address = address_in * 4;
	
	always @(posedge clock_50mhz) begin //sync_chain for data_valid bit
	
		meta_buffer[2] <= meta_buffer[1];
		meta_buffer[1] <= meta_buffer[0];
		meta_buffer[0] <= data_valid;	
	
	end
	
	
	
	always @(posedge clock_50mhz) begin
	
		case (state)
			
			0: begin //idle state
			
				if (meta_buffer[2] == 1) state <= 1;
				else state <= 0;
			
			end
			
			
			1:begin //write buffer
			
				buffer[buff_count] <= data;
				buff_count = buff_count + 1;
				state <= 2;
			
			end
			
			2:begin
				if (meta_buffer[2] == 0) state <= 0;
			end
		
		endcase
	
	end
	
	
	always @(posedge clock_50mhz) begin //output for debugging purposes
		buffer_data[31:24] <= buffer[address + 3];
		buffer_data[23:16] <= buffer[address + 2];
		buffer_data[15:8] <= buffer[address + 1];
		buffer_data[7:0] <= buffer[address];
	end
		
		
endmodule

	