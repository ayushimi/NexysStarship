//////////////////////////////////////////////////////////////////////////////////
// Author:			Shideh Shahidi, Bilal Zafar, Gandhi Puvvada
// Create Date:		02/25/08
// File Name:		ee354_GCD_top.v 
// Description: 
//
//
// Revision: 		2.2
// Additional Comments: 
// 10/13/2008 debouncing and single_clock_wide pulse_generation modules are added by Gandhi
// 10/13/2008 Clock Enable (CEN) has been added by Gandhi
//  3/ 1/2010 The Spring 2009 debounce design is replaced by the Spring 2010 debounce design
//            Now, in part 2 of the GCD lab, we do single-stepping 
//  2/19/2012 Nexys-2 to Nexys-3 conversion done by Gandhi
//  02/20/2020 Nexys-3 to Nexys-4 conversion done by Yue (Julien) Niu
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module nexys_starship_top
		(MemOE, MemWR, RamCS, QuadSpiFlashCS, // Disable the three memory chips

        ClkPort,                           // the 100 MHz incoming clock signal
		
		BtnL, BtnU, BtnD, BtnR,            // the Left, Up, Down, and the Right buttons BtnL, BtnR,
		BtnC,                              // the center button (this is our reset in most of our designs)
		Sw3, Sw2, Sw1, Sw0, // 8 switches
		Ld7, Ld6, Ld5, Ld4, Ld3, Ld2, Ld1, Ld0, // 8 LEDs
		An3, An2, An1, An0,			       // 4 anodes
		An7, An6, An5, An4,                // another 4 anodes which are not used
		Ca, Cb, Cc, Cd, Ce, Cf, Cg,        // 7 cathodes
		Dp                                 // Dot Point Cathode on SSDs
	  );

	/*  INPUTS */
	// Clock & Reset I/O
	input		ClkPort;	
	// Project Specific Inputs
	input		BtnL, BtnU, BtnD, BtnR, BtnC;	
	input		Sw3, Sw2, Sw1, Sw0;
	
	
	/*  OUTPUTS */
	// Control signals on Memory chips 	(to disable them)
	output 	MemOE, MemWR, RamCS, QuadSpiFlashCS;
	// Project Specific Outputs
	// LEDs
	output 	Ld0, Ld1, Ld2, Ld3, Ld4, Ld5, Ld6, Ld7;
	// SSD Outputs
	output 	Cg, Cf, Ce, Cd, Cc, Cb, Ca, Dp;
	output 	An0, An1, An2, An3;	
	output 	An4, An5, An6, An7;	

	
	/*  LOCAL SIGNALS */
	wire		Reset, ClkPort;
	wire		board_clk, sys_clk;
	wire [1:0] 	ssdscan_clk;
	reg [26:0]	DIV_CLK;
	
	wire Start_Ack_Pulse;
	wire Up_Pulse, Down_Pulse, Left_Pulse, Right_Pulse, Center_Pulse;
	wire BtnR_Pulse, BtnU_Pulse, BtnL_Pulse, BtnD_Pulse, BtnC_Pulse;
	wire q_Init, q_Play, q_Gameover; 
	wire q_TR_Init, q_TR_Working, q_TR_Repair;
	wire q_BR_Init, q_BR_Working, q_BR_Repair;
	wire q_LR_Init, q_LR_Working, q_LR_Repair;
	wire q_RR_Init, q_RR_Working, q_RR_Repair;
	wire q_TM_Init, q_TM_Empty, q_TM_Full;
	wire q_BM_Init, q_BM_Empty, q_BM_Full;
	wire q_LM_Init, q_LM_Empty, q_LM_Unshielded, q_LM_Shielded; 
	wire q_RM_Init, q_RM_Empty, q_RM_Unshielded, q_RM_Shielded; 
	
	// TODO: add game_timer reg 
	reg play_flag, game_over;
	reg top_broken, btm_broken, left_broken, right_broken;
	reg top_monster, btm_monster, left_monster, right_monster; 
	reg r_shield, l_shield; 
	reg [3:0] hex_combo; 
	reg [3:0] left_repair_combo, right_repair_combo, up_repair_combo, btm_repair_combo;
	reg [3:0]	SSD;
	wire [3:0]	SSD0;
	reg [7:0]  SSD_CATHODES;
	
