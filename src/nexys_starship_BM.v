//////////////////////////////////////////////////////////////////////////////////
// Author:			Ayushi Mittal, Kelly Chan
// Create Date:   	04/10/21
// File Name:		nexys_starship.v 
// Description: 	Main file for Nexys Starship (EE 354 Final Project).
//
//
//////////////////////////////////////////////////////////////////////////////////


module nexys_starship_BM(Clk, Reset, q_BM_Init, q_BM_Empty, q_BM_Full, 
                            play_flag, btm_monster_sm, btm_monster_ctrl, game_over, timerClk, btm_random);

	/*  INPUTS */
	input	Clk, Reset, btm_monster_ctrl, play_flag, timerClk, btm_random;
	
	/*  OUTPUTS */
	output reg btm_monster_sm, game_over;		
	output q_BM_Init, q_BM_Empty, q_BM_Full;
	reg [2:0] state;
	assign {q_BM_Full, q_BM_Empty, q_BM_Init} = state;
		
	localparam 	
	INIT = 3'b001, EMPTY = 3'b010, FULL = 3'b100, UNK = 3'bXXX;

	reg [7:0] bottom_timer;
	always @ (posedge timerClk, posedge Reset)
	begin
	   if (Reset || state == INIT)
	       bottom_timer <= 0;
	   else if (state == FULL)
           bottom_timer <= bottom_timer + 1;
	end
	
	// NSL AND SM
	always @ (posedge Clk, posedge Reset)
	begin 
	    btm_monster_sm <= btm_monster_ctrl;
		if(Reset) 
		  begin
			btm_monster_sm <= 0;
		  game_over <= 0;
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
						btm_monster_sm <= 0;
					end		
					EMPTY: 
					begin
					    // state transfers
					    if (btm_monster_sm) state <= FULL;
					    if (game_over) state <= INIT;
					    // data transfers 
					    // CLEAR DISPLAY  
					    if (btm_random)
					       btm_monster_sm <= 1; 
					end
					FULL:
					begin
						// state transfers
						if (!btm_monster_sm) state <= EMPTY;	
						if (game_over) state <= INIT;
    					// data transfers
						// DISPLAY MONSTER SHOOTING 
						// increment bottom_timer 
						if (bottom_timer >= 100) begin
						  game_over = 1; 
						end
				    end
						
					default:		
						state <= UNK;
				endcase
	end
		
	// OFL
	// no combinational output signals
	
endmodule
