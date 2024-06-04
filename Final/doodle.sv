module doodle #(    
    parameter [9:0] W = 640,        // screen width
    parameter [9:0] H = 480,        // screen height
    parameter [9:0] X_min = 140,    // game screen left bound
    parameter [9:0] X_max = 499     // game screen right bound
) ( 
    input Clk,                                  // 50 MHz clock
    input Reset,                                // Active-high reset signal
    input frame_clk,                            // The clock indicating a new frame (~60Hz)
    input [1:0] frame_clk_edge,     
    input [7:0] frame_count,        

    input [7:0] keycode, state,                 // game input
    input [9:0] Platform_X [0:7],               // up to 8 platforms on the screen
    input [9:0] Platform_Y [0:7],
    input [7:0] platform_size,                  // addjustable platform size
    //doodle state output
    output [9:0] Doodle_X_out, Doodle_Y_out,    // doodle position
    output [3:0] health,                        // doodle health
    output logic doodle_facing,                  // 0: left, 1: right
    output logic doodle_jumped                  // 1: doodle jumped
); 
    parameter [9:0] Doodle_size_X = 10'd32;     // Doodle size //TODO
    parameter [9:0] Doodle_size_Y = 10'd32;     // Doodle size //TODO
    parameter [9:0] Doodle_X_Center = (W-Doodle_size_X)/2;  // Center position on the X axis 
    parameter [9:0] Doodle_Y_Center = H*2/3;    // Center position on the Y axis 

    parameter [9:0] Doodle_Y_Min = 10'd1;       // Topmost point on the Y axis
    parameter [9:0] Doodle_Y_Max = H-2;         // Bottommost point on the Y axis 
    parameter [9:0] Doodle_X_Step = 3;          // Step size on the X axis
    parameter [9:0] gravity = 1;                
    //parameter [9:0] Doodle_Y_Step = 10'd1;      // Step size on the Y axis, and can be either pos or neg
    //parameter platform_size = 60;
    
    logic [9:0] Doodle_X_Pos, Doodle_X_Motion, Doodle_Y_Pos, Doodle_Y_Motion;
    logic [9:0] Doodle_X_Pos_in, Doodle_X_Motion_in, Doodle_Y_Pos_in, Doodle_Y_Motion_in;
    logic [9:0] jump_CD, jump_CD_in, on_ground;
