//////////////////////////////////////////////////////////////////////////////////
// Author:			Ayushi Mittal, Kelly Chan
// Create Date:   	04/10/21
// File Name:		nexys_starship_top.v 
// Description: 	Top file for Nexys Starship (EE 354 Final Project).
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module nexys_starship_top
		(MemOE, MemWR, RamCS, QuadSpiFlashCS, // Disable the three memory chips

        ClkPort,                           // the 100 MHz incoming clock signal
		
		BtnL, BtnU, BtnD, BtnR,            // the Left, Up, Down, and the Right buttons
		BtnC,                              // the center button (this is our reset in most of our designs)
		Sw3, Sw2, Sw1, Sw0, // 8 switches
		Ld7, Ld6, Ld5, Ld4, Ld3, Ld2, Ld1, Ld0, // 8 LEDs
		An3, An2, An1, An0,			       // 4 anodes
		An7, An6, An5, An4,                // another 4 anodes
		Ca, Cb, Cc, Cd, Ce, Cf, Cg,        // 7 cathodes
		Dp,                                // Dot Point Cathode on SSDs
	    hSync, vSync, vgaR, vgaG, vgaB     // VGA
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
	// LEDs
	output 	Ld0, Ld1, Ld2, Ld3, Ld4, Ld5, Ld6, Ld7;
	// SSD Outputs
	output 	Cg, Cf, Ce, Cd, Cc, Cb, Ca, Dp;
	output 	An0, An1, An2, An3;	
	output 	An4, An5, An6, An7;	
	//VGA signal
	output hSync, vSync;
	output [3:0] vgaR, vgaG, vgaB;

	
	/*  LOCAL SIGNALS */
	wire		Reset, ClkPort;
	wire		board_clk, sys_clk;
	wire        sysClk;
	wire [2:0] 	ssdscan_clk;
	reg [26:0]	DIV_CLK;
	wire move_clk, timer_clk, game_timer_clk;
	
	// VGA wires
	wire bright;
	wire[9:0] hc, vc;
	wire [11:0] rgb;
	wire up, down, left, right;

	// Button pulses
	wire Start_Ack_Pulse;
	wire Up_Pulse, Down_Pulse, Left_Pulse, Right_Pulse, Center_Pulse;
	wire BtnR_Pulse, BtnU_Pulse, BtnL_Pulse, BtnD_Pulse, BtnC_Pulse;
	
	// States
	wire q_Init, q_Play, q_GameOver; 
	wire q_TR_Init, q_TR_Working, q_TR_Repair;
	wire q_BR_Init, q_BR_Working, q_BR_Repair;
	wire q_LR_Init, q_LR_Working, q_LR_Repair;
	wire q_RR_Init, q_RR_Working, q_RR_Repair;
	wire q_TM_Init, q_TM_Empty, q_TM_Full;
	wire q_BM_Init, q_BM_Empty, q_BM_Full;
	wire q_LM_Init, q_LM_Empty, q_LM_Full; 
	wire q_RM_Init, q_RM_Empty, q_RM_Full; 
	
	// SM and VGA flags
	wire play_flag;
	wire top_monster_sm, top_monster_vga; 
	reg top_monster_ctrl; 
	wire btm_monster_sm, btm_monster_vga;
	reg btm_monster_ctrl;  
	wire left_monster, right_monster; 
	wire top_broken, btm_broken, left_broken, right_broken;
	wire right_shield, left_shield; 
	wire top_gameover, btm_gameover, left_gameover, right_gameover;
	reg gameover_ctrl;  
	
	// Random probability
	wire top_random, btm_random, left_random, right_random;
	wire TR_random, BR_random, LR_random, RR_random;
	
	// Hex combinations for repairs
	wire [3:0] TR_combo, BR_combo, LR_combo, RR_combo;
	reg [3:0] hex_combo; // current hex combination on Sw0-Sw3
	wire [3:0] random_hex; // currently produced random hex
	
	// Game timer
	reg [3:0] game_time_min;
	reg [5:0] game_time_sec_1s;
	reg [5:0] game_time_sec_10s;
	reg [18:0] clk_cycle_count;

	// SSDs
	reg [3:0]	SSD;
	wire [7:0]	SSD7, SSD6, SSD5, SSD4, SSD3, SSD2, SSD1, SSD0;
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

//------------------
	// CLOCKS
	assign move_clk = DIV_CLK[19]; //slower clock to drive the movement of objects on the vga screen
	assign random_clk = DIV_CLK[24];
	assign timer_clk = DIV_CLK[24];
	assign game_timer_clk = DIV_CLK[7];

//------------
// INPUT: BUTTONS

	assign {Up_Pulse, Down_Pulse, Left_Pulse, Right_Pulse, Center_Pulse} = 
	        {BtnU_Pulse, BtnD_Pulse, BtnL_Pulse, BtnR_Pulse, BtnC_Pulse};

	ee354_debouncer #(.N_dc(28)) ee354_debouncer_0 
			(.CLK(sys_clk), .RESET(Reset), .PB(BtnR), .DPB( ), 
			.SCEN(BtnR_Pulse), .MCEN( ), .CCEN( ));

	ee354_debouncer #(.N_dc(28)) ee354_debouncer_1 
			(.CLK(sys_clk), .RESET(Reset), .PB(BtnU), .DPB( ), 
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

	// State machine modules
	nexys_starship_game nexys_starship_game_1(.Clk(sys_clk), .BtnU(Up_Pulse), 
	                      .Reset(Reset), .q_Init(q_Init), .q_Play(q_Play), 
	                      .q_GameOver(q_GameOver), .play_flag(play_flag), 
	                      .gameover_ctrl(gameover_ctrl));
                           
	nexys_starship_TM nexys_starship_TM_1(.Clk(sys_clk), .Reset(Reset), .q_TM_Init(q_TM_Init), 
	                      .q_TM_Empty(q_TM_Empty), .q_TM_Full(q_TM_Full), .play_flag(play_flag), 
                          .top_monster_sm(top_monster_sm), .top_monster_ctrl(top_monster_ctrl),
                          .top_random(top_random), .top_gameover(top_gameover), 
                          .gameover_ctrl(gameover_ctrl), .timer_clk(timer_clk));
                          
    nexys_starship_BM nexys_starship_BM_1(.Clk(sys_clk), .Reset(Reset), .q_BM_Init(q_BM_Init), 
	                      .q_BM_Empty(q_BM_Empty), .q_BM_Full(q_BM_Full), .play_flag(play_flag), 
                          .btm_monster_sm(btm_monster_sm), .btm_monster_ctrl(btm_monster_ctrl),
                          .btm_random(btm_random), .btm_gameover(btm_gameover), 
                          .gameover_ctrl(gameover_ctrl), .timer_clk(timer_clk));
    
    nexys_starship_LM nexys_starship_LM_1(.Clk(sys_clk), .Reset(Reset), .q_LM_Init(q_LM_Init), 
	                      .q_LM_Empty(q_LM_Empty), .q_LM_Full(q_LM_Full), .play_flag(play_flag), 
                          .left_monster(left_monster), .left_shield(left_shield),
                          .left_random(left_random), .left_gameover(left_gameover), 
                          .gameover_ctrl(gameover_ctrl), .timer_clk(timer_clk));
                          
    nexys_starship_RM nexys_starship_RM_1(.Clk(sys_clk), .Reset(Reset), .q_RM_Init(q_RM_Init), 
	                      .q_RM_Empty(q_RM_Empty), .q_RM_Full(q_RM_Full), .play_flag(play_flag), 
                          .right_monster(right_monster), .right_shield(right_shield),
                          .right_random(right_random), .right_gameover(right_gameover), 
                          .gameover_ctrl(gameover_ctrl), .timer_clk(timer_clk));
					  
	nexys_starship_TR nexys_starship_TR_1(.Clk(sys_clk), .Reset(Reset), .q_TR_Init(q_TR_Init), 
	                      .q_TR_Working(q_TR_Working), .q_TR_Repair(q_TR_Repair), .BtnU(Up_Pulse),
                          .play_flag(play_flag), .top_broken(top_broken), .hex_combo(hex_combo), 
                          .random_hex(random_hex), .gameover_ctrl(gameover_ctrl),
                          .TR_random(TR_random), .TR_combo(TR_combo), .timer_clk(timer_clk));
                            
	nexys_starship_BR nexys_starship_BR_1(.Clk(sys_clk), .Reset(Reset), .q_BR_Init(q_BR_Init), 
	                      .q_BR_Working(q_BR_Working), .q_BR_Repair(q_BR_Repair), .BtnD(Down_Pulse),
                          .play_flag(play_flag), .btm_broken(btm_broken), .hex_combo(hex_combo), 
                          .random_hex(random_hex), .gameover_ctrl(gameover_ctrl),
                          .BR_random(BR_random), .BR_combo(BR_combo), .timer_clk(timer_clk));                      
                           
    nexys_starship_LR nexys_starship_LR_1(.Clk(sys_clk), .Reset(Reset), .q_LR_Init(q_LR_Init), 
	                      .q_LR_Working(q_LR_Working), .q_LR_Repair(q_LR_Repair), .BtnL(Left_Pulse),
                          .play_flag(play_flag), .left_broken(left_broken), .left_shield(left_shield), 
                          .hex_combo(hex_combo), .random_hex(random_hex), .gameover_ctrl(gameover_ctrl),
                          .LR_random(LR_random), .LR_combo(LR_combo), .timer_clk(timer_clk)); 
    
    nexys_starship_RR nexys_starship_RR_1(.Clk(sys_clk), .Reset(Reset), .q_RR_Init(q_RR_Init), 
	                      .q_RR_Working(q_RR_Working), .q_RR_Repair(q_RR_Repair), .BtnR(Right_Pulse),
                          .play_flag(play_flag), .right_broken(right_broken), .right_shield(right_shield),
                          .hex_combo(hex_combo), .random_hex(random_hex), .gameover_ctrl(gameover_ctrl),
                          .RR_random(RR_random), .RR_combo(RR_combo), .timer_clk(timer_clk));        
				  
	// Pseudo-random number generator module
	nexys_starship_PRNG nexys_starship_PRNG_1(.Clk(random_clk), .Reset(Reset),
	                     .top_random(top_random), .btm_random(btm_random), .left_random(left_random),
                         .right_random(right_random), .TR_random(TR_random), .BR_random(BR_random),
                         .LR_random(LR_random), .RR_random(RR_random), .random_hex(random_hex));
                      
	// VGA modules
	display_controller dc(.Clk(sys_clk), .hSync(hSync), .vSync(vSync), .bright(bright), .hCount(hc), 
	                     .vCount(vc));
	
	vga_game_controller sc(.Clk(move_clk), .bright(bright), .Reset(Reset), .up(BtnU), .down(BtnD),
						 .left(BtnL), .right(BtnR), .hCount(hc), .vCount(vc), .rgb(rgb),
						 .top_monster_vga(top_monster_vga), .top_monster_ctrl(top_monster_ctrl), 
						 .top_broken(top_broken), .btm_monster_vga(btm_monster_vga), 
						 .btm_monster_ctrl(btm_monster_ctrl), .btm_broken(btm_broken),
						 .left_monster(left_monster), .left_shield(left_shield), 
						 .left_broken(left_broken), .right_monster(right_monster),
						 .right_shield(right_shield), .right_broken(right_broken),
						 .sysClk(sys_clk), .TR_combo(TR_combo), .BR_combo(BR_combo),
						 .LR_combo(LR_combo), .RR_combo(RR_combo), .play_flag(play_flag),
						 .gameover_ctrl(gameover_ctrl));
	                       
//------------
// SWITCHES HEX COMBO

	always @ (posedge sys_clk, posedge Reset)
	begin
		if(Reset)
		begin
	        hex_combo <= 4'b0000; 
		end
		else
		begin
			hex_combo <= {Sw3, Sw2, Sw1, Sw0};	
		end
	end

//------------
// GAME TIMER

	always @ (posedge game_timer_clk, posedge Reset)
	begin
		if (Reset)
		begin
			game_time_min <= 0;
			game_time_sec_1s <= 0;
			game_time_sec_10s <= 0;
			clk_cycle_count <= 0;
		end
		else if (play_flag)
		begin
			clk_cycle_count <= clk_cycle_count + 1;
			if (clk_cycle_count == 390624)
			begin
				clk_cycle_count <= 0;
				game_time_sec_1s <= game_time_sec_1s + 1;
				if (game_time_sec_10s == 5 && game_time_sec_1s == 9)
				begin
					game_time_sec_10s <= 0;
					game_time_sec_1s <=0;
					game_time_min <= game_time_min + 1;
				end
				else if (game_time_sec_1s == 9)
				begin
					game_time_sec_1s <= 0;
					game_time_sec_10s <= game_time_sec_10s + 1;
				end
			end
		end
	end

//------------
// SHARED REGISTERS

    always @ (*)
    begin
        if (q_TM_Full)
            top_monster_ctrl <= top_monster_vga;
        else
            top_monster_ctrl <= top_monster_sm;  
			
        if (q_BM_Full)
            btm_monster_ctrl <= btm_monster_vga; 
        else
            btm_monster_ctrl <= btm_monster_sm;  
			
        if (q_GameOver)
            gameover_ctrl <= 1; 
        else
            gameover_ctrl <= top_gameover || btm_gameover || left_gameover || right_gameover; 
    end

//------------
// VGA OUTPUT

	assign vgaR = rgb[11 : 8];
	assign vgaG = rgb[7  : 4];
	assign vgaB = rgb[3  : 0];

//------------
// OUTPUT: LEDS

	assign {Ld7, Ld6, Ld5, Ld4} = {q_LM_Init, q_LM_Full, q_LM_Empty, left_monster};
	assign {Ld3, Ld2, Ld1, Ld0} = {left_shield, q_GameOver, left_gameover, gameover_ctrl}; // Reset is driven by BtnC

//------------
// SSD (Seven Segment Display)

	assign SSD0 = {Sw3, Sw2, Sw1, Sw0}; // current hex combo
	assign SSD4 = game_time_sec_1s;
	assign SSD5 = game_time_sec_10s;
	assign SSD6 = game_time_min;


	// scan clk for the seven segment display 
	assign ssdscan_clk = DIV_CLK[16:14];
	
    assign An0    = ~(~(ssdscan_clk[2]) && ~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when sev_seg_clk = 000
    assign An1    = ~(~(ssdscan_clk[2]) && ~(ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when sev_seg_clk = 001
    assign An2    = ~(~(ssdscan_clk[2]) &&  (ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when sev_seg_clk = 010
    assign An3    = ~(~(ssdscan_clk[2]) &&  (ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when sev_seg_clk = 011
    assign An4    = ~( (ssdscan_clk[2]) && ~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when sev_seg_clk = 100
    assign An5    = ~( (ssdscan_clk[2]) && ~(ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when sev_seg_clk = 101
    assign An6    = ~( (ssdscan_clk[2]) &&  (ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when sev_seg_clk = 110
    assign An7    = ~( (ssdscan_clk[2]) &&  (ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when sev_seg_clk = 111
        
	
	always @ (ssdscan_clk, SSD0, SSD1, SSD2, SSD3, SSD4, SSD5, SSD6, SSD7)
    begin
       case (ssdscan_clk) 
               3'b000: SSD = SSD0;
               3'b001: SSD = SSD1;
               3'b010: SSD = SSD2;
               3'b011: SSD = SSD3;
               3'b100: SSD = SSD4;
               3'b101: SSD = SSD5;
               3'b110: SSD = SSD6;
               3'b111: SSD = SSD7;
       endcase 
    end
	
	// and finally convert SSD_num to ssd
	// We convert the output of our 4-bit 4x1 mux

	assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp} = {SSD_CATHODES};

	// Following is Hex-to-SSD conversion
	always @ (SSD) 
	begin : HEX_TO_SSD
		case (SSD)
		    // abcdefg,Dp
			4'b0000: SSD_CATHODES = 8'b00000011; // 0
			4'b0001: SSD_CATHODES = 8'b10011111; // 1
			4'b0010: SSD_CATHODES = 8'b00100101; // 2
			4'b0011: SSD_CATHODES = 8'b00001101; // 3
			4'b0100: SSD_CATHODES = 8'b10011001; // 4
			4'b0101: SSD_CATHODES = 8'b01001001; // 5
			4'b0110: SSD_CATHODES = 8'b01000001; // 6
			4'b0111: SSD_CATHODES = 8'b00011111; // 7
			4'b1000: SSD_CATHODES = 8'b00000001; // 8
			4'b1001: SSD_CATHODES = 8'b00001001; // 9
			4'b1010: SSD_CATHODES = 8'b00010001; // A
			4'b1011: SSD_CATHODES = 8'b11000001; // B
			4'b1100: SSD_CATHODES = 8'b01100011; // C
			4'b1101: SSD_CATHODES = 8'b10000101; // D
			4'b1110: SSD_CATHODES = 8'b01100001; // E
			4'b1111: SSD_CATHODES = 8'b01110001; // F    
			default: SSD_CATHODES = 8'bXXXXXXXX; // default is not needed as we covered all cases
		endcase
	end	
	
endmodule

