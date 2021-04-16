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

	typedef enum {IDLE, LOAD_CONFIG, FILL_BUFF1, FILL_BUFF2_ALL, FILL_BUFF2_CHUNK, NEW_ROW, OPERATE, CHUNK_END, ROW_END, ROW_DONE, CHUNK_DONE, FINAL_REQUEST, WAIT_FINAL, DONE, XXX} state_e;
	state_e state, next;

	FPUConfig_if conf();
	FPUControllerConfigurationLoader ConfLoader(.*, .config_if(conf.Loader));

	logic [17:0] total_width, remaining_width;
	logic [15:0] remaining_height;

	//read and write increment enables, resets
	logic write_inc, read_inc, write_rst, read_rst;
	
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

			LOAD_CONFIG: if(conf.load_config_done)								next = FILL_BUFF1;
					else										next = LOAD_CONFIG;			//@loopback

			FILL_BUFF1: if(!making_request && (total_width > MEM_BUFFER_WIDTH))				next = FILL_BUFF2_ALL;
					  else if(!making_request && (total_width <= MEM_BUFFER_WIDTH))        		next = FILL_BUFF2_CHUNK;
					  else										next = FILL_BUFF1;	 		//@loopback

			FILL_BUFF2_ALL:											next = NEW_ROW;

			FILL_BUFF2_CHUNK:										next = NEW_ROW;

			NEW_ROW: if(read_col_address == 4) 								next = OPERATE;
				 	else										next = NEW_ROW;				//@loopback

			OPERATE: if(read_col_address == remaining_width)						next = ROW_END;
				else if(read_col_address == MEM_BUFFER_WIDTH)						next = CHUNK_END;
				else											next = OPERATE;				//@loopback

			CHUNK_END: if(!making_request && write_col_address == MEM_BUFFER_WIDTH-1)			next = CHUNK_DONE;
				else if (making_request)								next = ROW_DONE;			
				else											next = CHUNK_END;			//@loopback

			CHUNK_DONE: 											next = OPERATE;
	
			ROW_END: if(write_count == remaining_width-2)begin
					if(height_count < conf.image_height)						next = ROW_DONE;
					else										next = FINAL_REQUEST;
				end else										next = ROW_END;				//@loopback

			ROW_DONE: if(!making_request)									next = NEW_ROW;
				else											next = ROW_DONE;			//@loopback
	
			FINAL_REQUEST:	if(!making_request)								next = WAIT_FINAL;
				else											next = FINAL_REQUEST;			//@loopback
	
			WAIT_FINAL: if(!making_request)									next = DONE;
				else											next = WAIT_FINAL;			//@loopback
				
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
			address_mem <= '0;

			conf.load_config_start <= 0;
			write_inc <= 0;
			read_inc <= 0;
			read_rst <= 0;
			write_rst <= 0;
		end
		else begin
			shift_cols <= 0;
			done <=0;
			request_write <= 0;
			request_read <= 0;
			rd_buffer_sel <= rd_buffer_sel;
			wr_buffer_sel <= wr_buffer_sel;
			wr_en_wr_buffer <= 0;
			read_address <= '0;
			write_address <= '0;
			address_mem <= '0;
		
			conf.load_config_start <= 0;
			write_inc <= 0;
			read_inc <= 0;
			read_rst <= 0;
			write_rst <= 0;

			case(state)
				IDLE: address_mem <= M_START_ADDRESS;
				LOAD_CONFIG: begin
					address_mem <= conf.address_mem;
					conf.load_config_start <= 1;
				end
				FILL_BUFF1: begin
					request_read <= 1;
					read_address <= conf.start_address;
				end
				FILL_BUFF2_ALL: begin
					request_read <= 1;	
					read_address <= conf.start_address + MEM_BUFFER_WIDTH;
					read_rst <= 1;
					write_rst <= 1;
				end
				FILL_BUFF2_CHUNK: begin
					request_read <= 1;	
					read_address <= conf.start_address + (total_width * COL_WIDTH);
					read_rst <= 1;
					write_rst <= 1;
				end
				NEW_ROW: begin
					shift_cols <= 1;
					read_inc <= 1;
				end
				OPERATE: begin
					shift_cols <= 1;
					read_inc <= 1;
					write_inc <= 1;
					wr_en_wr_buffer <= 1;
				end
				CHUNK_END: begin
					shift_cols <= 1;
					read_inc <= 1;
					write_inc <= 1;
					wr_en_wr_buffer <= 1;
					rd_buffer_sel <= !wr_buffer_sel;
				end 
				CHUNK_DONE: begin
					shift_cols <= 1;
					read_inc <= 1;
					write_inc <= 1;
					wr_en_wr_buffer <= 1;
					wr_buffer_sel <= rd_buffer_sel;
					request_read <= 1;
					request_write <= 1;
					read_address <= todo;
					write_address <= todo;
				end
				ROW_END: begin
					shift_cols <= 1;
					write_inc <= 1;
					wr_en_wr_buffer <= 1;
				end 
				ROW_DONE: begin
					rd_buffer_sel <= rd_buffer_sel;
					wr_buffer_sel <= wr_buffer_sel;
					request_read <= 1;
					request_write <= 1;
					read_address <= todo;
					write_address <= todo;
				end
				FINAL_REQUEST: begin
					request_write <= 1;
					write_address <= todo;
				end
				WAIT_FINAL:
				DONE:	done <= 1;
				default: 
			endcase
		end
	end	

	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n | read_rst) read_col_address <= 0;
		else if (read_inc) read_col_address += 1;
	end
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n | write_rst) write_col_address <= 0;
		else if (write_inc) write_col_address += 1;
	end
	
	assign read_col_address
endmodule
