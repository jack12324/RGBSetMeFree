module FPUController #(COL_WIDTH = 10 )(col_new, shift_cols, filter, done, request_read, read_address, request_write, write_address, write_col_address, write_col, read_col_address, rd_buffer_sel, wr_buffer_sel, wr_en_wr_buffer, address_mem, read_col, result_pixels, stall, data, request_done);

	input clk, rst_n, stall, mapped_data_valid, request_done;
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

	typedef enum {IDLE, LOAD_CONFIG, INITITAL_MEM_REQ1, INITIAL_MEM_REQ2, OPERATE, MEM_REQ, DONE, XXX} state_e;
	state_e state, next;

	FPUConfig_if conf();
	FPUControllerConfigurationLoader ConfLoader(.*, .config_if(conf.Loader));
	
	assign conf.mapped_data_valid = mapped_data_valid;
	assign conf.data_mem = data_mem;

	always_ff @(posedge clk, negedge rst_n)
		if(!rst_n) state <= IDLE;
		else state <= next;
	
	//decide next state	
	always_comb begin
		next_state = XXX;
		case(state)
			IDLE: if(data_mem == 32'h0001 && mapped_data_valid)				next = LOAD_CONFIG;
			      else									next = IDLE;			//@loopback
			LOAD_CONFIG: if(conf.load_config_done)						next = INITIAL_MEM_REQ1;
					else								next = LOAD_CONFIG;		//@loopback
			INITIAL_MEM_REQ1: if(request_done)						next = INITIAL_MEM_REQ2;
					  else								next = INITIAL_MEM_REQ1; 	//@loopback
			INITIAL_MEM_REQ2:								next = OPERATE;
			OPERATE: if((width_counter == remaining width) || (width_counter == 512))	next = MEM_REQ;
				 else if(height_counter == height)					next = DONE;
				 else									next = OPERATE; 		//@loopback
			MEM_REQ:									next = OPERATE;
			DONE:										next = IDLE;
			default:									next = XXX;
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
			col_new <= '0;
			filter <= '0;
			read_address <= '0;
			write_address <= '0;
			write_col_address <= '0;
			write_col <= '0;
			read_col_address <= '0;
			address_mem <= '0;

			conf.load_config_start <= 1;
		end
		else begin
			shift_cols <= 0;
			done <=0;
			request_write <= 0;
			request_read <= 0;
			rd_buffer_sel <= 0;
			wr_buffer_sel <= 0;
			wr_en_wr_buffer <= 0;
			col_new <= '0;
			filter <= '0;
			read_address <= '0;
			write_address <= '0;
			write_col_address <= '0;
			write_col <= '0;
			read_col_address <= '0;
			address_mem <= '0;
		
			conf.load_config_start <= 0;
			case(state)
				IDLE: address_mem <= M_START_ADDRESS;
				LOAD_CONFIG: begin
					address_mem <= conf.address_mem;
					conf.load_config_start <= 1;
					end
				INITITAL_MEM_REQ1:
				INITIAL_MEM_REQ2:
				OPERATE:
				MEM_REQ:
				DONE:
				default: 
			endcase
		end
	end	
endmodule
