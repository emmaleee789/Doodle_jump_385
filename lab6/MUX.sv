module PC_mux (
    input logic Reset,
    input logic [1:0] sel, // 00: PC_next, 01: Bus_val, 10: Calc_addr
    input logic [15:0] Bus_val, Calc_addr, PC_next,
    output logic [15:0] PC_val
);
    always_comb
    begin
        if (Reset)
            PC_val = {16{1'b0}};
        else if (sel == 0)
            PC_val = PC_next;
        else if (sel == 1)     
            PC_val = Bus_val;
        else if (sel == 2)    
            PC_val = Calc_addr;
        else 
            PC_val = {16{1'bX}};
    end
endmodule


module MDR_mux (
    input logic Reset,
    input logic MIO_EN,
    input logic [15:0] Bus_val, MDR_In,
    output logic [15:0] MDRout
);
    always_comb
    begin
		if (~MIO_EN)
            MDRout = Bus_val;
        else
			MDRout = MDR_In;
    end
endmodule


module bus_mux(
    input logic Reset, GateALU, GateMARMUX, GateMDR, GatePC,
    input logic [15:0] ALU, addr_out, MDR, PC,
    output logic [15:0] bus
);
    always_comb
    begin
        if (Reset)
            bus = {16{1'b0}};
        else if (GateMARMUX)
            bus = addr_out; // TODO in week 2
        else if (GatePC)
            bus = PC;
        else if (GateMDR)
            bus = MDR;
        else if (GateALU)
            bus = ALU;
        else 
            bus = {16{1'b0}};
    end
endmodule


module addr1_mux(
    input logic [15:0] SR1_OUT,
    input logic [15:0] PC, 
    input logic ADDR1MUX, // 0: PC, 1: BaseR
    output logic [15:0] addr1
);
    always_comb
    begin
        case (ADDR1MUX)
            1'b0: addr1 = PC;
            1'b1: addr1 = SR1_OUT;
            default: addr1 = {16{1'bX}};
        endcase
    end
endmodule


module addr2_mux(
    input logic [15:0] in10, in8, in5,
    input logic [1:0] ADDR2MUX, // 00: 0, 01: offst6, 10: PCoffset9, 11: PCoffset11
    output logic [15:0] addr2
);
    always_comb
    begin
        case (ADDR2MUX)
            2'b00: addr2 = 16'b0;
            2'b01: addr2 = in5;
            2'b10: addr2 = in8;
            2'b11: addr2 = in10;
            default: addr2 = {16{1'bX}};
        endcase
    end
endmodule


module SR1_mux(
    input logic [15:0] IR,
    //input logic [2:0] IR_11to9, IR_8to6,
    input logic SR1MUX, // 0: IR[11:9], 1: IR[8:6]
    output logic [2:0] SR1
);
    always_comb
    begin
        case (SR1MUX)
            1'b0: SR1 = IR[11:9];
            1'b1: SR1 = IR[8:6];
            default: SR1 = {3{1'bX}};
        endcase
    end
endmodule


module SR2_mux(
    input logic [15:0] SR2_OUT, imm5,
    input logic SR2MUX,
    output logic [15:0] ALU_B
);
    always_comb
    begin
        case (SR2MUX)
            1'b0: ALU_B = SR2_OUT;
            1'b1: ALU_B = imm5;
            default: ALU_B = {16{1'bX}};
        endcase
    end
endmodule


module DR_mux(
    input logic [2:0] in1, in2,
    input logic DRMUX, //
    output logic [2:0] DR_out
);
    always_comb
    begin
        if (DRMUX == 0)
            DR_out = in1; //IR[11:9]
        else
            DR_out = in2; //111
        
    end
endmodule


module ALU(
    input logic[1:0] ALUK, //00: ADD, 01: AND, 10: NOT, 11: PASSA
    input logic[15:0] ALU_A, ALU_B,
    input logic [15:0] alu_sum_num,
    output logic [15:0] ALU_out
);
    always_comb
    begin
        case (ALUK)
        2'b00: ALU_out = alu_sum_num;
        2'b01: ALU_out = ALU_A & ALU_B;
        2'b10: ALU_out = ~ALU_A;
        2'b11: ALU_out = ALU_A;
        default: ALU_out = {16{1'bX}};
        endcase
        
    end
endmodule


//module PC_mux (
//    input logic Reset,
//    input logic [1:0] sel,
//    input logic [15:0] Bus_val, Calc_addr, PC_next,
//    output logic [15:0] PC_val
//);
//    always_comb
//    begin
//        case (sel)
//		  2'b00: PC_val = PC_next;
//		  2'b01: PC_val = Bus_val;
//		  2'b10: PC_val = Calc_addr;
//        default: PC_val = {16{1'bX}};
//		  endcase
//    end
//endmodule


//module bus_mux(
//    input logic Reset, 
//	 input logic [3:0] sel,
//    input logic [15:0] ALU, MARMUX, MDR, PC,
//    output logic [15:0] bus
//);
//    always_comb
//    begin
//        case (sel)
//		  4'b1000: bus = ALU;
//		  4'b0100: bus = 16'h0000;
//		  4'b0010: bus = MDR;
//		  4'b0001: bus = PC;
//		  default: bus = 16'h0000;
//		  endcase
//    end
//endmodule


// module mux_4_1(
//     input data_in0, data_in1, data_in2, data_in3,
//     input [1:0] sel,
//     output reg data_out
// );
// always @ (*) begin
//     case (sel)
//         2'b00: data_out = data_in[0];
//         2'b01: data_out = data_in[1];
//         2'b10: data_out = data_in[2];
//         2'b11: data_out = data_in[3];
//         default: data_out = data_in[0]; // 默认情况，选择第一个输入
//     endcase
// end

// endmodule