//////////////////////////////////////////////////////////////////////////////////
// Author:			Ayushi Mittal, Kelly Chan
// Create Date:   	04/10/21
// File Name:		nexys_starship_LM.v 
// Description: 	Left Monster file for Nexys Starship (EE 354 Final Project).
//////////////////////////////////////////////////////////////////////////////////


module nexys_starship_LM(Clk, Reset, q_LM_Init, q_LM_Empty, q_LM_Full, 
                            play_flag, left_monster, left_shield, left_random, 
                            left_gameover, gameover_ctrl, timer_clk);

	/*  INPUTS */
	input Clk, Reset, timer_clk;	
	input left_shield, left_random;
	input play_flag, gameover_ctrl;

	/*  OUTPUTS */
	output reg left_gameover, left_monster;
	output q_LM_Init, q_LM_Empty, q_LM_Full;
	
	reg [2:0] state;
	assign {q_LM_Full, q_LM_Empty, q_LM_Init} = state;
		
	localparam 	
	INIT = 3'b001, EMPTY = 3'b010, FULL = 3'b100, UNK = 3'bXXX;     
	
	// Timer and Delay
	reg [7:0] left_timer;
	reg [7:0] left_delay;
	reg generate_monster;
	
	always @ (posedge timer_clk, posedge Reset)
	begin
	   if (Reset || state == INIT || state == EMPTY)
	       left_timer <= 0;
	   else if (state == FULL)
           left_timer <= left_timer + 1;
	end
	
	always @ (posedge timer_clk, posedge Reset)
	begin
	   if (Reset || state == INIT || state == FULL)
	       left_delay <= 0;
	   else if (state == EMPTY)
	       left_delay <= left_delay + 1;
	end

	// NSL AND SM
	always @ (posedge Clk, posedge Reset)
	begin 
	    left_gameover <= gameover_ctrl; 
		if(Reset) 
		  begin
			left_gameover <=0; 
			left_monster <=0; 
			generate_monster <= 0;
			state <= INIT;
		  end
		else				
				case(state)	
					INIT:
					begin
						// state transfers
						if (play_flag) state <= EMPTY;

						// data transfers
						left_gameover <= 0; 
						left_monster <= 0;
						generate_monster <= 0;
					end		
					EMPTY: 
					begin
					    // state transfers
					    if (left_monster) state <= FULL;
					    if (left_gameover) state <= INIT;

					    // data transfers 
					    if (left_delay == 1)
					       generate_monster <= 1;
					    if (left_random && generate_monster)
					    begin
					           left_monster <= 1; 
					           generate_monster <= 0;
					    end
					end
					FULL:
					begin
						// state transfers
						if (!left_monster) state <= EMPTY;	
						if (left_gameover) state <= INIT;

    					// data transfers
						if (left_timer >= 12)
						begin
						   if (left_shield) 
						        left_monster <= 0;
						   else
						        left_gameover <= 1;  
						end
					end
						
					default:		
						state <= UNK;
				endcase
	end
		
	// OFL
	// no combinational output signals
	
endmodule
