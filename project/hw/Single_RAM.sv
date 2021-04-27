module Single_RAM#(DEPTH = 512, WIDTH = 8)(clk, wr, in, out, addr);
   output logic [WIDTH-1:0] out;
   input [WIDTH-1:0] in;
   input [$clog2(DEPTH)-1:0] addr;
   input wr, clk;
   reg [WIDTH-1:0] mem [DEPTH-1:0];
    always @(posedge clk) begin
        if (wr)
            mem[addr] <= in;
        out <= mem[addr];
   end
endmodule
