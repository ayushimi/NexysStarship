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
                            top_broken, game_over);

	/*  INPUTS */
	input	Clk, Reset;	
	input top_monster_ctrl;

	/*  OUTPUTS */
	output reg play_flag, top_monster_sm, top_broken, game_over;		
	output q_TM_Init, q_TM_Empty, q_TM_Full;
	reg [2:0] state;
	assign {q_TM_Full, q_TM_Empty, q_TM_Init} = state;
		
	localparam 	
	INIT = 3'b001, EMPTY = 3'b010, FULL = 3'b100, UNK = 3'bXXX;
	
	/*
	function [0:0] generateMonster (input[0:0] R);
	begin: GENERATEMONSTER
        reg [7:0] rand;
        rand = $random() % 256;
        if (rand>(99*255/100))
           R = 1'b1;
        else
           R = 1'b0; // 99% chance of being 0
   
	     generateMonster=R;
	end
	endfunction
	*/
	
	always @ (posedge Clk)
	begin 
	    top_monster_sm = top_monster_ctrl; 
	end

	// NSL AND SM
	always @ (posedge Clk, posedge Reset)
	begin 
		if(Reset) 
		  begin
		    play_flag <= 0;
			top_monster_sm <= 0;
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
						top_monster_sm = 0;
					end		
					EMPTY: 
					begin
					    // state transfers
					    if (top_monster_sm) state <= FULL;
					    // data transfers 
					    // CLEAR DISPLAY  
					    //if (generateMonster(1)) 
					    begin
					        top_monster_sm = 1; 
					        // top_timer <= 0; 
					    end
					end
					FULL:
					begin
						// state transfers
						if (!top_monster_sm) state <= EMPTY;	
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
