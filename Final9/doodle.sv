module doodle ( 
    input         Clk,                // 50 MHz clock
        Reset,              // Active-high reset signal
        frame_clk,          // The clock indicating a new frame (~60Hz)
    input [7:0] keycode,
    // input [9:0]   DrawX, DrawY,       // Current pixel coordinates
    // output logic  is_Doodle             // Whether current pixel belongs to ball or background
    output [9:0] Doodle_X_out, Doodle_Y_out
);
    parameter [9:0] W = 10'd320;      // Width of the screen
    parameter [9:0] H = 10'd240;      // Height of the screen
    parameter [9:0] Doodle_size_X = 10'd4;      // Doodle size //TODO
    parameter [9:0] Doodle_size_Y = 10'd4;      // Doodle size //TODO
    parameter [9:0] Doodle_X_Center = (W-Doodle_size_X)/2;  // Center position on the X axis //TODO
    parameter [9:0] Doodle_Y_Center = (H-Doodle_size_Y)*2/3;  // Center position on the Y axis //TODO
    parameter [9:0] Doodle_X_Min = 10'd0;       // Leftmost point on the X axis
    parameter [9:0] Doodle_X_Max = W-1;     // Rightmost point on the X axis //TODO
    parameter [9:0] Doodle_Y_Min = 10'd0;       // Topmost point on the Y axis
    parameter [9:0] Doodle_Y_Max = H-1;     // Bottommost point on the Y axis //TODO
    parameter [9:0] Doodle_X_Step = 10'd3;      // Step size on the X axis
    parameter [9:0] Doodle_Y_Step = ~(10'd5 + 1'b1);      // Step size on the Y axis, and can be either pos or neg
    
    logic [9:0] Doodle_X_Pos, Doodle_X_Motion, Doodle_Y_Pos, Doodle_Y_Motion;
    logic [9:0] Doodle_X_Pos_in, Doodle_X_Motion_in, Doodle_Y_Pos_in, Doodle_Y_Motion_in;
    
    // Detect rising edge of frame_clk
    logic frame_clk_delayed, frame_clk_rising_edge;
	 always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end
    // Update registers
    always_ff @ (posedge Clk)
	 begin
        if (Reset)
		  begin
            Doodle_X_Pos <= Doodle_X_Center;
            Doodle_Y_Pos <= Doodle_Y_Center;
            Doodle_X_Motion <= 10'd0;
            Doodle_Y_Motion <= Doodle_Y_Step;
        end
        else
		  begin
            Doodle_X_Pos <= Doodle_X_Pos_in;
            Doodle_Y_Pos <= Doodle_Y_Pos_in;
            Doodle_X_Motion <= Doodle_X_Motion_in;
            Doodle_Y_Motion <= Doodle_Y_Motion_in;
        end
    end
    
    // You need to modify always_comb block.
    always_comb
	 begin
        // By default, keep motion and position unchanged
        Doodle_X_Pos_in = Doodle_X_Pos;
        Doodle_Y_Pos_in = Doodle_Y_Pos;
        Doodle_X_Motion_in = Doodle_X_Motion;
        Doodle_Y_Motion_in = Doodle_Y_Motion;
        
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
		  begin
				case (keycode)
                8'h04: // left: A
                begin
                    Doodle_X_Motion_in = (~(Doodle_X_Step) + 1'b1);
                    Doodle_Y_Motion_in = 0;
                end
                8'h07: // right: D
                begin
                    Doodle_X_Motion_in = Doodle_X_Step;
                    Doodle_Y_Motion_in = 0;
                end
                default:; // do nothing
            endcase

            if( Doodle_Y_Pos + Doodle_size_Y >= Doodle_Y_Max )  // ---Doodle is at the bottom edge, BOUNCE!---
                Doodle_Y_Motion_in = ~(10'd5 + 1'b1);  // 2's complement.  
            // else if ( Doodle_Y_Pos <= Doodle_Y_Min + Doodle_size_Y )  // TODO ---Doodle is at the top edge, it should be still---
                // Doodle_Y_Motion_in = Doodle_Y_Step;
            else if ( Doodle_X_Pos + Doodle_size_X >= Doodle_X_Max ) // Doodle is at the right edge
                Doodle_X_Motion_in = (~(Doodle_X_Step) + 1'b1); 
            else if (Doodle_X_Pos <= Doodle_X_Min + Doodle_size_X) // Doodle is at the left edge
                Doodle_X_Motion_in = Doodle_X_Step; 
            else ;// Doodle is not at the edge
           
            // Update the Doodle's position with its motion
            if ( Doodle_X_Pos > Doodle_X_Max) // ---Doodle is at the right edge, CROSS!---
                Doodle_X_Pos_in = Doodle_X_Min + (Doodle_X_Pos + (~Doodle_X_Max) + 1'b1);
            else if ( Doodle_X_Pos + Doodle_size_X < Doodle_X_Min) // ---Doodle is at the left edge, CROSS!---
                Doodle_X_Pos_in = Doodle_X_Max + (Doodle_X_Pos + (~Doodle_X_Min) + 1'b1);
            else ;
        end
        
    end

    /* Outputs */
    assign Doodle_X_out = Doodle_X_Pos;
    assign Doodle_Y_out = Doodle_Y_Pos;
    
    // Compute whether the pixel corresponds to Doodle or background
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
    // int DistX, DistY, Size;
    // assign DistX = DrawX - Doodle_X_Pos;
    // assign DistY = DrawY - Doodle_Y_Pos;
    // assign Size = Doodle_size_X;
	// always_comb begin
    //     if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) ) 
    //         is_Doodle = 1'b1;
    //     else
    //         is_Doodle = 1'b0;
    //     /* The Doodle's (pixelated) circle is generated using the standard circle formula.  Note that while 
    //        the single line is quite powerful descriptively, it causes the synthesis tool to use up three
    //        of the 12 available multipliers on the chip! */
    // end
    
endmodule
