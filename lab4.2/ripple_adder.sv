module ripple_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);

    /* TODO
     *
     * Insert code here to implement a ripple adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
	 
	 logic[15:0] c_in;
	 
	 assign c_in[0] = 1'b0;
	
	wire Sum1,Sum2,Sum3,Sum4,Sum5,Sum6,Sum7,Sum8,
		 Sum9,Sum10,Sum11,Sum12,Sum13,Sum14,Sum15,Sum16;
//	wire CO1,CO2,CO3,CO4,CO5,CO6,CO7,CO8,
//		 CO9,CO10,CO11,CO12,CO13,CO14,CO15;
//	
	assign Sum = {Sum16,Sum15,Sum14,Sum13,Sum12,Sum11,Sum10,Sum9,Sum8,Sum7,Sum6,Sum5,Sum4,Sum3,Sum2,Sum1};
	
	full_adder m0(
		.A(A[0]), 
		.B(B[0]), 
		.c_in(c_in[0]), 
		.Sum(Sum1), 
		.CO(c_in[1]));
		
	full_adder m1(
		.A(A[1]),
		.B(B[1]),
		.c_in(c_in[1]),
		.Sum(Sum2),
		.CO(c_in[2]));
		
	full_adder m2(
		.A(A[2]),
		.B(B[2]),
		.c_in(c_in[2]),
		.Sum(Sum3),
		.CO(c_in[3]));
		
	full_adder m3(
		.A(A[3]),
		.B(B[3]),
		.c_in(c_in[3]),
		.Sum(Sum4),
		.CO(c_in[4]));

	full_adder m4(
		.A(A[4]),
		.B(B[4]),
		.c_in(c_in[4]),
		.Sum(Sum5),
		.CO(c_in[5]));

	full_adder m5(
		.A(A[5]),
		.B(B[5]),
		.c_in(c_in[5]),
		.Sum(Sum6),
		.CO(c_in[6]));

	full_adder m6(
		.A(A[6]),
		.B(B[6]),
		.c_in(c_in[6]),
		.Sum(Sum7),
		.CO(c_in[7]));
	
	full_adder m7(
		.A(A[7]),
		.B(B[7]),
		.c_in(c_in[7]),
		.Sum(Sum8),
		.CO(c_in[8]));

	full_adder m8(
		.A(A[8]),
		.B(B[8]),
		.c_in(c_in[8]),
		.Sum(Sum9),
		.CO(c_in[9]));

	full_adder m9(
		.A(A[9]),
		.B(B[9]),
		.c_in(c_in[9]),
		.Sum(Sum10),
		.CO(c_in[10]));

	full_adder m10(
		.A(A[10]),
		.B(B[10]),
		.c_in(c_in[10]),
		.Sum(Sum11),
		.CO(c_in[11]));

	full_adder m11(
		.A(A[11]),
		.B(B[11]),
		.c_in(c_in[11]),
		.Sum(Sum12),
		.CO(c_in[12]));
		
	full_adder m12(
		.A(A[12]),
		.B(B[12]),
		.c_in(c_in[12]),
		.Sum(Sum13),
		.CO(c_in[13]));
		
	full_adder m13(
		.A(A[13]),
		.B(B[13]),
		.c_in(c_in[13]),
		.Sum(Sum14),
		.CO(c_in[14]));

	full_adder m14(
		.A(A[14]),
		.B(B[14]),
		.c_in(c_in[14]),
		.Sum(Sum15),
		.CO(c_in[15]));

	full_adder m15(
		.A(A[15]),
		.B(B[15]),
		.c_in(c_in[15]),
		.Sum(Sum16),
		.CO(CO));
		
endmodule


