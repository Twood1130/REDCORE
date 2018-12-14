module usd_guidance(
	input clock_50mhz,
	input [15:0] usd_front,
	input [15:0] usd_left,
	input [15:0] usd_right,
	
	output reg [2:0] usd_trigs,
	output reg [1:0] hb1,
	output reg [1:0] hb2,
	output reg error,
	output reg [2:0] interrupt);
	
	reg [25:0] counter; //use a counter to determine when to pulse the usd sensors, counter is big enough for up to one second of counting.
	
	always @(posedge clock_50mhz) begin
	
		
		if (counter >= 12500000) begin //check usd sensors every quarter second
			usd_trigs = 3'b111;
			counter <= 0;
		end
		
		else begin //increment counter if check not needed.
			counter <= counter + 1;
			usd_trigs <= 3'b000;
		end
	end


	always begin
	
		if (usd_front <= 16'h0470) begin //front interrupt
		
			interrupt = 3'b010;
			if (usd_left >= usd_right) begin //if the left sensor has more space than the right, turn left
				hb1 = 2'b01;
				hb2 = 2'b01;
				interrupt = 3'b110;
			end
			
			else begin //else turn right
				hb1 = 2'b10;
				hb2 = 2'b10;
				interrupt = 3'b010;
			end
		
		end
		
		else if (usd_left <= 16'h0270) begin //left interrupt
			interrupt = 3'b100;
			hb1 = 2'b10;
			hb2 = 2'b10;
		
		end
		
		else if (usd_right <= 16'h0270) begin //right interrupt,turn left
			interrupt = 3'b001;
			hb1 = 2'b01;
			hb2 = 2'b01;
		end
		
		else begin//normal operation
			interrupt = 3'b000;
			hb1 = 2'b10;
			hb2 = 2'b01;
		end
	
	end
	
	
endmodule


	