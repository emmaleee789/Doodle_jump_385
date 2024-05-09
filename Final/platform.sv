module platform (
    input   Clk,                // 50 MHz clock
            Reset,              // Active-high reset signal
            frame_clk,          // The clock indicating a new frame (~60Hz)
    input [7:0] keycode,
    input [9:0]   DrawX, DrawY,       // Current pixel coordinates
    input []
    output [7:0][9:0] Platform_X_out, Platform_Y_out,
    output [9:0] platform_size
);

assign platform_size = 10'd20;
parameter [9:0] W = 10'd320;      // Width of the screen

always_ff @ (posedge frame_clk) 
    begin
        /* ----------- Initialize ----------- */
        if(Reset)		
            begin		
                Platform_X_out[0] <= 10'd;
                Platform_Y_out[0] <= 10'd;
                
                Platform_X_out[1] <= 10'd;
                Platform_Y_out[1] <= 10'd;
                
                Platform_X_out[2] <= 10'd;
                Platform_Y_out[2] <= 10'd;
                
                Platform_X_out[3] <= 10'd;
                Platform_Y_out[3] <= 10'd;
                
                Platform_X_out[4] <= 10'd;
                Platform_Y_out[4] <= 10'd;
                
                Platform_X_out[5] <= 10'd;
                Platform_Y_out[5] <= 10'd;
                
                Platform_X_out[6] <= 10'd;
                Platform_Y_out[6] <= 10'd;
                
                Platform_X_out[7] <= 10'd;
                Platform_Y_out[7] <= 10'd;
                
                for (int i = 0; i < 8; i++)
                begin
                if (Platform_X_out[i] + stair_size >= x_max)
                    Platform_X_out_in[i] <= -1;
                else if (Platform_X_out[i] - stair_size <= x_min)
                    Platform_X_out_in[i] <= 1;
                else
                    Platform_X_out_in[i] <= 1;
                end
                
        end
        
    else
        begin
            for (int i = 0; i < 8; i++)
                begin
            
                    if (Platform_X_out[i] + stair_size >= x_max)
                        Platform_X_out_in[i] <= -1;
                    else if (Platform_X_out[i] - stair_size <= x_min)
                        Platform_X_out_in[i] <= 1;
                    else
                        Platform_X_out_in[i] <= Platform_X_out_in[i];
                
                end

            for (int i = 0; i < 8; i++)
                begin
                    Platform_Y_out[i] <= Platform_Y_out[i] - distance;
                    
                    if(Platform_Y_out[i] > 10'd)
                        begin
                            if(active_message[i])
                                begin
                                    Platform_Y_out[i] <= 10'd0;
                                end
                            else
                                begin
                                    Platform_X_out[i] <= 10'd;
                                    Platform_Y_out[i] <= 10'd;
                                end
                        end
                end

        end

    end



endmodule
