//////////////////////////////////////////////////////////////////////////////////
// Author:			Ayushi Mittal, Kelly Chan
// Create Date:   	04/10/21
// File Name:		nexys_starship_game.v 
// Description: 	Game SM file for Nexys Starship (EE 354 Final Project).
//////////////////////////////////////////////////////////////////////////////////


module nexys_starship_game(Clk, BtnC, BtnU, Reset, q_Init, q_Play, q_GameOver, 
                            play_flag, gameover_ctrl);

	/*  INPUTS */
	input	Clk, BtnC, BtnU, Reset, gameover_ctrl;

	/*  OUTPUTS */
	output reg play_flag;
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
			state <= INIT;
		  end
		else
				case(state)	
					INIT:
					begin
						/* STATE TRANSFERS */ 
						if (play_flag) state <= PLAY;
						
						/* DATA TRANSFERS */
						// BtnU starts game 
						play_flag = 0;
						if (BtnU)
						    play_flag = 1; 
					end		
					PLAY: 
					begin
					    /* STATE TRANSFERS */ 
					    if (gameover_ctrl) state <= GAMEOVER;
						
					    /* DATA TRANSFERS */
					    play_flag = 1;
					end
					GAMEOVER:
					begin
    					/* DATA TRANSFERS */
						play_flag = 0; 	
					end
	
					default:		
						state <= UNK;
				endcase
	end
	
endmodule
