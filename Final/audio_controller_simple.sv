module audio_controller_simple(
	input	logic			Clk,
	input	logic			Reset,
	input	logic			Sound_clk,

	// I/O from board or wherever
	input	logic			play_sound,
	output	logic			is_sound_playing,
	output	logic			is_sound_done,

	// I/O from the Qsys
	input	logic	[15:0]	sound_data,
	output	logic	[9:0]	sound_address,	// remember to update the bit-width here to match your Qsys

	// I/O from board to the I2C codec
	output	logic			AUD_XCK,
	input	logic			AUD_BCLK,
	input	logic			AUD_ADCDAT,
	output	logic			AUD_DACDAT,
	input	logic			AUD_DACLRCK,
	input	logic			AUD_ADCLRCK,
	output	logic			I2C_SDAT,
	output	logic			I2C_SCLK
);

	logic INIT_FINISH, INIT;

	// these signals I don't really care about -- but you might find them useful
	logic adc_full, data_over;

	counter #(
		.N(16), .SAMPLES(133632)
	) sound_counter(
		.Play(play_sound),
		.Playing(is_sound_playing),
		.Done(is_sound_done),
		.Addr(sound_address),
		.*
	);

	audio_interface audio_driver(
		.clk(Clk),
		.Reset(Reset),
		.INIT(INIT),
		.LDATA(sound_data), // im using mono so both LDATA and RDATA are the same
		.RDATA(sound_data),
		.INIT_FINISH(INIT_FINISH),
		.adc_full(adc_full),
		.data_over(data_over),
		.AUD_BCLK(AUD_BCLK),
		.AUD_MCLK(AUD_XCK),
		.AUD_ADCDAT(AUD_ADCDAT),
		.AUD_DACDAT(AUD_DACDAT),
		.AUD_DACLRCK(AUD_DACLRCK),
		.AUD_ADCLRCK(AUD_ADCLRCK),
		.I2C_SDAT(I2C_SDAT),
		.I2C_SCLK(I2C_SCLK)
	);

	audio_driver_state_machine state_machine(.*);

endmodule // audio_controller
