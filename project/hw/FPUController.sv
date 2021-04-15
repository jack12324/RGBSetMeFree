module FPUController #(COL_WIDTH = 10 )(col_new, shift_cols, filter, done, request_read, read_address, request_write, write_address, write_col_address, write_col, read_col_address, rd_buffer_sel, wr_buffer_sel, wr_en_wr_buffer, address_mem, read_col, result_pixels, stall, data);

	input clk, rst_n, stall, mapped_data_valid;
	input [7:0] read_col [COL_WIDTH-1:0];
	input [7:0] result_pixels [COL_WIDTH-3:0];
	input [31:0] data_mem;

	output shift_cols, done, request_write, request_read, rd_buffer_sel, wr_buffer_sel, wr_en_wr_buffer;
	output [7:0] col_new [COL_WIDTH-1:0];
	output [7:0] filter [8:0];
	output [31:0] read_address;
	output [31:0] write_address;
	output [8:0] write_col_address;
	output [7:0] write_col [COL_WIDTH-3:0];
	output [8:0] read_col_address;
	output [31:0] address_mem;


	typedef enum {IDLE, LOAD_FILTER, LOAD_WIDTH, LOAD_HEIGHT, LOAD_START_ADDR, LOAD_RESULT_ADDR, INITITAL_MEM_REQ1, INITIAL_MEM_REQ2, OPERATE, MEM_REQ, DONE, XXX} state_e;

	state_e state, next;

	always_ff @(posedge clk, negedge rst_n)
		if(!rst_n) state <= IDLE;
		else state <= next;
	
	//decide next state	
	always_comb begin
		next_state = XXX;
		case(state)
			IDLE: if(data_mem == 32'h0001 && mapped_data_valid)				next = LOAD_FILTER;
			      else									next = IDLE;			//@loopback
			LOAD_FILTER: if(mapped_data_valid)						next = LOAD_WIDTH;
				     else								next = LOAD_FILETER;		//@loopback	
			LOAD_WIDTH: if(mapped_data_valid)						next = LOAD_HEIGHT;
				    else								next = LOAD_WIDTH;		//@loopback
			LOAD_HEIGHT: if(mapped_data_valid)						next = LOAD_START_ADDR;
				     else								next = LOAD_HEIGHT;		//@loopback
			LOAD_START_ADDR: if(mapped_data_valid)						next = LOAD_RESULT_ADDR;
					 else								next = LOAD_START_ADDR;		//@loopback
			LOAD_RESULT_ADDR: if(mapped_data_valid)						next = INITITAL_MEM_REQ1;
					  else								next = LOAD_RESULT_ADDR;	//@loopback
			INITIAL_MEM_REQ1: if(request_done)						next = INITIAL_MEM_REQ2;
					  else								next = INITIAL_MEM_REQ1; 	//@loopback
			INITIAL_MEM_REQ2:								next = OPERATE;
			OPERATE: if((width_counter == remaining width) || (width_counter == 512))	next = MEM_REQ;
				 else if(height_counter == height)					next = DONE;
				 else									next = OPERATE; 	//@loopback
			MEM_REQ:									next = OPERATE;
			DONE:										next = IDLE;
			default:									next = XXX;
		endcase
	end	
	
	//outputs	
	always_ff @(posedge clk, negedge rst_n) begin
	end	
	
endmodule
