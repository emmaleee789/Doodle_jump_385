module ram(
    output logic [31:0] q,
    input [31:0] d,
    input [31:0] write_address, read_address,
    input we, clk
);

    logic [31:0] mem [1300];

    always_ff @ (posedge clk) begin
        if (we)
        mem[write_address] <= d;
        q <= mem[read_address];
    end

endmodule