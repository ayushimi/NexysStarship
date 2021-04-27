//////////////////////////////////////////////////////////////////////////////////
// Author:			Ayushi Mittal, Kelly Chan
// Create Date:   	04/10/21
// File Name:		nexys_starship_RR.v 
// Description: 	Right Repair SM file for Nexys Starship (EE 354 Final Project).
//////////////////////////////////////////////////////////////////////////////////


module nexys_starship_RR(Clk, Reset, q_RR_Init, q_RR_Working , q_RR_Repair, BtnL,
                            play_flag, right_broken, hex_combo, random_hex, gameover_ctrl,
                            RR_random, RR_combo, timer_clk);

	/*  INPUTS */
	input Clk, Reset, BtnL, timer_clk;
	input play_flag, gameover_ctrl;	
	input [3:0] hex_combo, random_hex;
	input RR_random;

	/*  OUTPUTS */
	output reg right_broken;	
	output reg [3:0] RR_combo;
	output q_RR_Init, q_RR_Working , q_RR_Repair;
	
	reg [2:0] state;
	assign {q_RR_Repair, q_RR_Working , q_RR_Init} = state;
		
	localparam 	
	INIT = 3'b001, WORKING = 3'b010, REPAIR = 3'b100, UNK = 3'bXXX;
    
    // Delay
	reg [7:0] right_delay;
    reg break_shield;
	
	// Responsible for delay timer to create buffer between needed repairs 
    always @ (posedge timer_clk, posedge Reset)
	begin
	   if (Reset || state == INIT || state == REPAIR)
	       right_delay <= 0;
	   else if (state == WORKING)
	       right_delay <= right_delay + 1;
	end

	// NSL for State Machine 
	always @ (posedge Clk, posedge Reset)
	begin 
		if(Reset) 
		  begin
			right_broken <= 0; 
			break_shield <= 0;
			state <= INIT;
		  end
		else				
				case(state)	
					INIT:
					begin
						/* STATE RRANSFERS */ 
						if (play_flag) state <= WORKING;
						
						/* DATA RRANSFERS */
						right_broken <= 0;
						RR_combo <= 0;
					end		
					WORKING: 
					begin
					    /* STATE RRANSFERS */ 
					    if (right_broken) state <= REPAIR;
						if (gameover_ctrl) state <= INIT;
						
					    /* DATA RRANSFERS */ 
					    // Randomly breaks 
					    if (right_delay == 1)
					       break_shield <= 1;
					    if (RR_random && break_shield) 
					    begin
					        right_broken = 1; 
							RR_combo <= random_hex;
							break_shield <= 0;
					    end
					end
					REPAIR:
					begin
						/* STATE RRANSFERS */ 
						if (!right_broken) state <= WORKING;	
						if (gameover_ctrl) state <= INIT;
						
    					//* DATA RRANSFERS */
    					// If submit button pressed and correct switch input,
    					// repair broken part
						if (BtnU)
						begin
							if (hex_combo == RR_combo)
								right_broken <= 0;
						end
					end
					
					default:		
						state <= UNK;
				endcase
	end
		
endmodule
