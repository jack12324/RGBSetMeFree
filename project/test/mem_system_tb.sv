module mem_system_tb ();
    // Clock
	logic clk;
	logic rst;
    logic wr;
	logic [31 : 0] addr;
	logic [31 : 0] data_in;

	logic [31 : 0] data_out;
	logic data_valid;
    logic done;
    logic CacheHit;

    logic [31 : 0] data_out_ref;
    logic data_valid_ref;
    logic done_ref;
    logic CacheHit_ref;

    logic [511:0]   DataIn_host, DataOut_host;
    logic tx_done_host, rd_valid_host;
    logic [31:0]    AddrOut_host;
    logic [1:0]     op_host;

	always #5 clk = ~clk; 
    
    mem_system mem_dut(.wr(Wr), .rst_n(~rst).*);
    mem_system_ref ref  (
    // Outputs
    .DataOut(data_out_ref), .Done(data_valid_ref), .Stall(~done_ref), .CacheHit(CacheHit_ref), 
    // Inputs
    .*);

    reg    reg_readorwrite;
    integer n_requests;
    integer n_replies;
    integer n_cache_hits;
    reg     test_success;
    integer req_cycle;

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        Rd = 1'b0;
        Wr = 1'b0;
        Addr = 32'd0;
        DataIn = 32'd0;
        reg_readorwrite = 1'b0;
        n_requests = 0;
        n_replies = 0;
        n_cache_hits = 0;
        test_success = 1'b1;
        req_cycle = 0;
        #10;
        rst = 1'b1;
        
    end

    always @ (posedge clk) begin
        #2;
        // simulation delay
        
        if (Done) begin
        n_replies = n_replies + 1;
        if (CacheHit) begin
            n_cache_hits = n_cache_hits + 1;
        end
        if (Rd) begin
            $display("LOG: ReqNum %4d Rd Addr 0x%04x Value 0x%04x ValueRef 0x%04x Hit: %1d\n",
                    n_replies,
                    Addr,
                    DataOut,
                    DataOut_ref, CacheHit);
            if (DataOut != DataOut_ref) begin
                $display("ERROR");
                test_success = 1'b0;
            end
        end
        if (Wr) begin
            $display("LOG: ReqNum %4d Wr Addr 0x%04x Value 0x%04x ValueRef 0x%04x Hit: %1d\n",
                    n_replies, Addr, DataIn, DataIn, CacheHit);
        end
        Rd = 1'd0;
        Wr = 1'd0;
        end // if (Done_ref)

        // change inputs for next cycle
        
        #85;
        if (!rst && (!Stall)) begin      
        if (n_requests < 1000) begin
            full_random_addr;
        end else if (n_requests == 1000) begin
            Addr = 32'd0; 
            Rd = 1'd0;
            Wr = 1'd0;
            n_requests = n_requests + 1;
            n_replies = n_replies + 1;
            $display("LOG: Done full_random, Requests: %10d, Hits: %10d",
                    n_requests,
                    n_cache_hits );
            n_cache_hits_total = n_cache_hits_total + n_cache_hits;
            n_cache_hits = 0;
        end else if (n_requests == 100) begin
            Addr = 32'd0;
            Rd = 1'd0;
            Wr = 1'd0;
            n_requests = n_requests + 1;
            n_replies = n_replies + 1;
            $display("LOG: Done small_random, Requests: %10d, Hits: %10d",
                    n_requests,
                    n_cache_hits );
            n_cache_hits_total = n_cache_hits_total + n_cache_hits;            
            n_cache_hits = 0;
        end else if (n_requests == 200) begin
            Addr = 32'd0;
            Rd = 1'd0;
            Wr = 1'd0;
            n_requests = n_requests + 1;
            n_replies = n_replies + 1;
            $display("LOG: Done sequential_addr, Requests: %10d, Hits: %10d",
                    n_requests,
                    n_cache_hits );
            n_cache_hits_total = n_cache_hits_total + n_cache_hits;
            n_cache_hits = 0;
        end else if (n_requests < 100) begin
            small_random_addr;
        end else if (n_requests < 200) begin
            seq_addr;
        end else begin
            end_simulation;
        end
        end
    end

    task check_dropped_request;
        begin	
        if (n_replies != n_requests) begin
           if (Rd) begin
              $display("LOG: ReqNum %4d Rd Addr 0x%04x RefValue 0x%04x\n",
                       n_replies, Addr, DataOut_ref);
           end
           if (Wr) begin
              $display("LOG: ReQNum %4d Wr Addr 0x%04x Value 0x%04x\n",
                       n_replies, Addr, DataIn);
           end
           $display("ERROR! Request dropped");
           test_success = 1'b0;               
           n_replies = n_requests;	       
        end            
     end
    endtask
  
    reg [7:0] index = 0;
    task seq_addr;
        begin
            if (!rst && (!Stall)) begin
               check_dropped_request;
               reg_readorwrite = $random % 2;
               if (reg_readorwrite) begin
                  Wr = $random % 2;
                  index = (index < 8)?(index + 1):0;
                  Addr = {18'd0,index,3'd0,2'd0};
                  DataIn = $random % 32'hffff_ffff;
                  Rd = ~Wr;
                  n_requests = n_requests + 1;               
               end else begin
                  Wr = 1'd0;
                  Rd = 1'd0;
               end  // if (reg_readorwrite)
               
            end // if (!Stall)
         end         
    endtask // serial_addr
      
    reg [17:0] tag = 0;
    reg       n_iter  = 1;
    

    task full_random_addr;
        begin
        if (!rst && (!Stall)) begin
            check_dropped_request;
            reg_readorwrite = $random % 2;
            if (reg_readorwrite) begin
                Wr = $random % 2;
                Addr = ($random % 32'hffff) & 16'hFFFC;
                DataIn = $random % 32'hffff;
                Rd = ~Wr;
                n_requests = n_requests + 1;               
            end else begin
                Wr = 1'd0;
                Rd = 1'd0;
            end  // if (reg_readorwrite) 
        end // if (!Stall)
        end
        
    endtask

    task small_random_addr;
        // tag bits are always constant
        // all addresses will fit in cache
        // should generate a lot of cache hits
        begin
        if (!rst && (!Stall)) begin
            check_dropped_request;            
            reg_readorwrite = $random % 2;
            if (reg_readorwrite) begin
                Wr = $random % 2;
                Addr = (($random % 32'hffff) & 16'h07FC) | 16'h6000;
                DataIn = $random % 32'hffff;
                Rd = ~Wr;
                n_requests = n_requests + 1;               
            end else begin
                Wr = 1'd0;
                Rd = 1'd0;
            end  // if (reg_readorwrite) 
        end // if (!Stall)
        end
    endtask

    task end_simulation;
        begin
        $display("LOG: Done Requests: %10d Replies: %10d Hits: %10d",
                    n_requests,
                    n_replies,
                    n_cache_hits_total );
        if (!test_success)  begin
            $display("Test status: FAIL");
        end else begin
            $display("Test status: SUCCESS");
        end
        $finish;
        end
    endtask // end_simulation
endmodule