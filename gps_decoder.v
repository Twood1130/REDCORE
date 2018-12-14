module gps_decoder(
	input valid,
	input [7:0] data,
	
	output reg gps_valid,
	output reg north,
	output reg east,
	output [7:0] latd, lond,
	output [19:0] latm, lonm);
	
	reg [3:0] state;
	
	reg [3:0] count;
	reg [4:0] commas;
	
	
	reg [7:0] gp_string [4:0]; //storage for the GP string
	
	
	//register arrays for GPRMC data, comment out unused fields to save on logic units.
	//reg [7:0] gps_time [5:0];
	reg [7:0] lat_ascii [8:0];
	reg [7:0] lon_ascii [9:0];
	//reg [7:0] speed [7:0]; //Speed is a variable length field, and will be harder to parse
	//reg [7:0] aft [4:0]; //angle from true
	//reg [7:0] mag_var [7:0];
	
	//dump for unused data
	reg [7:0] noop;
	
	wire [31:0] error; //bus for carrying error data
	wire [19:0] decoded_data [31:0]; //wires for carrying decoded data
	
	//decode ascii data to binary values, each ascii decoder is set for which digit the data represents
	
	//lat degrees
	ascii_decoder10(lat_ascii[0],decoded_data[0],error[0]);
	ascii_decoder1(lat_ascii[1],decoded_data[1],error[1]);
	
	//lat minutes
	ascii_decoder100000(lat_ascii[2],decoded_data[2],error[2]);
	ascii_decoder10000(lat_ascii[3],decoded_data[3],error[3]);
	//the 4th entry would be a decimal point, so we are ignoring it.
	ascii_decoder1000(lat_ascii[5],decoded_data[4],error[4]);
	ascii_decoder100(lat_ascii[6],decoded_data[5],error[5]);
	ascii_decoder10(lat_ascii[7],decoded_data[6],error[6]);
	ascii_decoder1(lat_ascii[8],decoded_data[7],error[7]);
	
	//lon degrees
	ascii_decoder100(lon_ascii[0],decoded_data[8],error[8]);
	ascii_decoder10(lon_ascii[1],decoded_data[9],error[9]);
	
	//lon minutes
	ascii_decoder1(lon_ascii[2],decoded_data[10],error[10]);
	ascii_decoder100000(lon_ascii[3],decoded_data[11],error[11]);
	ascii_decoder10000(lon_ascii[4],decoded_data[12],error[12]);
	//this is a decimal point as well.
	ascii_decoder1000(lon_ascii[6],decoded_data[13],error[13]);
	ascii_decoder100(lon_ascii[7],decoded_data[14],error[14]);
	ascii_decoder10(lon_ascii[8],decoded_data[15],error[15]);
	ascii_decoder1(lon_ascii[9],decoded_data[16],error[16]);
	
	//assign output data as the summation of the decoded data
		assign latd = decoded_data[0] + decoded_data [1];
		assign latm = decoded_data[2] + decoded_data[3] + decoded_data[4] + decoded_data[5] + decoded_data[6] + decoded_data[7];
		assign lond = decoded_data[8] + decoded_data[9] + decoded_data[10];
		assign lonm = decoded_data[11] + decoded_data[12] + decoded_data[13] + decoded_data[14] + decoded_data[15] + decoded_data[16];
	
	//main state machine, uses the valid signal as a clock.
	always @(posedge valid) begin
		
		case (state)
		
			0: begin //reset state, initializes all values
				count <= 0;
				commas <= 0;
				if (data == 8'h24) state <= 1;
				else state <= 0;
			end
			
			1: begin //wait for 5 cycles to fill the gp_string buffer
				gp_string[count] <= data;
				count <= count + 1;
				if (count == 4'h4) state <= 2;
				else state <= 1;
			end
			
			2: begin
				//determine the current gp string
				if (data == 8'h2C) commas = commas + 1; //the check state take place during a comma, so we need to ensure a comma is added to the list if it is there
				
				if ((gp_string[2] = "G") && (gp_string[3] == "G") && (gp_string[3] == "A")) state <= 3; //GPGGA string
				else if ((gp_string[2] = "R") && (gp_string[3] == "M") && (gp_string[4] == "C")) state <= 4; //GPRMC string
				else if ((gp_string[2] = "V") && (gp_string[3] == "T") && (gp_string[4] == "G")) state <= 5; //GPVTG string
				else if ((gp_string[2] = "G") && (gp_string[3] == "S") && (gp_string[4] == "V")) state <= 6; //GPGSV string
				else state <= 0; //if no cases match reset
				
			end
			
			3: begin //Parse GPGGA string
				if (data == 8'h0D) state <= 0; //reset if carriage return found.
				else if (data == 8'h2C) commas = commas + 1; //increment commas if a comma is found
			end
			
			4: begin //Parse GPRMC string
				if (data == 8'h0D) state <= 0; //reset if carriage return found.
				else if (data == ",") begin
					commas <= commas + 1; //increment commas if a comma is found
					count <= 0;
				end
				
				else begin //Start parsing data
					case (commas)
					//cases commented out are there for possible future use.		
						// 1: time
						2: begin //Valid char
							if (data == "A") gps_valid <= 1;
							else gps_valid <= 0;
						end
						
						3: begin 
							lat_ascii[count] <= data;
							count <= count + 1;
						end
						
						4:begin //N/S
							if (data == "N") north <= 1;
							else north <= 0;
						end
						
						5: begin 
							lon_ascii[count] <= data;
							count <= count + 1;
						end
						
						6: begin//E/W
							if (data == "E") east <= 1;
							else east <= 0;
						end
						//7: //speed
						//8: //angle from true
						//9: //date
						//10: //magnetic variation
						//11: //magnetic variation direction
						//12: //checksum
						default: noop <= data;
					endcase
				end
			end
			
			5: begin //Parse
				if (data == 8'h0D) state <= 0; //reset if carriage return found.
				else if (data == 8'h2C) commas = commas + 1; //increment commas if a comma is found
			end
			
			6: begin
				if (data == 8'h0D) state <= 0; //reset if carriage return found.
				else if (data == 8'h2C) commas = commas + 1; //increment commas if a comma is found
			end
			
			default: state <= 0; //if somehow you end up in an unknown state, reset
		endcase
	end
endmodule	