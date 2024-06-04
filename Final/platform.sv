module platform #(
    parameter W = 320,      // Width of the screen
    parameter H = 240,      // Height of the screen
    parameter X_min = 70,      // Leftmost point on the X axis
    parameter X_max = 249    // Rightmost point on the X axis 
) (
    input   Clk,                // 50 MHz clock
            Reset,              // Active-high reset signal
            frame_clk,          // The clock indicating a new frame (~60Hz)
    input [1:0] frame_clk_edge, // The edge of the frame clock
    input [7:0] keycode, state,
    input [7:0] platform_size,
    output logic [9:0] Platform_X_out [0:7],
    output logic [9:0] Platform_Y_out [0:7]
    //input [9:0]   DrawX, DrawY,       // Current pixel coordinates
    // output [9:0]    Platform_X_out1, Platform_Y_out1, Platform_X_out2, Platform_Y_out2,
    //                 Platform_X_out3, Platform_Y_out3, Platform_X_out4, Platform_Y_out4,
    //                 Platform_X_out5, Platform_Y_out5, Platform_X_out6, Platform_Y_out6,
    //                 Platform_X_out7, Platform_Y_out7, Platform_X_out8, Platform_Y_out8
);
    //parameter [9:0] platform_size = 10'd60;
    parameter [9:0] Y_Max = H-1;     // Bottommost point on the Y axis
    int Platform_X_motion_step [0:7] = '{0, 0, 0, 0, 1, 1, 2, 2};
    int Platform_Y_motion_step [0:7] = '{1,1,1,1,1,1,1,1}; //'{2, 2, 2, 2, 2, 2, 2, 2};
    int flag = 1;
    logic [9:0] Platform_X_out_in [0:7];
    logic [9:0] Platform_Y_out_in [0:7];
    logic [9:0] Platform_X_motion [0:7];
    logic [9:0] Platform_Y_motion [0:7];
    logic [9:0] Platform_X_motion_in [0:7];
    logic [9:0] Platform_Y_motion_in [0:7];

    always_ff @ (posedge Clk) 
    begin
        /* ----------- Initialize ----------- */
        if(state == 0 && flag) 
        begin		
            Platform_X_out[0] <= 150; //TODOs
            Platform_Y_out[0] <= 50;
            
            Platform_X_out[1] <= 200;
            Platform_Y_out[1] <= 110;
            
            Platform_X_out[2] <= 80;
            Platform_Y_out[2] <= 170;
            
            Platform_X_out[3] <= 130;
            Platform_Y_out[3] <= 230;
            
            Platform_X_out[4] <= 180;
            Platform_Y_out[4] <= 70;
            
            Platform_X_out[5] <= 140;
            Platform_Y_out[5] <= 190;
            
            Platform_X_out[6] <= 220;
            Platform_Y_out[6] <= 10;

            Platform_X_out[7] <= 150;
            Platform_Y_out[7] <= 120;

            Platform_X_motion <= Platform_X_motion_step;
            Platform_Y_motion <= Platform_Y_motion_step;
            
            flag <= 0;
            
        end        
        else
        begin
            Platform_X_out <= Platform_X_out_in;
            Platform_Y_out <= Platform_Y_out_in;
            Platform_X_motion <= Platform_X_motion_in;
            Platform_Y_motion <= Platform_Y_motion_in;
            
        end
    end

    always_comb
    begin        
        // By default, keep motion and position unchanged
        Platform_X_out_in = Platform_X_out;
        Platform_Y_out_in = Platform_Y_out;
        Platform_X_motion_in = Platform_X_motion;
        Platform_Y_motion_in = Platform_Y_motion_step;

        if(frame_clk_edge == 2'b01) begin
            for(int i=0; i<8; i++) begin
                Platform_X_out_in[i] = Platform_X_out[i] + Platform_X_motion[i];
                Platform_Y_out_in[i] = Platform_Y_out[i] + Platform_Y_motion[i];
                if(Platform_Y_out_in[i] > Y_Max) begin
                    Platform_Y_out_in[i] = 0;
                end
                if(Platform_X_out_in[i] + platform_size +Platform_X_motion_step[i] >= X_max) begin
                    Platform_X_motion_in[i] = ~Platform_X_motion_step[i] + 1'b1;
                end
                if(Platform_X_out_in[i] -Platform_X_motion_step[i] <= X_min) begin
                    Platform_X_motion_in[i] = Platform_X_motion_step[i];
                end
                if(Platform_Y_out_in[i] >= Y_Max) begin
                    Platform_Y_out_in[i] = 0;
                end
            end
        end
    end


endmodule
