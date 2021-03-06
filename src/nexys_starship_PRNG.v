//////////////////////////////////////////////////////////////////////////////////
// Author:			Ayushi Mittal, Kelly Chan
// Create Date:   	04/10/21
// File Name:		nexys_starship.v 
// Description: 	Pseudo Random Number Generator file for Nexys Starship 
//                  (EE 354 Final Project).
//
//////////////////////////////////////////////////////////////////////////////////


module nexys_starship_PRNG(Clk, Reset, top_random, btm_random,
							left_random, right_random, TR_random,
							BR_random, LR_random, RR_random, random_hex);

	/*  INPUTS */
	input	Clk, Reset;	

	/*  OUTPUTS */
	// Random Monster Generation 
	output reg top_random, btm_random, left_random, right_random;
	// Random Repair Generation 
	output reg TR_random, BR_random, LR_random, RR_random;
	reg [7:0] TR_random_8, BR_random_8, LR_random_8, RR_random_8; 
	output reg [3:0] random_hex;
	
	// TOP
    reg [7:0] top0, top1, top2, top3, top_random_8;
    reg [7:0] random_hex_8;

    always @ (posedge Clk, posedge Reset) begin
        if (Reset)
        begin
            // Assign random initial values to each reg 
            top0 <= 0;
            top1 <= 31;
            top2 <= 127;
            top3 <= 214;
            top_random_8 <= 0;
            TR_random_8 <= 172; 
            random_hex_8 <=0;
            top_random <= 0;
            TR_random <=0; 
        end
        else
        begin
            // Increment, then randomly combine/XOR regs to produce pseudo random number. 
            top0 <= top0 + 7;
            top1 <= top1 + 5;
            top2 <= top2 + 3;
            top3 <= top3 + 9;
            top_random_8 <= {top3[7:5], top2[4:2] ^ top1[4:2], top0[1:0]};
            TR_random_8 <= {top0[7:5], top3[4:2] ^ top1[4:2], top2[1:0]};
            random_hex_8 <= {top2[7], top3[4], top0[3] ^ top3[4], top2[5], top1[1], 
                             top1[0] ^ top2[6], top1[6]^top3[0], top0[0]};
			
			// Assign flag according to probability. 
			if (top_random_8 <= 8)
				top_random <= 1;
			else
				top_random <= 0;
		    if (TR_random_8 <= 2)
                TR_random <= 1;
            else
                TR_random <= 0;
            
            // Generates random hex using top regs 
            random_hex <= random_hex_8 / 16;
        end
    end
    
    // BTM
    reg [7:0] btm0, btm1, btm2, btm3, btm_random_8;
    
    always @ (posedge Clk, posedge Reset) begin
        if (Reset)
        begin
            // Assign random initial values to each reg 
            btm0 <= 3;
            btm1 <= 230;
            btm2 <= 99;
            btm3 <= 180;
            btm_random_8 <= 0;
            BR_random_8 <= 175; 
            btm_random <= 0;
            BR_random <=0; 
        end
        else
        begin
            // Increment, then randomly combine/XOR regs to produce pseudo random number. 
            btm0 <= btm0 + 3;
            btm1 <= btm1 + 9;
            btm2 <= btm2 + 5;
            btm3 <= btm3 + 7;
            btm_random_8 <= {btm3[7:5], btm2[4:2] ^ btm1[4:2], btm0[1:0]};
            BR_random_8 <= {btm0[7:5], btm3[4:2] ^ btm1[4:2], btm2[1:0]};
            
            // Assign flag according to probability. 
			if (btm_random_8 <= 8)
				btm_random <= 1;
			else
				btm_random <= 0;
			if (BR_random_8 <= 2)
                BR_random <= 1;
            else
                BR_random <= 0;
        end
    end
   
   // LEFT
    reg [7:0] left0, left1, left2, left3, left_random_8;
    
    always @ (posedge Clk, posedge Reset) begin
        if (Reset)
        begin
            // Assign random initial values to each reg 
            left0 <= 12;
            left1 <= 202;
            left2 <= 33;
            left3 <= 99;
            left_random_8 <= 0;
            LR_random_8 <= 175; 
            left_random <= 0;
            LR_random <=0; 
        end
        else
        begin
            // Increment, then randomly combine/XOR regs to produce pseudo random number. 
            left0 <= left0 + 7;
            left1 <= left1 + 9;
            left2 <= left2 + 5;
            left3 <= left3 + 3;
            left_random_8 <= {left3[7:5], left2[4:2] ^ left1[4:2], left0[1:0]};
            LR_random_8 <= {left0[7:5], left3[4:2] ^ left1[4:2], left2[1:0]};
            
            // Assign flag according to probability. 
			if (left_random_8 <= 8)
				left_random <= 1;
			else
				left_random <= 0;
			if (LR_random_8 <= 2)
                LR_random <= 1;
            else
                LR_random <= 0;
        end
    end
    
    // RIGHT
    reg [7:0] right0, right1, right2, right3, right_random_8;
    
    always @ (posedge Clk, posedge Reset) begin
        if (Reset)
        begin
            // Assign random initial values to each reg 
            right0 <= 6;
            right1 <= 48;
            right2 <= 139;
            right3 <= 243;
            right_random_8 <= 0;
            RR_random_8 <= 175; 
            right_random <= 0;
            RR_random <=0; 
        end
        else
        begin
            // Increment, then randomly combine/XOR regs to produce pseudo random number. 
            right0 <= right0 + 3;
            right1 <= right1 + 9;
            right2 <= right2 + 7;
            right3 <= right3 + 5;
            right_random_8 <= {right3[7:5], right2[4:2] ^ right1[4:2], right0[1:0]};
            RR_random_8 <= {right0[7:5], right3[4:2] ^ right1[4:2], right2[1:0]};
            
            // Assign flag according to probability. 
			if (right_random_8 <= 8)
				right_random <= 1;
			else
				right_random <= 0;
			if (RR_random_8 <= 2)
                RR_random <= 1;
            else
                RR_random <= 0;
        end
    end
    
endmodule
