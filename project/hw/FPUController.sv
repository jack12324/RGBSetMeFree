module FPUController #(COL_WIDTH = 10, MEM_BUFFER_WIDTH = 512, M_STARTSIG_ADDRESS = 32'h1000_0120, M_FILTER_ADDRESS = 32'h1000_0040, M_DIMS_ADDRESS = 32'h1000_0000, M_START_ADDRESS = 32'h1000_0020, M_RESULT_ADDRESS = 32'h1000_0100)(clk, rst_n, mapped_data_valid, shift_cols, filter, done, request_read, read_address, request_write, write_address, write_col_address, read_col_address, rd_buffer_sel, wr_buffer_sel, wr_en_wr_buffer, address_mem, stall, data_mem, making_request, write_request_width, write_request_height);

	input clk, rst_n, stall, mapped_data_valid, making_request;
	input [31:0] data_mem;

	output logic shift_cols, done, request_write, request_read, rd_buffer_sel, wr_buffer_sel, wr_en_wr_buffer;
	output signed [7:0] filter [8:0];
	output logic [31:0] read_address;
	output logic [31:0] write_address;
	output logic [$clog2(MEM_BUFFER_WIDTH)-1:0] write_col_address;
	output logic [$clog2(MEM_BUFFER_WIDTH)-1:0] read_col_address;
	output logic [31:0] address_mem;
	output logic [16:0] write_request_width;
	output logic [8:0] write_request_height;

	typedef enum {IDLE, LOAD_CONFIG, FILL_BUFF1, ADDR_ALL, ADDR_CHUNK, FILL_BUFF2, NEW_ROW, OPERATE, PRE_PAUSE, PRE_CHUNK_END1, PRE_CHUNK_END2, PRE_CHUNK_END3, CHUNK_END, PAUSE_CHUNK, UPDATE_BASE, UPDATE_HEIGHT, UPDATE_WRITE, UPDATE_READ, ROW_END, ROW_DONE_WAIT, CHUNK_DONE, PRE_FINAL, FINAL_REQUEST, WAIT_FINAL, DONE, XXX} state_e;
	state_e state, next;

	FPUConfig_if conf();
	FPUControllerConfigurationLoader ConfLoader(.*, .config_if(conf.Loader));

	logic [18:0] total_width, remaining_width;
	logic [16:0] remaining_height;
	logic [1:0] update_write_address;

	//read and write increment enables, resets
	logic write_inc, read_inc, write_rst, read_rst, height_dec, set_remaining_height, width_dec, set_remaining_width, read_dec, write_dec;
	
	assign conf.mapped_data_valid = mapped_data_valid;
	assign conf.data_mem = data_mem;
	assign filter = conf.filter;

	assign total_width = (conf.image_width + 2)*3;
	assign write_request_width = MEM_BUFFER_WIDTH > remaining_width - 2 ? remaining_width - 2: MEM_BUFFER_WIDTH;
	assign write_request_height = COL_WIDTH > remaining_height ? remaining_height - 2: COL_WIDTH - 2;

	//track address of current row start
	logic [31:0] base_read_address;
	logic [31:0] base_write_address;

	always_ff @(posedge clk, negedge rst_n)
		if(!rst_n) state <= IDLE;
		else state <= next;
	
	//decide next state	
	always_comb begin
		next = XXX;
		case(state)
			IDLE: if(data_mem == 32'h0001 && mapped_data_valid)						next = LOAD_CONFIG;
			      else											next = IDLE;				//@loopback

			LOAD_CONFIG: if(conf.load_config_done)								next = FILL_BUFF1;
					else										next = LOAD_CONFIG;			//@loopback

			FILL_BUFF1: if(total_width > MEM_BUFFER_WIDTH)							next = ADDR_ALL;
				else 									       		next = ADDR_CHUNK;

			FILL_BUFF2:  if(!making_request)								next = NEW_ROW;
				else											next = FILL_BUFF2;			//@loopback

			ADDR_CHUNK: 											next = FILL_BUFF2;

			ADDR_ALL: 											next = FILL_BUFF2;

			NEW_ROW: if(read_col_address == 4) 								next = OPERATE;
				 	else										next = NEW_ROW;				//@loopback

			OPERATE: if(read_col_address >= remaining_width)						next = ROW_END;
				else if(remaining_width != MEM_BUFFER_WIDTH-1 &&
					 read_col_address == MEM_BUFFER_WIDTH-2 &&
					 making_request)								next = PRE_PAUSE;
				else if(read_col_address == MEM_BUFFER_WIDTH-1)						next = CHUNK_END;
				else											next = OPERATE;				//@loopback

			PRE_PAUSE:											next = PAUSE_CHUNK;
			PAUSE_CHUNK: if(!making_request)								next = PRE_CHUNK_END1;
				else											next = PAUSE_CHUNK;			//@loopback

			PRE_CHUNK_END1:											next = PRE_CHUNK_END2;
			PRE_CHUNK_END2:											next = PRE_CHUNK_END3;
			PRE_CHUNK_END3:											next = CHUNK_END;

			CHUNK_END: if(write_col_address == MEM_BUFFER_WIDTH-1)						next = UPDATE_BASE;
				else											next = CHUNK_END;			//@loopback
			
			UPDATE_BASE:											next = CHUNK_DONE;

			CHUNK_DONE: if(remaining_width - MEM_BUFFER_WIDTH < 3)						next = WAIT_FINAL;
				else										 	next = OPERATE;
			
			UPDATE_HEIGHT:											next = ROW_END;

			UPDATE_READ:											next = ROW_DONE_WAIT;
	
			ROW_END: if(write_col_address >= remaining_width-2)begin
					if(remaining_height > COL_WIDTH)						next = UPDATE_READ;
					else										next = PRE_FINAL;
				end else										next = ROW_END;				//@loopback

			ROW_DONE_WAIT: if(!making_request)								next = UPDATE_WRITE;
				else											next = ROW_DONE_WAIT;			//@loopback
	
			UPDATE_WRITE:											next = NEW_ROW;

			PRE_FINAL:											next = FINAL_REQUEST;

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
			address_mem <= '0;

			conf.load_config_start <= 0;
			write_inc <= 0;
			read_inc <= 0;
			read_rst <= 0;
			write_rst <= 0;
			height_dec <= 0;
			width_dec <= 0;
			set_remaining_height <= 0;
			set_remaining_width<= 0;
			update_write_address <= '0;
			base_read_address <= '0;
			base_write_address <= '0;
			read_dec <= 0;
			write_dec <= 0;
		end
		else begin
			shift_cols <= 0;
			done <=0;
			request_write <= 0;
			request_read <= 0;
			rd_buffer_sel <= rd_buffer_sel;
			wr_buffer_sel <= wr_buffer_sel;
			wr_en_wr_buffer <= 0;
			read_address <= read_address;
			address_mem <= '0;
		
			conf.load_config_start <= 0;
			write_inc <= 0;
			read_inc <= 0;
			read_rst <= 0;
			write_rst <= 0;
			height_dec <= 0;
			width_dec <= 0;
			set_remaining_height <= 0;
			set_remaining_width <= 0;
			update_write_address <= '0;
			base_read_address <= base_read_address;
			base_write_address <= base_write_address;
			write_dec <= 0;
			read_dec <= 0;

			case(next)
				IDLE: address_mem <= M_STARTSIG_ADDRESS;
				LOAD_CONFIG: begin
					address_mem <= conf.address_mem;
					conf.load_config_start <= 1;
				end
				FILL_BUFF1: begin
					set_remaining_height <= 1;
					set_remaining_width <= 1;
					request_read <= 1;
					read_address <= conf.start_address;
					base_read_address <= conf.start_address;
					base_write_address <= conf.result_address;
					update_write_address <= 1;
					rd_buffer_sel <= 1; //loads oposite so fills buffer 0
					wr_buffer_sel <= 0; 
				end
				ADDR_ALL: begin
					read_address <= read_address + MEM_BUFFER_WIDTH;
				end
				ADDR_CHUNK: begin
					base_read_address <= base_read_address + (total_width * (COL_WIDTH-2));
					read_address <= read_address + (total_width * (COL_WIDTH-2));
				end

				FILL_BUFF2:begin
					request_read <= 1;	
					read_rst <= 1;
					write_rst <= 1;
					rd_buffer_sel <= 0; //loads oposite so fills buffer 1
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
				PRE_PAUSE:begin
					wr_en_wr_buffer <= 1;
				end
				PAUSE_CHUNK: begin 
				end
				PRE_CHUNK_END1:begin
					read_dec <= 1;
					write_dec <= 1;
				end
				PRE_CHUNK_END2:begin
					read_inc <= 1;
					write_inc <= 1;
				end
				PRE_CHUNK_END3:begin
					shift_cols <= 1;
					read_inc <= 1;
					write_inc <= 1;
				end
				CHUNK_END: begin
					shift_cols <= 1;
					read_inc <= 1;
					write_inc <= 1;
					wr_en_wr_buffer <= 1;
					rd_buffer_sel <= !wr_buffer_sel;
				end 
				UPDATE_BASE: begin
					shift_cols <= 1;
					read_inc <= 1;
					write_inc <= 1;
					wr_en_wr_buffer <= 1;
					wr_buffer_sel <= rd_buffer_sel;
					if(remaining_width - MEM_BUFFER_WIDTH < MEM_BUFFER_WIDTH)
						base_read_address <= base_read_address + (total_width * (COL_WIDTH-2));	
				end
				CHUNK_DONE: begin
					shift_cols <= 1;
					read_inc <= 1;
					write_inc <= 1;
					wr_en_wr_buffer <= 1;
					request_read <= 1;
					request_write <= 1;
					read_address <= (remaining_width -MEM_BUFFER_WIDTH) < MEM_BUFFER_WIDTH ? base_read_address : read_address + MEM_BUFFER_WIDTH;
					update_write_address <= 2;
					width_dec <= 1;
				end
				UPDATE_HEIGHT: begin
					height_dec <= 1;
					shift_cols <= 1;
					write_inc <= 1;
					wr_en_wr_buffer <= 1;
				end
				UPDATE_READ: begin
					read_address <= read_address + (total_width > MEM_BUFFER_WIDTH ? MEM_BUFFER_WIDTH : total_width * (COL_WIDTH - 2));
					rd_buffer_sel <= !rd_buffer_sel;
					wr_buffer_sel <= !wr_buffer_sel;
				end


				ROW_END: begin
					shift_cols <= 1;
					write_inc <= 1;
					wr_en_wr_buffer <= 1;
				end 
				ROW_DONE_WAIT: begin
					request_read <= 1;
					request_write <= 1;
				end
				UPDATE_WRITE: begin
					base_write_address <= base_write_address + ((conf.image_width * 3) + 4) * (COL_WIDTH-2);
					update_write_address <= 3;
					read_rst <= 1;
					write_rst <= 1;
					height_dec <= 1;
					set_remaining_width <= 1;
				end
				PRE_FINAL: begin
					rd_buffer_sel <= !rd_buffer_sel;
				end
				FINAL_REQUEST: begin
					request_write <= 1;
				end
				WAIT_FINAL: begin end
				DONE:	done <= 1;
				default: begin end
			endcase
		end
	end	

	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n | read_rst) read_col_address <= 0;
		else if (read_inc) read_col_address += 1;
		else if (read_dec) read_col_address -= 1;
	end
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n | write_rst) write_col_address <= 0;
		else if (write_inc) write_col_address += 1;
		else if (write_dec) write_col_address -= 1;
	end
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n) remaining_height <= 0;
		else if (set_remaining_height) remaining_height <= conf.image_height + 2; 
		else if (height_dec) remaining_height -= (COL_WIDTH - 2);
	end
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n) remaining_width <= 0;
		else if (set_remaining_width) remaining_width <= total_width;
		else if (width_dec) remaining_width -= MEM_BUFFER_WIDTH;
	end
	always_ff @(posedge clk, negedge rst_n)begin
		if(!rst_n) write_address <= '0;
		else begin
			case(update_write_address)
				0: write_address <= write_address;
				1: write_address <= conf.result_address;
				2: write_address <= write_address + MEM_BUFFER_WIDTH;
				3: write_address <= base_write_address;
			endcase
		end
	end
endmodule