//    int Doodle_Y_Motion, Doodle_Y_Motion_in, Doodle_Y_Pos_in;
    int start = 1;
    logic [3:0] health_in = 10;
    logic doodle_jumped_in;

    always_ff @ (posedge Clk)
	begin
        if(start) begin //if(start!=1) begin
            Doodle_X_Pos <= Doodle_X_Center;
            Doodle_Y_Pos <= Doodle_Y_Center;
            doodle_facing <= 1;
            Doodle_X_Motion <= 0;
            Doodle_Y_Motion <= 5; 
            health <= 10;
            // jump_CD <= 0;
            start <= 0;
        end
        else
		begin
            Doodle_X_Pos <= Doodle_X_Pos_in;
            Doodle_Y_Pos <= Doodle_Y_Pos_in;
            Doodle_X_Motion <= Doodle_X_Motion_in;
            Doodle_Y_Motion <= Doodle_Y_Motion_in; 
            // jump_CD <= jump_CD_in;
            health <= health_in;
        end
                
        if (frame_clk_edge ==2'b01) begin
            if(Doodle_X_Motion == 0 && Doodle_Y_Motion <= 0 && frame_count%10==0) 
                doodle_facing <= ~doodle_facing;
            else 
                doodle_facing <= (Doodle_X_Motion < 10'd30)? 1: 0;
        end
    end
    
    always_comb
	begin
        // By default, keep motion and position unchanged
        Doodle_X_Pos_in = Doodle_X_Pos;
        Doodle_Y_Pos_in = Doodle_Y_Pos;
        Doodle_X_Motion_in = Doodle_X_Motion;
        Doodle_Y_Motion_in = Doodle_Y_Motion; //Doodle_Y_Motion_in = Doodle_Y_Motion;
        // jump_CD_in = jump_CD;
        health_in = health;
        doodle_jumped = 0;
        
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
                // 8'h2C: // space: jump
                // begin
                //     if(jump_CD == 0) begin
                //         Doodle_Y_Motion_in = -6; //Doodle_Y_Motion_in = -3;
                //         // jump_CD_in = 18;
                //     end 
                    
                // end
                default: begin
                    Doodle_X_Motion_in = 0;
				end
            endcase

            // if(jump_CD > 0) 
                // jump_CD_in = jump_CD - 1;
            
            
            Doodle_X_Pos_in = Doodle_X_Pos + Doodle_X_Motion; 
            Doodle_Y_Pos_in = Doodle_Y_Pos + Doodle_Y_Motion; 
        
            
            /* added for collision */
            //if(state == 1) begin
                for(int i=0; i<8; i++) begin
                    if    (Doodle_X_Pos_in < Platform_X[i] + platform_size 
                        && Doodle_X_Pos_in + Doodle_size_X > Platform_X[i] 
                        && Doodle_Y_Pos + Doodle_size_Y <= Platform_Y[i]
                        && Doodle_Y_Pos + Doodle_size_Y + Doodle_Y_Motion_in > Platform_Y[i]
                        && Doodle_Y_Motion_in > 0) 
                    begin
                            Doodle_Y_Motion_in = -4;
                            doodle_jumped = 1;
                            // jump_CD_in = 1;
                    end
                end
            //end

            /* added for spring */
            // for(int i=0; i<8; i++) begin
            //     if    ((Doodle_X_Pos_in < Platform_X[i] + platform_size 
            //         && Doodle_X_Pos_in + Doodle_size_X > Platform_X[i] + platform_size - 5) 
            //         && Doodle_Y_Pos + Doodle_size_Y <= Platform_Y[i]
            //         && Doodle_Y_Pos + Doodle_size_Y + Doodle_Y_Motion_in >= Platform_Y[i]
            //         && Doodle_Y_Motion_in > 0) 
            //     begin
            //             Doodle_Y_Motion_in = -24;
            //             // jump_CD_in = 1;
            //     end
            // end


            //gravity acceleration
            if(Doodle_Y_Motion < 4) //&& frame_count %2 == 0)  
                Doodle_Y_Motion_in = Doodle_Y_Motion + 1; 
                // maximum Y motion: 4

                
            //boundary check
            if(Doodle_Y_Pos_in > Doodle_Y_Max - Doodle_size_Y) begin //bottom
                Doodle_Y_Pos_in = 2;
                Doodle_Y_Motion_in = 1;
                if(state == 1) begin
                    health_in = health - 1;
                end
            end

            if(Doodle_Y_Motion < 0) begin 
                /* edge case 1 for upward motion: 
                Doodle_Y_Motion = -1, Doodle_Y_Motion_in = 0, Doodle_Y_Pos = 1 => Doodle_Y_Pos_in = 1 + (-1) = 0 which is fine*/
                /* edge case 2 for upward motion: 
                Doodle_Y_Motion = -2, Doodle_Y_Motion_in = -1, Doodle_Y_Pos = 1 => Doodle_Y_Pos_in = 1 + (-2) = -1 => Doodle_Y_Pos_in = 0*/
                if(Doodle_Y_Pos_in < Doodle_Y_Min)
                    Doodle_Y_Pos_in = Doodle_Y_Min;
            end
            
            if ( Doodle_X_Pos_in > X_max - Doodle_size_X) // ---Doodle is at the right edge, CROSS!---
                Doodle_X_Pos_in = X_min;// + (Doodle_X_Pos + (~X_max) + 1'b1);
            
            if ( Doodle_X_Pos_in < X_min) // ---Doodle is at the left edge, CROSS!---
                Doodle_X_Pos_in = X_max - Doodle_size_X;// + (Doodle_X_Pos + (~X_min) + 1'b1);
        
        end //if (frame_clk_edge ==2'b01)

    end //always_comb

    /* Outputs */
    assign Doodle_X_out = Doodle_X_Pos;
    assign Doodle_Y_out = Doodle_Y_Pos;
    
endmodule
