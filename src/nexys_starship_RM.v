//////////////////////////////////////////////////////////////////////////////////
// Author:			Ayushi Mittal, Kelly Chan
// Create Date:   	04/10/21
// File Name:		nexys_starship.v 
// Description: 	Main file for Nexys Starship (EE 354 Final Project).
//
//
//////////////////////////////////////////////////////////////////////////////////


module nexys_starship_RM(Clk, Reset, q_RM_Init, q_RM_Empty, q_RM_Full, 
                            play_flag, right_monster, right_shield, right_random, 
                            right_gameover, gameover_ctrl, timer_clk);

	/*  INPUTS */
	input	Clk, Reset, timer_clk;	
	input right_random, right_shield;

	/*  OUTPUTS */
	input play_flag, gameover_ctrl;
	output reg right_gameover, right_monster;
	output q_RM_Init, q_RM_Empty, q_RM_Full;
	reg [2:0] state;
	assign {q_RM_Full, q_RM_Empty, q_RM_Init} = state;
		
	localparam 	
	INIT = 3'b001, EMPTY = 3'b010, FULL = 3'b100, UNK = 3'bXXX;     
	
	reg [7:0] right_timer;
	reg [7:0] right_delay;
	reg generate_monster;
	
	always @ (posedge timer_clk, posedge Reset)
	begin
	   if (Reset || state == INIT || state == EMPTY)
	       right_timer <= 0;
	   else if (state == FULL)
           right_timer <= right_timer + 1;
	end
	
	always @ (posedge timer_clk, posedge Reset)
	begin
	   if (Reset || state == INIT || state == FULL)
	       right_delay <= 0;
	   else if (state == EMPTY)
	       right_delay <= right_delay + 1;
	end

	// NSL AND SM
	always @ (posedge Clk, posedge Reset)
	begin 
	    right_gameover <= gameover_ctrl; 
		if(Reset) 
		  begin
			right_gameover <=0; 
			right_monster <=0; 
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
						right_gameover <= 0; 
						right_monster <= 0;
						generate_monster <= 0;
					end		
					EMPTY: 
					begin
					    // state transfers
					    if (right_monster) state <= FULL;
					    if (right_gameover) state <= INIT;
					    // data transfers 
					    // CLEAR DISPLAY  
					    if (right_delay == 1)
					       generate_monster <= 1;
					    if (right_random && generate_monster)
					    begin
					           right_monster <= 1; 
					           generate_monster <= 0;
					    end
					end
					FULL:
					begin
						// state transfers
						if (!right_monster) state <= EMPTY;	
						if (right_gameover) state <= INIT;
    					// data transfers
						// DISPLAY MONSTER SHOOTING 
						if (right_timer >= 12)
						begin
						   if (right_shield) 
						        right_monster <= 0;
						   else
						        right_gameover <= 1;  
						end
					end
						
					default:		
						state <= UNK;
				endcase
	end
		
	// OFL
	// no combinational output signals
	
endmodule
