`include "SLC3_2.sv"
import SLC3_2::*;

module Reg #(N = 16) (
    input logic Clk, Reset,
    input logic LD_R,
    input logic [N-1:0] data_in,
    output logic [N-1:0] data_out
);
    always_ff @ (posedge Clk)
    begin
        if (Reset)
				data_out <= '0; 
		if (LD_R)
            data_out <= data_in;
			
    end
endmodule


module RegFile(
    input logic LD_REG, Reset, Clk,
    input logic [15:0] bus, 
    input logic [2:0] DR_out, SR1, SR2,
    output logic [15:0] RegFile_out1, RegFile_out2
	//output logic [15:0] R0_out, R1_out, R2_out, R4_out, R5_out, R2, R3, R4, R5, R6, R7
);
	logic [15:0] R0, R1, R2, R3, R4, R5, R6, R7;

    always_ff @ (posedge Clk)
    begin
        if (Reset) begin
            R0 <= 16'b0;
            R1 <= 16'b0;
            R2 <= 16'b0;
            R3 <= 16'b0;
            R4 <= 16'b0;
            R5 <= 16'b0;
            R6 <= 16'b0;
            R7 <= 16'b0;
        end

        if (LD_REG) begin
            case (DR_out)
            3'b000: R0 <= bus;
            3'b001: R1 <= bus;
            3'b010: R2 <= bus;
            3'b011: R3 <= bus;
            3'b100: R4 <= bus;
            3'b101: R5 <= bus;
            3'b110: R6 <= bus;
            3'b111: R7 <= bus;
            default: R7 <= bus;
            endcase
        end
    end

    always_comb
    begin
        case (SR1)
        3'b000: RegFile_out1 = R0;
        3'b001: RegFile_out1 = R1;
        3'b010: RegFile_out1 = R2;
        3'b011: RegFile_out1 = R3;
        3'b100: RegFile_out1 = R4;
        3'b101: RegFile_out1 = R5;
        3'b110: RegFile_out1 = R6;
        3'b111: RegFile_out1 = R7;
        default: RegFile_out1 = R7;
        endcase

        case (SR2)
        3'b000: RegFile_out2 = R0;
        3'b001: RegFile_out2 = R1;
        3'b010: RegFile_out2 = R2;
        3'b011: RegFile_out2 = R3;
        3'b100: RegFile_out2 = R4;
        3'b101: RegFile_out2 = R5;
        3'b110: RegFile_out2 = R6;
        3'b111: RegFile_out2 = R7;
        default: RegFile_out2 = R7;
        endcase

    end

endmodule



// module PCmodule (
//     //.*, .Clk(Clk), .LD_PC(LD_PC), .GatePC(GatePC)
//     input logic Clk, Reset,
//     input logic LD_PC, GatePC, 
//     input logic [1:0] PCMUX,
//     input logic [15:0] bus, 
//     output logic [15:0] PCout
// );
//     /* opJSR(PCoffset11): R7 <- PC; PC <- PC + SEXT(PCoffset11) */
//     //opJSR ldpc(.PCoffset11(2'b01));
//     // mux_4_1 [15:0] PCmux (
//     //     .data_in0(PC+1), .data_in1(), .data_in2(), .data_in3(PC), 
//     //     .sel(PCMUX[1:0]), .data_out(PCout)
//     // );
//     always_ff @ (posedge Clk)
//     begin
//         logic [15:0] PC;
//         PC <= PCout;
//         if (Reset)
//             PCout <= 16'b0;
//         else if (!LD_PC)
//             PCMUX <= 2'b11;
//     end

// endmodule



