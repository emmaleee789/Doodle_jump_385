module drawing_engine #(
    parameter [9:0] W = 640, 
    parameter [9:0] H = 480,
    parameter [9:0] Xmin = 140, 
    parameter [9:0] Xmax = 499
) (
    input Clk, frame_clk, Reset,
    input [7:0] state,
    input [1:0] frame_clk_edge,

    input buffer_using, wr_en,
    input [9:0] Doodle_X, Doodle_Y,
    input [9:0] Platform_X [0:7],
    input [9:0] Platform_Y [0:7],

    output [9:0] draw_x, draw_y,
    output [7:0] draw_color
);
    parameter [6:0] platform_size = 20;

    logic draw_bg1, draw_bg2, draw_platform, draw_doodle, draw_buffer, draw_spring;
    logic frame_done, frame_start, next_draw;
    int draw_platform_idx = 0;

    logic [9:0] x, y;
    logic [15:0] basic_doodle_address;
    assign x = draw_x - Doodle_X;
    assign y = draw_y - Doodle_Y;
    assign basic_doodle_address = y*32 + x;
    
    logic [7:0] basic_doodle_color;
    //int basic_doodle_color = 186;


    img_basic_doodle img_basic_doodle_instance (
        .read_address(basic_doodle_address),
        .Clk(Clk),
        .data_Out(basic_doodle_color)
    );
    

    always_ff @ (posedge Clk) begin
        if(Reset) begin
            draw_bg1 <= 0;
            draw_bg2 <= 0;
            draw_platform <= 0;
            draw_doodle <= 0;
            draw_x <= 0;
            draw_y <= 0;
            draw_color <= 0;
            frame_done <= 1;
        end
        if(frame_clk_edge==2'b01) begin
            frame_done <= 0; //start new frame
            next_draw <= 1;
            draw_bg1 <= 1;
        end

        
        if(wr_en) begin
            if(draw_bg1) begin //background1
                if(next_draw) begin
                    next_draw <= 0;
                    draw_x <= 0;
                    draw_y <= 0;
                    draw_color <= 8'h11; //#00005f
                end
                else begin
                    if(draw_x >= W-1) begin
                        if(draw_y >= H-1) begin //background1 done
                            draw_bg1 <= 0;
                            next_draw <= 1;
                            draw_bg2 <= 1;
                        end
                        else begin //draw next row
                            draw_x <= 0;
                            draw_y <= draw_y + 1;
                        end
                    end
                    else if(draw_x == Xmin-1) 
                        draw_x <= 500; //right side background
                    else 
                        draw_x <= draw_x + 1; //draw next pixel
                end
            end

            if(draw_bg2) begin //background2
                if(next_draw) begin
                    next_draw <= 0;
                    draw_x <= Xmin;
                    draw_y <= 0;
                    draw_color <= 230; //#ffffd7 
                end
                else begin
                    if(draw_x >= Xmax) begin
                        if(draw_y >= H-1) begin //background2 done
                            draw_bg2 <= 0;
                            next_draw <= 1;
                            draw_buffer <= 1;
                        end
                        else begin //draw next row
                            draw_x <= Xmin;
                            draw_y <= draw_y + 1;
                        end
                    end
                    else 
                        draw_x <= draw_x + 1; //draw next pixel
                end
            end

            if(draw_buffer) begin
                if(next_draw) begin
                    next_draw <= 0;
                    draw_x <= buffer_using? 70: 72;
                    draw_y <= 75;
                    draw_color <= buffer_using? 8'h09: 8'h0A; //#ff0000 #00ff00 
                end
                else begin
                    draw_buffer <= 0;
                    next_draw <= 1;
                    draw_platform <= 1; //start drawing platform
                end
            end

            if(draw_platform) begin
                if(next_draw) begin
                    next_draw <= 0;
                    draw_platform_idx = 0;
                    draw_x <= Platform_X[draw_platform_idx];
                    draw_y <= Platform_Y[draw_platform_idx];
                    draw_color <= 8'h46; //#5faf00
                end
                else begin
                    if (draw_platform_idx >= 8) begin
                        draw_platform <= 0; //platform done
                        next_draw <= 1;
                        draw_doodle <= 1; //start drawing doodle
                    end
                    else 
                        if(draw_x - Platform_X[draw_platform_idx] >= platform_size) begin
                            draw_platform_idx <= draw_platform_idx + 1; // move on to draw next platform
                            draw_x <= Platform_X[draw_platform_idx + 1];
                            draw_y <= Platform_Y[draw_platform_idx + 1];
                        end
                        else draw_x <= draw_x+1;
                    
                end
            end

            if(draw_doodle) begin
                if(next_draw) begin
                    next_draw <= 0;
                    draw_x <= Doodle_X;
                    draw_y <= Doodle_Y;
                    //basic_doodle_address = 0;

                    draw_color <= basic_doodle_color; 
                end
                else begin
                    if(draw_x >= Doodle_X + 31) begin
                        if(draw_y >= Doodle_Y + 31) begin
                            draw_doodle <= 0;
                            draw_spring <= 1;
                            //frame_done <= 1; //end of frame
                        end
                        else begin //draw next row
                            draw_x <= Doodle_X;
                            draw_y <= draw_y + 1;
                            draw_color <= basic_doodle_color;
                        end
                    end
                    else 
                        draw_x <= draw_x + 1;
                        draw_color <= basic_doodle_color;
                end
            end


        end //wr_en

    end //always_ff

endmodule


