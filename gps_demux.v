module gps_demux(
	input clock_50mhz,
	input data_valid,
	input [7:0] data,
	
	output [7:0] lat_d,
	output [15:0] lat_m,
	output [7:0] lon_d,
	output [15:0] lon_m,
	output error_sig);
	
	reg [1:0] state;
	reg [3:0] commas;
	reg [3:0] count;
	
	reg [2:0] meta_buffer;
	
	
	//ascii buffers
	reg [7:0] gp_string [5:0];
	reg [7:0] gps_valid;
	reg [7:0] lat [7:0];
	reg [7:0] lon [8:0];
	reg [7:0] null;
	
	wire [31:0] error;
	
	wire [3:0] number_data [31:0];
	
	always @(posedge clock_50mhz) begin //sync_chain for data_valid bit
	
		meta_buffer[2] <= meta_buffer[1];
		meta_buffer[1] <= meta_buffer[0];
		meta_buffer[0] <= data_valid;	
	
	end
		//decode numbers for latitude
		ascii_decoder(lat[0],number_data[0],error[0]);
		ascii_decoder(lat[1],number_data[1],error[1]);
		ascii_decoder(lat[2],number_data[2],error[2]);
		ascii_decoder(lat[3],number_data[3],error[3]);
		//ascii_decoder(lat[4],number_data[4],error[4]); //this is a period
		ascii_decoder(lat[5],number_data[5],error[5]);
		ascii_decoder(lat[6],number_data[6],error[6]);
		ascii_decoder(lat[7],number_data[7],error[7]);
		
		//decode numbers for longitude
		ascii_decoder(lon[0],number_data[8],error[8]);
		ascii_decoder(lon[1],number_data[9],error[9]);
		ascii_decoder(lon[2],number_data[10],error[10]);
		ascii_decoder(lon[3],number_data[11],error[11]);
		ascii_decoder(lon[4],number_data[12],error[12]);
		//ascii_decoder(lon[5],number_data[13],error[13]); //this is a period
		ascii_decoder(lon[6],number_data[14],error[14]);
		ascii_decoder(lon[7],number_data[15],error[15]);
		ascii_decoder(lon[8],number_data[16],error[16]);
	
	//assign outputs based on number data
	assign lat_d = (10* number_data[0]) + number_data[1];
	assign lat_m = (10000 * number_data[2]) + (1000 * number_data[3]) + (100 * number_data[5]) + (10 * number_data [6]) + number_data[7];
	
	assign lon_d = (100 * number_data[8]) + (10 * number_data[9]) + number_data[10];
	assign lon_m = (10000 * number_data[11]) + (1000 * number_data[12]) + (100 * number_data[14]) + (10 * number_data [15]) + number_data[16];
	
	always @(posedge clock_50mhz) begin
	
		case (state)
			
			0: begin //idle state
				
				//Transition to write state if data is valid.
				if (meta_buffer[2] == 1) state <= 1;
				else state <= 0;
			
			end
			
			
			1:begin
			
				if (data == 8'h2C) begin 
					commas <= commas + 1; //index on commas
					count <= 0;
				end
				
				else if (data == 8'h0D) begin
					commas <= 0; // reset commas on carriage return.
					count <= 0;
				end
				
				else begin
					
					if (commas == 0) gp_string[count] <= data; //Detect the string we are in
					
					else if (gp_string[3] == 8'h52) begin //Parsing the GPRMC string.
					
						case (commas)
						
							// 1: time
							2: gps_valid <= data;
							3: lat[count] <= data;
							//4: //N/S
							5: lon[count] <= data;
							//6: //E/W
							//7: //speed
							//8: //angle from true
							//9: //date
							//10: //magnetic variation
							//11: //checksum
							default: null <= data;
						endcase
						
					end
				 end
				 state <= 2;
			end

			2:begin
				if (meta_buffer[2] == 0) state <= 0;
			end
		
		endcase
	
	end
	
endmodule

	