//GPS Guidance System
//Tristan Woodrich
//12/11/2018
//v1: Limited Scope version, only takes minutes into account

module gps_guidance(
	input [7:0] latd,//inputs from gps_decoder
	input [7:0] lond,
	input [19:0] latm,
	input [19:0] lonm,
	
	output reg lat_prox_int,//1-bit output signals for proximity interrupts
	output reg lon_prox_int,
	output reg go_north, //outputs for direction to travel in
	output reg go_east);
	
	parameter accuracy = 20'h0000A; //parameter for the allowed deviation from an exact value
	parameter target_lat = 20'h84153; //parameters for target lat/lon
	parameter target_lon = 20'h61D60;
	
	
	always begin //always block for determining if destination reached
		
		if (latd == 8'h2C) begin //iff we are at 44 degres latitude
			if ((latm > (target_lat - accuracy)) && (latm < (target_lat + accuracy))) lat_prox_int = 1'b1;
			else lat_prox_int = 1'b0;
		end
		
		if (lond == 8'h44) begin //iff we are at 68 degrees longitude
			if ((lonm >= (target_lon - accuracy)) && (lonm <= (target_lon + accuracy))) lon_prox_int = 1'b1;
			else lon_prox_int = 1'b0;
		end
		
	end
	
	always begin //always block for determining which direction should be traveled in.
	
		if (target_lat > latm) go_north = 1'b1;
		else go_north = 1'b0;


		if (target_lon > lonm) go_east = 1'b1;
		else go_east = 1'b0;	
		
	end
	
endmodule

