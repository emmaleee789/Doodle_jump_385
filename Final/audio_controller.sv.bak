module audio_controller(
	input	logic			Clk,
	input	logic			Reset,
	// input	logic			Sound_clk,

	// // I/O from board or wherever
	// input	logic			play_sound,
	// output	logic			is_sound_playing,
	// output	logic			is_sound_done,

	// // I/O from the Qsys
	// input	logic	[15:0]	sound_data,
	// output	logic	[9:0]	sound_address,	// remember to update the bit-width here to match your Qsys

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

	// But I do care about -- these signals I don't really care about -- but you might find them useful
	logic adc_full, data_over;

    enum logic [3:0] { START, INI, PLAY, END } State, Next_state;
    logic [15:0] LDATA, RDATA, LDATA_in, RDATA_in, audio_content;
    logic [31:0] addr_counter;
    int start = 1;


    audio_ram audio_ram0(
        .Clk(Clk),
        .read_addr(addr_counter),
        .audio_content(audio_content)
    );


	audio_interface audio_driver(
		.clk(Clk),
		.Reset(Reset),
		.INIT(INIT),
		.LDATA(LDATA), // im using mono so both LDATA and RDATA are the same
		.RDATA(RDATA),
		.INIT_FINISH(INIT_FINISH),
		.adc_full(adc_full), // not ignore
		.data_over(data_over), // not ignore
		.AUD_BCLK(AUD_BCLK),
		.AUD_MCLK(AUD_XCK),
		.AUD_ADCDAT(AUD_ADCDAT),
		.AUD_DACDAT(AUD_DACDAT),
		.AUD_DACLRCK(AUD_DACLRCK),
		.AUD_ADCLRCK(AUD_ADCLRCK),
		.I2C_SDAT(I2C_SDAT),
		.I2C_SCLK(I2C_SCLK)
	);

    /* increment the address that is going to read from audio content */
    always_ff @(posedge data_over) begin
        if(start)
            addr_counter <= 1'b0;
            start <= 0;
        else
            addr_counter <= addr_counter + 1'b1;
    end

    always_ff @(posedge Clk) begin
        if (Reset)
            curr_state <= START;
        else begin
            curr_state <= next_state;
            LDATA <= LDATA_in;
            RDATA <= RDATA_in;
        end
    end

    always_comb 
    begin
        INIT = 1'b0;
        next_state = curr_state;
        LDATA_in = LDATA;
        RDATA_in = RDATA;
        unique case(curr_state)
            START: 	next_state = INI;
            INI: begin 
                if(INIT_FINISH)
                    next_state = PLAY;
                INIT = 1'd01;
            end
            PLAY: begin
                if(data_over)
                    next_state = END;
            end
            END: begin
                if(~data_over)
                    next_state = PLAY;
                LDATA_in = audio_content;
                RDATA_in = audio_content; 
            end 
            default:;
        endcase		

    end

	// // when "playing", automatically incrementing the address
	// counter #(.N(10), .SAMPLES(400)) sound_counter(
	// 	.Play(play_sound),
	// 	.Playing(is_sound_playing),
	// 	.Done(is_sound_done),
	// 	.Addr(sound_address),
	// 	.*
	// );

	// audio_driver_state_machine state_machine(.*);

endmodule // audio_controller
