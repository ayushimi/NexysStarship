//////////////////////////////////////////////////////////////////////////////////
// Author:			Ayushi Mittal, Kelly Chan
// Create Date:   	04/10/21
// File Name:		nexys_starship.v 
// Description: 	Main file for Nexys Starship (EE 354 Final Project).
//
//
//////////////////////////////////////////////////////////////////////////////////


module nexys_starship_BR(Clk, Reset, q_BR_Init, q_BR_Working , q_BR_Repair, BtnD,
                            play_flag, btm_broken, hex_combo, random_hex, gameover_ctrl,
                            BR_random, BtnR, BR_combo, timer_clk);

	/*  INPUTS */
	input	Clk, Reset, BtnD, gameover_ctrl;	
	input   play_flag;
	input [3:0] hex_combo, random_hex;
	input   BR_random;
	input   BtnR;
	input   timer_clk;

	/*  OUTPUTS */
	output reg btm_broken;	
	output q_BR_Init, q_BR_Working , q_BR_Repair;
	output reg [3:0] BR_combo;
	reg [2:0] state;
	assign {q_BR_Repair, q_BR_Working , q_BR_Init} = state;
		
	localparam 	
	INIT = 3'b001, WORKING = 3'b010, REPAIR = 3'b100, UNK = 3'bXXX;
    
    reg [7:0] btm_delay;
    reg break_shooter;
    always @ (posedge timer_clk, posedge Reset)
	begin
	   if (Reset || state == INIT || state == REPAIR)
	       btm_delay <= 0;
	   else if (state == WORKING)
	       btm_delay <= btm_delay + 1;
	end

	// NSL AND SM
	always @ (posedge Clk, posedge Reset)
	begin 
		if(Reset) 
		  begin
			btm_broken <= 0; 
			break_shooter <= 0;
			state <= INIT;
		  end
		else				
				case(state)	
					INIT:
					begin
						// state transfers
						if (play_flag) state <= WORKING;
						// data transfers
						btm_broken <= 0;
						BR_combo <= 0;
					end		
					WORKING: 
					begin
					    // state transfers
					    if (btm_broken) state <= REPAIR;
						if (gameover_ctrl) state <= INIT;
					    // data transfers 
					    if (btm_delay == 1)
					       break_shooter <= 1;
					    if (BR_random && break_shooter) 
					    begin
					        btm_broken = 1; 
							BR_combo <= random_hex;
							break_shooter <= 0;
					    end
					end
					REPAIR:
					begin
						// state transfers
						if (!btm_broken) state <= WORKING;	
						if (gameover_ctrl) state <= INIT;
    					// data transfers
						if (BtnD)
						begin
							if (hex_combo == BR_combo)
								btm_broken <= 0;
						end
                        if (BtnR)
                            btm_broken <= 0;
						end
						
					default:		
						state <= UNK;
				endcase
	end
		
	// OFL
	// no combinational output signals
	
endmodule
