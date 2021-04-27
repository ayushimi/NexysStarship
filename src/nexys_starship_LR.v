//////////////////////////////////////////////////////////////////////////////////
// Author:			Ayushi Mittal, Kelly Chan
// Create Date:   	04/10/21
// File Name:		nexys_starship_LR.v 
// Description: 	Left Repair SM file for Nexys Starship (EE 354 Final Project).
//////////////////////////////////////////////////////////////////////////////////


module nexys_starship_LR(Clk, Reset, q_LR_Init, q_LR_Working , q_LR_Repair, BtnL,
                            play_flag, left_broken, left_shield, hex_combo, random_hex, 
                            gameover_ctrl, LR_random, LR_combo, timer_clk);

	/*  INPUTS */
	input Clk, Reset, BtnL, timer_clk;
	input play_flag, gameover_ctrl;	
	input [3:0] hex_combo, random_hex;
	input LR_random, left_shield;

	/*  OUTPUTS */
	output reg left_broken;	
	output reg [3:0] LR_combo;
	output q_LR_Init, q_LR_Working , q_LR_Repair;
	
	reg [2:0] state;
	assign {q_LR_Repair, q_LR_Working , q_LR_Init} = state;
		
	localparam 	
	INIT = 3'b001, WORKING = 3'b010, REPAIR = 3'b100, UNK = 3'bXXX;
    
    // Delay
	reg [7:0] left_delay;
    reg break_shield;
	
	// Responsible for delay timer to create buffer between needed repairs 
    always @ (posedge timer_clk, posedge Reset)
	begin
	   if (Reset || state == INIT || state == REPAIR)
	       left_delay <= 0;
	   else if (state == WORKING)
	       left_delay <= left_delay + 1;
	end

	// NSL for State Machine 
	always @ (posedge Clk, posedge Reset)
	begin 
		if(Reset) 
		  begin
			left_broken <= 0; 
			break_shield <= 0;
			state <= INIT;
		  end
		else				
				case(state)	
					INIT:
					begin
						/* STATE LRANSFERS */ 
						if (play_flag) state <= WORKING;
						
						/* DATA LRANSFERS */
						left_broken <= 0;
						LR_combo <= 0;
					end		
					WORKING: 
					begin
					    /* STATE LRANSFERS */ 
					    if (left_broken) state <= REPAIR;
						if (gameover_ctrl) state <= INIT;
						
					    /* DATA LRANSFERS */ 
					    // Randomly breaks 
					    if (left_delay >= 1)
					       break_shield <= 1;
					    if (LR_random && break_shield && !left_shield) 
					    begin
					        left_broken = 1; 
							LR_combo <= random_hex;
							break_shield <= 0;
					    end
					end
					REPAIR:
					begin
						/* STATE LRANSFERS */ 
						if (!left_broken) state <= WORKING;	
						if (gameover_ctrl) state <= INIT;
						
    					//* DATA LRANSFERS */
    					// If submit button pressed and correct switch input,
    					// repair broken part
						if (BtnL)
						begin
							if (hex_combo == LR_combo)
								left_broken <= 0;
						end
					end
					
					default:		
						state <= UNK;
				endcase
	end
		
endmodule
