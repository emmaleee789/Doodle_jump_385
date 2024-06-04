module game_state (
    input Clk, Reset, frame_clk,
    input [1:0] frame_clk_edge,
    input [7:0] keycode,
    input [9:0] health,
    
    output [7:0] state,
    output [7:0] platform_size
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
        // if(health == 0) begin
        //     state <= 2;
        // end
    end //always_ff
    
    assign platform_size = 30;

endmodule