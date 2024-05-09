/************************************************************************
Avalon-MM Interface VGA Text mode display

Modified for DE2-115 board

Register Map:
0x000-0x0257 : VRAM, 80x30 (2400 byte, 600 word) raster order (first column then row)
0x258        : control register

VRAM Format:
X->
[ 31  30-24][ 23  22-16][ 15  14-8 ][ 7    6-0 ]
[IV3][CODE3][IV2][CODE2][IV1][CODE1][IV0][CODE0]

IVn = Draw inverse glyph
CODEn = Glyph code from IBM codepage 437

Control Register Format:
[[31-25][24-21][20-17][16-13][ 12-9][ 8-5 ][ 4-1 ][   0    ] 
[[RSVD ][FGD_R][FGD_G][FGD_B][BKG_R][BKG_G][BKG_B][RESERVED]

VSYNC signal = bit which flips on every Vsync (time for new frame), used to synchronize software
BKG_R/G/B = Background color, flipped with foreground when IVn bit is set
FGD_R/G/B = Foreground color, flipped with background when Inv bit is set

************************************************************************/
`define NUM_REGS 601 //80*30 characters / 4 characters per register
`define CTRL_REG 600 //index of control register

module vga_text_avl_interface (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,					// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  logic [9:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs,					// VGA HS/VS
	output logic sync, blank, pixel_clk		// Required by DE2-115 video encoder
);

	logic [31:0] LOCAL_REG       [`NUM_REGS]; // Registers

	//put other local variables here
	logic [10:0] addr;
	logic [7:0] data;
	logic [31:0] Row, Col, vram_addr_chara, vram_addr_word, letter_id;
	logic [31:0] temp [7:0];

	logic [9:0] DrawX, DrawY;
	logic [7:0] letter;
	logic [6:0] ASCII;

	logic [3:0] FGD_R, FGD_G, FGD_B;
    logic [3:0] BKG_R, BKG_G, BKG_B;

	// assign temp1 = letter_id*8+6;
	// assign temp2 = letter_id*8+7;
	// assign temp3 = letter_id*8;


	//Declare submodules..e.g. VGA controller, ROMS, etc
	vga_controller vga_controller_instance(
		.Clk(CLK), .Reset(RESET), .hs(hs), .vs(vs), .pixel_clk(pixel_clk), .blank(blank), 
		.sync(sync), .DrawX(DrawX), .DrawY(DrawY)
	);
	
	font_rom font_rom_instance(.addr(addr), .data(data));
	
	//vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));

	color_mapper color_mapper_instance(
		.*,
		.is_font(is_font), .inverse(inverse),
		.VGA_R(red), .VGA_G(green), .VGA_B(blue)
	);
	
	// Read and write from AVL interface to register block, note that READ waitstate = 1, so this should be in always_ff
	always_ff @(posedge CLK) begin
		if (AVL_WRITE && AVL_CS) begin
			if (AVL_BYTE_EN[0]) LOCAL_REG[AVL_ADDR][7:0] <= AVL_WRITEDATA[7:0];
			if (AVL_BYTE_EN[1]) LOCAL_REG[AVL_ADDR][15:8] <= AVL_WRITEDATA[15:8];
			if (AVL_BYTE_EN[2]) LOCAL_REG[AVL_ADDR][23:16] <= AVL_WRITEDATA[23:16];
			if (AVL_BYTE_EN[3]) LOCAL_REG[AVL_ADDR][31:24] <= AVL_WRITEDATA[31:24];
		end
		if (AVL_READ && AVL_CS) begin
			AVL_READDATA <= LOCAL_REG[AVL_ADDR];
		end
	end


	//handle drawing (may either be combinational or sequential - or both).
	always_comb 
	begin
			// step1: Use DrawX and DrawY to get proper address in VRAM
			// VRAM address is word address
			Row = DrawY/16;
			Col = DrawX/8;
			vram_addr_chara = Row*80+Col;
			vram_addr_word = vram_addr_chara/4;
			letter_id = vram_addr_chara%4; //character = letter3, letter2, letter1, letter0; 
			
			// step2: Look up VRAM to get 8 bits IV (1 bit) && Code (7 bits)
			//ASCII[6:0] = LOCAL_REG[vram_addr_word][temp1: temp3];
			//ASCII[6:0] = LOCAL_REG[vram_addr_word][letter_id*8+6: letter_id*8];
			// for (integer i=letter_id*8; i<letter_id*8+7; i=i+1)
			// 	begin
			// 		ASCII[i-temp3] = LOCAL_REG[vram_addr_word][i];
			// 	end
			//i = 
			temp[7] = letter_id*8+7;
			temp[6] = letter_id*8+6;
			temp[5] = letter_id*8+5;
			temp[4] = letter_id*8+4;
			temp[3] = letter_id*8+3;
			temp[2] = letter_id*8+2;
			temp[1] = letter_id*8+1;
			temp[0] = letter_id*8+0;
			ASCII[6] = LOCAL_REG[vram_addr_word][temp[6]];
			ASCII[5] = LOCAL_REG[vram_addr_word][temp[5]];
			ASCII[4] = LOCAL_REG[vram_addr_word][temp[4]];
			ASCII[3] = LOCAL_REG[vram_addr_word][temp[3]];
			ASCII[2] = LOCAL_REG[vram_addr_word][temp[2]];
			ASCII[1] = LOCAL_REG[vram_addr_word][temp[1]];
			ASCII[0] = LOCAL_REG[vram_addr_word][temp[0]];
			
			inverse = LOCAL_REG[vram_addr_word][temp[7]];

			addr = ASCII*16 + DrawY%16; //input to font_ROM //get dirty data

			is_font = data[7-(DrawX%8)]; //output from font_ROM //input to color_mapper

			// step3: Look up control register to get front & background color
			FGD_R = LOCAL_REG[`CTRL_REG][24:21];
			FGD_G = LOCAL_REG[`CTRL_REG][20:17];
			FGD_B = LOCAL_REG[`CTRL_REG][16:13];

			BKG_R = LOCAL_REG[`CTRL_REG][12:9];
			BKG_G = LOCAL_REG[`CTRL_REG][8:5];
			BKG_B = LOCAL_REG[`CTRL_REG][4:1];

			// step4: Look up font_ROM to get R/G/B
			
	end


endmodule
