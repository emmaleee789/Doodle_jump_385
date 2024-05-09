module platform (
    input   Clk,                // 50 MHz clock
            Reset,              // Active-high reset signal
            frame_clk,          // The clock indicating a new frame (~60Hz)
    input [7:0] keycode,
    input [9:0]   DrawX, DrawY,       // Current pixel coordinates
    output [9:0]    Platform_X_out1, Platform_Y_out1, Platform_X_out2, Platform_Y_out2,
                    Platform_X_out3, Platform_Y_out3, Platform_X_out4, Platform_Y_out4,
                    Platform_X_out5, Platform_Y_out5, Platform_X_out6, Platform_Y_out6,
                    Platform_X_out7, Platform_Y_out7, Platform_X_out8, Platform_Y_out8
);

parameter [9:0] H = 10'd240;      // Height of the screen
parameter [9:0] W = 10'd320;      // Width of the screen
parameter [9:0] platform_size = 10'd20;
parameter [9:0] Doodle_X_Min = 10'd80;       // Leftmost point on the X axis
parameter [9:0] Doodle_X_Max = 10'd239;     // Rightmost point on the X axis 
parameter [9:0] Doodle_Y_Max = H-1;     // Bottommost point on the Y axis
int Platform_X_out_in [0:7] = '{1, 3, 5, 2, 4, 3, 2, 1};

//always_ff @ (posedge frame_clk) 
//    begin
//        /* ----------- Initialize ----------- */
//        if(Reset)		
//            begin		
//                Platform_X_out[0] <= 90; //TODOs
//                Platform_Y_out[0] <= 230;
//                
//                Platform_X_out[1] <= 10'd;
//                Platform_Y_out[1] <= 10'd;
//                
//                Platform_X_out[2] <= 10'd;
//                Platform_Y_out[2] <= 10'd;
//                
//                Platform_X_out[3] <= 10'd;
//                Platform_Y_out[3] <= 10'd;
//                
//                Platform_X_out[4] <= 10'd;
//                Platform_Y_out[4] <= 10'd;
//                
//                Platform_X_out[5] <= 10'd;
//                Platform_Y_out[5] <= 10'd;
//                
//                Platform_X_out[6] <= 10'd;
//                Platform_Y_out[6] <= 10'd;
//                
//                Platform_X_out[7] <= 10'd;
//                Platform_Y_out[7] <= 10'd;
//                
//                // for (int i = 0; i < 8; i++)
//                // begin
//                //     if (Platform_X_out[i] + platform_size >= Doodle_X_Max)
//                //         Platform_X_out_in[i] <= ~Platform_X_out_in[i] + 1'd1;
//                //     else if (Platform_X_out[i] - platform_size <= Doodle_X_Min)
//                //         Platform_X_out_in[i] <= ~Platform_X_out_in[i] + 1'd1;
//                //     else ;
//                //         // Platform_X_out_in[i] <= 1;
//                // end
//                
//        end
//        
//    else
//        begin
//            // for motion in X axis: 
//            for (int i = 0; i < 8; i++)
//                begin
//                    if (Platform_X_out[i] + platform_size >= Doodle_X_Max) // roght edge
//                        Platform_X_out_in[i] <= ~Platform_X_out_in[i] + 1'd1;
//                    else if (Platform_X_out[i] - platform_size <= Doodle_X_Min) // left edge
//                        Platform_X_out_in[i] <= ~Platform_X_out_in[i] + 1'd1;
//                    else ;
//                        // Platform_X_out_in[i] <= 1;
//                end
//
//            // for motion in Y axis: 
//            for (int i = 0; i < 8; i++)
//            begin
//                Platform_Y_out[i] <= Platform_Y_out[i] - distance;
//                
//                if(Platform_Y_out[i] > Doodle_Y_Max) // TODO
//                begin
//                    // Platform_X_out[i] does not change
//                    Platform_Y_out[i] <= 10'1;
//                end
//            end
//
//        end
//
//    end
//
//    assign Platform_X_out1 = Platform_X_out[0];
//    assign Platform_Y_out1 = Platform_Y_out[0];
//    assign Platform_X_out2 = Platform_X_out[1];
//    assign Platform_Y_out2 = Platform_Y_out[1];
//    assign Platform_X_out3 = Platform_X_out[2];
//    assign Platform_Y_out3 = Platform_Y_out[2];
//    assign Platform_X_out4 = Platform_X_out[3];
//    assign Platform_Y_out4 = Platform_Y_out[3];
//    assign Platform_X_out5 = Platform_X_out[4];
//    assign Platform_Y_out5 = Platform_Y_out[4];
//    assign Platform_X_out6 = Platform_X_out[5];
//    assign Platform_Y_out6 = Platform_Y_out[5];
//    assign Platform_X_out7 = Platform_X_out[6];
//    assign Platform_Y_out7 = Platform_Y_out[6];
//    assign Platform_X_out8 = Platform_X_out[7];
//    assign Platform_Y_out8 = Platform_Y_out[7];


endmodule
