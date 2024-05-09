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
module  palette_mapper ( 
    input [7:0] draw_color,
    output logic [3:0] VGA_R, VGA_G, VGA_B // VGA RGB output
);
    // assign VGA_R = 4'b0001; 
    // assign VGA_G = 4'b0100; 
    // assign VGA_B = 4'b0101; 

    assign VGA_R = {2{draw_color[5:4]}};
    assign VGA_G = {2{draw_color[3:2]}};
    assign VGA_B = {2{draw_color[1:0]}};
    
endmodule
