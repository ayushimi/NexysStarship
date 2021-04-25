//////////////////////////////////////////////////////////////////////////////////
// Author:			Ayushi Mittal, Kelly Chan
// Create Date:   	04/10/21
// File Name:		nexys_starship.v 
// Description: 	Main file for Nexys Starship (EE 354 Final Project).
//
//
//////////////////////////////////////////////////////////////////////////////////


module nexys_starship_TR(Clk, Reset, q_TR_Init, q_TR_Working , q_TR_Repair, BtnU,
                            play_flag, top_broken, hex_combo, random_hex, gameover_ctrl,
                            TR_random, BtnR, TR_combo, timer_clk);

	/*  INPUTS */
	input	Clk, Reset, BtnU, gameover_ctrl;	
	input   play_flag;
	input [3:0] hex_combo, random_hex;
	input   TR_random;
	input   BtnR;
	input   timer_clk;

	/*  OUTPUTS */
	output reg top_broken;	
	output q_TR_Init, q_TR_Working , q_TR_Repair;
	output reg [3:0] TR_combo;
	reg [2:0] state;
	assign {q_TR_Repair, q_TR_Working , q_TR_Init} = state;
		
	localparam 	
	INIT = 3'b001, WORKING = 3'b010, REPAIR = 3'b100, UNK = 3'bXXX;
    
    reg [7:0] top_delay;
    reg break_shooter;
    always @ (posedge timer_clk, posedge Reset)
	begin
	   if (Reset || state == INIT || state == REPAIR)
	       top_delay <= 0;
	   else if (state == WORKING)
	       top_delay <= top_delay + 1;
	end

	// NSL AND SM
	always @ (posedge Clk, posedge Reset)
	begin 
		if(Reset) 
		  begin
			top_broken <= 0; 
			state <= INIT;
		  end
		else				
				case(state)	
					INIT:
					begin
						// state transfers
						if (play_flag) state <= WORKING;
						// data transfers
						top_broken <= 0;
						TR_combo <= 0;
					end		
					WORKING: 
					begin
					    // state transfers
					    if (top_broken) state <= REPAIR;
						if (gameover_ctrl) state <= INIT;
					    // data transfers 
					    if (top_delay == 1)
					       break_shooter <= 1;
					    if (TR_random && break_shooter) 
					    begin
					        top_broken = 1; 
							TR_combo <= random_hex;
					    end
					end
					REPAIR:
					begin
						// state transfers
						if (!top_broken) state <= WORKING;	
						if (gameover_ctrl) state <= INIT;
    					// data transfers
						if (BtnU)
						begin
							if (hex_combo == TR_combo)
								top_broken <= 0;
						end
                        if (BtnR)
                            top_broken <= 0;
						end
						
					default:		
						state <= UNK;
				endcase
	end
		
	// OFL
	// no combinational output signals
	
endmodule
