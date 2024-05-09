module drawing_engine (
    input Clk, frame_clk, Reset,
    input [1:0] frame_clk_edge,
    input W, H,
    input [9:0] Doodle_X, Doodle_Y,
    input buffer_using, wr_en,

    output [9:0] draw_x, draw_y,
    output [7:0] draw_color
);
    logic draw_bg, draw_platform, draw_doodle, draw_buffer;
    logic frame_done, frame_start;
    
    // logic [10:0] font_addr, img_addr;
    // logic [7:0] font_data, img_data;
    
    // font_rom font_rom_instance(
    //     .addr(font_addr), .data(font_data)
    // );

    // img_rom img_rom_instance(
    //     .addr(img_addr), .data(img_data)
    // );
    

    always_ff @ (posedge Clk) begin
        if(Reset) begin
            draw_bg <= 0;
            draw_platform <= 0;
            draw_doodle <= 0;
            draw_x <= 0;
            draw_y <= 0;
            draw_color <= 0;
            frame_done <= 1;
        end
        if(frame_clk_edge==2'b01) begin
            frame_done <= 0; //start new frame
            //frame_start <= 1;
            draw_buffer <= 1;
            draw_x <= buffer_using? 270: 272;
            draw_y <= 15;
            draw_color <= buffer_using? 8'b00110100: 8'b00001101; //buffer state 红/绿
        end
        if(wr_en) begin
            if(draw_buffer) begin
                draw_buffer <= 0;
                draw_bg <= 1; //start drawing background
                draw_x <= 80;
                draw_y <= 1;
                draw_color <= 8'b00111111; //background color
            end
            if(draw_bg) begin
                if(draw_x >= 239) begin
                    if(draw_y >= 238) begin 
                        draw_bg <= 0; //background done
                        draw_platform <= 1; //start drawing platform
                        draw_x <= 180;
                        draw_y <= 130;
                        draw_color <= 8'b00000111; //platform color 蓝色
                    end
                    else begin //draw next row
                        draw_x <= 80;
                        draw_y <= draw_y + 1;
                    end
                end
                else begin //draw next pixel
                    draw_x <= draw_x + 1;
                end
            end
            if(draw_platform) begin
                if(draw_x >=200) begin
                    draw_platform <= 0; //platform done
                    draw_doodle <= 1; //start drawing doodle
                    draw_x <= Doodle_X;
                    draw_y <= Doodle_Y;
                    draw_color <= 8'b00101100; //doodle color 黄绿色
                end
                else draw_x <= draw_x+1;
            end
            if(draw_doodle) begin
                if(draw_x >= Doodle_X+9) begin
                    if(draw_y >= Doodle_Y+9) begin
                        draw_doodle <= 0;
                        // draw_x = 1'bZ;
                        // draw_y = 1'bZ;
                        frame_done <= 1; //end of frame
                    end
                    else begin //draw next row
                        draw_x <= Doodle_X;
                        draw_y <= draw_y + 1;
                    end
                end
                else begin
                    draw_x <= draw_x + 1;
                end
            end
        end

    end //always_ff

endmodule


