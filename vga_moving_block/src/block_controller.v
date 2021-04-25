`timescale 1ns / 1ps

module block_controller (
	input Clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input bright,
	input Reset,
	input up, input down, input left, input right,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb,
	input top_monster_ctrl, output reg top_monster_vga, input top_broken,
	input btm_monster_ctrl, output reg btm_monster_vga, input btm_broken,
	input left_monster, output reg left_shield, input left_broken,
	input right_monster, output reg right_shield, input right_broken,
	input sysClk,
	input [3:0] TR_combo, BR_combo, LR_combo, RR_combo
   );
	wire spaceship_black_fill;
	wire left_stub_fill; 
	wire right_stub_fill; 
	wire tunnel_blue_fill;
	wire light_gray_fill;
	wire light_blue_fill;
	wire left_shield_fill, right_shield_fill;
	wire LS_mask_fill, RS_mask_fill, spaceship_mask_fill; 
	wire black_fill;
	wire head_fill;
	wire top_dark_gray_fill, btm_dark_gray_fill, top_medium_gray_fill, btm_medium_gray_fill;
	wire TM_black_fill, TM_red_fill, TM_cream_fill, TM_mask_fill, top_green_fill;
	wire BM_black_fill, BM_red_fill, BM_cream_fill, BM_mask_fill, btm_green_fill;
	wire LM_black_fill, LM_blue_fill, LM_cream_fill, LM_mask_fill, LM_red_fill, left_red_fill; 
	wire RM_black_fill, RM_blue_fill, RM_cream_fill, RM_mask_fill, RM_red_fill, right_red_fill; 
	wire T0_fill, T1_fill, T2_fill, T3_fill, T4_fill, T5_fill, T6_fill, T7_fill, T8_fill, T9_fill;
	wire B0_fill, B1_fill, B2_fill, B3_fill, B4_fill, B5_fill, B6_fill, B7_fill, B8_fill, B9_fill;
	wire L0_fill, L1_fill, L2_fill, L3_fill, L4_fill, L5_fill, L6_fill, L7_fill, L8_fill, L9_fill;
	wire R0_fill, R1_fill, R2_fill, R3_fill, R4_fill, R5_fill, R6_fill, R7_fill, R8_fill, R9_fill;
	wire TA_fill, TB_fill, TC_fill, TD_fill, TE_fill, TF_fill; 
	wire BA_fill, BB_fill, BC_fill, BD_fill, BE_fill, BF_fill; 
	wire LA_fill, LB_fill, LC_fill, LD_fill, LE_fill, LF_fill; 
	wire RA_fill, RB_fill, RC_fill, RD_fill, RE_fill, RF_fill; 

	reg signed [10:0] top_laser, btm_laser, left_laser, right_laser;
	reg top_shooting, btm_shooting;
	reg top_hex_fill, btm_hex_fill, left_hex_fill, right_hex_fill;

	
	parameter RED   = 12'b1111_0000_0000;
	parameter BLACK = 12'b0000_0000_0000;
	parameter GREY = 12'b1100_1100_1100;
	parameter LIGHT_BLUE = 12'b1001_1101_1111;
	parameter PINK = 12'b1111_1000_1000;
	parameter DARK_GREY = 12'b0110_0110_0110;
	parameter MEDIUM_GREY = 12'b1001_1001_1001;
	parameter BACKGROUND = 12'b0000_1000_1010; // sky blue
	parameter BACKGROUND2 = 12'b0000_0001_0100; // dark blue
	parameter TAN = 12'b1110_1011_1000; // EB8 
	parameter GREEN = 12'b0001_1111_0000;
	parameter CREAM = 12'b1111_1110_1011;
	parameter TUNNEL_BLUE = 12'b0000_0001_0101;
	parameter DISABLED_DARK_SHADE = 12'b0001_0001_0001; 
	parameter DISABLED_MEDIUM_SHADE = 12'b0010_0010_0010; 
    parameter TEXT_BABY_BLUE = 12'b1001_1100_1111;
    parameter BLUE = 12'b0011_1001_1111; //3399FF blue monster 
    
    parameter TOP_H = 314, TOP_V = 130;
    parameter BTM_H = 314, BTM_V = 336; 
    parameter LEFT_H = 230, LEFT_V = 250; 
    parameter RIGHT_H = 398, RIGHT_V = 250; 
    
    
	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*) begin
    	if (top_broken)
		begin
			case (TR_combo)
				4'b0000: top_hex_fill = T0_fill; // 0
				4'b0001: top_hex_fill = T1_fill; // 1
				4'b0010: top_hex_fill = T2_fill; // 2
				4'b0011: top_hex_fill = T3_fill; // 3
				4'b0100: top_hex_fill = T4_fill; // 4
				4'b0101: top_hex_fill = T5_fill; // 5
				4'b0110: top_hex_fill = T6_fill; // 6
				4'b0111: top_hex_fill = T7_fill; // 7
				4'b1000: top_hex_fill = T8_fill; // 8
				4'b1001: top_hex_fill = T9_fill; // 9
				4'b1010: top_hex_fill = TA_fill; // A
				4'b1011: top_hex_fill = TB_fill; // B
				4'b1100: top_hex_fill = TC_fill; // C
				4'b1101: top_hex_fill = TD_fill; // D
				4'b1110: top_hex_fill = TE_fill; // E
				4'b1111: top_hex_fill = TF_fill; // F    
				default: top_hex_fill = T0_fill;
			endcase
		end
		
		if (btm_broken)
		begin
			case (BR_combo)
				4'b0000: btm_hex_fill = B0_fill; // 0
				4'b0001: btm_hex_fill = B1_fill; // 1
				4'b0010: btm_hex_fill = B2_fill; // 2
				4'b0011: btm_hex_fill = B3_fill; // 3
				4'b0100: btm_hex_fill = B4_fill; // 4
				4'b0101: btm_hex_fill = B5_fill; // 5
				4'b0110: btm_hex_fill = B6_fill; // 6
				4'b0111: btm_hex_fill = B7_fill; // 7
				4'b1000: btm_hex_fill = B8_fill; // 8
				4'b1001: btm_hex_fill = B9_fill; // 9
				4'b1010: btm_hex_fill = BA_fill; // A
				4'b1011: btm_hex_fill = BB_fill; // B
				4'b1100: btm_hex_fill = BC_fill; // C
				4'b1101: btm_hex_fill = BD_fill; // D
				4'b1110: btm_hex_fill = BE_fill; // E
				4'b1111: btm_hex_fill = BF_fill; // F    
				default: btm_hex_fill = B0_fill;
			endcase
		end
		
		if (left_broken)
		begin
			case (LR_combo)
				4'b0000: left_hex_fill = L0_fill; // 0
				4'b0001: left_hex_fill = L1_fill; // 1
				4'b0010: left_hex_fill = L2_fill; // 2
				4'b0011: left_hex_fill = L3_fill; // 3
				4'b0100: left_hex_fill = L4_fill; // 4
				4'b0101: left_hex_fill = L5_fill; // 5
				4'b0110: left_hex_fill = L6_fill; // 6
				4'b0111: left_hex_fill = L7_fill; // 7
				4'b1000: left_hex_fill = L8_fill; // 8
				4'b1001: left_hex_fill = L9_fill; // 9
				4'b1010: left_hex_fill = LA_fill; // A
				4'b1011: left_hex_fill = LB_fill; // B
				4'b1100: left_hex_fill = LC_fill; // C
				4'b1101: left_hex_fill = LD_fill; // D
				4'b1110: left_hex_fill = LE_fill; // E
				4'b1111: left_hex_fill = LF_fill; // F    
				default: left_hex_fill = L0_fill;
			endcase
		end

        if (right_broken)
		begin
			case (RR_combo)
				4'b0000: right_hex_fill = R0_fill; // 0
				4'b0001: right_hex_fill = R1_fill; // 1
				4'b0010: right_hex_fill = R2_fill; // 2
				4'b0011: right_hex_fill = R3_fill; // 3
				4'b0100: right_hex_fill = R4_fill; // 4
				4'b0101: right_hex_fill = R5_fill; // 5
				4'b0110: right_hex_fill = R6_fill; // 6
				4'b0111: right_hex_fill = R7_fill; // 7
				4'b1000: right_hex_fill = R8_fill; // 8
				4'b1001: right_hex_fill = R9_fill; // 9
				4'b1010: right_hex_fill = RA_fill; // A
				4'b1011: right_hex_fill = RB_fill; // B
				4'b1100: right_hex_fill = RC_fill; // C
				4'b1101: right_hex_fill = RD_fill; // D
				4'b1110: right_hex_fill = RE_fill; // E
				4'b1111: right_hex_fill = RF_fill; // F    
				default: right_hex_fill = R0_fill;
			endcase
		end
		
		if(~bright )	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
        else if (top_broken && (top_medium_gray_fill || top_dark_gray_fill))
          begin 
                if (top_medium_gray_fill)
                    rgb = DISABLED_MEDIUM_SHADE; 
                else if (top_dark_gray_fill)
                    rgb = DISABLED_DARK_SHADE; 
          end 
        else if (btm_broken && (btm_medium_gray_fill || btm_dark_gray_fill))
          begin 
                if (btm_medium_gray_fill)
                    rgb = DISABLED_MEDIUM_SHADE; 
                else if (btm_dark_gray_fill)
                    rgb = DISABLED_DARK_SHADE; 
          end 
        else if (left_broken && left_stub_fill)
                    rgb = DISABLED_DARK_SHADE; 
        else if (right_broken && right_stub_fill)
                    rgb = DISABLED_DARK_SHADE;                
        else if (btm_broken && (btm_medium_gray_fill || btm_dark_gray_fill))
          begin 
                if (btm_medium_gray_fill)
                    rgb = DISABLED_MEDIUM_SHADE; 
                else if (btm_dark_gray_fill)
                    rgb = DISABLED_DARK_SHADE; 
          end 
		else if (top_broken && top_hex_fill)
			rgb = TEXT_BABY_BLUE;
		else if (btm_broken && btm_hex_fill)
			rgb = TEXT_BABY_BLUE;
		else if (left_broken && left_hex_fill)
			rgb = TEXT_BABY_BLUE;
		else if (right_broken && right_hex_fill)
			rgb = TEXT_BABY_BLUE;
		else if (spaceship_display_fill)
		  begin
				if (spaceship_black_fill)
					rgb = BLACK;
				else if (head_fill)
					rgb = TAN;
				else if (light_blue_fill)
					rgb = LIGHT_BLUE;
				else if (pink_fill)
				    rgb = PINK; 
				else if (light_gray_fill)
					rgb = GREY;
				else if (top_medium_gray_fill || btm_medium_gray_fill)
					rgb = MEDIUM_GREY;
				else if (top_dark_gray_fill || btm_dark_gray_fill)
					rgb = DARK_GREY;
				else if (spaceship_mask_fill)
				    rgb = TUNNEL_BLUE; 
		  end
		else if (left_shield && left_shield_fill) 
	       rgb = PINK; 
	    else if (left_shield && LS_mask_fill) 
	       rgb = TUNNEL_BLUE; 
		else if (right_shield && right_shield_fill)
		   rgb = PINK;
		else if (right_shield && RS_mask_fill) 
		   rgb = TUNNEL_BLUE; 
		else if (TM_display_fill)
          begin
                if (TM_black_fill)
                    rgb = BLACK;
                else if (TM_cream_fill)
                    rgb = CREAM;
                else if (TM_red_fill)
                    rgb = RED;
                else if (TM_mask_fill)
                    rgb = TUNNEL_BLUE;
          end
        else if (BM_display_fill)
          begin
                if (BM_black_fill)
                    rgb = BLACK;
                else if (BM_cream_fill)
                    rgb = CREAM;
                else if (BM_red_fill)
                    rgb = RED;
                else if (BM_mask_fill)
                    rgb = TUNNEL_BLUE;
          end
        else if (LM_display_fill)
          begin
                if (LM_red_fill)
                    rgb = RED;
                else if (LM_black_fill)
                    rgb = BLACK;
                else if (LM_cream_fill)
                    rgb = CREAM;
                else if (LM_blue_fill)
                    rgb = BLUE;
                else if (LM_mask_fill)
                    rgb = TUNNEL_BLUE;
          end
        else if (RM_display_fill)
          begin
                if (RM_red_fill)
                    rgb = RED;
                else if (RM_black_fill)
                    rgb = BLACK;
                else if (RM_cream_fill)
                    rgb = CREAM;
                else if (RM_blue_fill)
                    rgb = BLUE;
                else if (RM_mask_fill)
                    rgb = TUNNEL_BLUE;
          end
        else if (top_green_fill || btm_green_fill)
            rgb = GREEN;
        else if (left_red_fill && left_monster)
            rgb = RED;
        else if (right_red_fill && right_monster)
            rgb = RED; 
		else if (tunnel_blue_fill)
			rgb = TUNNEL_BLUE;
		else	
			rgb=BACKGROUND2;
	end
	
	assign tunnel_blue_fill = 
        (hCount>=(144+220)&&hCount<=(144+220+200)&&vCount>=(35)&&vCount<=(35+480)) // vertical tunnel 
        || (hCount>=(144)&&hCount<=(144+640)&&vCount>=(35+171)&&vCount<=(35+171+159)); // horizontal tunnel 

	
	// gray spaceship body
	assign light_gray_fill = 
		(hCount>=(144+248)&&hCount<=(144+248+144)&&vCount>=(35+248)&&vCount<=(35+248+20)) // middle
		|| (hCount>=(144+263)&&hCount<=(144+263+114)&&vCount>=(35+225)&&vCount<=(35+225+23)) // top
		|| (hCount>=(144+263)&&hCount<=(144+263+114)&&vCount>=(35+268)&&vCount<=(35+268+20)) // bottom
		|| (hCount>=(144+273)&&hCount<=(144+273+16)&&vCount>=(35+288)&&vCount<=(35+288+20)) // left leg
		|| (hCount>=(144+351)&&hCount<=(144+351+16)&&vCount>=(35+288)&&vCount<=(35+288+20)); // right leg
	
	// light blue window
	assign light_blue_fill = 
		(hCount>=(144+281)&&hCount<=(144+281+78)&&vCount>=(35+207)&&vCount<=(35+207+7)) // second strip
		|| (hCount>=(144+289)&&hCount<=(144+289+62)&&vCount>=(35+199)&&vCount<=(35+199+8)) // third strip
		|| (hCount>=(144+273)&&hCount<=(144+273+94)&&vCount>=(35+214)&&vCount<=(35+214+11)) // fourth strip
		|| (hCount>=(144+281)&&hCount<=(144+281+78)&&vCount>=(35+225)&&vCount<=(35+225+10)) // upper bottom strip
		|| (hCount>=(144+289)&&hCount<=(144+289+62)&&vCount>=(35+235)&&vCount<=(35+235+13)) // lower bottom strip
		|| (hCount>=(144+297)&&hCount<=(144+297+46)&&vCount>=(35+194)&&vCount<=(35+194+5)); // top window
	
	// shields - move to other always block for inputs?	
	assign left_shield_fill =
		(hCount>=(144+227)&&hCount<=(144+227+10)&&vCount>=(35+205)&&vCount<=(35+205+105)) // left outer shield 
		|| (hCount>=(144+237)&&hCount<=(144+237+11)&&vCount>=(35+200)&&vCount<=(35+200+115));// left inner shield
	
	assign LS_mask_fill = 
	    (hCount>=(144+248)&&hCount<=(144+248+25)&&vCount>=(35+220)&&vCount<=(35+220+4)) // top left mask shield 
		|| (hCount>=(144+248)&&hCount<=(144+248+25)&&vCount>=(35+291)&&vCount<=(35+291+4));// bottom left mask shield
	
	assign right_shield_fill = 
		(hCount>=(144+402)&&hCount<=(144+402+10)&&vCount>=(35+205)&&vCount<=(35+205+105)) // right outer shield
		|| (hCount>=(144+392)&&hCount<=(144+392+11)&&vCount>=(35+200)&&vCount<=(35+200+115)); // right inner shield
	
	assign RS_mask_fill = 
		(hCount>=(144+367)&&hCount<=(144+367+25)&&vCount>=(35+220)&&vCount<=(35+220+4)) // top right mask shield 
		|| (hCount>=(144+367)&&hCount<=(144+367+25)&&vCount>=(35+291)&&vCount<=(35+291+4));// bottom right mask shield
	// cannons
	assign top_dark_gray_fill =
		(hCount>=(144+314)&&hCount<=(144+314+12)&&vCount>=(35+152)&&vCount<=(35+152+10)) // top cannon tip
		|| (hCount>=(144+309)&&hCount<=(144+309+22)&&vCount>=(35+162)&&vCount<=(35+162+30)); // top cannon body
	
	assign top_medium_gray_fill =
		(hCount>=(144+314)&&hCount<=(144+314+12)&&vCount>=(35+192)&&vCount<=(35+192+2)) // top cannon base
		|| (hCount>=(144+309)&&hCount<=(144+309+22)&&vCount>=(35+165)&&vCount<=(35+165+4)); // top cannon strip
		
	assign btm_dark_gray_fill =  
		(hCount>=(144+314)&&hCount<=(144+314+12)&&vCount>=(35+320)&&vCount<=(35+320+10)) // bottom cannon tip
		|| (hCount>=(144+309)&&hCount<=(144+309+22)&&vCount>=(35+290)&&vCount<=(35+290+30)); // bottom cannon body
	
	assign btm_medium_gray_fill = 
		(hCount>=(144+314)&&hCount<=(144+314+12)&&vCount>=(35+288)&&vCount<=(35+288+2)) // bottom cannon base
		|| (hCount>=(144+309)&&hCount<=(144+309+22)&&vCount>=(35+312)&&vCount<=(35+312+4)); // bottom cannon strip
	
	// lights
	assign pink_fill =
		(hCount>=(144+271)&&hCount<=(144+271+14)&&vCount>=(35+250)&&vCount<=(35+250+14)) // left light
		|| (hCount>=(144+313)&&hCount<=(144+313+14)&&vCount>=(35+258)&&vCount<=(35+258+14)) // middle light
		|| (hCount>=(144+354)&&hCount<=(144+354+14)&&vCount>=(35+250)&&vCount<=(35+250+14)); // right light
	
	// 
	assign head_fill = 
	    (hCount>=(144+303)&&hCount<=(144+303+34)&&vCount>=(35+214)&&vCount<=(35+214+34)); // head
	    
	assign spaceship_black_fill = 
	    (hCount>=(144+302)&&hCount<=(144+302+36)&&vCount>=(35+217)&&vCount<=(35+217+7)) // eyebrows / headband 
		|| (hCount>=(144+309)&&hCount<=(144+309+5)&&vCount>=(35+224)&&vCount<=(35+224+3)) // left eye
		|| (hCount>=(144+326)&&hCount<=(144+326+5)&&vCount>=(35+224)&&vCount<=(35+224+3)) // right eye
		|| (hCount>=(144+310)&&hCount<=(144+310+5)&&vCount>=(35+236)&&vCount<=(35+236+3)) // left mouth 
		|| (hCount>=(144+314)&&hCount<=(144+314+12)&&vCount>=(35+238)&&vCount<=(35+238+3)) // mid mouth
		|| (hCount>=(144+325)&&hCount<=(144+325+5)&&vCount>=(35+236)&&vCount<=(35+236+3)) // right mouth  
		|| (hCount>=(144+314)&&hCount<=(144+314+3)&&vCount>=(35+211)&&vCount<=(35+211+2)) // left hair strand  
		|| (hCount>=(144+319)&&hCount<=(144+319+3)&&vCount>=(35+208)&&vCount<=(35+208+5)) // mid hair strand  
		|| (hCount>=(144+324)&&hCount<=(144+324+2)&&vCount>=(35+211)&&vCount<=(35+211+2)); // right hair strand  
	
	assign spaceship_mask_fill = 
	    (hCount>=(144+289)&&hCount<=(144+289+20)&&vCount>=(35+291)&&vCount<=(35+291+4)) // left spaceship mask  
		|| (hCount>=(144+331)&&hCount<=(144+331+20)&&vCount>=(35+291)&&vCount<=(35+291+4));// right spaceship mask 
	
	assign left_stub_fill = 
	    (hCount>=(144+248)&&hCount<=(144+248+15)&&vCount>=(35+248)&&vCount<=(35+248+20));
	
	assign right_stub_fill = 
	    (hCount>=(144+377)&&hCount<=(144+377+15)&&vCount>=(35+248)&&vCount<=(35+248+20));
	
	assign spaceship_display_fill = light_gray_fill || light_blue_fill || spaceship_black_fill 
	                                   || head_fill || top_dark_gray_fill || top_medium_gray_fill
	                                   || btm_dark_gray_fill || btm_medium_gray_fill || spaceship_mask_fill;
	
	assign top_green_fill = 
		(hCount>=(144+318)&&hCount<=(144+318+4)&&vCount>=(35+top_laser-24)&&vCount<=(35+top_laser)) // top 3rd bullet 
		|| (hCount>=(144+318)&&hCount<=(144+318+4)&&vCount>=(35+top_laser-24-40)&&vCount<=(35+top_laser-40)) // top 2nd bullet 
		|| (hCount>=(144+318)&&hCount<=(144+318+4)&&vCount>=(35+top_laser-24-80)&&vCount<=(35+top_laser-80)); // top 1st bullet 
		
	assign TM_red_fill =
		// left antenna
		(hCount>=(144+304)&&hCount<=(144+304+8)&&vCount>=(35+7)&&vCount<=(35+7+8))
		|| (hCount>=(144+306)&&hCount<=(144+306+4)&&vCount>=(35+15)&&vCount<=(35+15+9))
		// right antenna
		|| (hCount>=(144+330)&&hCount<=(144+330+8)&&vCount>=(35+7)&&vCount<=(35+7+8))
		|| (hCount>=(144+332)&&hCount<=(144+332+4)&&vCount>=(35+15)&&vCount<=(35+15+9))
		// body
		|| (hCount>=(144+290)&&hCount<=(144+290+59)&&vCount>=(35+24)&&vCount<=(35+24+52))
        || (hCount>=(144+266)&&hCount<=(144+266+5)&&vCount>=(35+71)&&vCount<=(35+71+7)) // left outermost leg block
        || (hCount>=(144+271)&&hCount<=(144+271+5)&&vCount>=(35+74)&&vCount<=(35+74+7)) // left second leg block
        || (hCount>=(144+276)&&hCount<=(144+276+5)&&vCount>=(35+71)&&vCount<=(35+71+7)) // left third leg block
        || (hCount>=(144+281)&&hCount<=(144+281+5)&&vCount>=(35+74)&&vCount<=(35+74+7)) // left fourth leg block
        || (hCount>=(144+286)&&hCount<=(144+286+5)&&vCount>=(35+71)&&vCount<=(35+71+7)) // left innermost leg block
        || (hCount>=(144+349)&&hCount<=(144+349+5)&&vCount>=(35+71)&&vCount<=(35+71+7)) // right innermost leg block
        || (hCount>=(144+354)&&hCount<=(144+354+5)&&vCount>=(35+74)&&vCount<=(35+74+7)) // right second leg block
        || (hCount>=(144+359)&&hCount<=(144+359+5)&&vCount>=(35+71)&&vCount<=(35+71+7)) // right third leg block
        || (hCount>=(144+364)&&hCount<=(144+364+5)&&vCount>=(35+74)&&vCount<=(35+74+7)) // right fourth leg block
        || (hCount>=(144+369)&&hCount<=(144+369+5)&&vCount>=(35+71)&&vCount<=(35+71+7)); // right outermost leg block 

		
	assign TM_black_fill =
		// eyebrow
		(hCount>=(144+298)&&hCount<=(144+298+9)&&vCount>=(35+29)&&vCount<=(35+29+5))
		|| (hCount>=(144+303)&&hCount<=(144+303+9)&&vCount>=(35+32)&&vCount<=(35+32+5))
		|| (hCount>=(144+309)&&hCount<=(144+309+9)&&vCount>=(35+34)&&vCount<=(35+34+5))
		|| (hCount>=(144+315)&&hCount<=(144+315+10)&&vCount>=(35+36)&&vCount<=(35+36+6))
		|| (hCount>=(144+333)&&hCount<=(144+333+9)&&vCount>=(35+29)&&vCount<=(35+29+5))
		|| (hCount>=(144+328)&&hCount<=(144+328+9)&&vCount>=(35+32)&&vCount<=(35+32+5))
		|| (hCount>=(144+322)&&hCount<=(144+322+9)&&vCount>=(35+34)&&vCount<=(35+34+5))
		// pupil
		|| (hCount>=(144+314)&&hCount<=(144+314+12)&&vCount>=(35+51)&&vCount<=(35+51+12))
		// mouth
		|| (hCount>=(144+309)&&hCount<=(144+309+9)&&vCount>=(35+65)&&vCount<=(35+65+5))
		|| (hCount>=(144+315)&&hCount<=(144+315+10)&&vCount>=(35+67)&&vCount<=(35+67+6))
		|| (hCount>=(144+322)&&hCount<=(144+322+9)&&vCount>=(35+65)&&vCount<=(35+65+5));
		
	assign TM_cream_fill =
		// white of eyeball
		(hCount>=(144+306)&&hCount<=(144+306+28)&&vCount>=(35+37)&&vCount<=(35+37+26));
	
	assign TM_mask_fill =
		(hCount>=(144+318)&&hCount<=(144+318+4)&&vCount>=(35)&&vCount<=(35+24));

	assign TM_display_fill = top_monster_vga && (TM_red_fill || TM_black_fill
								|| TM_cream_fill || TM_mask_fill);
	
	assign btm_green_fill = 
		(hCount>=(144+318)&&hCount<=(144+318+4)&&vCount>=(35+btm_laser)&&vCount<=(35+btm_laser+24)) // bottom 1st bullet 
		|| (hCount>=(144+318)&&hCount<=(144+318+4)&&vCount>=(35+btm_laser+40)&&vCount<=(35+btm_laser+40+24)) // bottom 2nd bullet 
		|| (hCount>=(144+318)&&hCount<=(144+318+4)&&vCount>=(35+btm_laser+80)&&vCount<=(35+btm_laser+80+24)); // bottom 3rd bullet
		
	assign BM_red_fill =
		// left antenna
		(hCount>=(144+304)&&hCount<=(144+304+8)&&vCount>=(35+389)&&vCount<=(35+389+8))
		|| (hCount>=(144+306)&&hCount<=(144+306+4)&&vCount>=(35+397)&&vCount<=(35+397+9))
		// right antenna
		|| (hCount>=(144+330)&&hCount<=(144+330+8)&&vCount>=(35+389)&&vCount<=(35+389+8))
		|| (hCount>=(144+332)&&hCount<=(144+332+4)&&vCount>=(35+397)&&vCount<=(35+397+9))
		// body
		|| (hCount>=(144+290)&&hCount<=(144+290+59)&&vCount>=(35+406)&&vCount<=(35+406+52))
        || (hCount>=(144+266)&&hCount<=(144+266+5)&&vCount>=(35+453)&&vCount<=(35+453+7)) // left outermost leg block
        || (hCount>=(144+271)&&hCount<=(144+271+5)&&vCount>=(35+456)&&vCount<=(35+456+7)) // left second leg block
        || (hCount>=(144+276)&&hCount<=(144+276+5)&&vCount>=(35+453)&&vCount<=(35+453+7)) // left third leg block
        || (hCount>=(144+281)&&hCount<=(144+281+5)&&vCount>=(35+456)&&vCount<=(35+456+7)) // left fourth leg block
        || (hCount>=(144+286)&&hCount<=(144+286+5)&&vCount>=(35+453)&&vCount<=(35+453+7)) // left innermost leg block
        || (hCount>=(144+349)&&hCount<=(144+349+5)&&vCount>=(35+453)&&vCount<=(35+453+7)) // right innermost leg block
        || (hCount>=(144+354)&&hCount<=(144+354+5)&&vCount>=(35+456)&&vCount<=(35+456+7)) // right second leg block
        || (hCount>=(144+359)&&hCount<=(144+359+5)&&vCount>=(35+453)&&vCount<=(35+453+7)) // right third leg block
        || (hCount>=(144+364)&&hCount<=(144+364+5)&&vCount>=(35+456)&&vCount<=(35+456+7)) // right fourth leg block
        || (hCount>=(144+369)&&hCount<=(144+369+5)&&vCount>=(35+453)&&vCount<=(35+453+7)); // right outermost leg block 
        
    
   assign BM_black_fill =
        // eyebrow
        (hCount>=(144+298)&&hCount<=(144+298+9)&&vCount>=(35+411)&&vCount<=(35+411+5))
        || (hCount>=(144+303)&&hCount<=(144+303+9)&&vCount>=(35+414)&&vCount<=(35+414+5))
        || (hCount>=(144+309)&&hCount<=(144+309+9)&&vCount>=(35+416)&&vCount<=(35+416+5))
        || (hCount>=(144+333)&&hCount<=(144+333+9)&&vCount>=(35+411)&&vCount<=(35+411+5))
        || (hCount>=(144+328)&&hCount<=(144+328+9)&&vCount>=(35+414)&&vCount<=(35+414+5))
        || (hCount>=(144+322)&&hCount<=(144+322+9)&&vCount>=(35+416)&&vCount<=(35+416+5))
        // pupil eyebrow
        || (hCount>=(144+314)&&hCount<=(144+314+12)&&vCount>=(35+418)&&vCount<=(35+418+13))
        // mouth
        || (hCount>=(144+309)&&hCount<=(144+309+9)&&vCount>=(35+447)&&vCount<=(35+447+5))
        || (hCount>=(144+315)&&hCount<=(144+315+10)&&vCount>=(35+449)&&vCount<=(35+449+6))
        || (hCount>=(144+322)&&hCount<=(144+322+9)&&vCount>=(35+447)&&vCount<=(35+447+5));
        
    assign BM_cream_fill =
        // white of eyeball
        (hCount>=(144+306)&&hCount<=(144+306+28)&&vCount>=(35+419)&&vCount<=(35+419+26));
    
    assign BM_mask_fill =
        (hCount>=(144+318)&&hCount<=(144+318+4)&&vCount>=(35+458)&&vCount<=(35+458+24));    
    
    assign BM_display_fill = btm_monster_vga && (BM_red_fill || BM_black_fill
								|| BM_cream_fill || BM_mask_fill);
	assign left_red_fill = 
		(hCount>=(144+left_laser)&&hCount<=(144+left_laser+17)&&vCount>=(35+220)&&vCount<=(35+220+4)) // top leftmost 1st bullet 
		|| (hCount>=(144+left_laser+30)&&hCount<=(144+left_laser+30+17)&&vCount>=(35+220)&&vCount<=(35+220+4)) // top 2nd bullet 
		|| (hCount>=(144+left_laser+60)&&hCount<=(144+left_laser+60+17)&&vCount>=(35+220)&&vCount<=(35+220+4)) // top 3rd bullet
		|| (hCount>=(144+left_laser)&&hCount<=(144+left_laser+17)&&vCount>=(35+291)&&vCount<=(35+291+4)) // bottom leftmost 1st bullet 
		|| (hCount>=(144+left_laser+30)&&hCount<=(144+left_laser+30+17)&&vCount>=(35+291)&&vCount<=(35+291+4)) // bottom 2nd bullet 
		|| (hCount>=(144+left_laser+60)&&hCount<=(144+left_laser+60+17)&&vCount>=(35+291)&&vCount<=(35+291+4)); // bottom 3rd bullet
	
	assign LM_blue_fill = 
	    (hCount>=(144+42)&&hCount<=(144+42+13)&&vCount>=(35+185)&&vCount<=(35+185+6)) // top #1 antenna 
	    || (hCount>=(144+43)&&hCount<=(144+43+7)&&vCount>=(35+191)&&vCount<=(35+191+9)) // top #2 antenna
	    || (hCount>=(144+15)&&hCount<=(144+15+4)&&vCount>=(35+209)&&vCount<=(35+209+26)) // top #1 body  
	    || (hCount>=(144+19)&&hCount<=(144+19+5)&&vCount>=(35+204)&&vCount<=(35+204+36)) // top #2 body  
	    || (hCount>=(144+24)&&hCount<=(144+24+42)&&vCount>=(35+200)&&vCount<=(35+200+45)) // top #3 body  
	    || (hCount>=(144+42)&&hCount<=(144+42+13)&&vCount>=(35+256)&&vCount<=(35+256+6)) // bottom #1 antenna 
	    || (hCount>=(144+43)&&hCount<=(144+43+7)&&vCount>=(35+262)&&vCount<=(35+262+9)) // bottom #2 antenna
	    || (hCount>=(144+15)&&hCount<=(144+15+4)&&vCount>=(35+280)&&vCount<=(35+280+26)) // bottom #1 body  
	    || (hCount>=(144+19)&&hCount<=(144+19+5)&&vCount>=(35+275)&&vCount<=(35+275+36)) // bottom #2 body  
	    || (hCount>=(144+24)&&hCount<=(144+24+42)&&vCount>=(35+271)&&vCount<=(35+271+45)); // bottom #3 body
	
	assign LM_black_fill = 
	    (hCount>=(144+43)&&hCount<=(144+43+6)&&vCount>=(35+205)&&vCount<=(35+205+4)) // top #1 brow
	    || (hCount>=(144+46)&&hCount<=(144+46+6)&&vCount>=(35+207)&&vCount<=(35+207+4)) // top #2 brow 
	    || (hCount>=(144+51)&&hCount<=(144+51+6)&&vCount>=(35+209)&&vCount<=(35+209+4)) // top #3 brow 
	    || (hCount>=(144+55)&&hCount<=(144+55+6)&&vCount>=(35+210)&&vCount<=(35+210+4)) // top #4 brow 
	    || (hCount>=(144+53)&&hCount<=(144+53+8)&&vCount>=(35+217)&&vCount<=(35+217+9)) // top pupil
	    || (hCount>=(144+51)&&hCount<=(144+51+11)&&vCount>=(35+232)&&vCount<=(35+232+7)) // top mouth     
	    || (hCount>=(144+43)&&hCount<=(144+43+6)&&vCount>=(35+276)&&vCount<=(35+276+4)) // bottom #1 brow
	    || (hCount>=(144+46)&&hCount<=(144+46+6)&&vCount>=(35+278)&&vCount<=(35+278+4)) // bottom #2 brow 
	    || (hCount>=(144+51)&&hCount<=(144+51+6)&&vCount>=(35+280)&&vCount<=(35+280+4)) // bottom #3 brow 
	    || (hCount>=(144+55)&&hCount<=(144+55+6)&&vCount>=(35+281)&&vCount<=(35+281+4)) // bottom #4 brow 
	    || (hCount>=(144+53)&&hCount<=(144+53+8)&&vCount>=(35+288)&&vCount<=(35+288+9)) // bottom pupil
	    || (hCount>=(144+51)&&hCount<=(144+51+11)&&vCount>=(35+303)&&vCount<=(35+303+7)); // bottom mouth 
	    
	assign LM_cream_fill = 
	    (hCount>=(144+42)&&hCount<=(144+42+20)&&vCount>=(35+212)&&vCount<=(35+212+18)) // top eyeball
	    || (hCount>=(144+42)&&hCount<=(144+42+20)&&vCount>=(35+283)&&vCount<=(35+283+18)); // bottom eyeball 
	
	assign LM_red_fill = 
	    (hCount>=(144+57)&&hCount<=(144+57+4)&&vCount>=(35+220)&&vCount<=(35+220+4)) // top pupil
	    || (hCount>=(144+57)&&hCount<=(144+57+4)&&vCount>=(35+291)&&vCount<=(35+291+4)); // bottom pupil 
	
	assign LM_mask_fill = 
        (hCount>=(144+0)&&hCount<=(144+0+15)&&vCount>=(35+291)&&vCount<=(35+291+4)) // top mask 
	    || (hCount>=(144+0)&&hCount<=(144+0+15)&&vCount>=(35+220)&&vCount<=(35+220+4)); // bottom mask 
	
	assign LM_display_fill = left_monster && (LM_blue_fill || LM_black_fill
                                || LM_cream_fill || LM_red_fill || LM_mask_fill);

    assign right_red_fill = 
		(hCount>=(144+right_laser-17)&&hCount<=(144+right_laser)&&vCount>=(35+220)&&vCount<=(35+220+4)) // top rightmost 1st bullet 
		|| (hCount>=(144+right_laser-30-17)&&hCount<=(144+right_laser-30)&&vCount>=(35+220)&&vCount<=(35+220+4)) // top 2nd bullet 
		|| (hCount>=(144+right_laser-60-17)&&hCount<=(144+right_laser-60)&&vCount>=(35+220)&&vCount<=(35+220+4)) // top 3rd bullet
		|| (hCount>=(144+right_laser-17)&&hCount<=(144+right_laser)&&vCount>=(35+291)&&vCount<=(35+291+4)) // bottom rightmost 1st bullet 
		|| (hCount>=(144+right_laser-30-17)&&hCount<=(144+right_laser-30)&&vCount>=(35+291)&&vCount<=(35+291+4)) // bottom 2nd bullet 
		|| (hCount>=(144+right_laser-60-17)&&hCount<=(144+right_laser-60)&&vCount>=(35+291)&&vCount<=(35+291+4)); // bottom 3rd bullet
		
	assign RM_blue_fill =
        // top body
        (hCount>=(144+574)&&hCount<=(144+574+42)&&vCount>=(35+200)&&vCount<=(35+200+45))
        || (hCount>=(144+616)&&hCount<=(144+616+5)&&vCount>=(35+204)&&vCount<=(35+204+36))
        || (hCount>=(144+621)&&hCount<=(144+621+4)&&vCount>=(35+209)&&vCount<=(35+209+26))
        // top antenna
        || (hCount>=(144+585)&&hCount<=(144+585+13)&&vCount>=(35+185)&&vCount<=(35+185+6))
        || (hCount>=(144+590)&&hCount<=(144+590+7)&&vCount>=(35+191)&&vCount<=(35+191+9))
        // bottom body
        || (hCount>=(144+574)&&hCount<=(144+574+42)&&vCount>=(35+271)&&vCount<=(35+271+45))
        || (hCount>=(144+616)&&hCount<=(144+616+5)&&vCount>=(35+275)&&vCount<=(35+275+36))
        || (hCount>=(144+621)&&hCount<=(144+621+4)&&vCount>=(35+280)&&vCount<=(35+280+26))
        // bottom antenna
        || (hCount>=(144+585)&&hCount<=(144+585+13)&&vCount>=(35+256)&&vCount<=(35+256+6))
        || (hCount>=(144+590)&&hCount<=(144+590+7)&&vCount>=(35+262)&&vCount<=(35+262+9));
	
	assign RM_black_fill =
        // top eyebrow
        (hCount>=(144+591)&&hCount<=(144+591+6)&&vCount>=(35+205)&&vCount<=(35+205+4))
        || (hCount>=(144+587)&&hCount<=(144+587+7)&&vCount>=(35+207)&&vCount<=(35+207+4))
        || (hCount>=(144+583)&&hCount<=(144+583+6)&&vCount>=(35+209)&&vCount<=(35+209+3))
        || (hCount>=(144+578)&&hCount<=(144+578+7)&&vCount>=(35+210)&&vCount<=(35+210+4))
        // top pupil
        || (hCount>=(144+579)&&hCount<=(144+579+8)&&vCount>=(35+217)&&vCount<=(35+217+9))
        // top mouth
        || (hCount>=(144+578)&&hCount<=(144+578+11)&&vCount>=(35+232)&&vCount<=(35+232+7))
        // bottom eyebrow
        || (hCount>=(144+591)&&hCount<=(144+591+6)&&vCount>=(35+276)&&vCount<=(35+276+4))
        || (hCount>=(144+587)&&hCount<=(144+587+7)&&vCount>=(35+278)&&vCount<=(35+278+4))
        || (hCount>=(144+583)&&hCount<=(144+583+6)&&vCount>=(35+280)&&vCount<=(35+280+3))
        || (hCount>=(144+578)&&hCount<=(144+578+7)&&vCount>=(35+281)&&vCount<=(35+281+4))
        // bottom pupil
        || (hCount>=(144+579)&&hCount<=(144+579+8)&&vCount>=(35+288)&&vCount<=(35+288+9))
        // bottom mouth
        || (hCount>=(144+578)&&hCount<=(144+578+11)&&vCount>=(35+303)&&vCount<=(35+303+7));
        
    assign RM_cream_fill =
        // top eyeball
        (hCount>=(144+578)&&hCount<=(144+578+20)&&vCount>=(35+212)&&vCount<=(35+212+18))
        // bottom eyeball
        || (hCount>=(144+578)&&hCount<=(144+578+20)&&vCount>=(35+283)&&vCount<=(35+283+18));
    
    assign RM_red_fill =
        // top pupil
        (hCount>=(144+579)&&hCount<=(144+579+4)&&vCount>=(35+220)&&vCount<=(35+220+4))
        // bottom pupil
        || (hCount>=(144+579)&&hCount<=(144+579+4)&&vCount>=(35+291)&&vCount<=(35+291+4));
    
    assign RM_mask_fill =
        // top mask
        (hCount>=(144+625)&&hCount<=(144+625+15)&&vCount>=(35+220)&&vCount<=(35+220+4))
        // bottom mask
        || (hCount>=(144+625)&&hCount<=(144+625+15)&&vCount>=(35+291)&&vCount<=(35+291+4));
        
    assign RM_display_fill = right_monster && (RM_blue_fill || RM_black_fill
                                || RM_cream_fill || RM_red_fill || RM_mask_fill);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	assign T0_fill = 
		(hCount>=(144+TOP_H+2)&&hCount<=(144+TOP_H+2+3)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+16))
		|| (hCount>=(144+TOP_H+5)&&hCount<=(144+TOP_H+5+3)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+3))
		|| (hCount>=(144+TOP_H+8)&&hCount<=(144+TOP_H+8+3)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+16))
		|| (hCount>=(144+TOP_H+5)&&hCount<=(144+TOP_H+5+3)&&vCount>=(35+TOP_V+13)&&vCount<=(35+TOP_V+13+3));
		
	assign T1_fill = 
		(hCount>=(144+TOP_H+3)&&hCount<=(144+TOP_H+3+3)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+3))
		|| (hCount>=(144+TOP_H+6)&&hCount<=(144+TOP_H+6+3)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+16));
		
	assign T2_fill =
		(hCount>=(144+TOP_H+1)&&hCount<=(144+TOP_H+1+6)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+3))
		|| (hCount>=(144+TOP_H+8)&&hCount<=(144+TOP_H+8+3)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+9))
		|| (hCount>=(144+TOP_H+1)&&hCount<=(144+TOP_H+1+3)&&vCount>=(35+TOP_V+6)&&vCount<=(35+TOP_V+6+10))
		|| (hCount>=(144+TOP_H+4)&&hCount<=(144+TOP_H+4+4)&&vCount>=(35+TOP_V+6)&&vCount<=(35+TOP_V+6+3))
		|| (hCount>=(144+TOP_H+4)&&hCount<=(144+TOP_H+4+7)&&vCount>=(35+TOP_V+13)&&vCount<=(35+TOP_V+13+3));

	assign T3_fill = 
		(hCount>=(144+TOP_H+2)&&hCount<=(144+TOP_H+2+6)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+3))
		|| (hCount>=(144+TOP_H+8)&&hCount<=(144+TOP_H+8+3)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+16))
		|| (hCount>=(144+TOP_H+5)&&hCount<=(144+TOP_H+5+3)&&vCount>=(35+TOP_V+6)&&vCount<=(35+TOP_V+6+3))
		|| (hCount>=(144+TOP_H+2)&&hCount<=(144+TOP_H+2+6)&&vCount>=(35+TOP_V+13)&&vCount<=(35+TOP_V+13+3));

	assign T4_fill = 
		(hCount>=(144+TOP_H+2)&&hCount<=(144+TOP_H+2+3)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+9))
		|| (hCount>=(144+TOP_H+8)&&hCount<=(144+TOP_H+8+3)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+16))
		|| (hCount>=(144+TOP_H+5)&&hCount<=(144+TOP_H+5+3)&&vCount>=(35+TOP_V+6)&&vCount<=(35+TOP_V+6+3));

	assign T5_fill =
		(hCount>=(144+TOP_H+1)&&hCount<=(144+TOP_H+1+3)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+9))
		|| (hCount>=(144+TOP_H+4)&&hCount<=(144+TOP_H+4+7)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+3))
		|| (hCount>=(144+TOP_H+4)&&hCount<=(144+TOP_H+4+4)&&vCount>=(35+TOP_V+6)&&vCount<=(35+TOP_V+6+3))
		|| (hCount>=(144+TOP_H+8)&&hCount<=(144+TOP_H+8+3)&&vCount>=(35+TOP_V+6)&&vCount<=(35+TOP_V+6+10))
		|| (hCount>=(144+TOP_H+1)&&hCount<=(144+TOP_H+1+7)&&vCount>=(35+TOP_V+13)&&vCount<=(35+TOP_V+13+3));

	assign T6_fill =
		(hCount>=(144+TOP_H+2)&&hCount<=(144+TOP_H+2+3)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+16))
		|| (hCount>=(144+TOP_H+5)&&hCount<=(144+TOP_H+5+3)&&vCount>=(35+TOP_V+7)&&vCount<=(35+TOP_V+7+3))
		|| (hCount>=(144+TOP_H+8)&&hCount<=(144+TOP_H+8+3)&&vCount>=(35+TOP_V+7)&&vCount<=(35+TOP_V+7+9))
		|| (hCount>=(144+TOP_H+5)&&hCount<=(144+TOP_H+5+3)&&vCount>=(35+TOP_V+13)&&vCount<=(35+TOP_V+13+3));

	assign T7_fill = 
		(hCount>=(144+TOP_H+2)&&hCount<=(144+TOP_H+2+6)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+3))
		|| (hCount>=(144+TOP_H+8)&&hCount<=(144+TOP_H+8+3)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+16));
		
	assign T8_fill = 
		(hCount>=(144+TOP_H+2)&&hCount<=(144+TOP_H+2+3)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+16))
		|| (hCount>=(144+TOP_H+5)&&hCount<=(144+TOP_H+5+3)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+3))
		|| (hCount>=(144+TOP_H+8)&&hCount<=(144+TOP_H+8+3)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+16))
		|| (hCount>=(144+TOP_H+5)&&hCount<=(144+TOP_H+5+3)&&vCount>=(35+TOP_V+6)&&vCount<=(35+TOP_V+6+3))
		|| (hCount>=(144+TOP_H+5)&&hCount<=(144+TOP_H+5+3)&&vCount>=(35+TOP_V+13)&&vCount<=(35+TOP_V+13+3));

	assign T9_fill = 
		(hCount>=(144+TOP_H+2)&&hCount<=(144+TOP_H+2+3)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+9))
		|| (hCount>=(144+TOP_H+5)&&hCount<=(144+TOP_H+5+3)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+3))
		|| (hCount>=(144+TOP_H+8)&&hCount<=(144+TOP_H+8+3)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+16))
		|| (hCount>=(144+TOP_H+5)&&hCount<=(144+TOP_H+5+3)&&vCount>=(35+TOP_V+6)&&vCount<=(35+TOP_V+6+3));
	
	assign TA_fill =
        // top terminal A 
        (hCount>=(144+TOP_H+2)&&hCount<=(144+TOP_H+2+3)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+16)) // left rectangle
        || (hCount>=(144+TOP_H+5)&&hCount<=(144+TOP_H+5+3)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+3)) // mid top 
        || (hCount>=(144+TOP_H+5)&&hCount<=(144+TOP_H+5+3)&&vCount>=(35+TOP_V+6)&&vCount<=(35+TOP_V+6+3)) // mid mid 
	    || (hCount>=(144+TOP_H+8)&&hCount<=(144+TOP_H+8+3)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+16)); // right rectangle 
	
	assign TB_fill =
        // top terminal B
        (hCount>=(144+TOP_H)&&hCount<=(144+TOP_H+9)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+3)) // top rectangle
        || (hCount>=(144+TOP_H)&&hCount<=(144+TOP_H+3)&&vCount>=(35+TOP_V+3)&&vCount<=(35+TOP_V+3+3)) // left second
        || (hCount>=(144+TOP_H+6)&&hCount<=(144+TOP_H+6+3)&&vCount>=(35+TOP_V+3)&&vCount<=(35+TOP_V+3+3)) // right second 
        || (hCount>=(144+TOP_H)&&hCount<=(144+TOP_H+9)&&vCount>=(35+TOP_V+6)&&vCount<=(35+TOP_V+6+3)) // mid rectangle 
        || (hCount>=(144+TOP_H)&&hCount<=(144+TOP_H+3)&&vCount>=(35+TOP_V+9)&&vCount<=(35+TOP_V+9+4)) // left fourth
        || (hCount>=(144+TOP_H+9)&&hCount<=(144+TOP_H+9+3)&&vCount>=(35+TOP_V+9)&&vCount<=(35+TOP_V+9+4)) // right fourth
        || (hCount>=(144+TOP_H)&&hCount<=(144+TOP_H+12)&&vCount>=(35+TOP_V+13)&&vCount<=(35+TOP_V+13+3)); // bottom rectangle
	
	assign TC_fill =
        // top terminal C
        (hCount>=(144+TOP_H+2)&&hCount<=(144+TOP_H+2+9)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+3)) // top rectangle
        || (hCount>=(144+TOP_H+2)&&hCount<=(144+TOP_H+2+3)&&vCount>=(35+TOP_V+3)&&vCount<=(35+TOP_V+3+10)) // left second
        ||(hCount>=(144+TOP_H+2)&&hCount<=(144+TOP_H+2+9)&&vCount>=(35+TOP_V+13)&&vCount<=(35+TOP_V+13+3)); // bottom rectangle
        
    assign TD_fill =
        // top terminal D
        (hCount>=(144+TOP_H+2)&&hCount<=(144+TOP_H+2+3)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+16)) // left rectangle
        || (hCount>=(144+TOP_H+5)&&hCount<=(144+TOP_H+5+4)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+3)) // top right 
        || (hCount>=(144+TOP_H+5)&&hCount<=(144+TOP_H+5+4)&&vCount>=(35+TOP_V+13)&&vCount<=(35+TOP_V+13+3)) // bottom right 
        || (hCount>=(144+TOP_H+8)&&hCount<=(144+TOP_H+8+3)&&vCount>=(35+TOP_V+3)&&vCount<=(35+TOP_V+3+10)); // right rectangle   
    
    assign TE_fill =
        // top terminal D
        (hCount>=(144+TOP_H+2)&&hCount<=(144+TOP_H+2+3)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+16)) // left rectangle
        || (hCount>=(144+TOP_H+5)&&hCount<=(144+TOP_H+5+6)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+3)) // top right 
        || (hCount>=(144+TOP_H+5)&&hCount<=(144+TOP_H+5+3)&&vCount>=(35+TOP_V+6)&&vCount<=(35+TOP_V+6+3)) // middle right 
         || (hCount>=(144+TOP_H+5)&&hCount<=(144+TOP_H+5+6)&&vCount>=(35+TOP_V+13)&&vCount<=(35+TOP_V+13+3)); // bottom right   
	
	assign TF_fill =
        // top terminal F
        (hCount>=(144+TOP_H+2)&&hCount<=(144+TOP_H+2+3)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+16)) // left rectangle
        || (hCount>=(144+TOP_H+5)&&hCount<=(144+TOP_H+5+6)&&vCount>=(35+TOP_V)&&vCount<=(35+TOP_V+3)) // top right 
        || (hCount>=(144+TOP_H+5)&&hCount<=(144+TOP_H+5+6)&&vCount>=(35+TOP_V+6)&&vCount<=(35+TOP_V+6+3)); // middle right 

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	assign B0_fill = 
		(hCount>=(144+BTM_H+2)&&hCount<=(144+BTM_H+2+3)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+16))
		|| (hCount>=(144+BTM_H+5)&&hCount<=(144+BTM_H+5+3)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+3))
		|| (hCount>=(144+BTM_H+8)&&hCount<=(144+BTM_H+8+3)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+16))
		|| (hCount>=(144+BTM_H+5)&&hCount<=(144+BTM_H+5+3)&&vCount>=(35+BTM_V+13)&&vCount<=(35+BTM_V+13+3));
		
	assign B1_fill = 
		(hCount>=(144+BTM_H+3)&&hCount<=(144+BTM_H+3+3)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+3))
		|| (hCount>=(144+BTM_H+6)&&hCount<=(144+BTM_H+6+3)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+16));
		
	assign B2_fill =
		(hCount>=(144+BTM_H+1)&&hCount<=(144+BTM_H+1+6)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+3))
		|| (hCount>=(144+BTM_H+8)&&hCount<=(144+BTM_H+8+3)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+9))
		|| (hCount>=(144+BTM_H+1)&&hCount<=(144+BTM_H+1+3)&&vCount>=(35+BTM_V+6)&&vCount<=(35+BTM_V+6+10))
		|| (hCount>=(144+BTM_H+4)&&hCount<=(144+BTM_H+4+4)&&vCount>=(35+BTM_V+6)&&vCount<=(35+BTM_V+6+3))
		|| (hCount>=(144+BTM_H+4)&&hCount<=(144+BTM_H+4+7)&&vCount>=(35+BTM_V+13)&&vCount<=(35+BTM_V+13+3));

	assign B3_fill = 
		(hCount>=(144+BTM_H+2)&&hCount<=(144+BTM_H+2+6)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+3))
		|| (hCount>=(144+BTM_H+8)&&hCount<=(144+BTM_H+8+3)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+16))
		|| (hCount>=(144+BTM_H+5)&&hCount<=(144+BTM_H+5+3)&&vCount>=(35+BTM_V+6)&&vCount<=(35+BTM_V+6+3))
		|| (hCount>=(144+BTM_H+2)&&hCount<=(144+BTM_H+2+6)&&vCount>=(35+BTM_V+13)&&vCount<=(35+BTM_V+13+3));

	assign B4_fill = 
		(hCount>=(144+BTM_H+2)&&hCount<=(144+BTM_H+2+3)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+9))
		|| (hCount>=(144+BTM_H+8)&&hCount<=(144+BTM_H+8+3)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+16))
		|| (hCount>=(144+BTM_H+5)&&hCount<=(144+BTM_H+5+3)&&vCount>=(35+BTM_V+6)&&vCount<=(35+BTM_V+6+3));

	assign B5_fill =
		(hCount>=(144+BTM_H+1)&&hCount<=(144+BTM_H+1+3)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+9))
		|| (hCount>=(144+BTM_H+4)&&hCount<=(144+BTM_H+4+7)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+3))
		|| (hCount>=(144+BTM_H+4)&&hCount<=(144+BTM_H+4+4)&&vCount>=(35+BTM_V+6)&&vCount<=(35+BTM_V+6+3))
		|| (hCount>=(144+BTM_H+8)&&hCount<=(144+BTM_H+8+3)&&vCount>=(35+BTM_V+6)&&vCount<=(35+BTM_V+6+10))
		|| (hCount>=(144+BTM_H+1)&&hCount<=(144+BTM_H+1+7)&&vCount>=(35+BTM_V+13)&&vCount<=(35+BTM_V+13+3));

	assign B6_fill =
		(hCount>=(144+BTM_H+2)&&hCount<=(144+BTM_H+2+3)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+16))
		|| (hCount>=(144+BTM_H+5)&&hCount<=(144+BTM_H+5+3)&&vCount>=(35+BTM_V+7)&&vCount<=(35+BTM_V+7+3))
		|| (hCount>=(144+BTM_H+8)&&hCount<=(144+BTM_H+8+3)&&vCount>=(35+BTM_V+7)&&vCount<=(35+BTM_V+7+9))
		|| (hCount>=(144+BTM_H+5)&&hCount<=(144+BTM_H+5+3)&&vCount>=(35+BTM_V+13)&&vCount<=(35+BTM_V+13+3));

	assign B7_fill = 
		(hCount>=(144+BTM_H+2)&&hCount<=(144+BTM_H+2+6)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+3))
		|| (hCount>=(144+BTM_H+8)&&hCount<=(144+BTM_H+8+3)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+16));
		
	assign B8_fill = 
		(hCount>=(144+BTM_H+2)&&hCount<=(144+BTM_H+2+3)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+16))
		|| (hCount>=(144+BTM_H+5)&&hCount<=(144+BTM_H+5+3)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+3))
		|| (hCount>=(144+BTM_H+8)&&hCount<=(144+BTM_H+8+3)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+16))
		|| (hCount>=(144+BTM_H+5)&&hCount<=(144+BTM_H+5+3)&&vCount>=(35+BTM_V+6)&&vCount<=(35+BTM_V+6+3))
		|| (hCount>=(144+BTM_H+5)&&hCount<=(144+BTM_H+5+3)&&vCount>=(35+BTM_V+13)&&vCount<=(35+BTM_V+13+3));

	assign B9_fill = 
		(hCount>=(144+BTM_H+2)&&hCount<=(144+BTM_H+2+3)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+9))
		|| (hCount>=(144+BTM_H+5)&&hCount<=(144+BTM_H+5+3)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+3))
		|| (hCount>=(144+BTM_H+8)&&hCount<=(144+BTM_H+8+3)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+16))
		|| (hCount>=(144+BTM_H+5)&&hCount<=(144+BTM_H+5+3)&&vCount>=(35+BTM_V+6)&&vCount<=(35+BTM_V+6+3));
		
	assign BA_fill =
        // top terminal A 
        (hCount>=(144+BTM_H+2)&&hCount<=(144+BTM_H+2+3)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+16)) // left rectangle
        || (hCount>=(144+BTM_H+5)&&hCount<=(144+BTM_H+5+3)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+3)) // mid top 
        || (hCount>=(144+BTM_H+5)&&hCount<=(144+BTM_H+5+3)&&vCount>=(35+BTM_V+6)&&vCount<=(35+BTM_V+6+3)) // mid mid 
	    || (hCount>=(144+BTM_H+8)&&hCount<=(144+BTM_H+8+3)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+16)); // right rectangle 
	
	assign BB_fill =
        // top terminal B
        (hCount>=(144+BTM_H)&&hCount<=(144+BTM_H+9)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+3)) // top rectangle
        || (hCount>=(144+BTM_H)&&hCount<=(144+BTM_H+3)&&vCount>=(35+BTM_V+3)&&vCount<=(35+BTM_V+3+3)) // left second
        || (hCount>=(144+BTM_H+6)&&hCount<=(144+BTM_H+6+3)&&vCount>=(35+BTM_V+3)&&vCount<=(35+BTM_V+3+3)) // right second 
        || (hCount>=(144+BTM_H)&&hCount<=(144+BTM_H+9)&&vCount>=(35+BTM_V+6)&&vCount<=(35+BTM_V+6+3)) // mid rectangle 
        || (hCount>=(144+BTM_H)&&hCount<=(144+BTM_H+3)&&vCount>=(35+BTM_V+9)&&vCount<=(35+BTM_V+9+4)) // left fourth
        || (hCount>=(144+BTM_H+9)&&hCount<=(144+BTM_H+9+3)&&vCount>=(35+BTM_V+9)&&vCount<=(35+BTM_V+9+4)) // right fourth
        || (hCount>=(144+BTM_H)&&hCount<=(144+BTM_H+12)&&vCount>=(35+BTM_V+13)&&vCount<=(35+BTM_V+13+3)); // bottom rectangle
	
	assign BC_fill =
        // top terminal C
        (hCount>=(144+BTM_H+2)&&hCount<=(144+BTM_H+2+9)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+3)) // top rectangle
        || (hCount>=(144+BTM_H+2)&&hCount<=(144+BTM_H+2+3)&&vCount>=(35+BTM_V+3)&&vCount<=(35+BTM_V+3+10)) // left second
        ||(hCount>=(144+BTM_H+2)&&hCount<=(144+BTM_H+2+9)&&vCount>=(35+BTM_V+13)&&vCount<=(35+BTM_V+13+3)); // bottom rectangle
        
    assign BD_fill =
        // top terminal D
        (hCount>=(144+BTM_H+2)&&hCount<=(144+BTM_H+2+3)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+16)) // left rectangle
        || (hCount>=(144+BTM_H+5)&&hCount<=(144+BTM_H+5+4)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+3)) // top right 
        || (hCount>=(144+BTM_H+5)&&hCount<=(144+BTM_H+5+4)&&vCount>=(35+BTM_V+13)&&vCount<=(35+BTM_V+13+3)) // bottom right 
        || (hCount>=(144+BTM_H+8)&&hCount<=(144+BTM_H+8+3)&&vCount>=(35+BTM_V+3)&&vCount<=(35+BTM_V+3+10)); // right rectangle   
    
    assign BE_fill =
        // top terminal D
        (hCount>=(144+BTM_H+2)&&hCount<=(144+BTM_H+2+3)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+16)) // left rectangle
        || (hCount>=(144+BTM_H+5)&&hCount<=(144+BTM_H+5+6)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+3)) // top right 
        || (hCount>=(144+BTM_H+5)&&hCount<=(144+BTM_H+5+3)&&vCount>=(35+BTM_V+6)&&vCount<=(35+BTM_V+6+3)) // middle right 
        || (hCount>=(144+BTM_H+5)&&hCount<=(144+BTM_H+5+6)&&vCount>=(35+BTM_V+13)&&vCount<=(35+BTM_V+13+3)); // bottom right   
	
	assign BF_fill =
        // top terminal F
        (hCount>=(144+BTM_H+2)&&hCount<=(144+BTM_H+2+3)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+16)) // left rectangle
        || (hCount>=(144+BTM_H+5)&&hCount<=(144+BTM_H+5+6)&&vCount>=(35+BTM_V)&&vCount<=(35+BTM_V+3)) // top right 
        || (hCount>=(144+BTM_H+5)&&hCount<=(144+BTM_H+5+6)&&vCount>=(35+BTM_V+6)&&vCount<=(35+BTM_V+6+3)); // middle right 

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	assign L0_fill = 
		(hCount>=(144+LEFT_H+2)&&hCount<=(144+LEFT_H+2+3)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+16))
		|| (hCount>=(144+LEFT_H+5)&&hCount<=(144+LEFT_H+5+3)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+3))
		|| (hCount>=(144+LEFT_H+8)&&hCount<=(144+LEFT_H+8+3)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+16))
		|| (hCount>=(144+LEFT_H+5)&&hCount<=(144+LEFT_H+5+3)&&vCount>=(35+LEFT_V+13)&&vCount<=(35+LEFT_V+13+3));
		
	assign L1_fill = 
		(hCount>=(144+LEFT_H+3)&&hCount<=(144+LEFT_H+3+3)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+3))
		|| (hCount>=(144+LEFT_H+6)&&hCount<=(144+LEFT_H+6+3)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+16));
		
	assign L2_fill =
		(hCount>=(144+LEFT_H+1)&&hCount<=(144+LEFT_H+1+6)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+3))
		|| (hCount>=(144+LEFT_H+8)&&hCount<=(144+LEFT_H+8+3)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+9))
		|| (hCount>=(144+LEFT_H+1)&&hCount<=(144+LEFT_H+1+3)&&vCount>=(35+LEFT_V+6)&&vCount<=(35+LEFT_V+6+10))
		|| (hCount>=(144+LEFT_H+4)&&hCount<=(144+LEFT_H+4+4)&&vCount>=(35+LEFT_V+6)&&vCount<=(35+LEFT_V+6+3))
		|| (hCount>=(144+LEFT_H+4)&&hCount<=(144+LEFT_H+4+7)&&vCount>=(35+LEFT_V+13)&&vCount<=(35+LEFT_V+13+3));

	assign L3_fill = 
		(hCount>=(144+LEFT_H+2)&&hCount<=(144+LEFT_H+2+6)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+3))
		|| (hCount>=(144+LEFT_H+8)&&hCount<=(144+LEFT_H+8+3)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+16))
		|| (hCount>=(144+LEFT_H+5)&&hCount<=(144+LEFT_H+5+3)&&vCount>=(35+LEFT_V+6)&&vCount<=(35+LEFT_V+6+3))
		|| (hCount>=(144+LEFT_H+2)&&hCount<=(144+LEFT_H+2+6)&&vCount>=(35+LEFT_V+13)&&vCount<=(35+LEFT_V+13+3));

	assign L4_fill = 
		(hCount>=(144+LEFT_H+2)&&hCount<=(144+LEFT_H+2+3)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+9))
		|| (hCount>=(144+LEFT_H+8)&&hCount<=(144+LEFT_H+8+3)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+16))
		|| (hCount>=(144+LEFT_H+5)&&hCount<=(144+LEFT_H+5+3)&&vCount>=(35+LEFT_V+6)&&vCount<=(35+LEFT_V+6+3));

	assign L5_fill =
		(hCount>=(144+LEFT_H+1)&&hCount<=(144+LEFT_H+1+3)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+9))
		|| (hCount>=(144+LEFT_H+4)&&hCount<=(144+LEFT_H+4+7)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+3))
		|| (hCount>=(144+LEFT_H+4)&&hCount<=(144+LEFT_H+4+4)&&vCount>=(35+LEFT_V+6)&&vCount<=(35+LEFT_V+6+3))
		|| (hCount>=(144+LEFT_H+8)&&hCount<=(144+LEFT_H+8+3)&&vCount>=(35+LEFT_V+6)&&vCount<=(35+LEFT_V+6+10))
		|| (hCount>=(144+LEFT_H+1)&&hCount<=(144+LEFT_H+1+7)&&vCount>=(35+LEFT_V+13)&&vCount<=(35+LEFT_V+13+3));

	assign L6_fill =
		(hCount>=(144+LEFT_H+2)&&hCount<=(144+LEFT_H+2+3)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+16))
		|| (hCount>=(144+LEFT_H+5)&&hCount<=(144+LEFT_H+5+3)&&vCount>=(35+LEFT_V+7)&&vCount<=(35+LEFT_V+7+3))
		|| (hCount>=(144+LEFT_H+8)&&hCount<=(144+LEFT_H+8+3)&&vCount>=(35+LEFT_V+7)&&vCount<=(35+LEFT_V+7+9))
		|| (hCount>=(144+LEFT_H+5)&&hCount<=(144+LEFT_H+5+3)&&vCount>=(35+LEFT_V+13)&&vCount<=(35+LEFT_V+13+3));

	assign L7_fill = 
		(hCount>=(144+LEFT_H+2)&&hCount<=(144+LEFT_H+2+6)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+3))
		|| (hCount>=(144+LEFT_H+8)&&hCount<=(144+LEFT_H+8+3)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+16));
		
	assign L8_fill = 
		(hCount>=(144+LEFT_H+2)&&hCount<=(144+LEFT_H+2+3)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+16))
		|| (hCount>=(144+LEFT_H+5)&&hCount<=(144+LEFT_H+5+3)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+3))
		|| (hCount>=(144+LEFT_H+8)&&hCount<=(144+LEFT_H+8+3)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+16))
		|| (hCount>=(144+LEFT_H+5)&&hCount<=(144+LEFT_H+5+3)&&vCount>=(35+LEFT_V+6)&&vCount<=(35+LEFT_V+6+3))
		|| (hCount>=(144+LEFT_H+5)&&hCount<=(144+LEFT_H+5+3)&&vCount>=(35+LEFT_V+13)&&vCount<=(35+LEFT_V+13+3));

	assign L9_fill = 
		(hCount>=(144+LEFT_H+2)&&hCount<=(144+LEFT_H+2+3)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+9))
		|| (hCount>=(144+LEFT_H+5)&&hCount<=(144+LEFT_H+5+3)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+3))
		|| (hCount>=(144+LEFT_H+8)&&hCount<=(144+LEFT_H+8+3)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+16))
		|| (hCount>=(144+LEFT_H+5)&&hCount<=(144+LEFT_H+5+3)&&vCount>=(35+LEFT_V+6)&&vCount<=(35+LEFT_V+6+3));
		
	assign LA_fill =
        // top terminal A 
        (hCount>=(144+LEFT_H+2)&&hCount<=(144+LEFT_H+2+3)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+16)) // left rectangle
        || (hCount>=(144+LEFT_H+5)&&hCount<=(144+LEFT_H+5+3)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+3)) // mid top 
        || (hCount>=(144+LEFT_H+5)&&hCount<=(144+LEFT_H+5+3)&&vCount>=(35+LEFT_V+6)&&vCount<=(35+LEFT_V+6+3)) // mid mid 
	    || (hCount>=(144+LEFT_H+8)&&hCount<=(144+LEFT_H+8+3)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+16)); // right rectangle 
	
	assign LB_fill =
        // top terminal B
        (hCount>=(144+LEFT_H)&&hCount<=(144+LEFT_H+9)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+3)) // top rectangle
        || (hCount>=(144+LEFT_H)&&hCount<=(144+LEFT_H+3)&&vCount>=(35+LEFT_V+3)&&vCount<=(35+LEFT_V+3+3)) // left second
        || (hCount>=(144+LEFT_H+6)&&hCount<=(144+LEFT_H+6+3)&&vCount>=(35+LEFT_V+3)&&vCount<=(35+LEFT_V+3+3)) // right second 
        || (hCount>=(144+LEFT_H)&&hCount<=(144+LEFT_H+9)&&vCount>=(35+LEFT_V+6)&&vCount<=(35+LEFT_V+6+3)) // mid rectangle 
        || (hCount>=(144+LEFT_H)&&hCount<=(144+LEFT_H+3)&&vCount>=(35+LEFT_V+9)&&vCount<=(35+LEFT_V+9+4)) // left fourth
        || (hCount>=(144+LEFT_H+9)&&hCount<=(144+LEFT_H+9+3)&&vCount>=(35+LEFT_V+9)&&vCount<=(35+LEFT_V+9+4)) // right fourth
        || (hCount>=(144+LEFT_H)&&hCount<=(144+LEFT_H+12)&&vCount>=(35+LEFT_V+13)&&vCount<=(35+LEFT_V+13+3)); // bottom rectangle
	
	assign LC_fill =
        // top terminal C
        (hCount>=(144+LEFT_H+2)&&hCount<=(144+LEFT_H+2+9)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+3)) // top rectangle
        || (hCount>=(144+LEFT_H+2)&&hCount<=(144+LEFT_H+2+3)&&vCount>=(35+LEFT_V+3)&&vCount<=(35+LEFT_V+3+10)) // left second
        ||(hCount>=(144+LEFT_H+2)&&hCount<=(144+LEFT_H+2+9)&&vCount>=(35+LEFT_V+13)&&vCount<=(35+LEFT_V+13+3)); // bottom rectangle
        
    assign LD_fill =
        // top terminal D
        (hCount>=(144+LEFT_H+2)&&hCount<=(144+LEFT_H+2+3)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+16)) // left rectangle
        || (hCount>=(144+LEFT_H+5)&&hCount<=(144+LEFT_H+5+4)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+3)) // top right 
        || (hCount>=(144+LEFT_H+5)&&hCount<=(144+LEFT_H+5+4)&&vCount>=(35+LEFT_V+13)&&vCount<=(35+LEFT_V+13+3)) // bottom right 
        || (hCount>=(144+LEFT_H+8)&&hCount<=(144+LEFT_H+8+3)&&vCount>=(35+LEFT_V+3)&&vCount<=(35+LEFT_V+3+10)); // right rectangle   
    
    assign LE_fill =
        // top terminal D
        (hCount>=(144+LEFT_H+2)&&hCount<=(144+LEFT_H+2+3)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+16)) // left rectangle
        || (hCount>=(144+LEFT_H+5)&&hCount<=(144+LEFT_H+5+6)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+3)) // top right 
        || (hCount>=(144+LEFT_H+5)&&hCount<=(144+LEFT_H+5+3)&&vCount>=(35+LEFT_V+6)&&vCount<=(35+LEFT_V+6+3)) // middle right 
        || (hCount>=(144+LEFT_H+5)&&hCount<=(144+LEFT_H+5+6)&&vCount>=(35+LEFT_V+13)&&vCount<=(35+LEFT_V+13+3)); // bottom right   
	
	assign LF_fill =
        // top terminal F
        (hCount>=(144+LEFT_H+2)&&hCount<=(144+LEFT_H+2+3)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+16)) // left rectangle
        || (hCount>=(144+LEFT_H+5)&&hCount<=(144+LEFT_H+5+6)&&vCount>=(35+LEFT_V)&&vCount<=(35+LEFT_V+3)) // top right 
        || (hCount>=(144+LEFT_H+5)&&hCount<=(144+LEFT_H+5+6)&&vCount>=(35+LEFT_V+6)&&vCount<=(35+LEFT_V+6+3)); // middle right 

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	assign R0_fill = 
		(hCount>=(144+RIGHT_H+2)&&hCount<=(144+RIGHT_H+2+3)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+16))
		|| (hCount>=(144+RIGHT_H+5)&&hCount<=(144+RIGHT_H+5+3)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+3))
		|| (hCount>=(144+RIGHT_H+8)&&hCount<=(144+RIGHT_H+8+3)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+16))
		|| (hCount>=(144+RIGHT_H+5)&&hCount<=(144+RIGHT_H+5+3)&&vCount>=(35+RIGHT_V+13)&&vCount<=(35+RIGHT_V+13+3));
		
	assign R1_fill = 
		(hCount>=(144+RIGHT_H+3)&&hCount<=(144+RIGHT_H+3+3)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+3))
		|| (hCount>=(144+RIGHT_H+6)&&hCount<=(144+RIGHT_H+6+3)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+16));
		
	assign R2_fill =
		(hCount>=(144+RIGHT_H+1)&&hCount<=(144+RIGHT_H+1+6)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+3))
		|| (hCount>=(144+RIGHT_H+8)&&hCount<=(144+RIGHT_H+8+3)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+9))
		|| (hCount>=(144+RIGHT_H+1)&&hCount<=(144+RIGHT_H+1+3)&&vCount>=(35+RIGHT_V+6)&&vCount<=(35+RIGHT_V+6+10))
		|| (hCount>=(144+RIGHT_H+4)&&hCount<=(144+RIGHT_H+4+4)&&vCount>=(35+RIGHT_V+6)&&vCount<=(35+RIGHT_V+6+3))
		|| (hCount>=(144+RIGHT_H+4)&&hCount<=(144+RIGHT_H+4+7)&&vCount>=(35+RIGHT_V+13)&&vCount<=(35+RIGHT_V+13+3));

	assign R3_fill = 
		(hCount>=(144+RIGHT_H+2)&&hCount<=(144+RIGHT_H+2+6)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+3))
		|| (hCount>=(144+RIGHT_H+8)&&hCount<=(144+RIGHT_H+8+3)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+16))
		|| (hCount>=(144+RIGHT_H+5)&&hCount<=(144+RIGHT_H+5+3)&&vCount>=(35+RIGHT_V+6)&&vCount<=(35+RIGHT_V+6+3))
		|| (hCount>=(144+RIGHT_H+2)&&hCount<=(144+RIGHT_H+2+6)&&vCount>=(35+RIGHT_V+13)&&vCount<=(35+RIGHT_V+13+3));

	assign R4_fill = 
		(hCount>=(144+RIGHT_H+2)&&hCount<=(144+RIGHT_H+2+3)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+9))
		|| (hCount>=(144+RIGHT_H+8)&&hCount<=(144+RIGHT_H+8+3)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+16))
		|| (hCount>=(144+RIGHT_H+5)&&hCount<=(144+RIGHT_H+5+3)&&vCount>=(35+RIGHT_V+6)&&vCount<=(35+RIGHT_V+6+3));

	assign R5_fill =
		(hCount>=(144+RIGHT_H+1)&&hCount<=(144+RIGHT_H+1+3)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+9))
		|| (hCount>=(144+RIGHT_H+4)&&hCount<=(144+RIGHT_H+4+7)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+3))
		|| (hCount>=(144+RIGHT_H+4)&&hCount<=(144+RIGHT_H+4+4)&&vCount>=(35+RIGHT_V+6)&&vCount<=(35+RIGHT_V+6+3))
		|| (hCount>=(144+RIGHT_H+8)&&hCount<=(144+RIGHT_H+8+3)&&vCount>=(35+RIGHT_V+6)&&vCount<=(35+RIGHT_V+6+10))
		|| (hCount>=(144+RIGHT_H+1)&&hCount<=(144+RIGHT_H+1+7)&&vCount>=(35+RIGHT_V+13)&&vCount<=(35+RIGHT_V+13+3));

	assign R6_fill =
		(hCount>=(144+RIGHT_H+2)&&hCount<=(144+RIGHT_H+2+3)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+16))
		|| (hCount>=(144+RIGHT_H+5)&&hCount<=(144+RIGHT_H+5+3)&&vCount>=(35+RIGHT_V+7)&&vCount<=(35+RIGHT_V+7+3))
		|| (hCount>=(144+RIGHT_H+8)&&hCount<=(144+RIGHT_H+8+3)&&vCount>=(35+RIGHT_V+7)&&vCount<=(35+RIGHT_V+7+9))
		|| (hCount>=(144+RIGHT_H+5)&&hCount<=(144+RIGHT_H+5+3)&&vCount>=(35+RIGHT_V+13)&&vCount<=(35+RIGHT_V+13+3));

	assign R7_fill = 
		(hCount>=(144+RIGHT_H+2)&&hCount<=(144+RIGHT_H+2+6)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+3))
		|| (hCount>=(144+RIGHT_H+8)&&hCount<=(144+RIGHT_H+8+3)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+16));
		
	assign R8_fill = 
		(hCount>=(144+RIGHT_H+2)&&hCount<=(144+RIGHT_H+2+3)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+16))
		|| (hCount>=(144+RIGHT_H+5)&&hCount<=(144+RIGHT_H+5+3)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+3))
		|| (hCount>=(144+RIGHT_H+8)&&hCount<=(144+RIGHT_H+8+3)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+16))
		|| (hCount>=(144+RIGHT_H+5)&&hCount<=(144+RIGHT_H+5+3)&&vCount>=(35+RIGHT_V+6)&&vCount<=(35+RIGHT_V+6+3))
		|| (hCount>=(144+RIGHT_H+5)&&hCount<=(144+RIGHT_H+5+3)&&vCount>=(35+RIGHT_V+13)&&vCount<=(35+RIGHT_V+13+3));

	assign R9_fill = 
		(hCount>=(144+RIGHT_H+2)&&hCount<=(144+RIGHT_H+2+3)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+9))
		|| (hCount>=(144+RIGHT_H+5)&&hCount<=(144+RIGHT_H+5+3)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+3))
		|| (hCount>=(144+RIGHT_H+8)&&hCount<=(144+RIGHT_H+8+3)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+16))
		|| (hCount>=(144+RIGHT_H+5)&&hCount<=(144+RIGHT_H+5+3)&&vCount>=(35+RIGHT_V+6)&&vCount<=(35+RIGHT_V+6+3));

    assign RA_fill =
        // top terminal A 
        (hCount>=(144+RIGHT_H+2)&&hCount<=(144+RIGHT_H+2+3)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+16)) // left rectangle
        || (hCount>=(144+RIGHT_H+5)&&hCount<=(144+RIGHT_H+5+3)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+3)) // mid top 
        || (hCount>=(144+RIGHT_H+5)&&hCount<=(144+RIGHT_H+5+3)&&vCount>=(35+RIGHT_V+6)&&vCount<=(35+RIGHT_V+6+3)) // mid mid 
	    || (hCount>=(144+RIGHT_H+8)&&hCount<=(144+RIGHT_H+8+3)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+16)); // right rectangle 
	
	assign RB_fill =
        // top terminal B
        (hCount>=(144+RIGHT_H)&&hCount<=(144+RIGHT_H+9)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+3)) // top rectangle
        || (hCount>=(144+RIGHT_H)&&hCount<=(144+RIGHT_H+3)&&vCount>=(35+RIGHT_V+3)&&vCount<=(35+RIGHT_V+3+3)) // left second
        || (hCount>=(144+RIGHT_H+6)&&hCount<=(144+RIGHT_H+6+3)&&vCount>=(35+RIGHT_V+3)&&vCount<=(35+RIGHT_V+3+3)) // right second 
        || (hCount>=(144+RIGHT_H)&&hCount<=(144+RIGHT_H+9)&&vCount>=(35+RIGHT_V+6)&&vCount<=(35+RIGHT_V+6+3)) // mid rectangle 
        || (hCount>=(144+RIGHT_H)&&hCount<=(144+RIGHT_H+3)&&vCount>=(35+RIGHT_V+9)&&vCount<=(35+RIGHT_V+9+4)) // left fourth
         || (hCount>=(144+RIGHT_H+9)&&hCount<=(144+RIGHT_H+9+3)&&vCount>=(35+RIGHT_V+9)&&vCount<=(35+RIGHT_V+9+4)) // right fourth
        || (hCount>=(144+RIGHT_H)&&hCount<=(144+RIGHT_H+12)&&vCount>=(35+RIGHT_V+13)&&vCount<=(35+RIGHT_V+13+3)); // bottom rectangle
	
	assign RC_fill =
        // top terminal C
        (hCount>=(144+RIGHT_H+2)&&hCount<=(144+RIGHT_H+2+9)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+3)) // top rectangle
        || (hCount>=(144+RIGHT_H+2)&&hCount<=(144+RIGHT_H+2+3)&&vCount>=(35+RIGHT_V+3)&&vCount<=(35+RIGHT_V+3+10)) // left second
        ||(hCount>=(144+RIGHT_H+2)&&hCount<=(144+RIGHT_H+2+9)&&vCount>=(35+RIGHT_V+13)&&vCount<=(35+RIGHT_V+13+3)); // bottom rectangle
        
    assign RD_fill =
        // top terminal D
        (hCount>=(144+RIGHT_H+2)&&hCount<=(144+RIGHT_H+2+3)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+16)) // left rectangle
        || (hCount>=(144+RIGHT_H+5)&&hCount<=(144+RIGHT_H+5+4)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+3)) // top right 
        || (hCount>=(144+RIGHT_H+5)&&hCount<=(144+RIGHT_H+5+4)&&vCount>=(35+RIGHT_V+13)&&vCount<=(35+RIGHT_V+13+3)) // bottom right 
        || (hCount>=(144+RIGHT_H+8)&&hCount<=(144+RIGHT_H+8+3)&&vCount>=(35+RIGHT_V+3)&&vCount<=(35+RIGHT_V+3+10)); // right rectangle   
    
    assign RE_fill =
        // top terminal D
        (hCount>=(144+RIGHT_H+2)&&hCount<=(144+RIGHT_H+2+3)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+16)) // left rectangle
        || (hCount>=(144+RIGHT_H+5)&&hCount<=(144+RIGHT_H+5+6)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+3)) // top right 
        || (hCount>=(144+RIGHT_H+5)&&hCount<=(144+RIGHT_H+5+3)&&vCount>=(35+RIGHT_V+6)&&vCount<=(35+RIGHT_V+6+3)) // middle right 
        || (hCount>=(144+RIGHT_H+5)&&hCount<=(144+RIGHT_H+5+6)&&vCount>=(35+RIGHT_V+13)&&vCount<=(35+RIGHT_V+13+3)); // bottom right   
	
	assign RF_fill =
        // top terminal F
        (hCount>=(144+RIGHT_H+2)&&hCount<=(144+RIGHT_H+2+3)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+16)) // left rectangle
        || (hCount>=(144+RIGHT_H+5)&&hCount<=(144+RIGHT_H+5+6)&&vCount>=(35+RIGHT_V)&&vCount<=(35+RIGHT_V+3)) // top right 
        || (hCount>=(144+RIGHT_H+5)&&hCount<=(144+RIGHT_H+5+6)&&vCount>=(35+RIGHT_V+6)&&vCount<=(35+RIGHT_V+6+3)); // middle right 
	

	always@(posedge sysClk, posedge Reset) begin
	    top_monster_vga <= top_monster_ctrl;
	    btm_monster_vga <= btm_monster_ctrl;
	   	if(Reset)
		begin 
			top_monster_vga<=0;
			btm_monster_vga<=0; 
		end
		else
		begin
            if (top_monster_vga && top_laser == 76) begin
                 top_monster_vga<=0;
            end
            if (btm_monster_vga && btm_laser == 406) begin
                 btm_monster_vga<=0;
            end
        end
	end
	

	always@(posedge Clk, posedge Reset) 
	begin
	    //top_monster_vga <= top_monster_ctrl;
	    //btm_monster_vga <= btm_monster_ctrl; 
		if(Reset)
		begin 
			top_laser<=256;
			btm_laser<=226;
			left_laser<=-11; 
			right_laser<=651;
			top_shooting<=0;
			btm_shooting<=0;
			left_shield<=0; 
			right_shield<=0; 
			//top_monster_vga<=0; 
			//btm_monster_vga<=0; 
		end
		else if (Clk) begin
		
		/* Note that the top left of the screen does NOT correlate to vCount=0 and hCount=0. The display_controller.v file has the 
			synchronizing pulses for both the horizontal sync and the vertical sync begin at vcount=0 and hcount=0. Recall that after 
			the length of the pulse, there is also a short period called the back porch before the display area begins. So effectively, 
			the top left corner corresponds to (hcount,vcount)~(144,35). Which means with a 640x480 resolution, the bottom right corner 
			corresponds to ~(783,515).  
		*/
			if(up && !top_shooting && !top_broken)
				top_shooting<=1;
			if(down && !btm_shooting && !btm_broken)
				btm_shooting<=1;
			if(left && left_monster && !left_broken)
			    left_shield<=1; 
            if(right && right_monster && !right_broken)
			    right_shield<=1; 
			    
			if(left_monster) begin
			    left_laser<=left_laser+4; 
			    if (left_shield && left_laser == 229)  
			        left_laser<=-11; 
			    else if(left_laser == 273)
			        left_laser<=-11; 
			end
			else begin
			    left_laser<=-11; 
			    left_shield<=0; 
			end
			
			if(right_monster) begin
			    right_laser<=right_laser-4; 
			    if (right_shield && right_laser == 411)  
			        right_laser<=651; 
			    else if(right_laser == 367)
			        right_laser<=651; 
			end
			else begin
			    right_laser<=651; 
			    right_shield<=0;   
			end  

			if(top_shooting) begin
				top_laser<=top_laser-4;
				if (top_monster_vga && top_laser == 76) begin
					top_shooting<=0;
					top_laser<=256;
				end
				else if(top_laser == 0) begin
					top_shooting<=0;
					top_laser<=256;
				end
			end
			
			if(btm_shooting) begin
				btm_laser<=btm_laser+4;
				if (btm_monster_vga && btm_laser == 406) begin
					btm_shooting<=0;
					btm_laser<=226;
				end
				else if(btm_laser == 478) begin
					btm_shooting<=0;
					btm_laser<=226;
				end
			end
		end
	end
		
endmodule
