module cpu_cache_ctrl #(
        parameter WORD_SIZE = 32,
        parameter CL_SIZE_WIDTH = 512,
        parameter ADDR_WIDTH = 32
    )
    (
    //Inputs
        // Mem_system
    clk, rst_n, AddrIn_mem, DataIn_mem, Rd_in, Wr_in, //New data to write
        // DMA
    DataIn_host, tx_done_host, rd_valid_host,
        // From Cache 
    hit_in, dirty_in, tag_in, validIn_cache, DataIn_cache, cache_line_in, 

    //Outputs
        //Mem_system
    DataOut_mem, stall, done, hit_out,
        //DMA
    AddrOut_host, DataOut_host, op_host,
        //Cache
    cache_en, index, offset, comp, wr_cache, tag_out, DataOut_cache, cache_line_out, replaceLine
);
    
input logic clk, rst_n, Wr_in, Rd_in, tx_done_host, rd_valid_host;
input logic [CL_SIZE_WIDTH-1:0] DataIn_host, cache_line_in;
output logic [CL_SIZE_WIDTH-1:0] DataOut_host, cache_line_out;

input logic [WORD_SIZE-1:0] DataIn_mem, DataIn_cache;
output logic [WORD_SIZE-1:0] DataOut_mem, DataOut_cache;

input logic [ADDR_WIDTH-1:0] AddrIn_mem;
output logic [ADDR_WIDTH-1:0] AddrOut_host;
output logic [1:0] op_host;

input logic [17:0] tag_in;
input logic validIn_cache, hit_in, dirty_in;
output logic replaceLine;
output logic [7:0] index;
output logic [5:0] offset;
output logic comp, wr_cache, stall, done, hit_out, cache_en;
output logic [17:0] tag_out;

typedef enum logic [2:0] { IDLE, CMPRD, MEMWB, MEMRD, CACHEWR, CMPWR, ACCRD} State;

State currentState, nextState;

logic [WORD_SIZE -1: 0] FloppedDataIn;
logic [ADDR_WIDTH-1: 0] FloppedAddressIn;

always_ff @( posedge clk ) begin 
    if(currentState == IDLE) begin
        FloppedDataIn <= DataIn_mem;
        FloppedAddressIn <= AddrIn_mem;
    end
    
end
always_ff @( posedge clk, negedge rst_n ) begin 

    if(~rst_n)
        currentState <= IDLE;
    else
        currentState <= nextState;
end

always_comb begin 
    case(currentState)
        IDLE: begin
            stall = 1'b0;
            nextState = Rd_in? CMPRD: Wr_in ? CMPWR: IDLE;
        end
        CMPRD: begin
            cache_en = 1'b1;
            comp = 1'b1;
            DataOut_cache = FloppedDataIn; //Data going out to cache is in mem
            //Set cache addr bits
            tag_out = FloppedAddressIn[31:14];
            index = FloppedAddressIn[13:6];
            offset = FloppedAddressIn[5:0];

            hit_out = hit_in&validIn_cache;
            done = hit_in&validIn_cache;
            DataOut_mem = hit_in&validIn_cache? DataIn_cache : 32'h0;
            nextState = hit_in&validIn_cache? IDLE: dirty_in? MEMWB : MEMRD ;
        end
        MEMWB: begin
            //Set cache addr bits 
            tag_out = FloppedAddressIn[31:14];
            index = FloppedAddressIn[13:6];
            offset = FloppedAddressIn[5:0];
            //Now the entire cache line is available on cache_line_in
            op_host = 2'b11;            //Signal write to the mem_ctrl;
            AddrOut_host = FloppedAddressIn;  //CPU Virtual Address must be prefixed
            DataOut_host = cache_line_in;
            nextState = tx_done_host? MEMRD : MEMWB;
        end
        MEMRD: begin
            //Set cache addr bits 
            tag_out = FloppedAddressIn[31:14];
            index = FloppedAddressIn[13:6];
            offset = FloppedAddressIn[5:0];
            //Now the entire cache line from host is available on dataIn_host
            op_host = 2'b01;            //Signal Read to the mem_ctrl;
            cache_line_out = DataIn_host;
            AddrOut_host = FloppedAddressIn;  //CPU Virtual Address must be prefixed
            DataOut_host = cache_line_in;
            replaceLine = tx_done_host? 1'b1: 1'b0;
            nextState = tx_done_host? CACHEWR : MEMRD;
        end
        CACHEWR: begin  //Writes the new word in replaced cache line
            wr_cache = 1'b1;
            cache_en = 1'b1;
            op_host = 2'b0; //Make sure no extra requests to mem_ctrl after tx_done
            
            tag_out = FloppedAddressIn[31:14];
            index = FloppedAddressIn[13:6];
            offset = FloppedAddressIn[5:0];

            DataOut_cache = FloppedDataIn;
            nextState = IDLE;   //At this point Rd and Wr operations are done and no more stalls
        end
        CMPWR: begin
            cache_en = 1'b1;
            wr_cache = 1'b1;
            comp = 1'b1;
            //Set cache addr bits
            tag_out = FloppedAddressIn[31:14];
            index = FloppedAddressIn[13:6];
            offset = FloppedAddressIn[5:0];
            
            hit_out = hit_in & validIn_cache;
            done = hit_in & validIn_cache;
            
            nextState = hit_in & validIn_cache? IDLE: validIn_cache ? ACCRD : MEMRD;
        end
        ACCRD: begin
            cache_en = 1'b1;
            //Set cache addr bits
            tag_out = FloppedAddressIn[31:14];
            index = FloppedAddressIn[13:6];
            offset = FloppedAddressIn[5:0];
            nextState = dirty_in ? MEMWB : MEMRD;
        end
        default: begin
            //Mem
            DataOut_mem = '0;
            stall = '0;
            done = '0;
            hit_out = '0;
            //DMA
            AddrOut_host = '0;
            DataOut_host = '0;
            op_host = '0;
            //Cache
            cache_en = '0;
            index = '0;
            offset = '0;
            comp = '0;
            wr_cache = '0;
            tag_out = '0;
            DataOut_cache = '0;
            cache_line_out = '0;
            replaceLine = '0;
            nextState = IDLE;
        end
    endcase
end


endmodule