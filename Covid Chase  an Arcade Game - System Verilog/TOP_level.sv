
module	Top_level	(	
					input	logic clk,
					input	logic resetN,
					input	logic [10:0] pixelX, // current VGA pixel 
					input	logic [10:0] pixelY,
					input	logic [2:0] level,

					output	logic [7:0] RGBout, //optional color output for mux 
					output	logic levelDrawingRequest
);

parameter int MAX_LEVEL = 5;

// this is the devider used to acess the right pixel 
parameter int OBJECT_NUMBER_OF_Y_BITS = 5;  // 2^5 = 32 
parameter int OBJECT_NUMBER_OF_X_BITS = 4;  // 2^4 = 16 

//the variable that is used in order to determine the current column
assign j = pixelX >> OBJECT_NUMBER_OF_X_BITS;  
logic [5:0] j;

localparam int OBJECT_HEIGHT_Y = 1 <<  OBJECT_NUMBER_OF_Y_BITS ;
localparam int OBJECT_WIDTH_X = 1 <<  OBJECT_NUMBER_OF_X_BITS;
localparam int NUM_OF_DIGITS = 20;

logic level_req_in;
logic levelDrawingRequest_in;
logic [10:0] offsetX_in;
logic [10:0] offsetY_in;
logic [0:OBJECT_HEIGHT_Y-1][0:OBJECT_WIDTH_X-1] [8-1:0] level_object_colors_in;//delete


bit [0:MAX_LEVEL] [0:2] [5-1:0] level_bitmap  =
{//L    V      level number
{5'd17, 5'd19, 5'd1}, 
{5'd17, 5'd19, 5'd2}, 
{5'd17, 5'd19, 5'd3}, 
{5'd17, 5'd19, 5'd4}, 
{5'd17, 5'd19, 5'd5}
};
	
				square_object #(.OBJECT_WIDTH_X(OBJECT_WIDTH_X), .OBJECT_HEIGHT_Y(OBJECT_HEIGHT_Y)) square_object (
					.clk(clk),
					.resetN(resetN),
					.pixelX(pixelX),
					.pixelY(pixelY),
					.topLeftX(j * OBJECT_WIDTH_X), //the actual location of the TopLeft of the block
					.topLeftY(0), //places the lung on the upper row
					.offsetX(offsetX_in),
					.offsetY(offsetY_in),
					.drawingRequest(level_req_in),
					.RGBout()
				);
				
				DigitsBitMap DigitsBitMap(
					.clk(clk),
					.resetN(resetN),
					.offsetX(offsetX_in),
					.offsetY(offsetY_in),
					.InsideRectangle(level_req_in),
					.digit(level_bitmap[level][j - 17]), //choosing column according to topLeftX square (0-19), and then reduces 17 to get the right range (0-2)
					.drawingRequest(levelDrawingRequest_in),
					.RGBout(RGBout)
				
				);
			
				//first checks whether the pixel is within the allowed boundaries					
				assign levelDrawingRequest = ((pixelX >= (640 - (3 * OBJECT_WIDTH_X))) && (pixelY < OBJECT_HEIGHT_Y)) ?  levelDrawingRequest_in : 1'b0;

 endmodule				
