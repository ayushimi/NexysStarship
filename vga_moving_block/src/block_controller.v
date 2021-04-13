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
	
	//these two values dictate the center of the block, incrementing and decrementing them leads the block to move in certain directions
	reg [9:0] xpos, ypos;
	
	parameter RED   = 12'b1111_0000_0000;
	parameter BLACK = 12'b0000_0000_0000;
	parameter GREY = 12'b_1100_1100_1100;
	parameter LIGHT_BLUE = 12'b_1001_1101_1111;
	parameter PINK = 12'b_1111_1110_1110;
	parameter DARK_GREY = 12'b_1100_1100_1100;
	parameter MEDIUM_GREY = 12'b_1001_1001_1001;
	parameter BACKGROUND = 12'b_0000_1000_1010;
	
	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*) begin
    	if(~bright )	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		if (light_gray_fill || light_blue_fill || pink_fill)
		  begin
		      if (light_gray_fill) 
			     rgb = GREY;  
		      if (light_blue_fill)
		           rgb = LIGHT_BLUE;
		      if (pink_fill)
		           rgb = PINK;
		  end
		else	
			rgb=BACKGROUND;
	end
		//the +-5 for the positions give the dimension of the block (i.e. it will be 10x10 pixels)
	assign block_fill=vCount>=(ypos-5) && vCount<=(ypos+5) && hCount>=(xpos-5) && hCount<=(xpos+5);
	
	assign light_gray_fill = 
		(hCount>=(144+248)&&hCount<=(144+248+144)&&vCount>=(35+248)&&vCount<=(35+248+20)) // middle
		|| (hCount>=(144+263)&&hCount<=(144+263+114)&&vCount>=(35+225)&&vCount<=(35+225+23)) // top
		|| (hCount>=(144+263)&&hCount<=(144+263+114)&&vCount>=(35+268)&&vCount<=(35+268+20)) // bottom
		|| (hCount>=(144+273)&&hCount<=(144+273+16)&&vCount>=(35+288)&&vCount<=(35+288+20)) // left leg
		|| (hCount>=(144+351)&&hCount<=(144+351+16)&&vCount>=(35+288)&&vCount<=(35+288+20)); // right leg
	
	assign light_blue_fill = 
	    (hCount>=(144+273)&&hCount<=(144+273+94)&&vCount>=(35+202)&&vCount<=(35+202+34)) // bottom window 
		|| (hCount>=(144+281)&&hCount<=(144+281+78)&&vCount>=(35+195)&&vCount<=(35+195+7)) // second strip
		|| (hCount>=(144+289)&&hCount<=(144+289+62)&&vCount>=(35+187)&&vCount<=(35+187+8)) // third strip
		|| (hCount>=(144+297)&&hCount<=(144+297+46)&&vCount>=(35+182)&&vCount<=(35+182+5)); // top window
	
	// move to other always block for inputs 	
	assign pink_fill = 
	    (hCount>=(144+227)&&hCount<=(144+227+10)&&vCount>=(35+193)&&vCount<=(35+193+105)) // left outer shield 
		|| (hCount>=(144+237)&&hCount<=(144+237+11)&&vCount>=(35+188)&&vCount<=(35+188+115)) // left inner shield
		|| (hCount>=(144+402)&&hCount<=(144+402+10)&&vCount>=(35+193)&&vCount<=(35+193+105)) // right outer shield
		|| (hCount>=(144+392)&&hCount<=(144+392+11)&&vCount>=(35+188)&&vCount<=(35+188+115)); // right inner shield
		
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
