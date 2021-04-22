//////////////////////////////////////////////////////////////////////////////////
// Author:			Ayushi Mittal, Kelly Chan
// Create Date:   	04/10/21
// File Name:		nexys_starship.v 
// Description: 	Main file for Nexys Starship (EE 354 Final Project).
//
//
//////////////////////////////////////////////////////////////////////////////////


module nexys_starship_game(Clk, BtnC, BtnU, Reset, q_Init, q_Play, q_GameOver, 
                            play_flag, game_over);

	/*  INPUTS */
	input	Clk, BtnC, BtnU, Reset, game_over;

	/*  OUTPUTS */
	// store the two flags 
	output reg play_flag;
	// store current state
	output q_Init, q_Play, q_GameOver;
	reg [2:0] state;
	assign {q_GameOver, q_Play, q_Init} = state;
		
	localparam 	
	INIT = 3'b001, PLAY = 3'b010, GAMEOVER = 3'b100, UNK = 3'bXXX;
	
	// NSL AND SM
	always @ (posedge Clk, posedge Reset)
	begin 
		if(Reset) 
		  begin
		    play_flag <= 0;
			//game_over <= 0;
			state <= INIT;
		  end
		else				// ****** TODO ****** complete several parts
				case(state)	
					INIT:
					begin
						// state transfers
						if (play_flag) state <= PLAY;
						// data transfers
						// DISPLAY HOMESCREEN
						// game_timer <= 0;
						play_flag = 0;
						if (BtnU)
						    play_flag = 1; 
					end		
					PLAY: 
					begin
					    // state transfers
					    if (game_over) state <= GAMEOVER;
					    // data transfers 
					    // DISPLAY SPACESHIP AND TERMINALS 
					    // game_timer <= game_timer + 1; 
					    play_flag = 1;
					end
					GAMEOVER:
					begin
						// state transfers
						if (BtnU) state <= INIT;	
    					// data transfers
						// DISPLAY END SCREEN AND GAME TIMER
						end
						
					default:		
						state <= UNK;
				endcase
	end
		
	// OFL
	// no combinational output signals
	
endmodule
