module audio_ram (input logic  Clk,
				  input logic  [16:0] read_addr,
				  output logic [16:0] audio_content
);
				  
	logic [16:0] mem [0:1111];	// TODO: the length of the txt file
	initial 
	begin 
		$readmemh("music.txt",mem); //TODO
	end
	
	always_ff @ (posedge Clk)
		begin
			audio_content <= mem[read_addr];
		end
endmodule