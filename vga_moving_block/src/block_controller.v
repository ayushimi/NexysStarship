`timescale 1ns / 1ps

module block_controller(
	input Clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input bright,
	input Reset,
	input BtnU, input BtnD, input BtnL, input BtnR,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb,
	input top_monster, input top_broken
   );
	wire spaceship_black_fill;
	wire light_gray_fill;
	wire light_blue_fill;
	wire left_shield_fill;
	wire right_shield_fill;
	wire black_fill;
	wire head_fill;
	wire dark_gray_fill;
	wire medium_gray_fill;
	wire TM_black_fill;
	wire TM_red_fill;
	wire TM_cream_fill;
	wire tunnel_blue_fill;
	wire laser_mask_fill;
	wire top_green_fill;
	
	reg top_shooting;	
	
	//these two values dictate the center of the block, incrementing and decrementing them leads the block to move in certain directions
	reg [9:0] xpos, ypos;
	reg signed [10:0] top_laser;
	
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
	parameter TUNNEL_BLUE = 12'b0000_0001_0110;


	
	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*) begin
    	if(~bright )	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		else if (spaceship_display_fill)
		  begin
		      // facial features
			  // head
			  // window
			  // lights
			  // gray body
			  // shields
			  // cannons
				if (spaceship_black_fill)
					rgb = BLACK;
				else if (head_fill)
					rgb = TAN;
				else if (light_blue_fill)
					rgb = LIGHT_BLUE;
				else if (pink_fill || left_shield_fill || right_shield_fill)
					rgb = PINK;
				else if (light_gray_fill)
					rgb = GREY;
				else if (medium_gray_fill)
					rgb = MEDIUM_GREY;
				else if (dark_gray_fill)
					rgb = DARK_GREY;
		  end
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
		else if (top_green_fill)
			rgb = GREEN;
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
	
	assign right_shield_fill = 
		(hCount>=(144+402)&&hCount<=(144+402+10)&&vCount>=(35+205)&&vCount<=(35+205+105)) // right outer shield
		|| (hCount>=(144+392)&&hCount<=(144+392+11)&&vCount>=(35+200)&&vCount<=(35+200+115)); // right inner shield
	
	// cannons
	assign dark_gray_fill =
		(hCount>=(144+314)&&hCount<=(144+314+12)&&vCount>=(35+152)&&vCount<=(35+152+10)) // top cannon tip
		|| (hCount>=(144+309)&&hCount<=(144+309+22)&&vCount>=(35+162)&&vCount<=(35+162+30)) // top cannon body
		|| (hCount>=(144+314)&&hCount<=(144+314+12)&&vCount>=(35+320)&&vCount<=(35+320+10)) // bottom cannon tip
		|| (hCount>=(144+309)&&hCount<=(144+309+22)&&vCount>=(35+290)&&vCount<=(35+290+30)); // bottom cannon body
	
	assign medium_gray_fill =
		(hCount>=(144+314)&&hCount<=(144+314+12)&&vCount>=(35+192)&&vCount<=(35+192+2)) // top cannon base
		|| (hCount>=(144+309)&&hCount<=(144+309+22)&&vCount>=(35+165)&&vCount<=(35+165+4)) // top cannon strip
		|| (hCount>=(144+314)&&hCount<=(144+314+12)&&vCount>=(35+288)&&vCount<=(35+288+2)) // bottom cannon base
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
	
	assign spaceship_display_fill = light_gray_fill || light_blue_fill || left_shield_fill || right_shield_fill || spaceship_black_fill || head_fill || dark_gray_fill || medium_gray_fill;
	
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

	assign TM_display_fill = top_monster && (TM_red_fill || TM_black_fill
								|| TM_cream_fill || TM_mask_fill);
	



	
	always@(posedge Clk, posedge Reset) 
	begin
		if(Reset)
		begin 
			//rough values for center of screen
			xpos<=450;
			ypos<=250;
			top_laser<=256;
			top_shooting<=0;
			top_monster<=1;
			top_broken<=0;
		end
		else if (Clk) begin
		
		/* Note that the top left of the screen does NOT correlate to vCount=0 and hCount=0. The display_controller.v file has the 
			synchronizing pulses for both the horizontal sync and the vertical sync begin at vcount=0 and hcount=0. Recall that after 
			the length of the pulse, there is also a short period called the back porch before the display area begins. So effectively, 
			the top left corner corresponds to (hcount,vcount)~(144,35). Which means with a 640x480 resolution, the bottom right corner 
			corresponds to ~(783,515).  
		*/
			if(BtnR) begin
			end
			else if(BtnL) begin
			end
			else if(BtnU && !top_shooting && !top_broken) begin
				top_shooting<=1;
				
			end
			else if(BtnD) begin
			end
			
			if(top_shooting) begin
				top_laser<=top_laser-2;
				if (top_monster && top_laser == 76) begin
					top_shooting<=0;
					top_monster<=0;
					top_laser<=256;
				end
				else if(top_laser == 0) begin
					top_shooting<=0;
					top_laser<=256;
				end
			end
		end
	end
		
endmodule
