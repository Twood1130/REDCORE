module gps_interpreter ( //v2, data out variation for vga display purposes
	input [7:0] data,
	input data_valid,
	input clk,
	input [3:0] rmc_data_add,
	
	output reg [31:0] rmc_data_out);
	
	reg [31:0] buffer;
	reg [1:0] buffer_index;
	
	reg [7:0] gp_string [4:0]; //register for hold the $GP*** string(might be removed later)
	reg [7:0] gprmc [63:0]; //register for holding the GPRMC string
	
	reg [5:0] out_count;
	
	integer gp_count, data_count, state;
	
	wire [5:0] address;
	
	assign address = rmc_data_add * 4;
	
	initial begin
		gp_count = 0;
		state = 0;
	end
	
	always @(posedge data_valid) begin
			
			gprmc[gp_count] <= data;
			
			/*
			case (state)
				0: begin
							gp_count = 0;
							//if (data == 8'h24) state = 2; //stay in state 0 until "$" is found
							state = 2;
					end
					
				1: begin
							gprmc[gp_count] <= data; //write data to gprmc buffer
						
							if (data == 8'h43) state = 2; //move to state 2 when "C" is found
							else if (gp_count == 10) state = 0; //if after 10 characters there is no "C" found, return to state 0
							else gp_count = gp_count + 1;
					end 
				
				2: begin
							gprmc[gp_count] <= data;
							gp_count = gp_count + 1;
							if (gp_count == 64) state = 0; //transition to state 0 if "*" is found
					end
					
				default state = 0;
				
			endcase
			*/
	end
			
	
	always @(posedge clk) begin //output for debugging purposes
		rmc_data_out[31:24] <= gprmc[address + 3];
		rmc_data_out[23:16] <= gprmc[address + 2];
		rmc_data_out[15:8] <= gprmc[address + 1];
		rmc_data_out[7:0] <= gprmc[address];
	end
		
		
endmodule
