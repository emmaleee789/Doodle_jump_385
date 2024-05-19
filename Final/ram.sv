module  img_basic_doodle
(
		//input[7:0] x, y, 
		input [15:0] read_address, 
		input Clk,
		output logic [7:0] data_Out 
);
	parameter [5:0] W = 32;
	parameter [5:0] H = 32;

	logic [7:0] mem [0: W*H-1]; 

	// logic [15:0] read_address;
	// assign read_address = y*W + x;

	initial
	begin
		$readmemh("img_txt/basic_doodle.txt", mem);
	end


	always_ff @ (posedge Clk) begin
		data_Out<= mem[read_address];
	end

endmodule


module  img_holiday_doodle (
	input[7:0] x, y, //input [18:0] read_address, 
	input Clk,
	output logic [4:0] data_Out 
);
	parameter [5:0] W = 32;
	parameter [5:0] H = 32;

	logic [7:0] mem [0: W*H-1]; 

	logic [15:0] read_address;
	assign read_address = y*W + x;

	initial
	begin
		$readmemh("img_txt/holilday_doodle.txt", mem);
	end


	always_ff @ (posedge Clk) begin
		data_Out<= mem[read_address];
	end

endmodule

module  img_nightmare_doodle (
	input[7:0] x, y, //input [18:0] read_address, 
	input Clk,
	output logic [4:0] data_Out 
);
	parameter [5:0] W = 32;
	parameter [5:0] H = 32;

	logic [2:0] mem [0: W*H-1]; 

	logic [15:0] read_address;
	assign read_address = y*W + x;

	initial
	begin
		$readmemh("img_txt/nightmare_doodle.txt", mem);
	end


	always_ff @ (posedge Clk) begin
		data_Out<= mem[read_address];
	end

endmodule