module	Machine_moveCollision(	
 
					input	logic	clk,
					input	logic	resetN,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
					
					input	logic	collision_doc,
					input	logic	collision_doc_Maze,
					input	logic	collision_maze,
					input	logic	magnet_on, // indicates whether to push or to pull
									
					input	logic	[10:0] INITIAL_X, //input of random placing of the doctor
					input	logic	[10:0] INITIAL_Y,
					input	logic	[3:0] HitEdgeCode, //one bit per edge 
					input	logic	Up_Move,//keys
					input	logic	Down_Move,
					input	logic	Right_Move,
					input	logic	Left_Move,
					
					input 	logic	[10:0] doctor_topleftX, 
					input 	logic	[10:0] doctor_topleftY,
					
					output logic signed [10:0]	topLeftX, // output the top left corner 
					output logic signed [10:0]	topLeftY
					
);


// a module used to generate the  ball trajectory.  

parameter int INITIAL_X_SPEED = 0;
parameter int INITIAL_Y_SPEED = 0;
parameter int SET_SPEED = 128; 
logic magnet_flag;

const int	FIXED_POINT_MULTIPLIER	=	64;

// FIXED_POINT_MULTIPLIER is used to work with integers in high resolution 
// we do all calulations with topLeftX_FixedPoint  so we get a resulytion inthe calcuatuions of 1/64 pixel 
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n 
const int	x_FRAME_SIZE	=	639 * FIXED_POINT_MULTIPLIER; // note it must be 2^n 
const int	y_FRAME_SIZE	=	479 * FIXED_POINT_MULTIPLIER;

const int POS = 1;
const int NEG = -1;
const int ZERO = 0;
const int Far_Coordinates_Range = 16 * FIXED_POINT_MULTIPLIER;
const int Close_Coordinates_Range = 3 * FIXED_POINT_MULTIPLIER;

const int DOC_size = 16 * FIXED_POINT_MULTIPLIER;
const int Far_DOC_size = 32 * FIXED_POINT_MULTIPLIER;
int X_Dist,Y_Dist;
int X_direction, Y_direction;

int topLeftX_FixedPoint; // local parameters 
int topLeftY_FixedPoint;

//==--------------------------------------------------------------------------------------------------------------=
//  calculation when doctor pushes the machine 

