module platform #(
    parameter W = 10'd640,      // Width of the screen
    parameter H = 10'd480,      // Height of the screen
    parameter X_Min = 140,      // Leftmost point on the X axis
    parameter X_Max = 499    // Rightmost point on the X axis 
) (
    input   Clk,                // 50 MHz clock
            Reset,              // Active-high reset signal
            frame_clk,          // The clock indicating a new frame (~60Hz)
    input [7:0] keycode, state,
    output logic [9:0] Platform_X_out [0:7],
    output logic [9:0] Platform_Y_out [0:7]
    //input [9:0]   DrawX, DrawY,       // Current pixel coordinates
    // output [9:0]    Platform_X_out1, Platform_Y_out1, Platform_X_out2, Platform_Y_out2,
    //                 Platform_X_out3, Platform_Y_out3, Platform_X_out4, Platform_Y_out4,
    //                 Platform_X_out5, Platform_Y_out5, Platform_X_out6, Platform_Y_out6,
    //                 Platform_X_out7, Platform_Y_out7, Platform_X_out8, Platform_Y_out8
);
    parameter [9:0] platform_size = 10'd20;
    parameter [9:0] Y_Max = H-1;     // Bottommost point on the Y axis
    int Platform_X_out_in [0:7] = '{1, 3, 5, 2, 4, 3, 2, 1};
    // logic [9:0] Platform_X_out [0:7];
    // logic [9:0] Platform_Y_out [0:7];

    always_ff @ (posedge Clk) 
    begin
        /* ----------- Initialize ----------- */
        if(1 == 1) 
        begin		
            Platform_X_out[0] <= 140; //TODOs
            Platform_Y_out[0] <= 40;
            
            Platform_X_out[1] <= 180;
            Platform_Y_out[1] <= 80;
            
            Platform_X_out[2] <= 220;
            Platform_Y_out[2] <= 120;
            
            Platform_X_out[3] <= 260;
            Platform_Y_out[3] <= 160;
            
            Platform_X_out[4] <= 300;
            Platform_Y_out[4] <= 200;
            
            Platform_X_out[5] <= 340;
            Platform_Y_out[5] <= 240;
            
            Platform_X_out[6] <= 380;
            Platform_Y_out[6] <= 240;

            Platform_X_out[7] <= 420;
            Platform_Y_out[7] <= 230;
        end               
            
            
            // for (int i = 0; i < 8; i++)
            // begin
            //     if (Platform_X_out[i] + platform_size >= X_Max)
            //         Platform_X_out_in[i] <= ~Platform_X_out_in[i] + 1'd1;
            //     else if (Platform_X_out[i] - platform_size <= X_Min)
            //         Platform_X_out_in[i] <= ~Platform_X_out_in[i] + 1'd1;
            //     else ;
            //         // Platform_X_out_in[i] <= 1;
            // end
            
    end
    //        
    //    else
    //        begin
    //            // for motion in X axis: 
    //            for (int i = 0; i < 8; i++)
    //                begin
    //                    if (Platform_X_out[i] + platform_size >= X_Max) // roght edge
    //                        Platform_X_out_in[i] <= ~Platform_X_out_in[i] + 1'd1;
    //                    else if (Platform_X_out[i] - platform_size <= X_Min) // left edge
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


endmodule
