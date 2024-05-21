/************************************************************************
Avalon-MM Interface VGA Text mode display

Modified for DE2-115 board
************************************************************************/

module vga_screen #(
	parameter W = 320,
	parameter H = 240
) (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	input logic RESET,	// Avalon Reset Input
	
	input logic [7:0] keycode, //

	output logic [7:0] state, // Game state
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [7:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs,					// VGA HS/VS
	output logic sync, blank, pixel_clk		// Required by DE2-115 video encoder
);
	localparam DW = 8; //data_width
	localparam logic [9:0] X_min = W*7.0/32; //140
	localparam logic [9:0] X_max = W*25.0/32 -1; //499

	logic [9:0] DrawX, DrawY;	

	logic hblank_ah, vblank_ah, frame_clk;
    logic [1:0] frame_clk_edge;
	logic buffer_using, wr_en;
	//logic [7:0] state;

	logic [9:0] draw_x, draw_y;
	logic [7:0] draw_color, palette_in;

	logic [9:0] Doodle_X, Doodle_Y, health;
	logic [9:0] Platform_X [0:7];
	logic [9:0] Platform_Y [0:7];
	logic [7:0] platform_size = 30;
	

	vga_controller vga_controller_instance (
		.Clk(CLK), .Reset(RESET), .hs(hblank_ah), .vs(vblank_ah), 
		.pixel_clk(pixel_clk), 
		.blank(blank), 
		.sync(sync), .DrawX(DrawX), .DrawY(DrawY)
	);
	assign frame_clk = vblank_ah;   
    always_ff @ (posedge CLK) begin // Detect rising edge of frame_clk
        frame_clk_edge = {frame_clk_edge[0], frame_clk};
    end

	// game process ---------------------------------------------------------------
	game_state game_state_instance (
		.Clk(CLK), .Reset(RESET), 
		.frame_clk(frame_clk), .frame_clk_edge(frame_clk_edge),
		.keycode(keycode),
		//output
		.state(state),
		.platform_size(platform_size)
	);

	doodle #(
		.W(W), .H(H), .X_min(X_min), .X_max(X_max)
	) doodle_instance (
		.*,
		.Clk(CLK), .Reset(RESET), 
		.frame_clk(frame_clk), .frame_clk_edge(frame_clk_edge),
		.keycode(keycode),
		.Doodle_X_out(Doodle_X), .Doodle_Y_out(Doodle_Y)
	);

	platform #(
		.W(W), .H(H), .X_min(X_min), .X_max(X_max)
	) platform_instance (
		.*,
		.Clk(CLK), .Reset(RESET), .frame_clk(frame_clk),
		.Platform_X_out(Platform_X), .Platform_Y_out(Platform_Y),
		.platform_size(platform_size)
	);

	// graphics --------------------------------------------------------------
	drawing_engine #(
		.W(W), .H(H), .X_min(X_min), .X_max(X_max)
	) drawing_instance (
		//.*,
		.Clk(CLK), .Reset(RESET),
		.state(state),
		.frame_clk(frame_clk), .frame_clk_edge(frame_clk_edge),
		.buffer_using(buffer_using), .wr_en(1), //.wr_en(wr_en),

		//.Doodle_X(W/2), .Doodle_Y(H*2/3), //centered doodle
		.Doodle_X(Doodle_X), .Doodle_Y(Doodle_Y),
		.Platform_X(Platform_X), .Platform_Y(Platform_Y),
		.platform_size(platform_size),

		//output
		.draw_x(draw_x), .draw_y(draw_y),
		.draw_color(draw_color)
	);

	framebuffer2 #(
		//.WIDHT(W), .HEIGHT(H), 
		.WIDTH(320), .HEIGHT(240), 
		.BUFF2X(1), //double buffering enabled
		.DW(8)
	) framebuffer_instance (
		.clk_pix(CLK), .clk_vga(pixel_clk), .clk_sys(),

		//input
		.x(draw_x), .y(draw_y), .rgb_in(draw_color), 
		//.hblank_in(0), .vblank_in(0),
		.hblank_in(~hblank_ah), .vblank_in(~vblank_ah), 

		//output
		.rgb_out(palette_in), 
		.hsync_out(), .vsync_out(), .blank_out(), 
		//.rotate(0), .disable_db(0), .odd_line_out(),

		//state signal
		.buffer_using(buffer_using), .wr_en(wr_en)
	);
	assign hs = hblank_ah;
	assign vs = vblank_ah;

	palette_mapper palette_mapper_instance(
		.Clk(CLK),
		.draw_color(palette_in), 
		.VGA_R(red), .VGA_G(green), .VGA_B(blue) 
	);
	

endmodule
