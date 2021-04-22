//////////////////////////////////////////////////////////////////////////////////
// Author:			Ayushi Mittal, Kelly Chan
// Create Date:   	04/10/21
// File Name:		nexys_starship.v 
// Description: 	Main file for Nexys Starship (EE 354 Final Project).
//
//
//////////////////////////////////////////////////////////////////////////////////


module nexys_starship_BM(Clk, Reset, q_BM_Init, q_BM_Empty, q_BM_Full, 
                            play_flag, btm_monster_sm, btm_monster_ctrl, 
                            btm_random, btm_gameover, gameover_ctrl, timer_clk);

	/*  INPUTS */
	input	Clk, Reset, timer_clk;
	input btm_monster_ctrl, btm_random; 
	input play_flag, gameover_ctrl; 
	/*  OUTPUTS */
	output reg btm_monster_sm, btm_gameover;		
	output q_BM_Init, q_BM_Empty, q_BM_Full;
	reg [2:0] state;
	assign {q_BM_Full, q_BM_Empty, q_BM_Init} = state;
		
	localparam 	
	INIT = 3'b001, EMPTY = 3'b010, FULL = 3'b100, UNK = 3'bXXX;

	reg [7:0] btm_timer;
	always @ (posedge timer_clk, posedge Reset)
	begin
	   if (Reset || state == INIT || state == EMPTY)
	       btm_timer <= 0;
	   else if (state == FULL)
           btm_timer <= btm_timer + 1;
	end
	
	// NSL AND SM
	always @ (posedge Clk, posedge Reset)
	begin 
	    btm_monster_sm <= btm_monster_ctrl;
	    btm_gameover <= gameover_ctrl;
		if(Reset) 
		  begin
			btm_monster_sm <= 0;
		    btm_gameover <= 0;
			state <= INIT;
		  end
		else				
				case(state)	
					INIT:
					begin
						// state transfers
						if (play_flag) state <= EMPTY;
						// data transfers
						// DISPLAY HOMESCREEN
						// game_timer <= 0;
						btm_gameover <=0; 
						btm_monster_sm <= 0;
					end		
					EMPTY: 
					begin
					    // state transfers
					    if (btm_monster_sm) state <= FULL;
					    if (btm_gameover) state <= INIT;
					    // data transfers 
					    // CLEAR DISPLAY  
					    if (btm_random)
					       btm_monster_sm <= 1; 
					end
					FULL:
					begin
						// state transfers
						if (!btm_monster_sm) state <= EMPTY;	
						if (btm_gameover) state <= INIT;
    					// data transfers
						// DISPLAY MONSTER SHOOTING 
						// increment bottom_timer 
						if (btm_timer >= 6) 
						begin
						  btm_gameover <= 1; 
						end
				    end
						
					default:		
						state <= UNK;
				endcase
	end
		
	// OFL
	// no combinational output signals
	
endmodule
