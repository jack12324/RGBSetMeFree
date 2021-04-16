module FPUController #(COL_WIDTH = 10, MEM_BUFFER_WIDTH = 512)(shift_cols, filter, done, request_read, read_address, request_write, write_address, write_col_address, read_col_address, rd_buffer_sel, wr_buffer_sel, wr_en_wr_buffer, address_mem, stall, data, making_request);

	input clk, rst_n, stall, mapped_data_valid, making_request;
	input [31:0] data_mem;

	output shift_cols, done, request_write, request_read, rd_buffer_sel, wr_buffer_sel, wr_en_wr_buffer;
	output [7:0] filter [8:0];
	output [31:0] read_address;
	output [31:0] write_address;
	output [8:0] write_col_address;
	output [8:0] read_col_address;
	output [31:0] address_mem;

	typedef enum {IDLE, LOAD_CONFIG, INITITAL_MEM_REQ1, INITIAL_MEM_REQ2_SAME_ROW, INITIAL_MEM_REQ2_NEW_ROW, OPERATE_NEW_ROW, OPERATE_CONTINUE, ROW_DONE_CONTINUE, WRITE_CATCHUP, ROW_DONE_NEW, FINAL_REQUEST, WAIT_WRITE, DONE, XXX} state_e;
	state_e state, next;

	FPUConfig_if conf();
	FPUControllerConfigurationLoader ConfLoader(.*, .config_if(conf.Loader));

	logic [17:0] total_width;
	logic [17:0] width_counter;
	logic [15:0] height_counter;

	//width and height counter enables
	logic w_inc_en, h_inc_en;
	
	assign conf.mapped_data_valid = mapped_data_valid;
	assign conf.data_mem = data_mem;
	assign filter = conf.filter;

	assign total_width = (conf.image_width + 2)*3;

	always_ff @(posedge clk, negedge rst_n)
		if(!rst_n) state <= IDLE;
		else state <= next;
	
	//decide next state	
	always_comb begin
		next_state = XXX;
		case(state)
			IDLE: if(data_mem == 32'h0001 && mapped_data_valid)						next = LOAD_CONFIG;
			      else											next = IDLE;				//@loopback

			LOAD_CONFIG: if(conf.load_config_done)								next = INITIAL_MEM_REQ1;
					else										next = LOAD_CONFIG;			//@loopback

			INITIAL_MEM_REQ1: if(!making_request && (total_width > MEM_BUFFER_WIDTH))			next = INITIAL_MEM_REQ2_SAME_ROW;
					  else if(!making_request && (total_width <= MEM_BUFFER_WIDTH))        		next = INITIAL_MEM_REQ2_NEW_ROW;
					  else										next = INITIAL_MEM_REQ1; 		//@loopback

			INITIAL_MEM_REQ2_SAME_ROW:									next = OPERATE_NEW_ROW;

			INITIAL_MEM_REQ2_NEW_ROW:									next = OPERATE_NEW_ROW;

			OPERATE_NEW_ROW: if(width_counter == 4) 							next = OPERATE_CONTINUE;
				 	else										next = OPERATE_NEW_ROW;			//@loopback

			OPERATE_CONTINUE: if(count == remaining_width)							next = WRITE_CATCHUP;
				else if(count == MEM_BUFFER_WIDTH)							next = ROW_DONE_CONTINUE;
				else											next = OPERATE_CONTINUE;		//@loopback

			ROW_DONE_CONTINUE: if(!making_request)								next = OPERATE_CONTINUE;
				else											next = ROW_DONE_CONTINUE;		//@loopback
	
			WRITE_CATCHUP: if(write_count == remaining_width-2)begin
					if(height_count < conf.image_height)						next = ROW_DONE_NEW;
					else										next = FINAL_REQUEST;
				end else										next = WRITE_CATCHUP;			//@loopback

			ROW_DONE_NEW: if(!making_request)								next = OPERATE_NEW_ROW;
				else											next = ROW_DONE_NEW;			//@loopback
	
			FINAL_REQUEST:	if(!making_request)								next = WAIT_WRITE;
				else											next = FINAL_REQUEST;			//@loopback
	
			WAIT_WRITE: if(!making_request)									next = DONE;
				else											next = WAIT_WRITE;			//@loopback
				
			DONE:												next = IDLE;

			default:											next = XXX;
		endcase
	end	
	
	//outputs	
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			shift_cols <= 0;
			done <=0;
			request_write <= 0;
			request_read <= 0;
			rd_buffer_sel <= 0;
			wr_buffer_sel <= 0;
			wr_en_wr_buffer <= 0;
			read_address <= '0;
			write_address <= '0;
			write_col_address <= '0;
			write_col <= '0;
			read_col_address <= '0;
			address_mem <= '0;

			conf.load_config_start <= 1;
			inc_en <= 1;
		end
		else begin
			shift_cols <= 0;
			done <=0;
			request_write <= 0;
			request_read <= 0;
			rd_buffer_sel <= 0;//
			wr_buffer_sel <= 0;//
			wr_en_wr_buffer <= 0;
			read_address <= '0;
			write_address <= '0;
			write_col_address <= '0;//
			write_col <= '0;
			read_col_address <= '0;//
			address_mem <= '0;
		
			inc_en <= 1;
			conf.load_config_start <= 0;

			case(state)
				IDLE: address_mem <= M_START_ADDRESS;
				LOAD_CONFIG: begin
					address_mem <= conf.address_mem;
					conf.load_config_start <= 1;
				end
				INITITAL_MEM_REQ1: begin
					request_read <= 1;
					read_address <= conf.start_address;
				end
				INITIAL_MEM_REQ2_SAME_ROW: begin
					request_read <= 1;	
					read_address <= conf.start_address + MEM_BUFFER_WIDTH;
				end
				INITIAL_MEM_REQ2_NEW_ROW: begin
					request_read <= 1;	
					read_address <= conf.start_address + (total_width * COL_WIDTH);
				end
				OPERATE: begin
					shift_cols <= 1;
					wr_en_wr_buffer <= 1;
					inc_en <= 1;
				end
				MEM_REQ:
				DONE:
				default: 
			endcase
		end
	end	

	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n) width_counter <= 0;
		else if(inc_en) width_counter += 1;
	end
	
	assign read_col_address
endmodule
