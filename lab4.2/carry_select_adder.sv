module carry_select_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);
    /* TODO
     *
     * Insert code here to implement a carry select.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
	wire[16:0] C;
	assign C[0]= 1'b0;
	// first 4 bit
	full_adder fa0(.A(A[0]), .B(B[0]), .c_in(C[0]), .Sum(Sum[0]), .CO(C[1]));
	full_adder fa1(.A(A[1]), .B(B[1]), .c_in(C[1]), .Sum(Sum[1]), .CO(C[2]));
	full_adder fa2(.A(A[2]), .B(B[2]), .c_in(C[2]), .Sum(Sum[2]), .CO(C[3]));
	full_adder fa3(.A(A[3]), .B(B[3]), .c_in(C[3]), .Sum(Sum[3]), .CO(C[4]));
	// [15:4]
	carry_select_adder4 ca1(.A(A[7:4]), .B(B[7:4]), .cin(C[4]), .S(Sum[7:4]), .cout(C[8]));
	carry_select_adder4 ca2(.A(A[11:8]), .B(B[11:8]), .cin(C[8]), .S(Sum[11:8]), .cout(C[12]));
	carry_select_adder4 ca3(.A(A[15:12]), .B(B[15:12]), .cin(C[12]), .S(Sum[15:12]), .cout(CO));
	
	
endmodule


module carry_select_adder4
        (   input [3:0] A,B,
            input cin,
            output [3:0] S,
            output cout
         );
        

	wire [3:0] temp0,temp1,carry0,carry1;

	//for carry 0
	full_adder fa00(.A(A[0]),.B(B[0]),.c_in(1'b0),.Sum(temp0[0]),.CO(carry0[0]));
	full_adder fa01(.A(A[1]),.B(B[1]),.c_in(carry0[0]),.Sum(temp0[1]),.CO(carry0[1]));
	full_adder fa02(.A(A[2]),.B(B[2]),.c_in(carry0[1]),.Sum(temp0[2]),.CO(carry0[2]));
	full_adder fa03(.A(A[3]),.B(B[3]),.c_in(carry0[2]),.Sum(temp0[3]),.CO(carry0[3]));

	//for carry 1
	full_adder fa10(.A(A[0]),.B(B[0]),.c_in(1'b1),.Sum(temp1[0]),.CO(carry1[0]));
	full_adder fa11(.A(A[1]),.B(B[1]),.c_in(carry1[0]),.Sum(temp1[1]),.CO(carry1[1]));
	full_adder fa12(.A(A[2]),.B(B[2]),.c_in(carry1[1]),.Sum(temp1[2]),.CO(carry1[2]));
	full_adder fa13(.A(A[3]),.B(B[3]),.c_in(carry1[2]),.Sum(temp1[3]),.CO(carry1[3]));

	//mux for carry
	multiplexer2 mux_carry(.i0(carry0[3]),.i1(carry1[3]),.sel(cin),.bitout(cout));
	//mux's for sum
	multiplexer2 mux_sum0(.i0(temp0[0]),.i1(temp1[0]),.sel(cin),.bitout(S[0]));
	multiplexer2 mux_sum1(.i0(temp0[1]),.i1(temp1[1]),.sel(cin),.bitout(S[1]));
	multiplexer2 mux_sum2(.i0(temp0[2]),.i1(temp1[2]),.sel(cin),.bitout(S[2]));
	multiplexer2 mux_sum3(.i0(temp0[3]),.i1(temp1[3]),.sel(cin),.bitout(S[3]));

endmodule 


module multiplexer2
        (   input i0,i1,sel,
            output reg bitout
            );

	always@(i0,i1,sel)
	begin
	if(sel == 0)
		 bitout = i0;
	else
		 bitout = i1; 
	end

endmodule