always_ff@(posedge clk or negedge resetN)
begin

	X_Dist <= ((doctor_topleftX * FIXED_POINT_MULTIPLIER) - topLeftX_FixedPoint);
	Y_Dist <= ((doctor_topleftY * FIXED_POINT_MULTIPLIER) - topLeftY_FixedPoint);

	if (!resetN) begin
		topLeftX_FixedPoint	<= INITIAL_X * FIXED_POINT_MULTIPLIER;
		topLeftY_FixedPoint	<= INITIAL_Y * FIXED_POINT_MULTIPLIER;
		X_direction <= ZERO;
		Y_direction <= ZERO;
	end

	else begin//Not in Reset

		topLeftX_FixedPoint <= topLeftX_FixedPoint;	
		topLeftY_FixedPoint <= topLeftY_FixedPoint;	

		if (!magnet_on) begin //Doctor Pushes the Machine				
			if (!collision_maze && startOfFrame) begin // No collision with maze and startOfFrame so machine will move with Doctor
	
				// we set a legal range for top left coordiantes of doctor in relative to top left coordiantes of machine:
				// for moving sideways: Y range: -3 to 19 pixels, X range: according to direction 
				if(!Up_Move && !Down_Move && (Y_Dist < (Far_Coordinates_Range + Close_Coordinates_Range)) && (Y_Dist > -Close_Coordinates_Range)) begin // if trying to go sideways and is close enough on Y axis to push

						if (Right_Move && !Left_Move && (X_Dist < 0) && (X_Dist > -Far_Coordinates_Range) )begin // trying to push Right and isnt too far from the machine, X range: 0 to -16 pixels
							topLeftX_FixedPoint <= topLeftX_FixedPoint + SET_SPEED;

						end
						else if (Left_Move && !Right_Move && (X_Dist > 0) && (X_Dist < 2*Far_Coordinates_Range) ) begin // trying to push Left and isnt too far from the machine, X range: 0 to 32 pixels
							topLeftX_FixedPoint <= topLeftX_FixedPoint - SET_SPEED;

						end
						
				end
				
				// for moving in Y axis: X range: -3 to 19 pixels, Y range: according to direction 
				if(!Left_Move && !Right_Move && (X_Dist < (Far_Coordinates_Range + Close_Coordinates_Range)) && (X_Dist > -Close_Coordinates_Range)) begin // if trying to go up or down and is close enough on X axis to push
					
						if (Up_Move && !Down_Move && (Y_Dist > 0) && (Y_Dist < (2*Far_Coordinates_Range + Close_Coordinates_Range))) begin // trying to push Up and isnt too far from the machine, Y range: 0 to 35 pixels
							topLeftY_FixedPoint <= topLeftY_FixedPoint - SET_SPEED;

						end
						else if (Down_Move && !Up_Move && (Y_Dist < 0) && (Y_Dist > -Far_Coordinates_Range) )begin  // trying to push Down and isnt too far from the machine, Y range: 0 to -16 pixels
							topLeftY_FixedPoint <= topLeftY_FixedPoint + SET_SPEED;

						end
					
				end
			
			
			end//no collision
		end //push logic
			
	
		else if ((magnet_on && collision_doc )|| magnet_flag) begin // Doctor pulls the Machine with the Magnet
				// the flag is intended to keep the magnet on even if the collision pushed the doctor abit away from the machine and there isnt direct touch.
				if(!magnet_on) //take down the magnet flag if magnet is turned off.
					magnet_flag <= 1'b0;
				
				else
					magnet_flag <= 1'b1; // if magnet is still on keep the flag on.
				
				if(collision_doc_Maze) begin//when doc collides with maze, push the machine back accordingly if needed
					
					if((Y_Dist < Far_Coordinates_Range) && (Y_Dist > -Close_Coordinates_Range))begin //if isnt far on Y axis while collision: range -3 to 16 pixels
					
						if((X_direction > 0) && (X_Dist < Far_DOC_size))//Doc Hits Maze while pulling machine from its Right side while not too far: range 0 to 32 pixels
							topLeftX_FixedPoint <= topLeftX_FixedPoint - SET_SPEED;
						if((X_direction < 0) && (X_Dist > -DOC_size))//Doc Hits Maze while pulling machine from its Left side while not too far: range 0 to -16 pixels
							topLeftX_FixedPoint <= topLeftX_FixedPoint + SET_SPEED;
							
					end
					else if((X_Dist < Far_Coordinates_Range) && (X_Dist > -Close_Coordinates_Range)) begin //if isnt far on X axis while collision: range -3 to 16 pixels
					
						if((Y_direction < 0) && (Y_Dist > -DOC_size))//Doc Hits Maze while pulling machine from its Top side while not too far: range 0 to -16 pixels
							topLeftY_FixedPoint <= topLeftY_FixedPoint + SET_SPEED;
						if((Y_direction > 0) && (Y_Dist < Far_DOC_size))//Doc Hits Maze while pulling machine from its Bottom side while not too far: range 0 to 32 pixels
							topLeftY_FixedPoint <= topLeftY_FixedPoint - SET_SPEED;
							
					end
					
				end //doc collision
				
				
		
			else if (startOfFrame) begin//Doctor pulling the machine with the Magnet, move only on startOfFrame
			
					// we set a legal range for top left coordiantes of doctor in relative to top left coordiantes of machine:
					// for moving sideways: Y range: -3 to 19 pixels, X range: according to direction 
					if(!Up_Move && !Down_Move && (Y_Dist < Far_Coordinates_Range) && (Y_Dist > -Close_Coordinates_Range)) begin // if trying to go left or right and is close enough on Y axis to magnet
					
						if (Left_Move && !Right_Move && (X_Dist < 0) && (X_Dist > -Far_Coordinates_Range) )begin // trying to magnet Left and isnt too far from the machine, X range: 0 to -16 pixels
							topLeftX_FixedPoint <= topLeftX_FixedPoint - SET_SPEED;
							X_direction <= NEG;
							Y_direction <= ZERO;
						end
						else if (Right_Move && !Left_Move && (X_Dist > 0) && (X_Dist < 2*Far_Coordinates_Range) ) begin // trying to magnet Right and isnt too far from the machine, X range: 0 to 32 pixels
							topLeftX_FixedPoint <= topLeftX_FixedPoint + SET_SPEED;
							X_direction <= POS;
							Y_direction <= ZERO;
						end
					end
					
					// for moving in Y axis: X range: -3 to 16 pixels, Y range: according to direction 
					if(!Left_Move && !Right_Move && (X_Dist < Far_Coordinates_Range) && (X_Dist > -Close_Coordinates_Range)) begin // if trying to go up or down and is close enough on X axis to magnet
					
						if (Up_Move && !Down_Move && (Y_Dist < 0) && (Y_Dist > -(Far_Coordinates_Range + Close_Coordinates_Range))) begin // trying to magnet Up and isnt too far from the machine, Y range: 0 to -19 pixels
							topLeftY_FixedPoint <= topLeftY_FixedPoint - SET_SPEED;
							Y_direction <= NEG;
							X_direction <= ZERO;
						end
						else if (Down_Move && !Up_Move && (Y_Dist > 0) && (Y_Dist < (2*Far_Coordinates_Range + Close_Coordinates_Range)))begin // trying to magnet Down and isnt too far from the machine, Y range: 0 to 35 pixels
							topLeftY_FixedPoint <= topLeftY_FixedPoint + SET_SPEED;
							Y_direction <= POS;
							X_direction <= ZERO;
						end
					
					end
					
			end //Magnet move
			
			
		end//Magnet
	
	
		if(collision_maze)begin //machine collision with maze
		
			if (HitEdgeCode [0] && !HitEdgeCode [1] && !HitEdgeCode [3]) //if collides with maze from below
				topLeftY_FixedPoint <= topLeftY_FixedPoint - SET_SPEED;
				
			if(HitEdgeCode [2] && !HitEdgeCode [1] && !HitEdgeCode [3]) //if collides with maze from above
				topLeftY_FixedPoint <= topLeftY_FixedPoint + SET_SPEED;
				
			if (HitEdgeCode [1] && !HitEdgeCode [0] && !HitEdgeCode [2]) //if collides with maze from right
				topLeftX_FixedPoint <= topLeftX_FixedPoint - SET_SPEED;
				
			if (HitEdgeCode [3] && !HitEdgeCode [0] && !HitEdgeCode [2]) //if collides with maze from left
				topLeftX_FixedPoint <= topLeftX_FixedPoint + SET_SPEED;
				
		end
		
	end
	
end

//get a better (64 times) resolution using integer   
assign 	topLeftX = topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER ;    


endmodule
