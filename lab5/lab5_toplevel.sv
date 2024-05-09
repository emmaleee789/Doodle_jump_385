module lab5_toplevel (
	input logic [7:0] S,
	input logic Clk, Reset, Run, ClearA_LoadB, 
	output logic [6:0] AhexU, AhexL, BhexU, BhexL,
	output logic [7:0] Aval, Bval,
	output logic X
);
	logic [7:0] A, B, A2, B2;
	logic Clr_Ld, Shift, Add, Sub, Clr_A, Xnew; ////
	assign Aval = A;
	assign Bval = B;

	
	shift_reg reg1 (
		.X(Xnew), .Reset(~Reset), .Clk(Clk),
		.A(A2), .B(B2), .S(S),
		.Clr_Ld(Clr_Ld), .Shift(Shift), .Add(Add), .Sub(Sub), .Clr_A(Clr_A),
		.X2(X),
		.A2(A), .B2(B)
	);

	ADD8 add(.A(A), .S(S), .Add(Add), .Sub(Sub), .A2(A2), .X(Xnew));
	assign B2=B; ////

	control control_unit (
		.Clk(Clk), .Reset(~Reset), .Run(~Run), .ClearA_LoadB(~ClearA_LoadB),
		.A(A), .B(B), .S(S),
		.Clr_Ld(Clr_Ld), .Shift(Shift),	.Add(Add), .Sub(Sub), .Clr_A(Clr_A) 
	);


		
	HexDriver        HexAL (
					.In0(A[3:0]),
					.Out0(AhexL) );
	HexDriver        HexBL (
					.In0(B[3:0]),
					.Out0(BhexL) );
	HexDriver        HexAU (
					.In0(A[7:4]),
					.Out0(AhexU) );	
	HexDriver        HexBU (
					.In0(B[7:4]),
					.Out0(BhexU) );

endmodule


module ADD8 (
	input logic [7:0] A, S,
	input logic Add, Sub,
	output logic [7:0] A2,
	output logic X
);
	logic [8:0] C;
	logic [7:0] temp, temp2;
	assign C[0] = Sub;
	assign temp2 = (S ^ {8{Sub}});
	assign temp = (temp2 & {8{Add}}); ////
	
	full_adder fa0(.A(A[0]), .B(temp[0]), .Cin(C[0]), .S(A2[0]), .Cout(C[1]));
	full_adder fa1(.A(A[1]), .B(temp[1]), .Cin(C[1]), .S(A2[1]), .Cout(C[2]));
	full_adder fa2(.A(A[2]), .B(temp[2]), .Cin(C[2]), .S(A2[2]), .Cout(C[3]));
	full_adder fa3(.A(A[3]), .B(temp[3]), .Cin(C[3]), .S(A2[3]), .Cout(C[4]));
	full_adder fa4(.A(A[4]), .B(temp[4]), .Cin(C[4]), .S(A2[4]), .Cout(C[5]));
	full_adder fa5(.A(A[5]), .B(temp[5]), .Cin(C[5]), .S(A2[5]), .Cout(C[6]));
	full_adder fa6(.A(A[6]), .B(temp[6]), .Cin(C[6]), .S(A2[6]), .Cout(C[7]));
	full_adder fa7(.A(A[7]), .B(temp[7]), .Cin(C[7]), .S(A2[7]), .Cout(C[8]));
	full_adder fa8(.A(A[7]), .B(temp[7]), .Cin(C[8]), .S(X), .Cout()); ////

	//assign X = A2[7];
endmodule

module full_adder (input A, B, Cin, output logic S, Cout);
	always_comb
	begin
		S=A^B^Cin;
		Cout=(A&B)|(B&Cin)|(A&Cin);
	end
endmodule

