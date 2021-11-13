
module	Doctor_moveCollision	(	
 
					input	logic	clk,
					input	logic	resetN,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
					input	logic	Up_Move,//keys
					input	logic	Down_Move,
					input	logic	Right_Move,
					input	logic	Left_Move,
					
					input	logic	magnet_on,
					//input	logic	stop_move,					
					
					input	logic	[10:0] INITIAL_X, //input of random placing of the doctor
					input	logic	[10:0] INITIAL_Y,	
					
					input	logic	collision_doc_maze,  //collision if Doctor hits the maze
					input	logic	collision_doc_machine,  //collision if Doctor hits the machine
					input	logic	collision_machine_maze,  //collision if the machine hits the maze
					input	logic	collision_doc_patient,  //collision if the Doctor hits the patient
					input	logic	[3:0] HitEdgeCode, //one bit per edge 

					output logic signed	[10:0] topLeftX,// output the top left corner 
					output logic signed	[10:0] topLeftY
					
);


// a module used to generate the  ball trajectory.  

parameter int INITIAL_X_SPEED = 0;
parameter int INITIAL_Y_SPEED = 0;
parameter int SET_SPEED = 128;
parameter int SET_SPEED_Collision = 64;//only for collision with machine from it's bottom
const int	FIXED_POINT_MULTIPLIER	=	64;
// FIXED_POINT_MULTIPLIER is used to work with integers in high resolution 
// we do all calulations with topLeftX_FixedPoint  so we get a resulytion inthe calcuatuions of 1/64 pixel 
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n 
const int	x_FRAME_SIZE	=	639 * FIXED_POINT_MULTIPLIER; // note it must be 2^n 
const int	y_FRAME_SIZE	=	479 * FIXED_POINT_MULTIPLIER;

int topLeftX_FixedPoint; // local parameters 
int topLeftY_FixedPoint;

//==--------------------------------------------------------------------------------------------------------------=
//  calculation x Axis speed 
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		topLeftX_FixedPoint	<= INITIAL_X * FIXED_POINT_MULTIPLIER;
		
	end
	
	else begin
		//Move	
		topLeftX_FixedPoint <= topLeftX_FixedPoint;	
		
			if (startOfFrame) begin
				
				if(!Up_Move && !Down_Move) begin
				
					if (Left_Move && !Right_Move) 
						topLeftX_FixedPoint <= topLeftX_FixedPoint - SET_SPEED;	// left move

					else if (Right_Move && !Left_Move) 
						topLeftX_FixedPoint <= topLeftX_FixedPoint + SET_SPEED; //right move
		
				end
				
			end
			
			else begin
				if ((collision_doc_maze||collision_doc_patient) && HitEdgeCode [3] && !HitEdgeCode [0] && !HitEdgeCode [2])//if doctor hits the maze from left
					topLeftX_FixedPoint <= topLeftX_FixedPoint + SET_SPEED;
				
				if ((collision_doc_maze||collision_doc_patient) && HitEdgeCode [1] && !HitEdgeCode [0] && !HitEdgeCode [2])//if doctor hits the maze from right
					topLeftX_FixedPoint <= topLeftX_FixedPoint - SET_SPEED;
			
				if (collision_doc_machine && HitEdgeCode [3] && !HitEdgeCode [0] && !HitEdgeCode [2])//if doctor hits the machine from left and the machine hits the maze
					topLeftX_FixedPoint <= topLeftX_FixedPoint + SET_SPEED;
				
				if (collision_doc_machine && HitEdgeCode [1] && !HitEdgeCode [0] && !HitEdgeCode [2])//if doctor hits the machine from right and the machine hits the maze
					topLeftX_FixedPoint <= topLeftX_FixedPoint - SET_SPEED;
					
			
			end
		
	end
		
end		

//==----------------------------------------------------------------------------------------------------------------=
//  calculation Y Axis speed using gravity

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		topLeftY_FixedPoint	<= INITIAL_Y * FIXED_POINT_MULTIPLIER;
	end
	
	else begin
		//Move	
		topLeftY_FixedPoint <= topLeftY_FixedPoint;	
		
			if (startOfFrame) begin
			
				if(!Left_Move && !Right_Move) begin
				
					if (Up_Move && !Down_Move) 
						topLeftY_FixedPoint <= topLeftY_FixedPoint - SET_SPEED; //up move

					else if (Down_Move && !Up_Move) 
						topLeftY_FixedPoint <= topLeftY_FixedPoint + SET_SPEED; //down move

				end
			
			end
			
			else begin
				if ((collision_doc_maze||collision_doc_patient)&& HitEdgeCode [2] && !HitEdgeCode [1] && !HitEdgeCode [3])//if doctor hits the maze from below
					topLeftY_FixedPoint <= topLeftY_FixedPoint + SET_SPEED;
				
				if ((collision_doc_maze||collision_doc_patient) && HitEdgeCode [0] && !HitEdgeCode [1] && !HitEdgeCode [3])//if doctor hits the maze from above
					topLeftY_FixedPoint <= topLeftY_FixedPoint - SET_SPEED;
				
				if (collision_doc_machine && HitEdgeCode [2] && !HitEdgeCode [1] && !HitEdgeCode [3])//if doctor hits the machine from the bottom of it
					topLeftY_FixedPoint <= topLeftY_FixedPoint + SET_SPEED;
				
				if (collision_doc_machine && HitEdgeCode [0] && !HitEdgeCode [1] && !HitEdgeCode [3])//if doctor hits the machine from the top of it
					topLeftY_FixedPoint <= topLeftY_FixedPoint - SET_SPEED_Collision;
					
			
			end		
		
	end
	
end

//get a better (64 times) resolution using integer   
assign 	topLeftX = topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER ;    


endmodule
