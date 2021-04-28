module cache_control(
    //Input
    clk, rst,
    mem_stall,
    cache_hit,
    dirty,
    valid,
    Wr_in,
    Rd_in,
    mem_data_out,
    busy,
    tag_out,
    cache_data_out,
    addr_in,
    DataIn_in,

    //Output
    mem_addr,
    write,
    en,
    stall,
    comp,
    memWr,
    done,
    memRd,
    cache_control_err,
    cache_tag_in,
    cache_index,
    cache_offset,
    cache_data_in,
    CacheHit,   //Top level output
    mem_data_in,
    DataOut
    );
endmodule 
    
module cache_controller(
	// Input from system
	clk,rst,creat_dump,Data_latch,
	// Input from mem
	Addr,DataIn,Rd,Wr,
	// Input from cache
	hit,dirty,tag_out,DataOut_cache,valid,
	// Input from four bank
	DataOut_mem,
	// Output to cache
	enable_ct,index_cache,
	offset_cache,cmp_ct,
	wr_cache,tag_cache,
	DataIn_ct,valid_in_ct,
	// Output to fourbank
	Addr_mem,DataIn_mem,
	wr_mem,rd_mem,
	// Output to system
	Done,CacheHit,Stall_sys, DataOut_ct, final_state
	);
endmodule
