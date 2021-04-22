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
							top_monster_vga, top_random, game_over, temp, BtnR);

	/*  INPUTS */
	input	Clk, Reset;	
	input top_monster_ctrl, top_random, top_monster_vga, BtnR;

	/*  OUTPUTS */
	input play_flag;
	output reg top_monster_sm;
	output reg [3:0] temp;	
	output reg game_over;
	output q_TM_Init, q_TM_Empty, q_TM_Full;
	reg[19:0] top_random_counter;
	reg slow_down;
	reg [2:0] state;
	assign {q_TM_Full, q_TM_Empty, q_TM_Init} = state;
		
	localparam 	
	INIT = 3'b001, EMPTY = 3'b010, FULL = 3'b100, UNK = 3'bXXX;        

	// NSL AND SM
	always @ (posedge Clk, posedge Reset)
	begin 
	    top_monster_sm <= top_monster_ctrl;
		if(Reset) 
		  begin
			top_monster_sm <= 0;
			top_random_counter<= 0;
			slow_down <= 0;
			state <= INIT;
			temp<=0;
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
						top_monster_sm <= 0;
					end		
					EMPTY: 
					begin
					    // state transfers
					    if (top_monster_sm) state <= FULL;
					    if (game_over) state <= INIT;
					    // data transfers 
					    // CLEAR DISPLAY  
					    //slow_down <= 0;
//					    temp<=0;
					    if (top_random)
					    begin
					       //temp<=temp+1;
					        top_random_counter <= top_random_counter + 1;
					        if (top_random_counter == 1000000) begin
					           top_random_counter <= 0;
					           top_monster_sm <= 1; 
					        // top_timer <= 0; 
					        end
					        
					    end
					end
					FULL:
					begin
						// state transfers
						if (!top_monster_sm) state <= EMPTY;	
						if (game_over) state <= INIT;
    					// data transfers
						// DISPLAY MONSTER SHOOTING 
						// increment top_timer 
						// if (top_timer) expires 
						// game_over = 1; 
						// if (slow_down == 0) slow_down <= 1;
//						temp<=temp+1;
//						if (temp == 2)
//						  temp <= 0;
						//top_monster_sm <= top_monster_vga;
						end
						
					default:		
						state <= UNK;
				endcase
	end
		
	// OFL
	// no combinational output signals
	
endmodule
