//////////////////////////////////////////////////////////////////////////////////
// Author:			Ayushi Mittal, Kelly Chan
// Create Date:   	04/10/21
// File Name:		nexys_starship.v 
// Description: 	Main file for Nexys Starship (EE 354 Final Project).
//
//
//////////////////////////////////////////////////////////////////////////////////


module nexys_starship_PRNG(Clk, Reset, top_random, btm_random,
							left_random, right_random);

	/*  INPUTS */
	input	Clk, Reset;	

	/*  OUTPUTS */
	output reg top_random, btm_random, left_random, right_random;
	
	// TOP
    reg [7:0] top0, top1, top2, top3, top_random_8;
    always @ (posedge Clk, posedge Reset) begin
        if (Reset)
        begin
            top0 <= 0;
            top1 <= 31;
            top2 <= 127;
            top3 <= 214;
            top_random_8 <= 0;
        end
        else
        begin
            top0 <= top0 + 7;
            top1 <= top1 + 5;
            top2 <= top2 + 3;
            top3 <= top3 + 9;
            top_random_8 <= {top3[7:5], top2[4:2] ^ top1[4:2], top0[1:0]};
			if (top_random_8 == 0)
				top_random <= 1;
			else
				top_random <= 0;
        end
    
    end
    

	
endmodule
