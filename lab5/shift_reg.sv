module shift_reg (
    input logic X, Reset, Clk,
    input logic[7:0] A, B, S,
    input logic Clr_Ld, Shift, Add, Sub, Clr_A,
    output logic X2, 
    output logic [7:0] A2, B2
);

    logic tempX;
	assign X2 = tempX;
    // logic [7:0] tempA, tempB;

    always_ff @ (posedge Clk)
    begin
        if (Clr_Ld) begin
            tempX <= 1'b0;
            A2 <= 8'b0;
            B2 <= S;
			// $display("load_B");
        end 
		  if (Clr_A) begin ////
            tempX <= 1'b0; 
            A2 <= 8'b0;
			end
        else if (Reset) begin    
            tempX <= 1'b0;
            A2 <= 8'b0;
            B2 <= 8'b0;
        end 
        else if (Add | Sub) begin
            tempX <= X;
            A2 <= A;
            B2 <= B;
        end 
        if (Shift)
            begin
                A2 <= {tempX, A[7:1]};
				B2 <= {A[0], B[7:1]};
            end
    end
endmodule


module flip (
	input logic Clk, D,
	output logic Q
);
	always_ff @ (posedge Clk) begin
		Q <= D;
	end
endmodule
