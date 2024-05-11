module doodle ( 
    input         Clk,                // 50 MHz clock
        Reset,              // Active-high reset signal
        frame_clk,          // The clock indicating a new frame (~60Hz)
    input [1:0] frame_clk_edge,
    input [7:0] keycode,
    output [9:0] Doodle_X_out, Doodle_Y_out
);
    parameter [9:0] W = 10'd320;      // Width of the screen
    parameter [9:0] H = 10'd240;      // Height of the screen
    parameter [9:0] Doodle_size_X = 10'd10;      // Doodle size //TODO
    parameter [9:0] Doodle_size_Y = 10'd10;      // Doodle size //TODO
    parameter [9:0] Doodle_X_Center = (W-Doodle_size_X)/2;  // Center position on the X axis 
    parameter [9:0] Doodle_Y_Center = H*2/3;  // Center position on the Y axis 
    parameter [9:0] Doodle_X_Min = 10'd80;       // Leftmost point on the X axis
    parameter [9:0] Doodle_X_Max = 10'd239;     // Rightmost point on the X axis 
    parameter [9:0] Doodle_Y_Min = 10'd1;       // Topmost point on the Y axis
    parameter [9:0] Doodle_Y_Max = H-2;     // Bottommost point on the Y axis 
    parameter [9:0] Doodle_X_Step = 10'd1;      // Step size on the X axis
    parameter [9:0] gravity = 1;      // Step size on the Y axis
    parameter [9:0] Doodle_Y_Step = 10'd1;      // Step size on the Y axis, and can be either pos or neg
    
    logic [9:0] Doodle_X_Pos, Doodle_X_Motion, Doodle_Y_Pos, Doodle_Y_Motion;
    logic [9:0] Doodle_X_Pos_in, Doodle_X_Motion_in, Doodle_Y_Pos_in, Doodle_Y_Motion_in;
    logic [9:0] jump_CD, jump_CD_in;
    int y_speed, y_speed_in, y_pos_in;

    always_ff @ (posedge Clk)
	begin
        if(Doodle_X_Pos <=10) begin //if(start!=1) begin
            Doodle_X_Pos <= Doodle_X_Center;
            Doodle_Y_Pos <= Doodle_Y_Center;
            Doodle_X_Motion <= 0;
            y_speed <= -5; //Doodle_Y_Motion <= -3;
            jump_CD <= 0;
            //start <= 1;
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
        end
    end
    
    // You need to modify always_comb block.
    always_comb
	begin
        // By default, keep motion and position unchanged
        Doodle_X_Pos_in = Doodle_X_Pos;
        y_pos_in = Doodle_Y_Pos;
        Doodle_X_Motion_in = Doodle_X_Motion;
        y_speed_in = y_speed; //Doodle_Y_Motion_in = Doodle_Y_Motion;
        jump_CD_in = jump_CD;
        
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
                        y_speed_in = -9; //Doodle_Y_Motion_in = -3;
                        jump_CD_in = 18;
                    end 
                    else ;
                end
                default: begin
                    Doodle_X_Motion_in = 0;
				end
            endcase

            if(jump_CD > 0) begin
                jump_CD_in = jump_CD - 1;
            end

            if(y_speed_in < 3) begin
                y_speed_in += gravity; //Doodle_Y_Motion_in += gravity;
            end

            Doodle_X_Pos_in = Doodle_X_Pos + Doodle_X_Motion;
            y_pos_in = Doodle_Y_Pos + y_speed; //Doodle_Y_Pos_in = Doodle_Y_Pos + Doodle_Y_Motion;
            
            if(y_pos_in > Doodle_Y_Max - Doodle_size_Y) begin
                y_pos_in = Doodle_Y_Min+10;
            end
            if(y_pos_in < Doodle_Y_Min+10 ) begin
                y_pos_in = Doodle_Y_Min+10;
            end

            if ( Doodle_X_Pos_in > Doodle_X_Max - Doodle_size_X) begin// ---Doodle is at the right edge, CROSS!---
                Doodle_X_Pos_in = Doodle_X_Min;// + (Doodle_X_Pos + (~Doodle_X_Max) + 1'b1);
            end
            if ( Doodle_X_Pos_in < Doodle_X_Min) begin// ---Doodle is at the left edge, CROSS!---
                Doodle_X_Pos_in = Doodle_X_Max - Doodle_size_X;// + (Doodle_X_Pos + (~Doodle_X_Min) + 1'b1);
            end

        end
        
    end

    /* Outputs */
    assign Doodle_X_out = Doodle_X_Pos;
    assign Doodle_Y_out = Doodle_Y_Pos;
    
endmodule
