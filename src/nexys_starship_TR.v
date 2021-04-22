//////////////////////////////////////////////////////////////////////////////////
// Author:			Ayushi Mittal, Kelly Chan
// Create Date:   	04/10/21
// File Name:		nexys_starship.v 
// Description: 	Main file for Nexys Starship (EE 354 Final Project).
//
//
//////////////////////////////////////////////////////////////////////////////////


module nexys_starship_TR(Clk, Reset, q_TR_Init, q_TR_Working , q_TR_Repair, BtnU,
                            play_flag, top_broken, hex_combo, random_hex, gameover_ctrl);

	/*  INPUTS */
	input	Clk, Reset, BtnU, gameover_ctrl;	
	input   play_flag, hex_combo, random_hex;

	/*  OUTPUTS */
	output reg top_broken;	
	output q_TR_Init, q_TR_Working , q_TR_Repair;
	reg [3:0] random_repair_combo;
	reg [2:0] state;
	assign {q_TR_Repair, q_TR_Working , q_TR_Init} = state;
		
	localparam 	
	INIT = 3'b001, WORKING = 3'b010, REPAIR = 3'b100, UNK = 3'bXXX;
	
	
	// PSEUDO-RANDOM NUMBER GENERATOR
    reg [7:0] count0, count1, count2, count3, random;
    reg monster;
    always @ (posedge Clk, posedge Reset) begin
        if (Reset)
        begin
            count0 <= 0;
            count1 <= 31;
            count2 <= 127;
            count3 <= 214;
            random <= 0;
        end
        else
        begin
            count0 <= count0 + 1;
            count1 <= count1 + 2;
            count2 <= count2 + 3;
            count3 <= count3 + 4;
            random <= {count3[7:5], count2[4:2] ^ count1[4:2], count0[1:0]};
        end
    
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
					end		
					WORKING: 
					begin
					    // state transfers
					    if (top_broken) state <= REPAIR;
						if (gameover_ctrl) state <= INIT;
					    // data transfers 
					    if (random <= 25) 
					    begin
					        top_broken <= 1; 
							random_repair_combo <= random_hex;
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
							if (hex_combo == random_repair_combo)
								top_broken <= 0;
						end
						end
						
					default:		
						state <= UNK;
				endcase
	end
		
	// OFL
	// no combinational output signals
	
endmodule
