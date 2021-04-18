//////////////////////////////////////////////////////////////////////////////////
// Author:			Ayushi Mittal, Kelly Chan
// Create Date:   	04/10/21
// File Name:		nexys_starship.v 
// Description: 	Main file for Nexys Starship (EE 354 Final Project).
//
//
//////////////////////////////////////////////////////////////////////////////////


module nexys_starship_BM(Clk, Reset, q_BM_Init, q_BM_Empty, q_BM_Full, 
                            play_flag, btm_monster, btm_broken, game_over);

	/*  INPUTS */
	input	Clk, Reset;
	
	/*  OUTPUTS */
	output reg play_flag, btm_monster, btm_broken, game_over;		
	output q_BM_Init, q_BM_Empty, q_BM_Full;
	reg [2:0] state;
	assign {q_BM_Full, q_BM_Empty, q_BM_Init} = state;
		
	localparam 	
	INIT = 3'b001, EMPTY = 3'b010, FULL = 3'b100, UNK = 3'bXXX;

	// NSL AND SM
	always @ (posedge Clk, posedge Reset)
	begin 
		if(Reset) 
		  begin
		    play_flag <= 0;
			btm_monster <= 0;
			btm_broken <= 0; 
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
						btm_monster = 0;
					end		
					EMPTY: 
					begin
					    // state transfers
					    if (btm_monster) state <= FULL;
					    // data transfers 
					    // CLEAR DISPLAY  
					    // if (generateMonster()) 
					    btm_monster = 1; 
					    // bottom_timer <= 0; 
					end
					FULL:
					begin
						// state transfers
						if (!btm_monster) state <= EMPTY;	
    					// data transfers
						// DISPLAY MONSTER SHOOTING 
						// increment bottom_timer 
						// if (bottom_timer) expires 
						// game_over = 1; 
						end
						
					default:		
						state <= UNK;
				endcase
	end
		
	// OFL
	// no combinational output signals
	
endmodule
