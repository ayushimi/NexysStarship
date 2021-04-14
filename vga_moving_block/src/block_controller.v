`timescale 1ns / 1ps

module block_controller(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input bright,
	input rst,
	input up, input down, input left, input right,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb,
	output reg [11:0] background
   );
	wire block_fill;
	wire light_gray_fill;
	wire light_blue_fill;
	wire left_shield_fill;
	wire right_shield_fill;
	wire black_fill;
	wire head_fill;
	wire dark_gray_fill;
	wire medium_gray_fill;
	
	
	//these two values dictate the center of the block, incrementing and decrementing them leads the block to move in certain directions
	reg [9:0] xpos, ypos;
	
	parameter RED   = 12'b1111_0000_0000;
	parameter BLACK = 12'b0000_0000_0000;
	parameter GREY = 12'b1100_1100_1100;
	parameter LIGHT_BLUE = 12'b1001_1101_1111;
	parameter PINK = 12'b1111_1000_1000;
	parameter DARK_GREY = 12'b1100_1100_1100;
	parameter MEDIUM_GREY = 12'b1001_1001_1001;
	parameter BACKGROUND = 12'b0000_1000_1010; // sky blue
	parameter BACKGROUND2 = 12'b0000_0001_0101; // dark blue
	parameter TAN = 12'b1110_1011_1000; // EB8 	

	
	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*) begin
    	if(~bright )	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		else if (light_gray_fill || light_blue_fill || left_shield_fill || right_shield_fill)
		  begin
		      // facial features
			  // head
			  // window
			  // lights
			  // gray body
			  // shields
			  // cannons
				if (black_fill)
					rgb = BLACK;
				else if (head_fill)
					rgb = TAN;
				else if (light_blue_fill)
					rgb = LIGHT_BLUE;
				else if (pink_fill || left_shield_fill || right_shield_fill)
					rgb = PINK;
				else if (light_gray_fill)
					rgb = GREY;
				else if (dark_gray_fill)
					rgb = DARK_GREY;
				else if (medium_gray_fill)
					rgb = MEDIUM_GREY;
		  end
		else	
			rgb=BACKGROUND2;
	end
		//the +-5 for the positions give the dimension of the block (i.e. it will be 10x10 pixels)
	assign block_fill=vCount>=(ypos-5) && vCount<=(ypos+5) && hCount>=(xpos-5) && hCount<=(xpos+5);
	
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
	
	assign dark_gray_fill =
		(hCount>=(144+314)&&hCount<=(144+314+12)&&vCount>=(35+152)&&vCount<=(35+152+10)) // top cannon tip
		|| (hCount>=(144+309)&&hCount<=(144+309+22)&&vCount>=(35+162)&&vCount<=(35+162+30)) // top cannon body
		|| (hCount>=(144+314)&&hCount<=(144+314+12)&&vCount>=(35+320)&&vCount<=(35+320+10)) // bottom cannon tip
		|| (hCount>=(144+309)&&hCount<=(144+309+22)&&vCount>=(35+290)&&vCount<=(35+290+30)); // bottom cannon body
	
	assign medium_gray_fill =
		(hCount>=(144+314)&&hCount<=(144+314+12)&&vCount>=(35+192)&&vCount<=(35+192+2)) // top cannon base
		|| (hCount>=(144+309)&&hCount<=(144+309+22)&&vCount>=(35+165)&&vCount<=(35+165+5)) // top cannon strip
		|| (hCount>=(144+314)&&hCount<=(144+314+12)&&vCount>=(35+288)&&vCount<=(35+288+2)) // bottom cannon base
		|| (hCount>=(144+309)&&hCount<=(144+309+22)&&vCount>=(35+312)&&vCount<=(35+312+5)); // bottom cannon strip
		
	assign pink_fill =
		(hCount>=(144+271)&&hCount<=(144+271+14)&&vCount>=(35+250)&&vCount<=(35+250+14)) // left light
		|| (hCount>=(144+313)&&hCount<=(144+313+14)&&vCount>=(35+258)&&vCount<=(35+258+14)) // middle light
		|| (hCount>=(144+354)&&hCount<=(144+354+14)&&vCount>=(35+250)&&vCount<=(35+250+14)); // right light
		
	assign head_fill = 
	    (hCount>=(144+303)&&hCount<=(144+303+34)&&vCount>=(35+214)&&vCount<=(35+214+34)); // head
	    
	assign black_fill = 
	    (hCount>=(144+302)&&hCount<=(144+302+36)&&vCount>=(35+217)&&vCount<=(35+217+7)) // eyebrows / headband 
		|| (hCount>=(144+309)&&hCount<=(144+309+5)&&vCount>=(35+224)&&vCount<=(35+224+3)) // left eye
		|| (hCount>=(144+326)&&hCount<=(144+326+5)&&vCount>=(35+224)&&vCount<=(35+224+3)) // right eye
		|| (hCount>=(144+310)&&hCount<=(144+310+5)&&vCount>=(35+236)&&vCount<=(35+236+3)) // left mouth 
		|| (hCount>=(144+314)&&hCount<=(144+314+12)&&vCount>=(35+238)&&vCount<=(35+238+3)) // mid mouth
		|| (hCount>=(144+325)&&hCount<=(144+325+5)&&vCount>=(35+236)&&vCount<=(35+236+3)) // right mouth  
		|| (hCount>=(144+314)&&hCount<=(144+314+3)&&vCount>=(35+211)&&vCount<=(35+211+3)) // left hair strand  
		|| (hCount>=(144+319)&&hCount<=(144+319+3)&&vCount>=(35+208)&&vCount<=(35+208+6)) // mid hair strand  
		|| (hCount>=(144+324)&&hCount<=(144+324+2)&&vCount>=(35+211)&&vCount<=(35+211+3)); // right hair strand  
		
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin 
			//rough values for center of screen
			xpos<=450;
			ypos<=250;
		end
		else if (clk) begin
		
		/* Note that the top left of the screen does NOT correlate to vCount=0 and hCount=0. The display_controller.v file has the 
			synchronizing pulses for both the horizontal sync and the vertical sync begin at vcount=0 and hcount=0. Recall that after 
			the length of the pulse, there is also a short period called the back porch before the display area begins. So effectively, 
			the top left corner corresponds to (hcount,vcount)~(144,35). Which means with a 640x480 resolution, the bottom right corner 
			corresponds to ~(783,515).  
		*/
			if(right) begin
				xpos<=xpos+2; //change the amount you increment to make the speed faster 
				if(xpos==800) //these are rough values to attempt looping around, you can fine-tune them to make it more accurate- refer to the block comment above
					xpos<=150;
			end
			else if(left) begin
				xpos<=xpos-2;
				if(xpos==150)
					xpos<=800;
			end
			else if(up) begin
				ypos<=ypos-2;
				if(ypos==34)
					ypos<=514;
			end
			else if(down) begin
				ypos<=ypos+2;
				if(ypos==514)
					ypos<=34;
			end
		end
	end
	
	//the background color reflects the most recent button press
	always@(posedge clk, posedge rst) begin
		if(rst)
			background <= 12'b1111_1111_1111;
		else 
			if(right)
				background <= 12'b1111_1111_0000;
			else if(left)
				background <= 12'b0000_1111_1111;
			else if(down)
				background <= 12'b0000_1111_0000;
			else if(up)
				background <= 12'b0000_0000_1111;
	end

	
	
endmodule
