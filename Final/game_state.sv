module game_state 
(
    input Clk, Reset, frame_clk,
    input [1:0] frame_clk_edge,
    input [7:0] keycode,
    
    output [7:0] state
);
    
    always_ff @ (posedge Clk) begin
        if(Reset) begin
            state <= 0;
        end
        case (keycode)
            8'd41: begin // Esc
                state <= 0;
            end
            8'd40: begin // Enter
                state <= 1;
            end
            default: begin
            end
        endcase

    end //always_ff
endmodule