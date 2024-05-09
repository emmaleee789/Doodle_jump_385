module full_adder (
	input A, B, c_in,
	output logic Sum,
	output logic CO
	);
	assign Sum=A^B^c_in;
	assign CO=(A&B)|(B&c_in)|(A&c_in);
	
endmodule
