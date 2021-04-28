
//
// Cache module for CS/ECE 552 Project
// Written by Andy Phelps
// 4 May 2006
//
//  Modified by Derek Hower
//  30 Oct 2006
//   Changed to 4-word lines, byte addressable
//
//  
// Modified for ECE 554 Project :: RGBSetMeFree (Spring 2021)
//  by Mayukh Misra
//  4096 bytes (4kB) Cache Module
//  256 Lines Cache Module
//  Each Line contains 16 Words = 64 Bytes 
//  1 Host DMA Cache Line = 1 CPU Cache line
//  256 * 16 = 4096 Bytes
//

module cpu_cache (
    cache_if.cache cintf,
    input logic replaceLine,   //Replace entire cache line with cl_in
    input logic [511:0] cl_in,  //Used for direct read from mem_ctrl
    output logic [511:0] cl_out //Used for direct writeback to mem_ctrl
);
//NOTE: Bits 1:0 of Offset must always be 0 for automatic word alignment!

logic [31:0]       w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15;
assign            go = cintf.en & cintf.rst_n;  
assign            match = (cintf.tag_in == cintf.tag_out);
assign            cl_out = {w15, w14, w13, w12, w11, w10, w9, w8, w7, w6, w5, w4, w3, w2, w1, w0};  //TODO:: Verify the Endianness

assign            wr_word0 = go & cintf.wr  & ~cintf.offset[5] & ~cintf.offset[4] & ~cintf.offset[3] & ~cintf.offset[2] & (match | ~cintf.comp);
assign            wr_word1 = go & cintf.wr  & ~cintf.offset[5] & ~cintf.offset[4] & ~cintf.offset[3] & cintf.offset[2] & (match | ~cintf.comp);
assign            wr_word2 = go & cintf.wr  & ~cintf.offset[5] & ~cintf.offset[4] & cintf.offset[3] & ~cintf.offset[2] & (match | ~cintf.comp);
assign            wr_word3 = go & cintf.wr  & ~cintf.offset[5] & ~cintf.offset[4] & cintf.offset[3] & cintf.offset[2] & (match | ~cintf.comp);

assign            wr_word4 = go & cintf.wr  & ~cintf.offset[5] & cintf.offset[4] & ~cintf.offset[3] & ~cintf.offset[2] & (match | ~cintf.comp);
assign            wr_word5 = go & cintf.wr  & ~cintf.offset[5] & cintf.offset[4] & ~cintf.offset[3] & cintf.offset[2] & (match | ~cintf.comp);
assign            wr_word6 = go & cintf.wr  & ~cintf.offset[5] & cintf.offset[4] & cintf.offset[3] & ~cintf.offset[2] & (match | ~cintf.comp);
assign            wr_word7 = go & cintf.wr  & ~cintf.offset[5] & cintf.offset[4] & ~cintf.offset[3] & cintf.offset[2] & (match | ~cintf.comp);

assign            wr_word8 = go & cintf.wr  & cintf.offset[5] & ~cintf.offset[4] & ~cintf.offset[3] & ~cintf.offset[2] & (match | ~cintf.comp);
assign            wr_word9 = go & cintf.wr  & cintf.offset[5] & ~cintf.offset[4] & ~cintf.offset[3] & cintf.offset[2] & (match | ~cintf.comp);
assign            wr_word10 = go & cintf.wr  & cintf.offset[5] & ~cintf.offset[4] & cintf.offset[3] & ~cintf.offset[2] & (match | ~cintf.comp);
assign            wr_word11 = go & cintf.wr  & cintf.offset[5] & ~cintf.offset[4] & cintf.offset[3] & cintf.offset[2] & (match | ~cintf.comp);

assign            wr_word12 = go & cintf.wr  & cintf.offset[5] & cintf.offset[4] & ~cintf.offset[3] & ~cintf.offset[2] & (match | ~cintf.comp);
assign            wr_word13 = go & cintf.wr  & cintf.offset[5] & cintf.offset[4] & ~cintf.offset[3] & cintf.offset[2] & (match | ~cintf.comp);
assign            wr_word14 = go & cintf.wr  & cintf.offset[5] & cintf.offset[4] & cintf.offset[3] & ~cintf.offset[2] & (match | ~cintf.comp);
assign            wr_word15 = go & cintf.wr  & cintf.offset[5] & cintf.offset[4] & cintf.offset[3] & cintf.offset[2] & (match | ~cintf.comp);


assign            wr_dirty = go & cintf.wr & (match | ~cintf.comp);
assign            wr_tag   = go & cintf.wr & ~cintf.comp;
assign            wr_valid = go & cintf.wr & ~cintf.comp;
assign            dirty_in = cintf.comp;  // a compare-and-wr sets dirty; a cache-fill clears it

