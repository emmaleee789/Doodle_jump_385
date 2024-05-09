module control (
	input logic Clk, Reset, Run, ClearA_LoadB, 
	input logic [7:0] A, B, S,
	output logic Clr_Ld, Shift, Add, Sub, Clr_A
);
    enum logic [7:0] {Add1, Shift1, Add2, Shift2, Add3, Shift3, Add4, Shift4, Add5, Shift5, Add6, Shift6, Add7, Shift7, Add8, Subtract, Shift8, Stop, Start, CALB, Done}   curr_state, next_state; 
	logic [7:0] A2, B2;
	logic M, X;

    always_ff @ (posedge Clk)  
    begin
        if (Reset)
            curr_state <= Stop;
        else 
            curr_state <= next_state;
    end

	always_comb
    begin        
		next_state  = curr_state;	//required because I haven't enumerated all possibilities below
		M = B[0];
        unique case (curr_state) 
            Stop : 	if (ClearA_LoadB)
                        next_state = CALB;
					else if(Run) ////
						next_state = Start; ////
			CALB:     next_state = Start;
			Start: 	if (Run)
						next_state = Add1;
			
            Add1 :    next_state = Shift1;
            Shift1 :  next_state = Add2;
            Add2 :    next_state = Shift2;
            Shift2 :  next_state = Add3;
            Add3 :	  next_state = Shift3;
            Shift3 :  next_state = Add4;
            Add4 :	  next_state = Shift4;
            Shift4 :  next_state = Add5;
			Add5 :    next_state = Shift5;
            Shift5 :  next_state = Add6;
            Add6 :    next_state = Shift6;
            Shift6 :  next_state = Add7;
            Add7 :	  next_state = Shift7;
            Shift7: begin
				if(M==0) next_state = Add8;
				else next_state = Subtract;
			end
			Add8 :	  next_state = Shift8;
            Subtract: next_state = Shift8;
            Shift8 :  next_state = Done;
            
            Done :  if (~Run) 
                    	next_state = Stop;
        endcase

		// Assign outputs based on ‘state’
        Clr_Ld = 0;
        Shift = 0;
        Add = 0;
        Sub = 0;
		  Clr_A = 0;
        case (curr_state) 
			Start: Clr_A = 1; ////
		  
			CALB: begin
				Clr_Ld = 1;
			end
            Add1, Add2, Add3, Add4, Add5, Add6, Add7 : begin
				if (M == 1) 
					Add = 1;
				else 
					Add = 0;
			end
			Subtract : begin
				Sub = 1;
				Add = 1;
			end
			Shift1, Shift2, Shift3, Shift4, Shift5, Shift6, Shift7, Shift8 : begin
				Shift = 1;
			end
			
		endcase
    end

endmodule
