//////////////////////////////////////////////////////////////////////////////////
// Author:			Ayushi Mittal, Kelly Chan
// Create Date:   	04/10/21
// File Name:		nexys_starship.v 
// Description: 	Main file for Nexys Starship (EE 354 Final Project).
//
//
//////////////////////////////////////////////////////////////////////////////////


module nexys_starship_TM(Clk, Reset, q_TM_Init, q_TM_Empty, q_TM_Full, 
                            play_flag, top_monster_sm, top_monster_ctrl, 
							top_random, top_gameover, gameover_ctrl, timer_clk);

	/*  INPUTS */
	input	Clk, Reset, timer_clk;	
	input top_monster_ctrl, top_random;

	/*  OUTPUTS */
	input play_flag, gameover_ctrl;
	output reg top_monster_sm;	
	output reg top_gameover;
	output q_TM_Init, q_TM_Empty, q_TM_Full;
	reg [2:0] state;
	assign {q_TM_Full, q_TM_Empty, q_TM_Init} = state;
		
	localparam 	
	INIT = 3'b001, EMPTY = 3'b010, FULL = 3'b100, UNK = 3'bXXX;     
	
	reg [7:0] top_timer;
	reg [7:0] top_delay;
	reg generate_monster;
	
	always @ (posedge timer_clk, posedge Reset)
	begin
	   if (Reset || state == INIT || state == EMPTY)
	       top_timer <= 0;
	   else if (state == FULL)
           top_timer <= top_timer + 1;
	end
	
	always @ (posedge timer_clk, posedge Reset)
	begin
	   if (Reset || state == INIT || state == FULL)
	       top_delay <= 0;
	   else if (state == EMPTY)
	       top_delay <= top_delay + 1;
	end

	// NSL AND SM
	always @ (posedge Clk, posedge Reset)
	begin 
	    top_monster_sm <= top_monster_ctrl;
	    top_gameover <= gameover_ctrl; 
		if(Reset) 
		  begin
			top_monster_sm <= 0;
			top_gameover <=0; 
			state <= INIT;
			generate_monster <= 0;
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
						top_gameover <= 0; 
						top_monster_sm <= 0;
						generate_monster <= 0;
					end		
					EMPTY: 
					begin
					    // state transfers
					    if (top_monster_sm) state <= FULL;
					    if (top_gameover) state <= INIT;
					    // data transfers 
					    // CLEAR DISPLAY  
					    if (top_delay == 1)
					       generate_monster <= 1;
					    if (top_random && generate_monster)
					    begin
					           top_monster_sm <= 1; 
					           generate_monster <= 0;
					    end
					end
					FULL:
					begin
						// state transfers
						if (!top_monster_sm) state <= EMPTY;	
						if (top_gameover) state <= INIT;
    					// data transfers
						// DISPLAY MONSTER SHOOTING 
						if (top_timer >= 6) 
						begin
						  top_gameover <= 1; 
						end
					end
						
					default:		
						state <= UNK;
				endcase
	end
		
	// OFL
	// no combinational output signals
	
endmodule
