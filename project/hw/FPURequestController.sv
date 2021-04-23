module FPURequestController#(BUFFER_DEPTH = 512, COL_WIDTH = 10)(clk, rst_n, req_if, dram_if, buffer_rd_address, buffer_read_data, buffer_wr_address, buffer_write_data, wr_en_rd_buffer);
	localparam CL_WIDTH = 64; //bytes
	input clk, rst_n;
	output logic wr_en_rd_buffer;
	input [7:0] buffer_read_data;
	output logic [CL_WIDTH-1: 0] buffer_write_data;
	output [$clog2(BUFFER_DEPTH) + $clog2(COL_WIDTH-2) - 1:0] buffer_rd_address;
	output [$clog2(BUFFER_DEPTH) + $clog2(COL_WIDTH) - 1:0] buffer_wr_address;
	FPUCntrlReq_if req_if;
	FPUDRAM_if dram_if;

	typedef enum {IDLE, SAVE_WRITE_ADDR, START_WRITE_REQUEST, FIRST_LOAD, LOAD_WRITE_DATA, LAST_SHIFT, WAIT_DRAM_READY_WRITE, SEND_WRITE_CL, WAIT_WRITE_DONE, UPDATE_WRITE_ADDRESS, CHECK_WRITE_REQ_DONE, DONE, SAVE_READ_ADDR, START_READ_REQUEST, WAIT_DRAM_READY, GET_CL, FIRST_SAVE, SAVE_DATA, SAVE_END, FPU_READY, WAIT_READ_DONE, WAIT_READ_DONE_LINE, UPDATE_READ_ADDRESS, XXX} state_e;
	state_e state, next;

	//used to save the initial state
	logic capture;
	logic cap_read;
	logic [16:0] cap_width;
	logic [16:0] cap_height;
	logic [31:0] cap_wr_addr;
	logic [31:0] cap_rd_addr;
	logic [7:0] request_size;

	logic [$clog2(BUFFER_DEPTH)-1:0] rd_col;
	logic [$clog2(COL_WIDTH-2)-1:0] rd_row;
	logic [$clog2(BUFFER_DEPTH)-1:0] wr_col;
	logic [$clog2(COL_WIDTH)-1:0] wr_row;
	logic [$clog2(CL_WIDTH):0] load_count;


	logic [7:0] sent_lines;
	logic [16:0] rows_sent;

	logic [(CL_WIDTH << 3) -1:0] read_cl;

	assign buffer_rd_address = {rd_row, rd_col};
	assign buffer_wr_address = {wr_row, wr_col};
	assign dram_if.request_size = request_size;
	
	always_ff @(posedge clk, negedge rst_n)
		if(!rst_n) state <= IDLE;
		else state <= next;

	always_comb begin
		next = XXX;
		case(state)
			IDLE: if(req_if.write)					next = SAVE_WRITE_ADDR;
				else if(req_if.read) 				next = SAVE_READ_ADDR;
				else						next = IDLE;				//@loopback

			SAVE_WRITE_ADDR:					next = START_WRITE_REQUEST;
	
			START_WRITE_REQUEST:					next = FIRST_LOAD;

			FIRST_LOAD: 						next = LOAD_WRITE_DATA;
	
			LOAD_WRITE_DATA: if(load_count == CL_WIDTH)		next = LAST_SHIFT;		
				else						next = LOAD_WRITE_DATA;			//@loopback		
			
			LAST_SHIFT: 						next = WAIT_DRAM_READY_WRITE;		

			WAIT_DRAM_READY_WRITE: if(dram_if.dram_ready)		next = SEND_WRITE_CL;
				else						next = WAIT_DRAM_READY_WRITE;		//@loopback
			
			SEND_WRITE_CL: if(sent_lines == request_size)		next = WAIT_WRITE_DONE;
				else						next = FIRST_LOAD;
		
			WAIT_WRITE_DONE: if(dram_if.request_done) begin
					if(rd_row == cap_height-1)		next = IDLE;
					else					next = UPDATE_WRITE_ADDRESS;
				end else					next = WAIT_WRITE_DONE;			//@loopback

			UPDATE_WRITE_ADDRESS: 					next = START_WRITE_REQUEST;
	
			SAVE_READ_ADDR:						next = START_READ_REQUEST;
	
			START_READ_REQUEST:					next = WAIT_DRAM_READY;
			
			WAIT_DRAM_READY: if (dram_if.dram_ready)		next = GET_CL;
				else						next = WAIT_DRAM_READY;			//@loopback
	
			GET_CL:							next = FIRST_SAVE;

			FIRST_SAVE:						next = SAVE_DATA;

			SAVE_DATA: if(load_count == (CL_WIDTH >> 3)-1)		next = SAVE_END;
				else						next = SAVE_DATA;			//@loopback
	
			SAVE_END:						next = FPU_READY;

			FPU_READY: if(sent_lines != request_size)		next = WAIT_DRAM_READY;
				else begin
					if(wr_row == COL_WIDTH - 1)begin
						if(dram_if.request_done)	next = IDLE;
						else				next = WAIT_READ_DONE;
					end
					else if(dram_if.request_done)		next = UPDATE_READ_ADDRESS;
					else					next = WAIT_READ_DONE_LINE;
				end

			WAIT_READ_DONE: if(dram_if.request_done)		next = IDLE;
				else						next = WAIT_READ_DONE;			//@loopback	

			WAIT_READ_DONE_LINE: if(dram_if.request_done)		next = UPDATE_READ_ADDRESS;
				else						next = WAIT_READ_DONE_LINE;		//@loopback
	
			UPDATE_READ_ADDRESS:					next = START_READ_REQUEST;
		endcase
	end
	
	always_ff @(posedge clk, negedge rst_n)begin
		if(!rst_n)begin
			capture <= '0;
			dram_if.address <= '0;
			dram_if.request <= '0;
			dram_if.rd_wr <= '0;
			dram_if.fpu_ready <= '0;
			dram_if.write_data <= '0;
			rd_row <= '0;
			rd_col <= '0;
			wr_row <= '0;
			wr_col<= '0;
			load_count <= '0;
			req_if.making_request <= '0;
			sent_lines <= '0;
			rows_sent <= '0;
			read_cl <= '0;
			buffer_write_data <= '0;
			wr_en_rd_buffer <= '0;
		end else begin
			capture <= '0;
			dram_if.address <= dram_if.address;
			dram_if.request <= '0;
			dram_if.rd_wr <= '0;
			dram_if.fpu_ready <= '0;
			dram_if.write_data <= dram_if.write_data;
			rd_row <= rd_row;
			rd_col <= rd_col;
			wr_row <= wr_row;
			wr_col <= wr_col ;
			load_count <= load_count;
			req_if.making_request <= '1;
			sent_lines <= sent_lines;
			rows_sent <= rows_sent;
			read_cl <= read_cl;
			buffer_write_data <= '0;
			wr_en_rd_buffer <= '0;

			case(next)
				IDLE: begin
					capture <= '1;
					req_if.making_request <= '0;
					rows_sent <= '0;
					rd_row <= '1;
					wr_row <= '1;
				end
				SAVE_WRITE_ADDR: begin
					dram_if.address <= req_if.write_address;
				end
				START_WRITE_REQUEST: begin
					dram_if.rd_wr <= '1;
					dram_if.request <= '1;
					load_count <= '0;
					rd_col <= '0;
					sent_lines <= '0;
					rows_sent <= rows_sent +1;
					rd_row <= rd_row + 1;
				end
				FIRST_LOAD: begin
					load_count <= load_count + 1;
					rd_col <= rd_col + 1;
				end
				LOAD_WRITE_DATA: begin
					load_count <= load_count + 1;
					rd_col <= rd_col + 1;
					dram_if.write_data <= (dram_if.write_data << 8) + buffer_read_data; 
				end
				LAST_SHIFT: begin
					dram_if.write_data <= (dram_if.write_data << 8) + buffer_read_data; 
					load_count <= '0;
				end
				WAIT_DRAM_READY_WRITE: begin
				end
				SEND_WRITE_CL: begin
					dram_if.fpu_ready <= '1;
					sent_lines <= sent_lines + 1;
				end
				WAIT_WRITE_DONE: begin
					dram_if.write_data <= '0;
				end
				UPDATE_WRITE_ADDRESS: begin
					dram_if.address <= dram_if.address + request_size * 64;
				end
				SAVE_READ_ADDR: begin
					dram_if.address <= req_if.read_address;
				end
				START_READ_REQUEST: begin
					dram_if.rd_wr <= '0;
					dram_if.request <= '1;
					load_count <= '0;
					wr_col <= '0;
					sent_lines <= '0;
					rows_sent <= rows_sent +1;
					wr_row <= wr_row + 1;
				end
				WAIT_DRAM_READY:begin
					dram_if.fpu_ready <= '1;
				end
				GET_CL: begin
					read_cl <= dram_if.read_data;
					load_count <= '0;
				end
				FIRST_SAVE: begin
					read_cl <= read_cl << CL_WIDTH;
					buffer_write_data <= read_cl[(CL_WIDTH << 3) - 1 -: CL_WIDTH];
					wr_en_rd_buffer <= '1;
				end
				SAVE_DATA: begin
					load_count <= load_count + 1;
					wr_col <= wr_col + 8;
					read_cl <= read_cl << CL_WIDTH;
					buffer_write_data <= read_cl[(CL_WIDTH << 3) - 1 -: CL_WIDTH];
					wr_en_rd_buffer <= '1;
				end
				SAVE_END: begin
					load_count <= load_count + 1;
					wr_col <= wr_col + 8;
				end
				FPU_READY: begin
					dram_if.fpu_ready <= '1;
					sent_lines <= sent_lines + 1;
				end
				UPDATE_READ_ADDRESS: begin
					dram_if.address <= dram_if.address + req_if.input_row_width;
				end
				WAIT_READ_DONE: begin 
					dram_if.fpu_ready <= '1;
				end
				WAIT_READ_DONE_LINE: begin
					dram_if.fpu_ready <= '1;
				end
			endcase
		end
	end

	always_ff @(posedge clk, negedge rst_n)begin
		if(!rst_n)begin
			cap_read <= '0;
			cap_width <= '0;
			cap_height <= '0;
			cap_wr_addr <= '0;
			cap_rd_addr <= '0;
			request_size <= '0;
		end else if (capture)begin
			cap_read <= req_if.read;
			cap_width <= req_if.width;
			cap_height <= req_if.height;
			cap_wr_addr <= req_if.write_address;
			cap_rd_addr <= req_if.read_address;
			request_size <= req_if.write ? (req_if.width >> 6) + |req_if.width[5:0] : CL_WIDTH >> 3;
		end
	end
	
endmodule