//------------	
// Disable the three memories so that they do not interfere with the rest of the design.
	assign {MemOE, MemWR, RamCS, QuadSpiFlashCS} = 4'b1111;
	
	
//------------
// CLOCK DIVISION

	// The clock division circuitary works like this:
	//
	// ClkPort ---> [BUFGP2] ---> board_clk
	// board_clk ---> [clock dividing counter] ---> DIV_CLK
	// DIV_CLK ---> [constant assignment] ---> sys_clk;
	
	BUFGP BUFGP1 (board_clk, ClkPort); 	

// As the ClkPort signal travels throughout our design,
// it is necessary to provide global routing to this signal. 
// The BUFGPs buffer these input ports and connect them to the global 
// routing resources in the FPGA.

	assign Reset = BtnC;
	
//------------
	// Our clock is too fast (100MHz) for SSD scanning
	// create a series of slower "divided" clocks
	// each successive bit is 1/2 frequency
  always @(posedge board_clk, posedge Reset) 	
    begin							
        if (Reset)
		DIV_CLK <= 0;
        else
		DIV_CLK <= DIV_CLK + 1'b1;
    end
//-------------------	
	// In this design, we run the core design at full 100MHz clock!
	assign	sys_clk = board_clk;
	// assign	sys_clk = DIV_CLK[25];

//------------
// INPUT: SWITCHES & BUTTONS

	assign {Up_Pulse, Down_Pulse, Left_Pulse, Right_Pulse, Center_Pulse} = 
	        {BtnU_Pulse, BtnD_Pulse, BtnL_Pulse, BtnR_Pulse, BtnC_Pulse};

ee354_debouncer #(.N_dc(28)) ee354_debouncer_0 
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnR), .DPB( ), 
		.SCEN(BtnR_Pulse), .MCEN( ), .CCEN( ));

ee354_debouncer #(.N_dc(28)) ee354_debouncer_1 // ****** TODO  in Part 2 ******
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnU), .DPB( ), // complete this instantiation
		.SCEN(BtnU_Pulse), .MCEN( ), .CCEN( )); // to produce BtnU_Pulse from BtnU
		
ee354_debouncer #(.N_dc(28)) ee354_debouncer_2 
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnL), .DPB( ), 
		.SCEN(BtnL_Pulse), .MCEN( ), .CCEN( ));

ee354_debouncer #(.N_dc(28)) ee354_debouncer_3 
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnD), .DPB( ), 
		.SCEN(BtnD_Pulse), .MCEN( ), .CCEN( ));
		
ee354_debouncer #(.N_dc(28)) ee354_debouncer_4 
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnC), .DPB( ), 
		.SCEN(BtnC_Pulse), .MCEN( ), .CCEN( ));
//------------
// DESIGN
	// On two pushes of BtnR, numbers A and B are recorded in Ain and Bin
    // (registers of the TOP) respectively
	always @ (posedge sys_clk, posedge Reset)
	begin
		if(Reset)
		begin
            top_broken <= 0;
            btm_broken <= 0;
            left_broken <= 0;
            right_broken <= 0;
	        top_monster <= 0;
	        btm_monster <= 0;
	        left_monster <= 0;
	        right_monster <= 0; 
	        r_shield <= 0;
	        l_shield <= 0; 
	        hex_combo <= 4'b0000; 
	        left_repair_combo <= 4'b0000;
	        right_repair_combo <= 4'b0000;
	        up_repair_combo <= 4'b0000;
	        btm_repair_combo <= 4'b0000;
		end
		else
		begin
			if (Center_Pulse)  	// Note: in_AB_Pulse is same as BtnR_Pulse.
								// ****** TODO  in Part 2 ******
								// Complete the lines below so that you deposit the value on switches
								// either in Ain or in Bin based on the value of the flag A_bar_slash_B. 
								// Also you need to toggle the value of the flag A_bar_slash_B.
				begin	
					hexCombo <= {Sw3, Sw2, Sw1, Sw0};	
				end
		end
	end
	
	// the state machine module
	nexys_starship_game nexys_starship_game_1(.Clk(sys_clk), .BtnC(Center_Pulse), .Reset(Reset),  
						  .q_Init(q_Init), .q_Play(q_Play), .q_GameOver(q_GameOver), 
						  .play_flag(play_flag), .game_over(game_over));

