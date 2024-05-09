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

module vga_screen (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	// input  logic AVL_READ,					// Avalon-MM Read
	// input  logic AVL_WRITE,					// Avalon-MM Write
	// input  logic AVL_CS,					// Avalon-MM Chip Select
	// input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	// input  logic [11:0] AVL_ADDR,			// Avalon-MM Address
	// input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	// output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	input logic [7:0] keycode, //
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs,					// VGA HS/VS
	output logic sync, blank, pixel_clk		// Required by DE2-115 video encoder


);
	//put other local variables here
	parameter [9:0] W = 320;
	parameter [9:0] H = 240;
	parameter [9:0] data_width = 8;

	logic [9:0] DrawX, DrawY;	

	logic hblank_ah, vblank_ah, frame_clk;

	logic [9:0] draw_x, draw_y;
	logic [7:0] draw_color, palette_in;
	logic [9:0] Doodle_X, Doodle_Y;
	logic buffer_using, wr_en;

	assign frame_clk = vblank_ah;   
	 // Detect rising edge of frame_clk
    logic [1:0] frame_clk_edge;
        always_ff @ (posedge CLK) begin
        frame_clk_edge = {frame_clk_edge[0], frame_clk};
    end

	//Declare submodules..e.g. VGA controller, ROMS, etc
	vga_controller vga_controller_instance(
		.Clk(CLK), .Reset(RESET), .hs(hblank_ah), .vs(vblank_ah), 
		.pixel_clk(pixel_clk), 
		.blank(blank), 
		.sync(sync), .DrawX(DrawX), .DrawY(DrawY)
	);
	
	doodle doodle_instance(
		.Clk(CLK), .Reset(RESET), 
		.frame_clk(frame_clk), .frame_clk_edge(frame_clk_edge),
		.keycode(keycode),
		.Doodle_X_out(Doodle_X), .Doodle_Y_out(Doodle_Y)
	);

	drawing_engine drawing_instance(
		.*,
		.Clk(CLK), .Reset(RESET),
		.frame_clk(frame_clk), .frame_clk_edge(frame_clk_edge),
		.W(W), .H(H),
		.Doodle_X(Doodle_X), .Doodle_Y(Doodle_Y), 
		//.Doodle_X(W/2), .Doodle_Y(H*2/3), //centered doodle
		//output
		.draw_x(draw_x), .draw_y(draw_y),
		.draw_color(draw_color)
	);

	framebuffer #(
		//.WIDHT(W), .HEIGHT(H), .DW(8),
		.BUFF2X(1) //double buffering enabled
	) 
	framebuffer_instance (
		.clk_pix(CLK), .clk_vga(pixel_clk),
		//input
		.x(draw_x), .y(draw_y), 
		.rgb_in(draw_color), 
		//.hblank_in(0), 
		//.vblank_in(0),
		.hblank_in(~hblank_ah), 
		.vblank_in(~vblank_ah),
		//output
		.rgb_out(palette_in), 
		.buffer_using(buffer_using), .wr_en(wr_en),
		.hsync_out(hs), .vsync_out(vs), .blank_out(),
	);
	//assign hs = hblank_ah;
	//assign vs = vblank_ah;

	palette_mapper palette_mapper_instance(
		.draw_color(palette_in),
		.VGA_R(red), .VGA_G(green), .VGA_B(blue) 
	);
	// assign red= 4'b0000;
	// assign green= 4'b0000;
	// assign blue= 4'b1101;

endmodule
