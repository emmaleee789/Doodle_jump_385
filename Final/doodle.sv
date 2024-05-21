module doodle #(    
    parameter W = 640,      // Width of the screen
    parameter H = 480,      // Height of the screen
    parameter Doodle_X_Min = 140,       // Leftmost point on the X axis
    parameter Doodle_X_Max = 499     // Rightmost point on the X axis 
) ( 
    input Clk,                // 50 MHz clock
    input Reset,              // Active-high reset signal
    input frame_clk,          // The clock indicating a new frame (~60Hz)
    input [1:0] frame_clk_edge,

    input [7:0] keycode, state,
    input [9:0] Platform_X [0:7],
    input [9:0] Platform_Y [0:7],

    output [9:0] Doodle_X_out, Doodle_Y_out,
    output [9:0] health
); 
    parameter [9:0] Doodle_size_X = 10'd32;      // Doodle size //TODO
    parameter [9:0] Doodle_size_Y = 10'd32;      // Doodle size //TODO
    parameter [9:0] Doodle_X_Center = (W-Doodle_size_X)/2;  // Center position on the X axis 
    parameter [9:0] Doodle_Y_Center = H*2/3;  // Center position on the Y axis 

    parameter [9:0] Doodle_Y_Min = 10'd1;       // Topmost point on the Y axis
    parameter [9:0] Doodle_Y_Max = H-2;     // Bottommost point on the Y axis 
    parameter [9:0] Doodle_X_Step = 3;      // Step size on the X axis
    parameter [9:0] gravity = 1;      // Step size on the Y axis
    //parameter [9:0] Doodle_Y_Step = 10'd1;      // Step size on the Y axis, and can be either pos or neg
    parameter platform_size = 60;
    
    logic [9:0] Doodle_X_Pos, Doodle_X_Motion, Doodle_Y_Pos, Doodle_Y_Motion;
    logic [9:0] Doodle_X_Pos_in, Doodle_X_Motion_in, Doodle_Y_Pos_in, Doodle_Y_Motion_in;
    logic [9:0] jump_CD, jump_CD_in, on_ground;
    int y_speed, y_speed_in, y_pos_in;
    int start = 1;
    logic [9:0] health_cnt = 10;

    always_ff @ (posedge Clk)
	begin
        if(start) begin //if(start!=1) begin
            Doodle_X_Pos <= Doodle_X_Center;
            Doodle_Y_Pos <= Doodle_Y_Center;
            Doodle_X_Motion <= 0;
            y_speed <= -5; //Doodle_Y_Motion <= -3;
            jump_CD <= 0;
            start <= 0;
        end
        else if (Reset)
		begin
            Doodle_X_Pos <= Doodle_X_Center;
            Doodle_Y_Pos <= Doodle_Y_Center;
            Doodle_X_Motion <= 0;
            y_speed <= 0; //Doodle_Y_Motion <= 0;
        end
        else
		begin
            Doodle_X_Pos <= Doodle_X_Pos_in;
            Doodle_Y_Pos <= y_pos_in;
            Doodle_X_Motion <= Doodle_X_Motion_in;
            y_speed = y_speed_in; //Doodle_Y_Motion <= Doodle_Y_Motion_in;
            jump_CD = jump_CD_in;
            // health <= health_cnt; 
        end
    end
    
    always_comb
	begin
        // By default, keep motion and position unchanged
        Doodle_X_Pos_in = Doodle_X_Pos;
        y_pos_in = Doodle_Y_Pos;
        Doodle_X_Motion_in = Doodle_X_Motion;
        y_speed_in = y_speed; //Doodle_Y_Motion_in = Doodle_Y_Motion;
        jump_CD_in = jump_CD;
        health_cnt = health;
        
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_edge ==2'b01)
		begin
			case (keycode)
                8'h04: // A: left
                begin
                    Doodle_X_Motion_in = (~(Doodle_X_Step) + 1'b1);
                end
                8'h07: // D: right
                begin
                    Doodle_X_Motion_in = Doodle_X_Step;
                end
                8'h2C: // space: jump
                begin
                    if(jump_CD == 0) begin
                        y_speed_in = -6; //Doodle_Y_Motion_in = -3;
                        jump_CD_in = 18;
                    end 
                    
                end
                default: begin
                    Doodle_X_Motion_in = 0;
				end
            endcase

            if(jump_CD > 0) 
                jump_CD_in = jump_CD - 1;
            

            if(y_speed_in < 4)  //gravity acceleration
                y_speed_in += gravity; 
            

            Doodle_X_Pos_in = Doodle_X_Pos + Doodle_X_Motion;
            y_pos_in = Doodle_Y_Pos + y_speed; //Doodle_Y_Pos_in = Doodle_Y_Pos + Doodle_Y_Motion;
            
            if(Doodle_Y_Pos > Doodle_Y_Max - Doodle_size_Y) begin
                y_pos_in = Doodle_Y_Min+10;
                // if(state == 1) begin
                //     health_cnt = health - 1;
                // end
                // if(state == 0) begin
                //     health_cnt = 10;
                // end
            end
            
            if(y_pos_in < Doodle_Y_Min+10 ) 
                y_pos_in = Doodle_Y_Min+10;
            

            if ( Doodle_X_Pos_in > Doodle_X_Max - Doodle_size_X) // ---Doodle is at the right edge, CROSS!---
                Doodle_X_Pos_in = Doodle_X_Min;// + (Doodle_X_Pos + (~Doodle_X_Max) + 1'b1);
            
            if ( Doodle_X_Pos_in < Doodle_X_Min) // ---Doodle is at the left edge, CROSS!---
                Doodle_X_Pos_in = Doodle_X_Max - Doodle_size_X;// + (Doodle_X_Pos + (~Doodle_X_Min) + 1'b1);
            
            /* added for collision */
            //if(state == 1) begin
                for(int i=0; i<8; i++) begin
                    if    (Doodle_X_Pos_in < Platform_X[i] + platform_size 
                        && Doodle_X_Pos_in + Doodle_size_X > Platform_X[i] 
                        && Doodle_Y_Pos + Doodle_size_Y <= Platform_Y[i]
                        && Doodle_Y_Pos + Doodle_size_Y + y_speed_in >= Platform_Y[i]
                        && y_speed_in > 0) 
                    begin
                            y_speed_in = -12;
                            jump_CD_in = 1;
                    end
                end
            //end

            /* added for spring */
            for(int i=0; i<8; i++) begin
                if    ((Doodle_X_Pos_in < Platform_X[i] + platform_size 
                    && Doodle_X_Pos_in + Doodle_size_X > Platform_X[i] + platform_size - 5) 
                    && Doodle_Y_Pos + Doodle_size_Y <= Platform_Y[i]
                    && Doodle_Y_Pos + Doodle_size_Y + y_speed_in >= Platform_Y[i]
                    && y_speed_in > 0) 
                begin
                        y_speed_in = -12;
                        jump_CD_in = 1;
                end
            end

        end
        
    end

    /* Outputs */
    assign Doodle_X_out = Doodle_X_Pos;
    assign Doodle_Y_out = Doodle_Y_Pos;
    
endmodule
