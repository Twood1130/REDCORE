module buzzer_mixer(
	input buzzer_1,
	input buzzer_2,
	input buzzer_3,
	input buzzer_4,
	
	output buzzer_out);
	
	assign buzzer_out = buzzer_1 ^ buzzer_2;
	
endmodule
	