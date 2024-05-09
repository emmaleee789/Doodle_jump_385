module carry_lookahead_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);

    /* TODO
     *
     * Insert code here to implement a CLA adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
	  wire[3:0] P,G;
	  wire[4:0] C;
	  assign C[0]=1'b0;
	  
	  ahead_adder_4bit ah0(.A(A[3:0]), .B(B[3:0]), .Ci(C[0]), .Y(Sum[3:0]), .PG(P[0]), .GG(G[0]), .Co(C[1]));
	  ahead_adder_4bit ah1(.A(A[7:4]), .B(B[7:4]), .Ci(C[1]), .Y(Sum[7:4]), .PG(P[1]), .GG(G[1]), .Co(C[2]));
	  ahead_adder_4bit ah2(.A(A[11:8]), .B(B[11:8]), .Ci(C[2]), .Y(Sum[11:8]), .PG(P[2]), .GG(G[2]), .Co(C[3]));
	  ahead_adder_4bit ah3(.A(A[15:12]), .B(B[15:12]), .Ci(C[3]), .Y(Sum[15:12]), .PG(P[3]), .GG(G[3]), .Co(C[4]));
     assign CO=C[0];
	  
endmodule


module ahead_adder_4bit(
	input [3:0]A,
	input [3:0]B,
	input Ci,
	output [3:0]Y,
	output PG,GG,Co
);
	//This is 4bit CLA adder
	wire [4:0]C;
	wire [3:0]P;
	wire [3:0]G;

	assign C[0] = Ci;
	assign Co = C[4];

	bit_full_adder fa_0(.A(A[0]), .B(B[0]), .C(C[0]), .P(P[0]), .G(G[0]), .S(Y[0]));
	bit_full_adder fa_1(.A(A[1]), .B(B[1]), .C(C[1]), .P(P[1]), .G(G[1]), .S(Y[1]));
	bit_full_adder fa_2(.A(A[2]), .B(B[2]), .C(C[2]), .P(P[2]), .G(G[2]), .S(Y[2]));
	bit_full_adder fa_3(.A(A[3]), .B(B[3]), .C(C[3]), .P(P[3]), .G(G[3]), .S(Y[3]));	 

	//Carry Look Ahead Unit.
	CLU clu(.P(P), .G(G), .C0(C[0]), .PG(PG), .GG(GG), .C1to4(C[4:1]));

endmodule


module bit_full_adder(
	input A,B,C,
	output P,G,S
);
	//Full adder and subtractor whit the mode selection.
	assign P = A^B;
	assign G = A&B;
	assign S = A^B^C;

endmodule


module CLU(
	input [3:0]P,
	input [3:0]G,
	input C0,
	output PG,GG,
	output [4:1]C1to4
);
	//Common Carry Look Ahead Unit.
	//Used by every adder layer.
	wire [4:0]C;

	assign C1to4 = C[4:1];
	assign PG = &P;
	assign GG = G[3]|(G[2]&P[3])|(G[1]&P[3]&P[2])|(G[0]&P[3]&P[2]&P[1]);
	assign C[1] = G[0]|(P[0]&C0);
	assign C[2] = G[1]|(G[0]&P[1])|(C0&P[0]&P[1]);
	assign C[3] = G[2]|(G[1]&P[2])|(G[0]&P[1]&P[2])|(C0&P[0]&P[1]&P[2]);
	assign C[4] = G[3]|(G[2]&P[3])|(G[1]&P[2]&P[3])|(G[0]&P[1]&P[2]&P[3])|(C0&P[0]&P[1]&P[2]&P[3]);
	
endmodule
