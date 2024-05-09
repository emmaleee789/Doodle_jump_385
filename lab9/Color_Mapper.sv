//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper ( 
    input              is_font, inverse,
    input [11:0] FGD, BKG,
    input        [9:0] DrawX, DrawY,       // Current pixel coordinates
    output logic [3:0] VGA_R, VGA_G, VGA_B // VGA RGB output
);
    logic is_fore;
    assign is_fore = is_font ^ inverse;
    
    // Assign color based on is_ball signal
    always_comb
    begin
        if (is_fore == 1'b1) 
        begin
            // Foreground
            VGA_R = FGD[11:8];
            VGA_G = FGD[7:4];
            VGA_B = FGD[3:0];
        end
        else 
        begin
            // Background
            VGA_R = BKG[11:8];
            VGA_G = BKG[7:4];
            VGA_B = BKG[3:0];
        end
    end 
    
endmodule
