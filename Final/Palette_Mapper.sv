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
	input Clk,
    input [7:0] draw_color,
    output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
);
    logic we;
    logic [7:0] write_address, read_address;
	logic [23:0] mem [0: 255]; 
    logic [23:0] data_Out, data_In;
    assign we = 0;
    assign read_address = draw_color;
    
	initial
	begin
		$readmemh("img_txt/palette.txt", mem);
        // $display("Memory contents:");
        // for (int i = 0; i < 10; i++)
        //     $display("mem[%0d] = %h", i, mem[i]);
	end

    always_ff @ (posedge Clk) begin
        if (we)
            mem[write_address] <= data_In;
        data_Out<= mem[read_address];
    end 

    assign VGA_R = data_Out[23:16];
    assign VGA_G = data_Out[15:8];
    assign VGA_B = data_Out[7:0];

    //test
    // assign VGA_R = {4{draw_color[1:0]}};
    // assign VGA_G = {4{draw_color[3:2]}};
    // assign VGA_B = {4{draw_color[1:0]}};
    // assign VGA_R = 255;
    // assign VGA_G = 8'hf0;
    // assign VGA_B = 8'hf0;
endmodule


