`default_nettype none

module frame_vram2
#(
    parameter WIDHT           = 320,     //! Data Port Width
    parameter HEIGHT          = 240,     //! Data Port Width
    parameter DW              = 8,       //! Data Port Width
    // Used as attributes, not values
    parameter rStyle          = "no_rw_check",
    parameter rwAddrCollision = "auto"
) (
    // Port A (Write)
    input  logic          wr_clk,  //! Write Clock
    input  logic          wr_en,   //! Write Enable
    input  logic [AW-1:0] wr_addr, //! Write Address
    input  logic [DW-1:0] wr_d,    //! Write Data Bus
    // Port B (Read)
    input  logic          rd_clk,  //! Read Clock
    input  logic wr2_en,
    input  logic [AW-1:0] rd_addr, //! Read Address
    input  logic wr2_d,
    output logic [DW-1:0] rd_q     //! Read Data Bus
);

    initial begin
        rd_q = {DW{1'b0}};
    end

    // Non-user-definable parameters
    localparam AW        = $clog2(WIDHT * HEIGHT); //! Address Port Width

    // Set the ram style to control implementation.
    (* ramstyle          = rStyle *)           // Quartus
    (* ram_style         = rStyle *)           // Vivado
    (* rw_addr_collision = rwAddrCollision *)  // Vivado
    logic [DW-1:0] ram[0:((WIDHT * HEIGHT)-1)]; //! Register to Hold Data

    // Write to Memory on Port A
    always @(posedge wr_clk) begin : WriteToMem
        if(wr_en) begin
            ram[wr_addr] <= wr_d;
        end
    end

    // Read from Memory on Port B
    always @(posedge rd_clk) begin : ReadFromMem
        if(wr2_en) begin
            ram[rd_addr] <= wr2_d;
        end
        rd_q <= ram[rd_addr];
    end

endmodule
