/* 
    Perfect 64kB memory for output verification of Cache
    ECE 554
    Author: Mayukh Misra
*/

module mem_system_ref (
    // Outputs
    DataOut, Done, Stall, CacheHit, 
    // Inputs
    Addr_in, DataIn, Rd, Wr, clk, rst_n
    );
    
    input [31:0] Addr_in;
    input [31:0] DataIn;
    input        Rd;
    input        Wr;
    input        clk;
    input        rst_n;
    
    
    output [31:0] DataOut;
    output Done;
    output Stall;
    output CacheHit;
 
    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    // End of automatics
 
    //Test on only 16 bits of addresses, because 32 bits is too large
    logic [7:0]           mem[0:65535];
    logic                 loaded;
    integer             i;
 
    logic [31:0] Addr;    //Word aligned address
    logic [31:0] DataOut;
    
    assign Addr = {Addr_in[31:2], 2'b0};
    initial begin
       loaded = 0;
       for (i = 0; i < 65536; i=i+1) begin
          mem[i] = 0;
       end
    end
 
    always @(*) begin
       if (~rst_n) begin
          if (!loaded) begin
             $readmemh("loadfile_all.img", mem);
             loaded = 1;
          end
       end else begin
          if (Wr) begin
            {mem[Addr], mem[Addr+8'd1], mem[Addr + 8'd2], mem[Addr + 8'd3]} = DataIn;
          end
          if (Rd) begin
             DataOut = {mem[Addr], mem[Addr+8'd1], mem[Addr + 8'd2], mem[Addr + 8'd3]};    //Little Endian or Big Endian would affect this. This is little endian
          end
          loaded = 1;
       end
    end 
 
    assign Done = (Rd|Wr);
    assign Stall = 1'b0;
    assign CacheHit = 1'b0;
       
 endmodule // mem_system_ref
 