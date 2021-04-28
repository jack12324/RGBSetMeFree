interface cache_if();
    logic en; 
    logic clk; 
    logic rst_n;
    logic [7:0] index;
    logic [5:0] offset;
    logic comp;
    logic wr;
    logic [17:0] tag_in;
    logic [31:0] data_in;
    logic valid_in;

    logic hit;
    logic dirty;
    logic [17:0] tag_out;
    logic [31:0] data_out;
    logic valid;
 
    modport cache (
    input en, clk, rst_n, index, offset, comp, wr, tag_in, data_in, valid_in,
    output hit, dirty, tag_out, data_out, valid
    );
    
    modport control (
    input hit, dirty, tag_out, data_out, valid,
    output en, clk, rst_n, index, offset, comp, wr, tag_in, data_in, valid_in);
endinterface //cache_if
