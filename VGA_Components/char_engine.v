//char_engine
//GPS Edition

//Characters are 8 * 8 pixels each with a blank line above each character, allowing allowing 80 * 53 characters on screen.
//The memory mapping takes into account only a 640*480 screen resolution

module char_engine(
	input wire clock,
	
	output reg [0:7] mem_out, //if everything is backwards, swap the bit order on this output and recompile!
	output reg [15:0] mem_add,
	output mem_write,
	
	input wire [31:0] rmc_data,
	output reg [3:0] rmc_sw);
	
	assign mem_write = 1;
	
	reg [7:0] hex_digit;
	reg [31:0] data;
	reg [7:0] hex_buffer[0:(MAX_STRING_LENGTH - 1)];
	reg [63:0] mem_buffer;
	
	parameter HORI_OFFSET = 0; //sets the horizontal offset of the memory renderer, only use if the top of the screen gets cut off.
	parameter NUM_LABEL_TASKS = 1; // This tells the code where to start tasks that require data manipulation, this must be set as you add more labels, debug tasks must be part of this number
	parameter MAX_STRING_LENGTH = 20; //Generally you do not need to modify this, but it will change the global maximum string length (default = 20)
	
	
	integer mode, data_index, reg_index, row, column, slice_delay, decode_delay, num_chars, k, x, y;
	
	//mode integer
	//mode = 0 use hex decoder
	//mode = 1 use ascii decoder
	
	initial begin
	slice_delay = 0; //initial values for the character renderer
	decode_delay = 0;
	x = 0;
	y = -1;
	data_index = -1;
	reg_index = 0;
	end
	
	always @(posedge clock) begin //semi-pipelined design, only executes one if statement per clock
				
		if (x < 0) begin //source and slice steps
			if (slice_delay == 0) data_index = data_index + 1;
			source_data();
			if (data_index > NUM_LABEL_TASKS) 
				
				if (mode == 0) hex_slice_data(); //slice data into properly sized chunks depending on data type
				else ascii_slice_data();

			slice_delay = slice_delay + 1;
			if (slice_delay == 2) begin
				x = num_chars - 1;
				slice_delay = 0;
			end
		end
		
		else if (y < 0) begin //decode steps
			hex_digit <= hex_buffer[x];
			if (decode_delay == 0) begin
				x = x - 1;
			end
			
			if (mode == 0) decode_hex(); //decode either hex or ascii
			else decode_ascii();
			
			decode_delay = decode_delay + 1;
			if (decode_delay == 3) begin
				y = 8;
				decode_delay = 0;
			end
		end
		
		else if (y >= 0) begin //this step writes to memory
			k = (y * 8) - 1;
			mem_add <= (80 * y) + (800 * row) + (num_chars - (x + 1)) + (column) + (HORI_OFFSET * 80); //this complicated formula tranlates information into a linear address
			mem_out <= mem_buffer[k -: 8];
			y = y - 1;
		end
	end
	
	task source_data; //This part of the module is the main task list for the renderer, it can be utilized in a variety of ways to render information.
							//this code requests the data from memory to be printed on screen
		if (data_index == NUM_LABEL_TASKS) rmc_sw <= reg_index;
		
		case (data_index)
		//in the case of text labels, the hex_buffer is set manually for each character, and the data is only written to memory once.
			
			0: begin //"GPRMC DATA" label
					hex_buffer[10] <= 8'h47;
					hex_buffer[9] <= 8'h50;
					hex_buffer[8] <= 8'h52;
					hex_buffer[7] <= 8'h4d;
					hex_buffer[6] <= 8'h43;
					hex_buffer[5] <= 8'h20;
					hex_buffer[4] <= 8'h44;
					hex_buffer[3] <= 8'h41;
					hex_buffer[2] <= 8'h54;
					hex_buffer[1] <= 8'h41;
					hex_buffer[0] <= 8'h20;
					
					mode = 1;
					row = 0;
					column = 0;
					num_chars = 11;
				end
								
			(NUM_LABEL_TASKS + 1): begin //rmc_mem indexes 00-15
					data <= reg_index;
					column = 0;
					row = reg_index + 1;
					num_chars = 2;
					mode = 0;
				end
			
			(NUM_LABEL_TASKS + 2): begin //rmc_memory data hex display
					data <= rmc_data; 
					column = 3;
					row = reg_index + 1;
					num_chars = 8;
					mode = 0;
				end
				
			(NUM_LABEL_TASKS + 3): begin //rmc_memory data ascii display
					data <= rmc_data; 
					column = 11;
					row = reg_index + 1;
					num_chars = 5;
					hex_buffer[4] <= 8'h3A;
					mode = 1;
					
					if (slice_delay == 1) reg_index = reg_index + 1;
					if (reg_index == 16) begin //this resets the register index variable to zero once it reaches 16
						reg_index = 0;
					end
				end
				
			default: data_index = NUM_LABEL_TASKS;
		endcase
	endtask
	
	task hex_slice_data; //I tried other ways of doing this, but the straightforward approach works better.
		hex_buffer[7] <= data[31:28];
		hex_buffer[6] <= data[27:24];
		hex_buffer[5] <= data[23:20];
		hex_buffer[4] <= data[19:16];
		hex_buffer[3] <= data[15:12];
		hex_buffer[2] <= data[11:8];
		hex_buffer[1] <= data[7:4];
		hex_buffer[0] <= data[3:0];
	endtask
	
	task ascii_slice_data; //I tried other ways of doing this, but the straightforward approach works better.
		hex_buffer[3] <= data[31:24];
		hex_buffer[2] <= data[23:16];
		hex_buffer[1] <= data[15:8];
		hex_buffer[0] <= data[7:0];
	endtask
	
	task decode_ascii;
		case (hex_digit)
			
			8'h20: begin //space
					mem_buffer[7:0] <=   8'b00000000;
					mem_buffer[15:8] <=  8'b00000000;
					mem_buffer[23:16] <= 8'b00000000;
					mem_buffer[31:24] <= 8'b00000000;
					mem_buffer[39:32] <= 8'b00000000;
					mem_buffer[47:40] <= 8'b00000000;
					mem_buffer[55:48] <= 8'b00000000;
					mem_buffer[63:56] <= 8'b00000000;
					end
					
			8'h21: begin //!
					mem_buffer[7:0] <=   8'b00000000;
					mem_buffer[15:8] <=  8'b00011000;
					mem_buffer[23:16] <= 8'b00011000;
					mem_buffer[31:24] <= 8'b00011000;
					mem_buffer[39:32] <= 8'b00000000;
					mem_buffer[47:40] <= 8'b00000000;
					mem_buffer[55:48] <= 8'b00011000;
					mem_buffer[63:56] <= 8'b00000000;
					end
			
			8'h22: begin //"
					mem_buffer[7:0] <=   8'b00000000;
					mem_buffer[15:8] <=  8'b01100110;
					mem_buffer[23:16] <= 8'b01100110;
					mem_buffer[31:24] <= 8'b00100010;
					mem_buffer[39:32] <= 8'b00000000;
					mem_buffer[47:40] <= 8'b00000000;
					mem_buffer[55:48] <= 8'b00000000;
					mem_buffer[63:56] <= 8'b00000000;
					end
			
			8'h23: begin //#
					mem_buffer[7:0] <=   8'b00000000;
					mem_buffer[15:8] <=  8'b00100100;
					mem_buffer[23:16] <= 8'b01111110;
					mem_buffer[31:24] <= 8'b00100100;
					mem_buffer[39:32] <= 8'b00100100;
					mem_buffer[47:40] <= 8'b01111110;
					mem_buffer[55:48] <= 8'b00100100;
					mem_buffer[63:56] <= 8'b00000000;
					end
					
			8'h24: begin //$
					mem_buffer[7:0] <=   8'b00011000;
					mem_buffer[15:8] <=  8'b00111100;
					mem_buffer[23:16] <= 8'b01000000;
					mem_buffer[31:24] <= 8'b00111100;
					mem_buffer[39:32] <= 8'b00000010;
					mem_buffer[47:40] <= 8'b00000010;
					mem_buffer[55:48] <= 8'b00111100;
					mem_buffer[63:56] <= 8'b00011000;
					end
					
			8'h25: begin //%
					mem_buffer[7:0] <=   8'b00000000;
					mem_buffer[15:8] <=  8'b01100010;
					mem_buffer[23:16] <= 8'b01100100;
					mem_buffer[31:24] <= 8'b00001000;
					mem_buffer[39:32] <= 8'b00010000;
					mem_buffer[47:40] <= 8'b00100110;
					mem_buffer[55:48] <= 8'b01000110;
					mem_buffer[63:56] <= 8'b00000000;
					end
					
			8'h27: begin //,
					mem_buffer[7:0] <=   8'b00000000;
					mem_buffer[15:8] <=  8'b00000000;
					mem_buffer[23:16] <= 8'b00000000;
					mem_buffer[31:24] <= 8'b00000000;
					mem_buffer[39:32] <= 8'b00000000;
					mem_buffer[47:40] <= 8'b00110000;
					mem_buffer[55:48] <= 8'b01100000;
					mem_buffer[63:56] <= 8'b01000000;
					end
					
			8'h2E: begin //.
					mem_buffer[7:0] <=   8'b00000000;
					mem_buffer[15:8] <=  8'b00000000;
					mem_buffer[23:16] <= 8'b00000000;
					mem_buffer[31:24] <= 8'b00000000;
					mem_buffer[39:32] <= 8'b00000000;
					mem_buffer[47:40] <= 8'b00000000;
					mem_buffer[55:48] <= 8'b11000000;
					mem_buffer[63:56] <= 8'b11000000;
					end
		
			8'h30: begin //zero
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b01000010;
					mem_buffer[39:32] <= 8'b01000010;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b00111100;
					end
			
			8'h31: begin //one
					mem_buffer[7:0] <=   8'b00011000;
					mem_buffer[15:8] <=  8'b00111000;
					mem_buffer[23:16] <= 8'b01111000;
					mem_buffer[31:24] <= 8'b00011000;
					mem_buffer[39:32] <= 8'b00011000;
					mem_buffer[47:40] <= 8'b00011000;
					mem_buffer[55:48] <= 8'b00011000;
					mem_buffer[63:56] <= 8'b01111110;
					end
			
			8'h32: begin //two
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01100110;
					mem_buffer[23:16] <= 8'b01100110;
					mem_buffer[31:24] <= 8'b00001100;
					mem_buffer[39:32] <= 8'b00011000;
					mem_buffer[47:40] <= 8'b00110000;
					mem_buffer[55:48] <= 8'b01100000;
					mem_buffer[63:56] <= 8'b01111110;
					end
					
			8'h33: begin //three
					mem_buffer[7:0] <=   8'b01111100;
					mem_buffer[15:8] <=  8'b00000110;
					mem_buffer[23:16] <= 8'b00000110;
					mem_buffer[31:24] <= 8'b01111100;
					mem_buffer[39:32] <= 8'b00000110;
					mem_buffer[47:40] <= 8'b00000110;
					mem_buffer[55:48] <= 8'b00000110;
					mem_buffer[63:56] <= 8'b01111100;
					end
				
			8'h34: begin //four
					mem_buffer[7:0] <=   8'b00001110;
					mem_buffer[15:8] <=  8'b00010110;
					mem_buffer[23:16] <= 8'b00100110;
					mem_buffer[31:24] <= 8'b01000110;
					mem_buffer[39:32] <= 8'b01000110;
					mem_buffer[47:40] <= 8'b01111110;
					mem_buffer[55:48] <= 8'b00000110;
					mem_buffer[63:56] <= 8'b00000110;
					end
					
			8'h35: begin //five
					mem_buffer[7:0] <=   8'b01111110;
					mem_buffer[15:8] <=  8'b01100000;
					mem_buffer[23:16] <= 8'b01100000;
					mem_buffer[31:24] <= 8'b01111000;
					mem_buffer[39:32] <= 8'b00001100;
					mem_buffer[47:40] <= 8'b00000110;
					mem_buffer[55:48] <= 8'b00001100;
					mem_buffer[63:56] <= 8'b01111000;
					end
					
			8'h36: begin //six
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000000;
					mem_buffer[23:16] <= 8'b01000000;
					mem_buffer[31:24] <= 8'b01111100;
					mem_buffer[39:32] <= 8'b01000010;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b00111100;
					end
					
			8'h37: begin //seven
					mem_buffer[7:0] <=   8'b01111110;
					mem_buffer[15:8] <=  8'b00000110;
					mem_buffer[23:16] <= 8'b00000110;
					mem_buffer[31:24] <= 8'b00000110;
					mem_buffer[39:32] <= 8'b00001100;
					mem_buffer[47:40] <= 8'b00011000;
					mem_buffer[55:48] <= 8'b00110000;
					mem_buffer[63:56] <= 8'b01100000;
					end
					
			8'h38: begin //eight
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b00111100;
					mem_buffer[39:32] <= 8'b01000010;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b00111100;
					end
					
			8'h39: begin //nine
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000110;
					mem_buffer[23:16] <= 8'b01000110;
					mem_buffer[31:24] <= 8'b01000110;
					mem_buffer[39:32] <= 8'b00111110;
					mem_buffer[47:40] <= 8'b00000110;
					mem_buffer[55:48] <= 8'b00000110;
					mem_buffer[63:56] <= 8'b00000110;
					end
					
			8'h3A: begin //:
					mem_buffer[7:0] <=   8'b00000000;
					mem_buffer[15:8] <=  8'b00011000;
					mem_buffer[23:16] <= 8'b00011000;
					mem_buffer[31:24] <= 8'b00000000;
					mem_buffer[39:32] <= 8'b00000000;
					mem_buffer[47:40] <= 8'b00011000;
					mem_buffer[55:48] <= 8'b00011000;
					mem_buffer[63:56] <= 8'b00000000;
					end
					
			8'h41: begin //A
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b01000010;
					mem_buffer[39:32] <= 8'b01111110;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b01000010;
					end
					
			8'h42: begin //B
					mem_buffer[7:0] <=   8'b01111100;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000110;
					mem_buffer[31:24] <= 8'b01111100;
					mem_buffer[39:32] <= 8'b01000110;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b01111100;
					end
					
			8'h43: begin //C
					mem_buffer[7:0] <=   8'b00111110;
					mem_buffer[15:8] <=  8'b01100000;
					mem_buffer[23:16] <= 8'b01100000;
					mem_buffer[31:24] <= 8'b01100000;
					mem_buffer[39:32] <= 8'b01100000;
					mem_buffer[47:40] <= 8'b01100000;
					mem_buffer[55:48] <= 8'b01100000;
					mem_buffer[63:56] <= 8'b00111110;
					end
					
			8'h44: begin //D
					mem_buffer[7:0] <=   8'b01111100;
					mem_buffer[15:8] <=  8'b01100010;
					mem_buffer[23:16] <= 8'b01100010;
					mem_buffer[31:24] <= 8'b01100010;
					mem_buffer[39:32] <= 8'b01100010;
					mem_buffer[47:40] <= 8'b01100010;
					mem_buffer[55:48] <= 8'b01100010;
					mem_buffer[63:56] <= 8'b01111100;
					end
					
			8'h45: begin //E
					mem_buffer[7:0] <=   8'b00111110;
					mem_buffer[15:8] <=  8'b01100000;
					mem_buffer[23:16] <= 8'b01100000;
					mem_buffer[31:24] <= 8'b01111110;
					mem_buffer[39:32] <= 8'b01100000;
					mem_buffer[47:40] <= 8'b01100000;
					mem_buffer[55:48] <= 8'b01100000;
					mem_buffer[63:56] <= 8'b00111110;
					end
					
			8'h46: begin //F
					mem_buffer[7:0] <=   8'b01111110;
					mem_buffer[15:8] <=  8'b01100000;
					mem_buffer[23:16] <= 8'b01100000;
					mem_buffer[31:24] <= 8'b01111110;
					mem_buffer[39:32] <= 8'b01100000;
					mem_buffer[47:40] <= 8'b01100000;
					mem_buffer[55:48] <= 8'b01100000;
					mem_buffer[63:56] <= 8'b01100000;
					end
				
			8'h47: begin //G
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01100000;
					mem_buffer[23:16] <= 8'b01100000;
					mem_buffer[31:24] <= 8'b01101110;
					mem_buffer[39:32] <= 8'b01100110;
					mem_buffer[47:40] <= 8'b01100110;
					mem_buffer[55:48] <= 8'b01100110;
					mem_buffer[63:56] <= 8'b00111100;
					end
					
			8'h48: begin //H
					mem_buffer[7:0] <=   8'b01100110;
					mem_buffer[15:8] <=  8'b01100110;
					mem_buffer[23:16] <= 8'b01100110;
					mem_buffer[31:24] <= 8'b01111110;
					mem_buffer[39:32] <= 8'b01100110;
					mem_buffer[47:40] <= 8'b01100110;
					mem_buffer[55:48] <= 8'b01100110;
					mem_buffer[63:56] <= 8'b01100110;
					end
					
			8'h49: begin //I
					mem_buffer[7:0] <=   8'b01111110;
					mem_buffer[15:8] <=  8'b00011000;
					mem_buffer[23:16] <= 8'b00011000;
					mem_buffer[31:24] <= 8'b00011000;
					mem_buffer[39:32] <= 8'b00011000;
					mem_buffer[47:40] <= 8'b00011000;
					mem_buffer[55:48] <= 8'b00011000;
					mem_buffer[63:56] <= 8'b01111110;
					end
					
			8'h4A: begin //J
					mem_buffer[7:0] <=   8'b01111110;
					mem_buffer[15:8] <=  8'b00000110;
					mem_buffer[23:16] <= 8'b00000110;
					mem_buffer[31:24] <= 8'b00000110;
					mem_buffer[39:32] <= 8'b00000110;
					mem_buffer[47:40] <= 8'b00000110;
					mem_buffer[55:48] <= 8'b01100110;
					mem_buffer[63:56] <= 8'b00111100;
					end
					
			8'h4B: begin //K
					mem_buffer[7:0] <=   8'b01100110;
					mem_buffer[15:8] <=  8'b01100110;
					mem_buffer[23:16] <= 8'b01101100;
					mem_buffer[31:24] <= 8'b01110000;
					mem_buffer[39:32] <= 8'b01110000;
					mem_buffer[47:40] <= 8'b01101100;
					mem_buffer[55:48] <= 8'b01100110;
					mem_buffer[63:56] <= 8'b01100110;
					end
					
			8'h4C: begin //I
					mem_buffer[7:0] <=   8'b01100000;
					mem_buffer[15:8] <=  8'b01100000;
					mem_buffer[23:16] <= 8'b01100000;
					mem_buffer[31:24] <= 8'b01100000;
					mem_buffer[39:32] <= 8'b01100000;
					mem_buffer[47:40] <= 8'b01100000;
					mem_buffer[55:48] <= 8'b01100000;
					mem_buffer[63:56] <= 8'b01111110;
					end
					
			8'h4D: begin //M
					mem_buffer[7:0] <=   8'b01000010;
					mem_buffer[15:8] <=  8'b01100110;
					mem_buffer[23:16] <= 8'b01011010;
					mem_buffer[31:24] <= 8'b01011010;
					mem_buffer[39:32] <= 8'b01000010;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b01000010;
					end
					
			8'h4E: begin //N
					mem_buffer[7:0] <=   8'b01000010;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01100010;
					mem_buffer[31:24] <= 8'b01010010;
					mem_buffer[39:32] <= 8'b01001010;
					mem_buffer[47:40] <= 8'b01000110;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b01000010;
					end
					
			8'h4F: begin //O
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b01000010;
					mem_buffer[39:32] <= 8'b01000010;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b00111100;
					end
					
			8'h50: begin //P
					mem_buffer[7:0] <=   8'b01111100;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b01000010;
					mem_buffer[39:32] <= 8'b01111100;
					mem_buffer[47:40] <= 8'b01100000;
					mem_buffer[55:48] <= 8'b01100000;
					mem_buffer[63:56] <= 8'b01100000;
					end
					
			8'h51: begin //Q
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b01000010;
					mem_buffer[39:32] <= 8'b01000010;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000100;
					mem_buffer[63:56] <= 8'b00111010;
					end
					
			8'h52: begin //R
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b01000010;
					mem_buffer[39:32] <= 8'b01111100;
					mem_buffer[47:40] <= 8'b01011000;
					mem_buffer[55:48] <= 8'b01001100;
					mem_buffer[63:56] <= 8'b01000110;
					end
					
			8'h53: begin //S
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000000;
					mem_buffer[23:16] <= 8'b01000000;
					mem_buffer[31:24] <= 8'b00111100;
					mem_buffer[39:32] <= 8'b00000010;
					mem_buffer[47:40] <= 8'b00000010;
					mem_buffer[55:48] <= 8'b00000010;
					mem_buffer[63:56] <= 8'b00111100;
					end
					
			8'h54: begin //T
					mem_buffer[7:0] <=   8'b01111110;
					mem_buffer[15:8] <=  8'b00011000;
					mem_buffer[23:16] <= 8'b00011000;
					mem_buffer[31:24] <= 8'b00011000;
					mem_buffer[39:32] <= 8'b00011000;
					mem_buffer[47:40] <= 8'b00011000;
					mem_buffer[55:48] <= 8'b00011000;
					mem_buffer[63:56] <= 8'b00011000;
					end
					
			8'h55: begin //U
					mem_buffer[7:0] <=   8'b01000010;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b01000010;
					mem_buffer[39:32] <= 8'b01000010;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b00111100;
					end
					
			8'h56: begin //V
					mem_buffer[7:0] <=   8'b01000010;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b01000010;
					mem_buffer[39:32] <= 8'b01000010;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b00100100;
					mem_buffer[63:56] <= 8'b00011000;
					end
					
			8'h57: begin //W
					mem_buffer[7:0] <=   8'b01000010;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b01000010;
					mem_buffer[39:32] <= 8'b01011010;
					mem_buffer[47:40] <= 8'b01011010;
					mem_buffer[55:48] <= 8'b01100110;
					mem_buffer[63:56] <= 8'b01000010;
					end
					
			8'h58: begin //X
					mem_buffer[7:0] <=   8'b01000010;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b00100100;
					mem_buffer[31:24] <= 8'b00011000;
					mem_buffer[39:32] <= 8'b00011000;
					mem_buffer[47:40] <= 8'b00100100;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b01000010;
					end
					
			8'h59: begin //Y
					mem_buffer[7:0] <=   8'b01000010;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b00100100;
					mem_buffer[39:32] <= 8'b00011000;
					mem_buffer[47:40] <= 8'b00011000;
					mem_buffer[55:48] <= 8'b00011000;
					mem_buffer[63:56] <= 8'b00011000;
					end
					
			8'h5A: begin //Z
					mem_buffer[7:0] <=   8'b01111110;
					mem_buffer[15:8] <=  8'b00000110;
					mem_buffer[23:16] <= 8'b00000110;
					mem_buffer[31:24] <= 8'b00001100;
					mem_buffer[39:32] <= 8'b00110000;
					mem_buffer[47:40] <= 8'b01100000;
					mem_buffer[55:48] <= 8'b01100000;
					mem_buffer[63:56] <= 8'b01111110;
					end
					
			default: mem_buffer <= 63'hffffffffffffffff;
		endcase
	endtask

