module logic_ben(
    input logic [2:0] IR11to9, 
    input logic [2:0] nzp_num,
    output logic logic_out
    //output logic PC_mux
);
    logic [2:0] res;
    assign res = IR11to9 & nzp_num;
    
    always_comb
    begin
        if (res == 3'b000)//(IR11to9[2] & nzp_num[2] == 0) && (IR11to9[1] & nzp_num[1] == 0) && (IR11to9[0] & nzp_num[0] == 0))
            logic_out = 1'b0;         
        else 
			logic_out = 1'b1;
    end
endmodule


module logic_nzp(
    input logic [15:0] bus,
    output logic [2:0] nzp_in
);
    always_comb
    begin
        if (bus == {16'h0000})
            nzp_in = 3'b010;
        else if (bus[15] == 1)
            nzp_in = 3'b100;
        else
            nzp_in = 3'b001;
    end
endmodule


module FullAdder16bit (
    input signed [15:0] a, b, // 16-bit signed inputs
    output signed [15:0] sum // 16-bit signed output
    // output cout // Carry-out
);
    wire [15:0] sum_temp;
    wire [15:0] carry_temp;
    assign sum_temp = a + b;
    assign sum = sum_temp;
    assign cout = (sum_temp[15] != sum_temp[14]); // Carry-out generated if MSB changes
endmodule

//RegFile moved to register.sv