// 1024 bytes (1kB) Cache Module
// 256 Line Cache Module
// Each Line contains 4 Words = 16 Bytes [ 4 * 32 bits = 4 * 4 * 8 bits]
// 256 * 4 = 1024 Bytes
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
//

module fpu_cache (
    cache_if.cache cintf
);
//NOTE: Bits 1:0 of Offset must always be 0 for automatic word alignment!

logic [31:0]       w0, w1, w2, w3;
assign            go = cintf.en & cintf.rst_n;  
assign            match = (cintf.tag_in == cintf.tag_out);

assign            wr_word0 = go & cintf.wr & ~cintf.offset[3] & ~cintf.offset[2] & (match | ~cintf.comp);
assign            wr_word1 = go & cintf.wr & ~cintf.offset[3] &  cintf.offset[2] & (match | ~cintf.comp);
assign            wr_word2 = go & cintf.wr &  cintf.offset[3] & ~cintf.offset[2] & (match | ~cintf.comp);
assign            wr_word3 = go & cintf.wr &  cintf.offset[3] &  cintf.offset[2] & (match | ~cintf.comp);

assign            wr_dirty = go & cintf.wr & (match | ~cintf.comp);
assign            wr_tag   = go & cintf.wr & ~cintf.comp;
assign            wr_valid = go & cintf.wr & ~cintf.comp;
assign            dirty_in = cintf.comp;  // a compare-and-wr sets dirty; a cache-fill clears it

//Create Array of 256 lines, w represents the module of each word
ram_block #(32) mem_w0 (.q(w0), .index(cintf.index), .d(cintf.data_in),  .WrEn(wr_word0), .clk(cintf.clk), .rst_n(cintf.rst_n));
ram_block #(32) mem_w1 (.q(w1), .index(cintf.index), .d(cintf.data_in),  .WrEn(wr_word1), .clk(cintf.clk), .rst_n(cintf.rst_n));
ram_block #(32) mem_w2 (.q(w2), .index(cintf.index), .d(cintf.data_in),  .WrEn(wr_word2), .clk(cintf.clk), .rst_n(cintf.rst_n));
ram_block #(32) mem_w3 (.q(w3), .index(cintf.index), .d(cintf.data_in),  .WrEn(wr_word3), .clk(cintf.clk), .rst_n(cintf.rst_n));

ram_block #(20) mem_tag (.q(cintf.tag_out), .index(cintf.index), .d(cintf.tag_in),  .WrEn(wr_tag), .clk(cintf.clk), .rst_n(cintf.rst_n));
ram_block #( 1) mem_dr (.q(dirtybit), .index(cintf.index), .d(cintf.dirty_in),  .WrEn(wr_dirty), .clk(cintf.clk), .rst_n(cintf.rst_n));
ram_block #( 1) mem_vl (.q(validbit), .index(cintf.index), .d(cintf.valid_in),  .WrEn(wr_valid), .clk(cintf.clk), .rst_n(cintf.rst_n));

assign            cintf.hit = go & match;
assign            cintf.dirty = go & (~cintf.wr | (cintf.comp & ~match)) & dirtybit;
assign            cintf.data_out = (cintf.wr | ~go)? 'b0 : 
                    cintf.offset[3] ? (cintf.offset[2] ? w3 : w2) : 
                        (cintf.offset[2] ? w1 : w0) ;
assign            cintf.valid = go & validbit & (~cintf.wr | cintf.comp);

endmodule