module datapath (
    input logic Clk, Reset, Run, Continue,
    input logic GateALU, GateMARMUX, GateMDR, GatePC, 
    input logic MIO_EN,
    input logic LD_IR, LD_MAR, LD_MDR, LD_PC, LD_BEN, LD_CC, LD_REG, LD_LED,
    input logic [1:0] PCMUX, 
    input logic [15:0] MDR_In,
    
    /* newly added in week 2 */
    input logic ADDR1MUX, DRMUX, SR1MUX, SR2MUX, 
    input logic [1:0] ALUK, ADDR2MUX,
    output logic [11:0] LED,

    output logic [15:0] PC, MAR, MDR, IR,
    output logic BEN
);
    /* everything with 16 bits needed to pass through the main bus */
	//logic [15:0] R0_out, R1_out, R2_out, R4_out, R5_out, R7_out;//, R2, R3, R4, R5, R6, R7;
    logic [15:0] bus, PC_next, addr1, addr2, SR1_OUT, SR2_OUT, ALU_out, ALU_B, alu_sum_num;
    logic [15:0] PC_wire, MAR_wire, MDR_wire;
	logic [2:0] nzp_in, nzp_out, DR_out;
    logic [2:0] SR1, SR2;
    logic BEN_in, BEN_out;
    logic [15:0] addr_out;

    assign SR2 = IR[2:0];
    //assign in5 = {10'b0, IR[5:0]};
    //assign in8 = {7'b0, IR[8:0]};
    //assign in10 = {5'b0, IR[10:0]};
    assign PC_next = PC + 1;
    //assign addr_out = addr1 + addr2;

    FullAdder16bit adder16(.a(addr1), .b(addr2), .sum(addr_out));
    FullAdder16bit addersum(.a(SR1_OUT), .b(ALU_B), .sum(alu_sum_num));
	
    //system registers
    Reg PC_reg(.*, .LD_R(LD_PC), .data_in(PC_wire), .data_out(PC));
    Reg MAR_reg(.*, .LD_R(LD_MAR), .data_in(bus), .data_out(MAR));
    Reg MDR_reg(.*, .LD_R(LD_MDR), .data_in(MDR_wire), .data_out(MDR));
    Reg IR_reg(.*, .LD_R(LD_IR), .data_in(bus), .data_out(IR));
    Reg #(.N(12)) led0(.*, .LD_R(LD_LED), .data_in(IR[11:0]), .data_out(LED));

    //mux
    PC_mux pc_mux0(.*, .sel(PCMUX), .Bus_val(bus), .Calc_addr(addr_out), .PC_next(PC_next), 
                        .PC_val(PC_wire)); // TODO in week2
    MDR_mux mdr_mux0(.*, .MIO_EN(MIO_EN), .Bus_val(bus), .MDR_In(MDR_In), .MDRout(MDR_wire));
	bus_mux bus_mux0(.*, .bus(bus), 
        .GateALU(GateALU), .GateMARMUX(GateMARMUX), .GateMDR(GateMDR), .GatePC(GatePC), 
        .ALU(ALU_out), .MDR(MDR), .PC(PC));
                            // TODO in week2

    /* setcc: */
    logic_nzp logic_nzp0(.bus(bus), .nzp_in(nzp_in));
    logic_ben logic_ben0(.IR11to9(IR[11:9]), .nzp_num(nzp_out), .logic_out(BEN_in));
    Reg #(.N(3)) nzp(.*, .LD_R(LD_CC), .data_in(nzp_in), .data_out(nzp_out));
    Reg #(.N(1)) ben(.*, .LD_R(LD_BEN), .data_in(BEN_in), .data_out(BEN));
    
    
    /* Register File: */
    RegFile regfile0(.*, .RegFile_out1(SR1_OUT), .RegFile_out2(SR2_OUT));
    SR1_mux sr1_mux0(.*, .SR1MUX(SR1MUX), .IR(IR), .SR1(SR1));
    SR2_mux sr2_mux0(.*, .SR2_OUT(SR2_OUT), .imm5({ {11{IR[4]}}, IR[4:0] }));
    DR_mux dr_mux0(.*, .DRMUX(DRMUX), .in1(IR[11:9]), .in2(3'b111));

    addr1_mux addr1_mux0(.*);
    addr2_mux addr2_mux0(.*, .in10({ {5{IR[10]}}, IR[10:0] }), .in8({ {7{IR[8]}}, IR[8:0]}), .in5({ {10{IR[5]}}, IR[5:0] }) );

    /* ALU */
    ALU alu0(.*, .ALU_A(SR1_OUT), .ALU_B(ALU_B), .ALU_out(ALU_out), .ALUK(ALUK));


endmodule