task decode_hex;
		case (hex_digit)	
		
			6'h00: begin //zero
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b01000010;
					mem_buffer[39:32] <= 8'b01000010;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b00111100;
					end
			
			6'h01: begin //one
					mem_buffer[7:0] <=   8'b00011000;
					mem_buffer[15:8] <=  8'b00111000;
					mem_buffer[23:16] <= 8'b01111000;
					mem_buffer[31:24] <= 8'b00011000;
					mem_buffer[39:32] <= 8'b00011000;
					mem_buffer[47:40] <= 8'b00011000;
					mem_buffer[55:48] <= 8'b00011000;
					mem_buffer[63:56] <= 8'b01111110;
					end
			
			6'h02: begin //two
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01100110;
					mem_buffer[23:16] <= 8'b01100110;
					mem_buffer[31:24] <= 8'b00001100;
					mem_buffer[39:32] <= 8'b00011000;
					mem_buffer[47:40] <= 8'b00110000;
					mem_buffer[55:48] <= 8'b01100000;
					mem_buffer[63:56] <= 8'b01111110;
					end
					
			6'h03: begin //three
					mem_buffer[7:0] <=   8'b01111100;
					mem_buffer[15:8] <=  8'b00000110;
					mem_buffer[23:16] <= 8'b00000110;
					mem_buffer[31:24] <= 8'b01111100;
					mem_buffer[39:32] <= 8'b00000110;
					mem_buffer[47:40] <= 8'b00000110;
					mem_buffer[55:48] <= 8'b00000110;
					mem_buffer[63:56] <= 8'b01111100;
					end
				
			6'h04: begin //four
					mem_buffer[7:0] <=   8'b00001110;
					mem_buffer[15:8] <=  8'b00010110;
					mem_buffer[23:16] <= 8'b00100110;
					mem_buffer[31:24] <= 8'b01000110;
					mem_buffer[39:32] <= 8'b01000110;
					mem_buffer[47:40] <= 8'b01111110;
					mem_buffer[55:48] <= 8'b00000110;
					mem_buffer[63:56] <= 8'b00000110;
					end
					
			6'h05: begin //five
					mem_buffer[7:0] <=   8'b01111110;
					mem_buffer[15:8] <=  8'b01100000;
					mem_buffer[23:16] <= 8'b01100000;
					mem_buffer[31:24] <= 8'b01111000;
					mem_buffer[39:32] <= 8'b00001100;
					mem_buffer[47:40] <= 8'b00000110;
					mem_buffer[55:48] <= 8'b00001100;
					mem_buffer[63:56] <= 8'b01111000;
					end
					
			6'h06: begin //six
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000000;
					mem_buffer[23:16] <= 8'b01000000;
					mem_buffer[31:24] <= 8'b01111100;
					mem_buffer[39:32] <= 8'b01000010;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b00111100;
					end
					
			6'h07: begin //seven
					mem_buffer[7:0] <=   8'b01111110;
					mem_buffer[15:8] <=  8'b00000110;
					mem_buffer[23:16] <= 8'b00000110;
					mem_buffer[31:24] <= 8'b00000110;
					mem_buffer[39:32] <= 8'b00001100;
					mem_buffer[47:40] <= 8'b00011000;
					mem_buffer[55:48] <= 8'b00110000;
					mem_buffer[63:56] <= 8'b01100000;
					end
					
			6'h08: begin //eight
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b00111100;
					mem_buffer[39:32] <= 8'b01000010;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b00111100;
					end
					
			6'h09: begin //nine
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000110;
					mem_buffer[23:16] <= 8'b01000110;
					mem_buffer[31:24] <= 8'b01000110;
					mem_buffer[39:32] <= 8'b00111110;
					mem_buffer[47:40] <= 8'b00000110;
					mem_buffer[55:48] <= 8'b00000110;
					mem_buffer[63:56] <= 8'b00000110;
					end
					
			6'h0A: begin //A
					mem_buffer[7:0] <=   8'b00111100;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000010;
					mem_buffer[31:24] <= 8'b01000010;
					mem_buffer[39:32] <= 8'b01111110;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b01000010;
					end
					
			6'h0B: begin //B
					mem_buffer[7:0] <=   8'b01111100;
					mem_buffer[15:8] <=  8'b01000010;
					mem_buffer[23:16] <= 8'b01000110;
					mem_buffer[31:24] <= 8'b01111100;
					mem_buffer[39:32] <= 8'b01000110;
					mem_buffer[47:40] <= 8'b01000010;
					mem_buffer[55:48] <= 8'b01000010;
					mem_buffer[63:56] <= 8'b01111100;
					end
					
			6'h0C: begin //C
					mem_buffer[7:0] <=   8'b00111110;
					mem_buffer[15:8] <=  8'b01100000;
					mem_buffer[23:16] <= 8'b01100000;
					mem_buffer[31:24] <= 8'b01100000;
					mem_buffer[39:32] <= 8'b01100000;
					mem_buffer[47:40] <= 8'b01100000;
					mem_buffer[55:48] <= 8'b01100000;
					mem_buffer[63:56] <= 8'b00111110;
					end
					
			6'h0D: begin //D
					mem_buffer[7:0] <=   8'b01111100;
					mem_buffer[15:8] <=  8'b01100010;
					mem_buffer[23:16] <= 8'b01100010;
					mem_buffer[31:24] <= 8'b01100010;
					mem_buffer[39:32] <= 8'b01100010;
					mem_buffer[47:40] <= 8'b01100010;
					mem_buffer[55:48] <= 8'b01100010;
					mem_buffer[63:56] <= 8'b01111100;
					end
					
			6'h0E: begin //E
					mem_buffer[7:0] <=   8'b00111110;
					mem_buffer[15:8] <=  8'b01100000;
					mem_buffer[23:16] <= 8'b01100000;
					mem_buffer[31:24] <= 8'b01111110;
					mem_buffer[39:32] <= 8'b01100000;
					mem_buffer[47:40] <= 8'b01100000;
					mem_buffer[55:48] <= 8'b01100000;
					mem_buffer[63:56] <= 8'b00111110;
					end
					
			6'h0F: begin //F
					mem_buffer[7:0] <=   8'b01111110;
					mem_buffer[15:8] <=  8'b01100000;
					mem_buffer[23:16] <= 8'b01100000;
					mem_buffer[31:24] <= 8'b01111110;
					mem_buffer[39:32] <= 8'b01100000;
					mem_buffer[47:40] <= 8'b01100000;
					mem_buffer[55:48] <= 8'b01100000;
					mem_buffer[63:56] <= 8'b01100000;
					end
			default: mem_buffer <= 63'h0000000000000000;
		endcase
	endtask
endmodule