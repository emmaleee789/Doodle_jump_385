module drawing_engine (
    input Clk, frame_clk, Reset,
    input W, H,
    input [9:0] Doodle_X, Doodle_Y,
    input buffer_using,

    output [9:0] draw_x, draw_y,
    output [7:0] draw_color
);
    logic draw_bg, draw_platform, draw_doodle, frame_done;	
    // logic [10:0] font_addr, img_addr;
	// logic [7:0] font_data, img_data;
    
    // font_rom font_rom_instance(
	// 	.addr(font_addr), .data(font_data)
	// );

	// img_rom img_rom_instance(
	// 	.addr(img_addr), .data(img_data)
	// );
    
    // Detect rising edge of frame_clk
    logic frame_clk_delayed, frame_clk_rising_edge;
	always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end

    always_ff @ (posedge Clk) begin
        if(Reset) begin
            draw_bg <= 0;
            draw_platform <= 0;
            draw_doodle <= 0;
            draw_x <= 0;
            draw_y <= 0;
            draw_color <= 0;
            frame_done <= 0;
        end

        if(frame_clk_rising_edge && frame_done) begin
            frame_done <= 0; //start new frame
            draw_x <= 10;
            draw_y <= 10;
            draw_color <= buffer_using? 8'b00111000: 8'b00001011; //buffer state
        end
        if(frame_clk && !draw_bg && !frame_done) begin
            draw_bg <= 1; //start drawing background
            draw_platform <= 0;
            draw_doodle <= 0;
            draw_x <= 80;
            draw_y <= 0;
            draw_color <= 8'b00111111; //background color
        end
        if(draw_bg) begin
            if(draw_x >= 239) begin
                if(draw_y >= 239) begin
                    draw_bg <= 0; //background done
                    draw_platform <= 1; //start drawing platform
                    draw_x <= 180;
                    draw_y <= 130;
                    draw_color <= 8'b00000111; //platform color
                end
                else begin
                    draw_x <= 80;
                    draw_y <= draw_y + 1;
                end
            end
            else begin
                draw_x <= draw_x + 1;
            end
        end
        if(draw_platform) begin
            draw_platform <= 0; //platform done
            draw_doodle <= 1; //start drawing doodle
            draw_x <= Doodle_X;
            draw_y <= Doodle_Y;
            draw_color <= 8'b00101100; //doodle color
        end
        if(draw_doodle) begin
            if(draw_x >= Doodle_X+6) begin
                if(draw_y >= Doodle_Y+8) begin
                    draw_doodle <= 0;
                    // draw_x = 1'bZ;
                    // draw_y = 1'bZ;
                    frame_done <= 1; //end of frame
                end
                else begin
                    draw_x <= Doodle_X;
                    draw_y <= draw_y + 1;
                end
            end
            else begin
                draw_x <= draw_x + 1;    
            end
        end


    end //always_ff

endmodule


