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
	input  logic [11:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs,					// VGA HS/VS
	output logic sync, blank, pixel_clk		// Required by DE2-115 video encoder
);

	//logic [31:0] LOCAL_REG       [`NUM_REGS]; // Registers
	logic [31:0] PALETTE_REG     [8]; // Palette registers

	//put other local variables here
	logic [10:0] addr;
	logic [7:0] data, data_out;
	logic [31:0] Row, Col, vram_addr_chara, vram_addr_word, letter_id;
	logic [31:0] temp [7:0];
	logic [31:0] ram_in, ram_out, ram_out_a, REG_READDATA;
	logic ram_we;
	logic [31:0] write_address, read_address;
	logic [3:0]  red_reg, green_reg, blue_reg;

	logic [9:0] DrawX, DrawY;	
	logic [7:0] DrawChar;
	logic [3:0] DrawFGD_IDX, DrawBKG_IDX;
	logic [7:0] letter;
	logic [6:0] ASCII;
	logic inverse, is_font;

	logic [12:0] palette[16];
	logic [11:0] FGD, BKG;




	//Declare submodules..e.g. VGA controller, ROMS, etc
	vga_controller vga_controller_instance(
		.Clk(CLK), .Reset(RESET), .hs(hs), .vs(vs), 
		.pixel_clk(pixel_clk), .blank(blank), 
		.sync(sync), .DrawX(DrawX), .DrawY(DrawY)
	);
	
	font_rom font_rom_instance(.addr(addr), .data(data));
	
	// color_mapper color_mapper_instance(
	// 	.*,
	// 	.is_font(is_font), .inverse(inverse),
	// 	.VGA_R(red), .VGA_G(green), .VGA_B(blue) 
	// 	// .VGA_R(red_reg), .VGA_G(green_reg), .VGA_B(blue_reg)
	// );

	assign red= 4'b1111;
	assign green= 4'b1000;
	assign blue= 4'b1101;


	OCM_2 on_chip_mem0 (
		.address_a(AVL_ADDR[10:0]), // port a for AVL API; read and write
		.address_b(read_address), // port b for VGA screening; read only
		.byteena_a(AVL_BYTE_EN),
		.byteena_b(4'b1111),
		.clock(CLK),
		.data_a(AVL_WRITEDATA),
		.data_b(),
		.rden_a(AVL_READ && AVL_CS),
		.rden_b(1'b1),
		.wren_a(AVL_WRITE && AVL_CS & ~AVL_ADDR[11]),
		.wren_b(1'b0),
		.q_a(ram_out_a),
		.q_b(ram_out)
	);
	
	// Read and write from AVL interface to register block, note that READ waitstate = 1, so this should be in always_ff
	always_ff @(posedge CLK) begin
		if (RESET) begin
            PALETTE_REG <= '{default:0};
        end

		if(AVL_ADDR[11])
			if (AVL_WRITE && AVL_CS) begin
				
				PALETTE_REG[AVL_ADDR[2:0]][7:0] <= AVL_BYTE_EN[0] ? AVL_WRITEDATA[7:0] : PALETTE_REG[AVL_ADDR[2:0]][7:0];
				PALETTE_REG[AVL_ADDR[2:0]][15:8] <= AVL_BYTE_EN[1] ? AVL_WRITEDATA[15:8] : PALETTE_REG[AVL_ADDR[2:0]][15:8];
				PALETTE_REG[AVL_ADDR[2:0]][23:16] <= AVL_BYTE_EN[2] ? AVL_WRITEDATA[23:16] : PALETTE_REG[AVL_ADDR[2:0]][23:16];
				PALETTE_REG[AVL_ADDR[2:0]][31:24] <= AVL_BYTE_EN[3] ? AVL_WRITEDATA[31:24] : PALETTE_REG[AVL_ADDR[2:0]][31:24];
			end
			else if (AVL_READ && AVL_CS) begin
				REG_READDATA <= PALETTE_REG[AVL_ADDR[2:0]];
			end
	end

    always_comb begin
        if (AVL_ADDR[11]) begin
            AVL_READDATA = REG_READDATA;
        end
        else begin
            AVL_READDATA = ram_out_a;
        end
    end

	
	assign read_address = vram_addr_word;

	//handle drawing (may either be combinational or sequential - or both).
	always_comb 
	begin
		// step1: Use DrawX and DrawY to get proper address in VRAM
		// VRAM address is word address
		Row = DrawY/16;
		Col = DrawX/8;
		vram_addr_chara = Row*80+Col;
		vram_addr_word = vram_addr_chara/2;
		letter_id = vram_addr_chara%2; //word = letter1, letter0; 
		
		// step2: Look up VRAM to get 8 bits IV (1 bit) && Code (7 bits)

        if (letter_id == 0)
        begin
            DrawChar = ram_out[15:8];
            DrawFGD_IDX = ram_out[7:4];
            DrawBKG_IDX = ram_out[3:0];
        end
        else
        begin
            DrawChar = ram_out[31:24];
            DrawFGD_IDX = ram_out[23:20];
            DrawBKG_IDX = ram_out[19:16];
        end
			
	end

	assign inverse = DrawChar[7]; 
	assign ASCII = DrawChar[6:0];


	assign addr = ASCII*16 + DrawY%16; //input to font_ROM //get dirty data

	assign is_font = data[7-(DrawX%8)]; //output from font_ROM //input to color_mapper

	// step3: Look up front & background color
	always_comb begin
        // If odd, choose upper bits
        if (DrawFGD_IDX[0])
        begin
            FGD = PALETTE_REG[DrawFGD_IDX[3:1]][24:13];
        end
        // If even, choose lower bits
        else
        begin
            FGD = PALETTE_REG[DrawFGD_IDX[3:1]][12:1];
        end
            
        // If odd
        if (DrawBKG_IDX[0])
        begin
            BKG = PALETTE_REG[DrawBKG_IDX[3:1]][24:13];
        end
        else
        begin
            BKG = PALETTE_REG[DrawBKG_IDX[3:1]][12:1];
        end
    end
	


endmodule
