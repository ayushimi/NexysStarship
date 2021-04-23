//////////////////////////////////////////////////////////////////////////////////
// Author:			Ayushi Mittal, Kelly Chan
// Create Date:   	04/10/21
// File Name:		nexys_starship.v 
// Description: 	Main file for Nexys Starship (EE 354 Final Project).
//
//
//////////////////////////////////////////////////////////////////////////////////


module nexys_starship_PRNG(Clk, Reset, top_random, btm_random,
							left_random, right_random, TR_random,
							BR_random, LR_random, RR_random);

	/*  INPUTS */
	input	Clk, Reset;	

	/*  OUTPUTS */
	output reg top_random, btm_random, left_random, right_random;
	output reg TR_random, BR_random, LR_random, RR_random;
	
	// TOP
    reg [7:0] top0, top1, top2, top3, top_random_8;
    reg [7:0] TR_random_8;
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
            TR_random_8 <= {top0[7:5], top3[4:2] ^ top1[4:2], top2[1:0]};
			if (top_random_8 <= 15)
				top_random <= 1;
			else
				top_random <= 0;
		    if (TR_random_8 <= 15)
                TR_random <= 1;
            else
                TR_random <= 0;
        end
    end
    
    // BTM
    reg [7:0] btm0, btm1, btm2, btm3, btm_random_8;
    always @ (posedge Clk, posedge Reset) begin
        if (Reset)
        begin
            btm0 <= 0;
            btm1 <= 230;
            btm2 <= 99;
            btm3 <= 180;
            btm_random_8 <= 0;
        end
        else
        begin
            btm0 <= btm0 + 3;
            btm1 <= btm1 + 9;
            btm2 <= btm2 + 5;
            btm3 <= btm3 + 7;
            btm_random_8 <= {btm3[7:5], btm2[4:2] ^ btm1[4:2], btm0[1:0]};
			if (btm_random_8 <= 15)
				btm_random <= 1;
			else
				btm_random <= 0;
        end
    end

	
endmodule
