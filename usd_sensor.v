//Ultra-sonic distance sensor interface
//Tristan Woodrich
//v1 external trigger version.
//r2 fixed condition of no obstacle 
//November 4th, 2018

module usd_sensor(
	input clk_50mhz,
	input sensor_in, //input from the USD sensor
	input trigger, //external trigger
	
	output reg sensor_trigger, //output to the USD
	output reg [15:0] sensor_response); //16-bits of hex data indicating distance.

	reg [2:0] sync_chain; //register for synchronizing the external signal
	reg [1:0] state; //register for the state variable
	
	reg [19:0] counter; //20-bit counter allows a count of 1/100th of a second at 50 mhz

	//state definitions
	parameter [1:0] 	RESET 	= 	2'b00, 
							TRIGGER = 	2'b01,
							TIME	=	2'b10;
					
	
	always @(posedge clk_50mhz) begin //Synchronizer chain
		sync_chain[2] <= sync_chain[1];
		sync_chain[1] <= sync_chain[0];
		sync_chain[0] <= sensor_in;
	end
	
	always @(posedge clk_50mhz) begin
	
		case (state)
		
			RESET: begin //reset counter and trigger output
				counter <= 0;
				sensor_trigger <= 0;
				if (trigger == 1) state <= TRIGGER; //If the external trigger is on, begin triggering the sensor
				else state <= RESET;
			end
			
			TRIGGER: begin //sends a 10 microsecond pulse to the sensor
				
				counter <= counter + 1;
				state <= TRIGGER;
				
				if (counter <= 500) begin  //500 clocks to get 10 us, sensor trigger is high during this time
					sensor_trigger <= 1;
				end
				else sensor_trigger <= 0;
				
				if(sync_chain[2] == 1) begin //transition to time once the sensor begins returning a value
					state <= TIME;
					counter <= 0;
				end
				
				if (counter >= 500500) begin//timeout function, return max value if sensor times out
					sensor_response <= 16'h2710;
					state <= RESET;
				end


			end
			
			TIME: begin //increment the counter as long as the input signal is high.
				
				if (counter >= 500000) begin //time out if 1/100th of a second goes by. (Distance > 3.43 meters)
					state <= RESET;
					sensor_response <= 16'h2709; //return counter value in microseconds. 
				end
				
				else if (sync_chain[2] == 1) begin
					counter <= counter + 1;
					state <= TIME;
				end
		
				else begin //once signal goes low, output the counter value.
					sensor_response <= (counter/50);
					if (trigger == 0) state <= RESET; //prevent multiple executions when being operated by humans
				end
			end
			
			default: state <= RESET;
		
		endcase
		
	end
endmodule
