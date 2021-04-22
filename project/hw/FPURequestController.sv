module FPURequestController();
	typedef enum {IDLE, START_WRITE_REQUEST, LOAD_WRITE_DATA, WAIT_DRAM_READY_WRITE, SEND_WRITE_CL, WAIT_WRITE_DONE, CHECK_WRITE_REQ_DONE, DONE, XXX} state_e;
	state_e state, next;
	
	always_comb begin
		next = XXX;
		case(state)
			IDLE: if(
		endcase
	end
endmodule
