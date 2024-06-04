module drawing_engine #(
    parameter [9:0] W = 640, 
    parameter [9:0] H = 480,
    parameter [9:0] X_min = 140, 
    parameter [9:0] X_max = 499
) (
    input Clk, frame_clk, Reset,
    input [7:0] state,
    input [1:0] frame_clk_edge,
    input buffer_using, wr_en,

    input [9:0] Doodle_X, Doodle_Y,
    input logic doodle_facing,
    input [9:0] Platform_X [0:7],
    input [9:0] Platform_Y [0:7],
    input [7:0] platform_size,

    output [9:0] draw_x, draw_y,
    output [7:0] draw_color
);
    logic [7:0] draw_state = 0;
    // logic draw_bg1, draw_bg2, draw_platform, draw_doodle, draw_buffer, draw_spring;
    logic frame_done = 1, frame_start, next_draw;
    int draw_platform_idx = 0;

    int x, y;
    logic [15:0] basic_doodle_address;
    assign x = draw_x - Doodle_X;
    assign y = draw_y - Doodle_Y;
    //assign basic_doodle_address = y*32 + x +2;
    
    logic [7:0] basic_doodle_color;
    //int basic_doodle_color = 186;


    img_basic_doodle img_basic_doodle_instance (
        .read_address(basic_doodle_address),
        .Clk(Clk),
        .data_Out(basic_doodle_color)
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
                        draw_color <= 8'd153; //#afd7ff
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
                8'h03: begin //buffer
                    if(next_draw) begin
                        next_draw <= 0;
                        draw_x <= buffer_using? 50: 52;
                        draw_y <= 35;
                        draw_color <= buffer_using? 8'h09: 8'h0A; //#ff0000 #00ff00 
                    end
                    else begin
                        if(draw_y >= 36) begin
                            next_draw <= 1;
                            draw_state <= 8'h04; //start drawing platform
                        end
                        else 
                            draw_y <= draw_y +1;
                    end
                end
                8'h04: begin //platform
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
                                draw_state <= 8'h05; //start drawing doodle
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
                8'h05: begin //doodle
                    //basic_doodle_address = y*32 + x +3;
                    if(next_draw) begin
                        next_draw <= 0;
                        draw_x <= doodle_facing? Doodle_X: Doodle_X + 31;
                        draw_y <= Doodle_Y;
                        draw_color <= basic_doodle_color; 
                        basic_doodle_address = 2;
                    end
                    else begin
                        if((doodle_facing && draw_x >= Doodle_X + 31)||(~doodle_facing && draw_x <= Doodle_X)) begin
                            if(draw_y >= Doodle_Y + 31) begin
                                draw_state <= 8'h06; 
                                frame_done <= 1; //end of frame
                            end
                            else begin //draw next row
                                draw_x <= doodle_facing? Doodle_X: Doodle_X + 31;
                                draw_y <= draw_y + 1;
                                draw_color <= basic_doodle_color;
                                basic_doodle_address = basic_doodle_address + 1;
                            end
                        end
                        else begin
                            draw_x <= doodle_facing? draw_x + 1: draw_x - 1;
                            draw_color <= basic_doodle_color;
                            basic_doodle_address = basic_doodle_address + 1;
                        end
                    end
                end
                default: begin
                    draw_state <= 8'h00;
                end
            endcase

        end //wr_en

    end //always_ff

endmodule