//------------
// OUTPUT: LEDS
	
	assign {Ld7, Ld6, Ld5} = {q_Init, q_Play, q_GameOver};
	assign {Ld3, Ld2, Ld1, Ld0} = {BtnL, BtnU, BtnR, BtnD}; // Reset is driven by BtnC
	// Here
	// BtnL = Start/Ack
	// BtnU = Single-Step
	// BtnR = in_A_in_B
	// BtnD = not used here
	
//------------
// SSD (Seven Segment Display)
	
	//SSDs show Ain and Bin in initial state, A and B in subtract state, and GCD and i_count in multiply and done states.
	// ****** TODO  in Part 2 ******
	// assign y = s ? i1 : i0;  // an example of a 2-to-1 mux coding
	// assign y = s1 ? (s0 ? i3: i2): (s0 ? i1: i0); // an example of a 4-to-1 mux coding
	assign SSD0 = {Sw3, Sw2, Sw1, Sw0};


	// need a scan clk for the seven segment display 
	// 191Hz (100 MHz / 2^19) works well
	assign ssdscan_clk = DIV_CLK[19:18];
	
	assign An0	=  !((ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 11
	// close another four anodes
	assign An7 = 1'b1;
	assign An6 = 1'b1;
	assign An5 = 1'b1;
	assign An4 = 1'b1;
	assign An3 = 1'b1;
	assign An2 = 1'b1;
	assign An1 = 1'b1;
	
	
	always @ (ssdscan_clk, SSD0)
	begin : SSD_SCAN_OUT
		case (ssdscan_clk) 
				  2'b11: SSD = SSD0;
		endcase 
	end
	
	// and finally convert SSD_num to ssd
	// We convert the output of our 4-bit 4x1 mux

	assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp} = {SSD_CATHODES};

	// Following is Hex-to-SSD conversion
	always @ (SSD) 
	begin : HEX_TO_SSD
		case (SSD) // in this solution file the dot points are made to glow by making Dp = 0
		    //                                                                abcdefg,Dp
			4'b0000: SSD_CATHODES = 8'b00000010; // 0
			4'b0001: SSD_CATHODES = 8'b10011110; // 1
			4'b0010: SSD_CATHODES = 8'b00100100; // 2
			4'b0011: SSD_CATHODES = 8'b00001100; // 3
			4'b0100: SSD_CATHODES = 8'b10011000; // 4
			4'b0101: SSD_CATHODES = 8'b01001000; // 5
			4'b0110: SSD_CATHODES = 8'b01000000; // 6
			4'b0111: SSD_CATHODES = 8'b00011110; // 7
			4'b1000: SSD_CATHODES = 8'b00000000; // 8
			4'b1001: SSD_CATHODES = 8'b00001000; // 9
			4'b1010: SSD_CATHODES = 8'b00010000; // A
			4'b1011: SSD_CATHODES = 8'b11000000; // B
			4'b1100: SSD_CATHODES = 8'b01100010; // C
			4'b1101: SSD_CATHODES = 8'b10000100; // D
			4'b1110: SSD_CATHODES = 8'b01100000; // E
			4'b1111: SSD_CATHODES = 8'b01110000; // F    
			default: SSD_CATHODES = 8'bXXXXXXXX; // default is not needed as we covered all cases
		endcase
	end	
	
endmodule