//Create Array of 256 lines, w represents the module of each word
ram_block #(32) mem_w0 (.q(w0), .index(cintf.index), .d(cintf.data_in),  .WrEn(wr_word0), .clk(cintf.clk), .rst_n(cintf.rst_n));
ram_block #(32) mem_w1 (.q(w1), .index(cintf.index), .d(cintf.data_in),  .WrEn(wr_word1), .clk(cintf.clk), .rst_n(cintf.rst_n));
ram_block #(32) mem_w2 (.q(w2), .index(cintf.index), .d(cintf.data_in),  .WrEn(wr_word2), .clk(cintf.clk), .rst_n(cintf.rst_n));
ram_block #(32) mem_w3 (.q(w3), .index(cintf.index), .d(cintf.data_in),  .WrEn(wr_word3), .clk(cintf.clk), .rst_n(cintf.rst_n));

ram_block #(32) mem_w4 (.q(w4), .index(cintf.index), .d(cintf.data_in),  .WrEn(wr_word4), .clk(cintf.clk), .rst_n(cintf.rst_n));
ram_block #(32) mem_w5 (.q(w5), .index(cintf.index), .d(cintf.data_in),  .WrEn(wr_word5), .clk(cintf.clk), .rst_n(cintf.rst_n));
ram_block #(32) mem_w6 (.q(w6), .index(cintf.index), .d(cintf.data_in),  .WrEn(wr_word6), .clk(cintf.clk), .rst_n(cintf.rst_n));
ram_block #(32) mem_w7 (.q(w7), .index(cintf.index), .d(cintf.data_in),  .WrEn(wr_word7), .clk(cintf.clk), .rst_n(cintf.rst_n));

ram_block #(32) mem_w8 (.q(w8), .index(cintf.index), .d(cintf.data_in),  .WrEn(wr_word8), .clk(cintf.clk), .rst_n(cintf.rst_n));
ram_block #(32) mem_w9 (.q(w9), .index(cintf.index), .d(cintf.data_in),  .WrEn(wr_word9), .clk(cintf.clk), .rst_n(cintf.rst_n));
ram_block #(32) mem_w10 (.q(w10), .index(cintf.index), .d(cintf.data_in),  .WrEn(wr_word10), .clk(cintf.clk), .rst_n(cintf.rst_n));
ram_block #(32) mem_w11 (.q(w11), .index(cintf.index), .d(cintf.data_in),  .WrEn(wr_word11), .clk(cintf.clk), .rst_n(cintf.rst_n));

ram_block #(32) mem_w12 (.q(w12), .index(cintf.index), .d(cintf.data_in),  .WrEn(wr_word12), .clk(cintf.clk), .rst_n(cintf.rst_n));
ram_block #(32) mem_w13 (.q(w13), .index(cintf.index), .d(cintf.data_in),  .WrEn(wr_word13), .clk(cintf.clk), .rst_n(cintf.rst_n));
ram_block #(32) mem_w14 (.q(w14), .index(cintf.index), .d(cintf.data_in),  .WrEn(wr_word14), .clk(cintf.clk), .rst_n(cintf.rst_n));
ram_block #(32) mem_w15 (.q(w15), .index(cintf.index), .d(cintf.data_in),  .WrEn(wr_word15), .clk(cintf.clk), .rst_n(cintf.rst_n));

ram_block #(18) mem_tag (.q(cintf.tag_out), .index(cintf.index), .d(cintf.tag_in),  .WrEn(wr_tag), .clk(cintf.clk), .rst_n(cintf.rst_n));
ram_block #( 1) mem_dr (.q(dirtybit), .index(cintf.index), .d(cintf.dirty_in),  .WrEn(wr_dirty), .clk(cintf.clk), .rst_n(cintf.rst_n));
ram_block #( 1) mem_vl (.q(validbit), .index(cintf.index), .d(cintf.valid_in),  .WrEn(wr_valid), .clk(cintf.clk), .rst_n(cintf.rst_n));

assign            cintf.hit = go & match;
assign            cintf.dirty = go & (~cintf.wr | (cintf.comp & ~match)) & dirtybit;


assign            cintf.valid = go & validbit & (~cintf.wr | cintf.comp);

always_comb begin 
    case (cintf.offset[5:2])
        4'd0: cintf.data_out = w0;
        4'd1: cintf.data_out = w1;
        4'd2: cintf.data_out = w2;
        4'd3: cintf.data_out = w3;

        4'd4: cintf.data_out = w4;
        4'd5: cintf.data_out = w5;
        4'd6: cintf.data_out = w6;
        4'd7: cintf.data_out = w7;

        4'd8: cintf.data_out = w8;
        4'd9: cintf.data_out = w9;
        4'd10: cintf.data_out = w10;
        4'd11: cintf.data_out = w11;

        4'd12: cintf.data_out = w12;
        4'd13: cintf.data_out = w13;
        4'd14: cintf.data_out = w14;
        4'd15: cintf.data_out = w15;
    endcase
end

endmodule