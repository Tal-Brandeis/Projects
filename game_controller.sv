
module game_controller
	(
	input logic clk, 
	input logic resetN,
	input logic timerend,
	input logic startOfFrame,
	
	//collision flags to ensure the placement of an object is ok
	input logic collision_machine_patient,
	input logic collision_machine_maze,
	input logic collision_machine_doc,
	input logic collision_doc_maze,
	input logic collision_surprise_with_all,
	
	//drawing orders and other indications
	output logic [2:0] level,
	output logic [1:0] lives,
	output logic draw_maze,
	output logic draw_objects,
	
	//flags outputs
	output logic flag_lose,
	output logic flag_win,	
	output logic start_timer,
	output logic completed_level,	
	output logic lose_life
   );
	
	logic [2:0] lvl;
	logic [1:0] lives_count;
	logic level_up, reduce_life;
	logic draw_mode;
//-------------------------------------------------------------------------------------------

// state machine decleration 
	enum logic [2:0] {S_draw_maze, S_draw_objects, S_check_draw,S_play, S_level_up, S_lose, S_win} pres_st, next_st;
	
//--------------------------------------------------------------------------------------------
//  1.  syncronous code:  executed once every clock to update the current state and the level
always_ff @(posedge clk or negedge resetN) begin
	   
	if (!resetN) begin  // Asynchronic reset
		pres_st <= S_draw_maze;
		lvl <= 3'b1;
		lives_count <= 2'b11;
	end
	
	else begin		// Synchronic logic FSM
		pres_st <= next_st;
		if (level_up)//if flag level_up than level up
			lvl <= lvl + 1;
			
		if (reduce_life) //if flag reduce_life than reduce_life
			lives_count <= lives_count - 1;
			
			
		if(draw_mode) begin //flag for draw mode - allow relocate of objects which were not placed on an empty spot
			if(collision_doc_maze || collision_machine_maze || collision_machine_doc
				|| collision_surprise_with_all || collision_machine_patient)// if any object is in collision with something and needs to be redrawed
				pres_st <= S_draw_objects;
		end
		
	end 
end // always sync


//--------------------------------------------------------------------------------------------
//  2.  asynchornous code: logically defining what is the next state, and the ouptput 
//      							(not seperating to two different always sections)  	

always_comb // Update next state and outputs
	begin
	// set all default values 
		next_st = pres_st; 		
		draw_maze = 1'b0;
		draw_objects = 1'b0;
		flag_lose = 1'b0;
		flag_win = 1'b0;
		start_timer = 1'b0;
		level_up = 1'b0;
		reduce_life = 1'b0;
		draw_mode = 1'b0;
		
		case (pres_st)
		
			S_draw_maze: begin //output flag draw the random maze, will draw maze according to level (there is an output of which level we are in)
				draw_maze = 1'b1;
				next_st = S_draw_objects;
			end //draw_maze
				
				
			S_draw_objects: begin
				draw_mode = 1'b1;//flag that we are in draw mode
				draw_objects = 1'b1;//draw objects randomly

				if(startOfFrame)//after finsihed scanning screen go to check mode
					next_st = S_check_draw;
		
			end //draw_objects
			
			
			S_check_draw: begin //check all objects were placed in empty spots 
				draw_mode = 1'b1;	//flag that we are in draw mode
				
				if(startOfFrame) begin //after finsihed scanning all of the screen, all objects are placed correctly and can start game.
					start_timer = 1'b1;
					next_st = S_play;
				end
				
			end//check_draw
			
			
			S_play: begin
				if (timerend) begin //if time is up
					if (lives_count > 1) begin //if player has more lives, reduce 1 life and restart level
						reduce_life = 1'b1;
						next_st = S_draw_maze;
					end
					
					else begin //if player has no more lives, game over
						next_st = S_lose;
						reduce_life = 1'b1;
					end
				end
					
				else if (collision_machine_patient) begin //if the machine reached the patient in time
					if (lvl == 3'b101) //if in the last level, player wins
						next_st = S_win;					
					else begin //if not in the last level, start the next level
						next_st = S_level_up;
					end
				end					
			end //play
			

			S_level_up: begin //level up and redraw maze according to new level
				level_up = 1'b1;
				next_st = S_draw_maze;
			end
			
			
			S_lose: begin //lose mode
				flag_lose = 1'b1;	
			end //lose
			
			
			S_win: begin //win mode
				flag_win = 1'b1;	
			end //win

		endcase
	
	end // always comb

assign level = lvl;
assign lives = lives_count;
assign completed_level = level_up;
assign lose_life = reduce_life;

endmodule
