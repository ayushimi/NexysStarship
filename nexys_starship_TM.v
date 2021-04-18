//////////////////////////////////////////////////////////////////////////////////
// Author:			Ayushi Mittal, Kelly Chan
// Create Date:   	04/10/21
// File Name:		nexys_starship.v 
// Description: 	Main file for Nexys Starship (EE 354 Final Project).
//
//
//////////////////////////////////////////////////////////////////////////////////


module nexys_starship_TM(Clk, Reset, q_TM_Init, q_TM_Empty, q_TM_Full, 
                            play_flag, top_monster, top_broken, game_over);

	/*  INPUTS */
	input	Clk, BtnC, Reset;	

	/*  OUTPUTS */
	output reg [7:0] play_flag, top_monster, top_broken, game_over;		
	output q_TM_Init, q_TM_Empty, q_TM_Full;
	reg [2:0] state;
	assign {q_TM_Full, q_TM_Empty, q_TM_Init} = state;
		
	localparam 	
	INIT = 3'b001, EMPTY = 3'b010, FULL = 3'b100, UNK = 3'bXXX;
	
	function [1:0] generateMonster ();
	begin 
	     assert(randomize(generateMonster) with 
	           { generateMonster dist {0:= 999, 1:= 1}; } );
	end
	end function

	// NSL AND SM
	always @ (posedge Clk, posedge Reset)
	begin 
		if(Reset) 
		  begin
		    play_flag <= 0;
			top_monster <= 0;
			top_broken <= 0; 
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
						top_monster = 0;
					end		
					EMPTY: 
					begin
					    // state transfers
					    if (top_monster) state <= FULL;
					    // data transfers 
					    // CLEAR DISPLAY  
					    if (generateMonster()) 
					    begin
					        top_monster = 1; 
					        // top_timer <= 0; 
					    end
					end
					FULL:
					begin
						// state transfers
						if (!top_monster) state <= EMPTY;	
    					// data transfers
						// DISPLAY MONSTER SHOOTING 
						// increment top_timer 
						// if (top_timer) expires 
						// game_over = 1; 
						end
						
					default:		
						state <= UNK;
				endcase
	end
		
	// OFL
	// no combinational output signals
	
endmodule
