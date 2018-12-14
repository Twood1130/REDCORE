//500hz PWM module
//Tristan Woodrich 
//12/11/18
//v1 4-options for duty cycle, based on 2-bit input
//module works only at 500hz, with an input of 50mhz

module pwm_500hz(
	input clock_50mhz,
	input [1:0] duty_cycle, //2-bit duty cycle selection, allows 4 options
	
	output reg pwm);
	
	reg [16:0] counter; //17-bit counter holds enough for 100,000 clocks(500hz)
	integer duty_count;
	
	always begin //this block determines the duty cycle count
		case(duty_cycle)
		
			0: duty_count = 25000; //25% duty cycle
			1: duty_count = 50000; //50% duty cycle
			2: duty_count = 75000; //75% duty cycle
			3: duty_count = 100000;//100% duty cycle
		
		endcase
	end
	
	always @(posedge clock_50mhz) begin
	
		counter <= counter + 1; //increment the counter
		if (counter >= 100000) counter <= 0; //reset the counter at 500hz
		
		if (counter > duty_count) pwm <= 1'b0; //determine the output
		else pwm <= 1'b1;
		
	end
	
endmodule