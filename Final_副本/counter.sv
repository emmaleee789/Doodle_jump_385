/*
	This module creates an incrementing address to pass into the ROM synthesized in Qsys.

	Parameters:
	- N: the bit-width of the address for the ROM Qsys module
	- SAMPLES: the number of samples in your sound file (this is DEPTH of the mif file)

	Input Signals:
	- Reset: Active high reset signal
	- Sound_clk: (usually 48 kHz)
	- Play: Active high play signal

	Output Signals:
	- Playing: high when "playing" (aka high when address is incrementing)
	- Done: high when the sound is done "playing"
	- Addr: the address to pipe into the Qsys module

*/

module counter #(parameter N = 16, parameter SAMPLES = 100) (
	input	logic			Reset,
	input	logic			Sound_clk,
	input	logic			Play,

	output	logic			Playing,
	output	logic			Done,
	output	logic	[N-1:0]	Addr
);

	logic isPlaying, isDone;
	logic [N-1:0] address;

	assign Playing = isPlaying;
	assign Done = isDone;
	assign Addr = address;

	always_ff @(posedge Sound_clk or posedge  Reset)
	begin
		if (Reset)
		begin
			// handle reset
			address <= {N{1'b0}};
			isPlaying <= 1'b0;
			isDone <= 1'b0;
		end
		else
		begin
			if (Play & ~isPlaying)
			begin
				// handle play trigger
				address <= {N{1'b0}};
				isPlaying <= 1'b1;
				isDone <= 1'b0;
			end
			else if (isPlaying)
			begin
				if (address >= SAMPLES)
				begin
					// handle end of sound
					isPlaying <= 1'b0;
					isDone <= 1'b1;
				end
				else
					address <= address + 1'b1;
			end
		end
	end

endmodule // counter
