//////////////////////////////////////////////////////////////////////////////////
// Author:			Ayushi Mittal, Kelly Chan
// Create Date:   	04/10/21
// File Name:		nexys_starship.v 
// Description: 	Main file for Nexys Starship (EE 354 Final Project).
//
//
//////////////////////////////////////////////////////////////////////////////////


module nexys_starship_LR(Clk, Reset, q_LR_Init, q_LR_Working , q_LR_Repair, BtnL,
                            play_flag, left_broken, hex_combo, random_hex, gameover_ctrl,
                            LR_random, BtnR, LR_combo);

	/*  INPUTS */
	input	Clk, Reset, BtnL, gameover_ctrl;	
	input   play_flag;
	input [3:0] hex_combo, random_hex;
	input   LR_random;
	input   BtnR;

	/*  OUTPUTS */
	output reg left_broken;	
	output q_LR_Init, q_LR_Working , q_LR_Repair;
	output reg [3:0] LR_combo;
	reg [2:0] state;
	assign {q_LR_Repair, q_LR_Working , q_LR_Init} = state;
		
	localparam 	
	INIT = 3'b001, WORKING = 3'b010, REPAIR = 3'b100, UNK = 3'bXXX;
    
        

	// NSL AND SM
	always @ (posedge Clk, posedge Reset)
	begin 
		if(Reset) 
		  begin
			left_broken <= 0; 
			state <= INIT;
		  end
		else				
				case(state)	
					INIT:
					begin
						// state transfers
						if (play_flag) state <= WORKING;
						// data transfers
						left_broken = 0;
						LR_combo <= 0;
					end		
					WORKING: 
					begin
					    // state transfers
					    if (left_broken) state <= REPAIR;
						if (gameover_ctrl) state <= INIT;
					    // data transfers 
					    if (LR_random) 
					    begin
					        left_broken = 1; 
							LR_combo <= random_hex;
					    end
					end
					REPAIR:
					begin
						// state transfers
						if (!left_broken) state <= WORKING;	
						if (gameover_ctrl) state <= INIT;
    					// data transfers
						if (BtnL)
						begin
							if (hex_combo == LR_combo)
								left_broken = 0;
						end
                        if (BtnR)
                            left_broken = 0;
						end
						
					default:		
						state <= UNK;
				endcase
	end
		
	// OFL
	// no combinational output signals
	
endmodule
