module audio_driver_state_machine(
	input	logic			Clk,
	input	logic			Reset,
	input	logic			INIT_FINISH,
	output	logic			INIT
);

	enum logic [3:0] {
		Begin, // init
		Setup, // wait for INIT_FINISH
		Play
	} State, Next_State;

	// state machine progress
	always_ff @ (posedge Clk)
	begin
		if (Reset)
			State <= Begin;
		else
			State <= Next_State;
	end

	always_comb
	begin
		// default to current state
		Next_State = State;

		// Set defualt signals
		INIT = 1'b1;

		// assign next state
		unique case (State)
			Begin:
				Next_State = Setup;
			Setup:
				if (INIT_FINISH)
					Next_State = Play;
			Play:
				Next_State = Play;
			default: ;
		endcase

		// assign signals
		unique case (State)
			Begin: INIT = 1'b1;
			Setup: ;
			Play: ;
		endcase
	end

endmodule
