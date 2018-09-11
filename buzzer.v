module buzzer( //v1: no live modification of note data
	
	input clk_50mhz,
	input enable,
	input wire [3:0] note,
	input wire [2:0] octave,
	
	output reg buzzer);
		
	//counter for holding a count of at least 1 second.
	reg [26:0] counter;
	
	integer note_count;
	
	initial begin
		counter = 0;
	end
	
	always begin
	//generate the value when the counter toggles
			//This table is 50,000,000 divided by the base frequency of each note
			//Octave bitshifts the frequency, dividing it by 2 with each bit shift.
			case (note)	
				0: note_count = 3058104 >> octave >> 1; //C
				1: note_count = 2886836 >> octave >> 1; //C#
				2: note_count = 2724796 >> octave >> 1; //D
				3: note_count = 2570694 >> octave >> 1; //D#
				4: note_count = 2427184 >> octave >> 1; //E
				5: note_count = 2290426 >> octave >> 1; //F
				6: note_count = 2162629 >> octave >> 1; //F#
				7: note_count = 2040816 >> octave >> 1; //G
				8: note_count = 1946282 >> octave >> 1; //G#
				9: note_count = 1818182 >> octave >> 1; //A
				10: note_count = 1715854 >> octave >> 1;//A#
				11: note_count = 1619695 >> octave >> 1;//B
				default: note_count = 0;
			endcase
	end
	
	always @(posedge clk_50mhz) begin
		
		if (enable == 1) begin
		
			//toggle the buzzer pin, and reset the counter if note_count has been reached
			if (counter >= note_count) begin
				buzzer = !buzzer;
				counter = 0;
			end
			//else increment the counter
			else counter = counter + 1;
			
		end
		
	end
	
endmodule