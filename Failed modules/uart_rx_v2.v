module uart_rx_v2(
	
	input clk,
	input serial_in,
	
	output valid,
	output [7:0] data);
	
	PARAMETER [1:0] IDLE = 2'b00,
				       START = 2'b01,
				       RX = 2'b10,
				       STOP = 2'b11;
	
	reg [7:0] output_buffer;
	reg [7:0] counter;
	reg [2:0] sync_chain;
	reg [2:0] ones;
	reg [2:0] bit_count;

	
	always @(posedge clk) begin //synchronizer chain
		sync_chain[2] <= sync_chain[1];
		sync_chain[1] <= sync_chain[0];
		sync_chain[0] <= serial_in;
	end
	
	always @(posedge clk) begin
	
	case(state)
	
		IDLE: begin
			bit_count <= 0;
			counter <= 0;
			valid <= 0;
			if (sync_chain[2] == 0) state <= START;
		end
		
		START: begin
			count < count + 1;
			//Oversampling the start bit by taking samples near the center of the signal
			if (count == 84) begin
				if (sync_chain[2] == 1) ones <= ones + 1;
			end
			
			else if (count == 96) begin
				if (sync_chain[2] == 1) ones <= ones + 1;
			end
			
			else if (count == 108) begin
				if (sync_chain[2] == 1) ones <= ones + 1;
			end
			
			if (count == 191) begin
				if (ones >= 2) state <= RX;
				else state <= IDLE;
				count <= 0;
				ones <= 0;
			end
			
		end
		
		RX: begin
			count = count + 1;
			
			if (count == 84) begin
				if (sync_chain[2] == 1) ones <= ones + 1;
			end
			
			else if (count == 96) begin
				if (sync_chain[2] == 1) ones <= ones + 1;
			end
			
			else if (count == 108) begin
				if (sync_chain[2] == 1) ones <= ones + 1;
			end
			
			if (count == 191) begin
				if (ones >= 2) output_buffer[bit_count] <= 1;
				else output_buffer[bit_count] <= 0;
				
				if (bit_count >= 7) state <= STOP;
				
				bit_count = bit_count + 1;
				count <= 0;
				ones <= 0;
			end
			
		end
		
		STOP: begin
		
		end
	end
endmodule
