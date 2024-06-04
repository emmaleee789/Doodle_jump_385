module drawing_engine #(
    parameter [9:0] W = 640,        // screen width
    parameter [9:0] H = 480,        // screen height
    parameter [9:0] X_min = 140,    // game screen left bound
    parameter [9:0] X_max = 499     // game screen right bound
) (
    //system
    input Clk, Reset,               // system clock and reset
    input frame_clk,                // The clock indicating a new frame (~60Hz)
    input [1:0] frame_clk_edge,     // {previous frame_clk, current frame_clk}
    input [7:0] keycode, state,              // game state {0: start screen, 1: game running, 2: end}
    input buffer_using, wr_en,      // frame buffer using, write enable
    //elements
    input [9:0] Doodle_X, Doodle_Y, // doodle position
    input [3:0] health,             // doodle health
    input logic doodle_facing,      // doodle disrection {0: left, 1: right}
    input [9:0] Platform_X [0:7],   // up to 8 platforms on the screen
    input [9:0] Platform_Y [0:7], 
    input [7:0] platform_size,      // addjustable platform size
    //output to frame buffer
    output [9:0] draw_x, draw_y,    // draw pixel(x,y) to frame
    output [7:0] draw_color         // palette color of pixel
);
    logic [7:0] draw_state = 0;
    logic frame_done = 1, frame_start, next_draw;
    int draw_platform_idx = 0;

    int x, y;
    logic [15:0] basic_doodle_address;
    assign x = draw_x - Doodle_X;
    assign y = draw_y - Doodle_Y;
    //assign basic_doodle_address = y*32 + x +2;
    logic [7:0] basic_doodle_color, holiday_doodle_color, nightmare_doodle_color;
    logic [3:0] doodle_using = 0;
    logic [10:0] font_addr;
    logic [7:0] font_data;


    img_basic_doodle img_basic_doodle_instance (
        .read_address(basic_doodle_address),
        .Clk(Clk),
        .data_Out(basic_doodle_color)
    );

    img_holiday_doodle img_holiday_doodle_instance (
        .read_address(basic_doodle_address),
        .Clk(Clk),
        .data_Out(holiday_doodle_color)
    );
    
    img_nightmare_doodle img_nightmare_doodle_instance (
        .read_address(basic_doodle_address),
        .Clk(Clk),
        .data_Out(nightmare_doodle_color)
    );

    font_rom font_rom_instance (
        .addr(font_addr),
        .data(font_data)
    );
    

    always_ff @ (posedge Clk) begin
        if(Reset) begin
            draw_state <= 8'h00;
            frame_done <= 1;
        end

        if(frame_clk_edge == 2'b01) begin //if(frame_done && frame_clk_edge == 2'b10) begin 
            frame_done <= 0; //start new frame
            next_draw <= 1;
            draw_state <= 8'h01;
            basic_doodle_address = 0;
        end
        // if(!frame_done && frame_clk_edge == 2'b10) begin
        //     frame_done <= 1;
        // end

        if(wr_en && !frame_done) begin
        case(draw_state)
            8'h01: begin //background1
                if(next_draw) begin //first pixel
                    next_draw <= 0;
                    draw_x <= 0;
                    draw_y <= 0;
                    draw_color <= 8'd16; //#304050
                end
                else begin
                    if(draw_x >= W-1) begin
                        if(draw_y >= H-1) begin //background1 done
                            next_draw <= 1;
                            draw_state <= 8'h02;
                        end
                        else begin //draw next row
                            draw_x <= 0;
                            draw_y <= draw_y + 1;
                        end
                    end
                    else if(draw_x == X_min-1) 
                        draw_x <= X_max+1; //right side background
                    else 
                        draw_x <= draw_x + 1; //draw next pixel
                end
            end
            8'h02: begin //background2
                if(next_draw) begin
                    next_draw <= 0;
                    draw_x <= X_min;
                    draw_y <= 0;
                    draw_color <= 230; //#ffffd7 
                end
                else begin
                    if(draw_x >= X_max) begin
                        if(draw_y >= H-1) begin //background2 done
                            next_draw <= 1;
                            draw_state <= 8'h03;
                        end
                        else begin //draw next row
                            draw_x <= X_min;
                            draw_y <= draw_y + 1;
                        end
                    end
                    else 
                        draw_x <= draw_x + 1; //draw next pixel
                end
            end
            8'h03: begin //platform
                if(next_draw) begin 
                    next_draw <= 0;
                    draw_platform_idx = 0;
                    draw_x <= Platform_X[draw_platform_idx];
                    draw_y <= Platform_Y[draw_platform_idx];
                    draw_color <= 8'h46; //#5faf00
                end
                else 
                begin
                    if(draw_x - Platform_X[draw_platform_idx] >= platform_size) begin
                        if (draw_platform_idx >= 7) begin
                            next_draw <= 1;
                            draw_state <= 8'h04; //start drawing doodle
                            basic_doodle_address = 1;
                        end
                        else begin
                            draw_platform_idx <= draw_platform_idx + 1; // move on to draw next platform
                            draw_x <= Platform_X[draw_platform_idx + 1];
                            draw_y <= Platform_Y[draw_platform_idx + 1];
                        end
                    end
                    else 
                        draw_x <= draw_x+1;
                    
                end
            end
            8'h04: begin //doodle
                if(next_draw) begin //first pixel
                    next_draw <= 0;
                    draw_x <= doodle_facing? Doodle_X: Doodle_X + 31;
                    draw_y <= Doodle_Y;
                    basic_doodle_address = 2;
                    //draw_color <= basic_doodle_color; 
                end
                else begin
                    if((doodle_facing && draw_x >= Doodle_X + 31)||(~doodle_facing && draw_x <= Doodle_X)) begin
                        if(draw_y >= Doodle_Y + 31) begin //end
                            next_draw <= 1;
                            draw_state <= 8'h05; 
                        end
                        else begin //draw next row
                            draw_x <= doodle_facing? Doodle_X: Doodle_X + 31;
                            draw_y <= draw_y + 1;
                            //draw_color <= basic_doodle_color;
                            basic_doodle_address = basic_doodle_address + 1;
                        end
                    end
                    else begin
                        draw_x <= doodle_facing? draw_x + 1: draw_x - 1;
                        //draw_color <= basic_doodle_color;
                        basic_doodle_address = basic_doodle_address + 1;
                    end
                end
                case(keycode)
                    8'd30: begin
                        doodle_using <= 0;
                    end
                    8'd31: begin
                        doodle_using <= 1; 
                    end
                    8'd32: begin
                        doodle_using <= 2;
                    end
                    default: begin
                    end
                endcase
                case(doodle_using)
                    0: begin
                        draw_color <= basic_doodle_color;
                    end
                    1: begin
                        draw_color <= holiday_doodle_color;
                    end
                    2: begin
                        draw_color <= nightmare_doodle_color;
                    end
                    default: begin
                        draw_color <= basic_doodle_color;
                    end
                endcase

            end
            8'h05: begin //health
                if(next_draw) begin
                    next_draw <= 0;
                    draw_x <= 10;
                    draw_y <= 220;
                    draw_color <= 8'd0; //
                end
                else begin
                    if(draw_x >= 59) begin
                        if(draw_y >= 229) begin //health done
                            next_draw <= 1;
                            draw_state <= 8'h08; //start drawing function
                        end
                        else begin //draw next row
                            draw_x <= 10;
                            draw_y <= draw_y + 1;
                            draw_color <= health? 8'd154: 8'd1;
                            if(draw_y==228)
                                draw_color <= 8'd0; //#000000
                        end
                    end
                    else begin
                        draw_x <= draw_x + 1; //draw next pixel
                        if(draw_y>220 && draw_y<229)
                            draw_color <= (draw_x-10)/5 < health? 8'd154: 8'd1; //#afff00 #800000
                    end
                end
            end
            8'h08: begin //text "health"
                                // Ensure all logic variables are declared at the module level
                logic [7:0] x_start = 11;
                logic [7:0] y_start = 200;
                logic [7:0] text_length = 6;
                logic [7:0] text_idx;
                logic [6:0] text_buffer [0:5] = '{7'h68, 7'h65, 7'h61, 7'h6c, 7'h74, 7'h68};
                logic [1:0] wait_rom;
                logic move_x;

                if (next_draw) begin // first pixel
                    next_draw <= 0;
                    text_idx <= 0;
                    font_addr <= 16 * text_buffer[0];
                    wait_rom <= 2;
                    draw_x <= x_start;
                    draw_y <= y_start;
                    draw_color <= 8'd15;
                end
                else if (wait_rom) begin
                    wait_rom <= wait_rom - 1;
                end
                else begin
                    if (draw_x >= x_start + 8 * text_idx + 7) begin // end of row
                        if (draw_y >= y_start + 15) begin // end of letter
                            if (text_idx >= text_length - 1) begin // function done
                                wait_rom <= 0;
                                next_draw <= 1;
                                draw_state <= 8'h06;
                            end
                            else begin // draw next letter
                                text_idx <= text_idx + 1;
                                font_addr <= 16 * text_buffer[text_idx + 1];
                                wait_rom <= 2;
                                draw_x <= x_start + 8 * (text_idx + 1);
                                draw_y <= y_start;
                                // draw_color <= 8'h00;
                            end
                        end
                        else begin // draw next row
                            font_addr <= 16 * text_buffer[text_idx] + (draw_y - y_start + 1);
                            wait_rom <= 2;
                            draw_x <= x_start + 8 * text_idx;
                            draw_y <= draw_y + 1;
                        end
                    end
                    else begin // drawing one row
                        if (draw_x == x_start + 8 * text_idx) begin
                            draw_color <= font_data[7] ? 8'd15 : 8'd16;
                            if(move_x) begin
                                draw_x <= draw_x + 1;
                                draw_color <= font_data[6] ? 8'd15 : 8'd16;
                                move_x <= 0;
                            end
                            else begin
                                move_x <= 1;
                            end
                        end
                        else begin
                            draw_x <= draw_x + 1; // draw next pixel
                            draw_color <= font_data[7 - (draw_x - x_start - 8 * text_idx + 1)] ? 8'd15 : 8'd16;
                        end
                    end
                end
            end
            8'h06: begin //buffer
                if(next_draw) begin
                    next_draw <= 0;
                    draw_x <= buffer_using? 311: 313;
                    draw_y <= 27;
                    draw_color <= buffer_using? 8'h9: 8'h10; //#ff0000 #00ff00 
                end
                else begin
                    if(draw_y >= 29) begin
                        next_draw <= 1;
                        draw_state <= 8'h07; //start drawing text
                    end
                    else 
                        draw_y <= draw_y +1;
                end
            end
            8'h07: begin // text "buffer"
                // Ensure all logic variables are declared at the module level
                logic [7:0] x_start = 255;
                logic [7:0] y_start = 20;
                logic [7:0] text_length = 6;
                logic [7:0] text_idx;
                logic [6:0] text_buffer [0:5] = '{7'h62, 7'h75, 7'h66, 7'h66, 7'h65, 7'h72};
                logic [1:0] wait_rom;
                logic move_x;

                if (next_draw) begin // first pixel
                    next_draw <= 0;
                    text_idx <= 0;
                    font_addr <= 16 * text_buffer[0];
                    wait_rom <= 2;
                    draw_x <= x_start;
                    draw_y <= y_start;
                    draw_color <= 8'd15;
                end
                else if (wait_rom) begin
                    wait_rom <= wait_rom - 1;
                end
                else begin
                    if (draw_x >= x_start + 8 * text_idx + 7) begin // end of row
                        if (draw_y >= y_start + 15) begin // end of letter
                            if (text_idx >= text_length - 1) begin // function done
                                wait_rom <= 0;
                                next_draw <= 1;
                                frame_done <= 1; // end of frame
                                // draw_state <= 8'h08;
                            end
                            else begin // draw next letter
                                text_idx <= text_idx + 1;
                                font_addr <= 16 * text_buffer[text_idx + 1];
                                wait_rom <= 2;
                                draw_x <= x_start + 8 * (text_idx + 1);
                                draw_y <= y_start;
                                // draw_color <= 8'h00;
                            end
                        end
                        else begin // draw next row
                            font_addr <= 16 * text_buffer[text_idx] + (draw_y - y_start + 1);
                            wait_rom <= 2;
                            draw_x <= x_start + 8 * text_idx;
                            draw_y <= draw_y + 1;
                        end
                    end
                    else begin // drawing one row
                        if (draw_x == x_start + 8 * text_idx) begin
                            draw_color <= font_data[7] ? 8'd15 : 8'd16;
                            if(move_x) begin
                                draw_x <= draw_x + 1;
                                draw_color <= font_data[6] ? 8'd15 : 8'd16;
                                move_x <= 0;
                            end
                            else begin
                                move_x <= 1;
                            end
                        end
                        else begin
                            draw_x <= draw_x + 1; // draw next pixel
                            draw_color <= font_data[7 - (draw_x - x_start - 8 * text_idx + 1)] ? 8'd15 : 8'd16;
                        end
                    end
                end
            end // function monitor



            default: begin
                draw_state <= 8'h00;
            end
        endcase
        end //wr_en

    end //always_ff

endmodule


