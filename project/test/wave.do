onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {Top Level TB} -radix hexadecimal /mem_system_tb/Wr
add wave -noupdate -expand -group {Top Level TB} -radix hexadecimal /mem_system_tb/Rd
add wave -noupdate -expand -group {Top Level TB} -radix hexadecimal /mem_system_tb/data_out
add wave -noupdate -expand -group {Top Level TB} -radix hexadecimal /mem_system_tb/Done
add wave -noupdate -expand -group {Top Level TB} -radix hexadecimal /mem_system_tb/CacheHit
add wave -noupdate -expand -group {Top Level TB} -radix hexadecimal /mem_system_tb/Data_out_ref
add wave -noupdate -expand -group {Top Level TB} -radix hexadecimal /mem_system_tb/DataIn_host
add wave -noupdate -expand -group {Top Level TB} -radix hexadecimal /mem_system_tb/DataOut_host
add wave -noupdate -expand -group {Top Level TB} -radix hexadecimal /mem_system_tb/tx_done_host
add wave -noupdate -expand -group {Top Level TB} -radix hexadecimal /mem_system_tb/rd_valid_host
add wave -noupdate -expand -group {Top Level TB} -radix hexadecimal /mem_system_tb/n_requests
add wave -noupdate -expand -group {Top Level TB} -radix hexadecimal /mem_system_tb/n_replies
add wave -noupdate -expand -group {Top Level TB} -radix hexadecimal /mem_system_tb/n_cache_hits
add wave -noupdate -expand -group {Top Level TB} -radix hexadecimal /mem_system_tb/n_cache_hits_total
add wave -noupdate -expand -group {Top Level TB} -radix hexadecimal /mem_system_tb/Stall
add wave -noupdate -expand -group {Mem System} -radix hexadecimal /mem_system_tb/mem_dut/addr
add wave -noupdate -expand -group {Mem System} -radix hexadecimal /mem_system_tb/mem_dut/data_in
add wave -noupdate -expand -group {Mem System} -radix hexadecimal /mem_system_tb/mem_dut/data_out
add wave -noupdate -group Controller -radix hexadecimal /mem_system_tb/mem_dut/cache_ctrl/DataIn_mem
add wave -noupdate -group Controller -radix hexadecimal /mem_system_tb/mem_dut/cache_ctrl/DataIn_cache
add wave -noupdate -group Controller -radix hexadecimal /mem_system_tb/mem_dut/cache_ctrl/DataOut_mem
add wave -noupdate -group Controller -radix hexadecimal /mem_system_tb/mem_dut/cache_ctrl/DataOut_cache
add wave -noupdate -group Controller -radix hexadecimal /mem_system_tb/mem_dut/cache_ctrl/AddrIn_mem
add wave -noupdate -group Controller -radix hexadecimal /mem_system_tb/mem_dut/cache_ctrl/AddrOut_host
add wave -noupdate -group Controller -radix hexadecimal /mem_system_tb/mem_dut/cache_ctrl/op_host
add wave -noupdate -group Controller -radix hexadecimal /mem_system_tb/mem_dut/cache_ctrl/tag_in
add wave -noupdate -group Controller -radix hexadecimal /mem_system_tb/mem_dut/cache_ctrl/stall
add wave -noupdate -group Controller -radix hexadecimal /mem_system_tb/mem_dut/cache_ctrl/done
add wave -noupdate -group Controller -radix hexadecimal /mem_system_tb/mem_dut/cache_ctrl/FloppedDataIn
add wave -noupdate -group Controller -radix hexadecimal /mem_system_tb/mem_dut/cache_ctrl/FloppedAddressIn
add wave -noupdate -group Controller -radix hexadecimal /mem_system_tb/mem_dut/cache_ctrl/Rd
add wave -noupdate -group Controller /mem_system_tb/mem_dut/cache_ctrl/currentState
add wave -noupdate -group Controller /mem_system_tb/mem_dut/cache_ctrl/nextState
add wave -noupdate -group Controller /mem_system_tb/mem_dut/cache_ctrl/comp
add wave -noupdate -group Controller /mem_system_tb/mem_dut/cache_ctrl/wr_cache
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/WORD_SIZE
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/CL_SIZE_WIDTH
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/ADDR_WIDTH
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/clk
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/rst_n
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/en
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/Wr_in
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/Rd_in
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/tx_done_host
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/rd_valid_host
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/DataIn_host
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/cache_line_in
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/DataOut_host
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/cache_line_out
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/DataIn_mem
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/DataIn_cache
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/DataOut_mem
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/DataOut_cache
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/AddrIn_mem
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/AddrOut_host
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/op_host
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/tag_in
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/validIn_cache
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/hit_in
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/dirty_in
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/replaceLine
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/index
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/offset
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/comp
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/wr_cache
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/stall
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/done
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/hit_out
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/cache_en
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -childformat {{{/mem_system_tb/mem_dut/cache_ctrl/tag_out[17]} -radix hexadecimal} {{/mem_system_tb/mem_dut/cache_ctrl/tag_out[16]} -radix hexadecimal} {{/mem_system_tb/mem_dut/cache_ctrl/tag_out[15]} -radix hexadecimal} {{/mem_system_tb/mem_dut/cache_ctrl/tag_out[14]} -radix hexadecimal} {{/mem_system_tb/mem_dut/cache_ctrl/tag_out[13]} -radix hexadecimal} {{/mem_system_tb/mem_dut/cache_ctrl/tag_out[12]} -radix hexadecimal} {{/mem_system_tb/mem_dut/cache_ctrl/tag_out[11]} -radix hexadecimal} {{/mem_system_tb/mem_dut/cache_ctrl/tag_out[10]} -radix hexadecimal} {{/mem_system_tb/mem_dut/cache_ctrl/tag_out[9]} -radix hexadecimal} {{/mem_system_tb/mem_dut/cache_ctrl/tag_out[8]} -radix hexadecimal} {{/mem_system_tb/mem_dut/cache_ctrl/tag_out[7]} -radix hexadecimal} {{/mem_system_tb/mem_dut/cache_ctrl/tag_out[6]} -radix hexadecimal} {{/mem_system_tb/mem_dut/cache_ctrl/tag_out[5]} -radix hexadecimal} {{/mem_system_tb/mem_dut/cache_ctrl/tag_out[4]} -radix hexadecimal} {{/mem_system_tb/mem_dut/cache_ctrl/tag_out[3]} -radix hexadecimal} {{/mem_system_tb/mem_dut/cache_ctrl/tag_out[2]} -radix hexadecimal} {{/mem_system_tb/mem_dut/cache_ctrl/tag_out[1]} -radix hexadecimal} {{/mem_system_tb/mem_dut/cache_ctrl/tag_out[0]} -radix hexadecimal}} -radixshowbase 1 -subitemconfig {{/mem_system_tb/mem_dut/cache_ctrl/tag_out[17]} {-height 15 -radix hexadecimal -radixshowbase 1} {/mem_system_tb/mem_dut/cache_ctrl/tag_out[16]} {-height 15 -radix hexadecimal -radixshowbase 1} {/mem_system_tb/mem_dut/cache_ctrl/tag_out[15]} {-height 15 -radix hexadecimal -radixshowbase 1} {/mem_system_tb/mem_dut/cache_ctrl/tag_out[14]} {-height 15 -radix hexadecimal -radixshowbase 1} {/mem_system_tb/mem_dut/cache_ctrl/tag_out[13]} {-height 15 -radix hexadecimal -radixshowbase 1} {/mem_system_tb/mem_dut/cache_ctrl/tag_out[12]} {-height 15 -radix hexadecimal -radixshowbase 1} {/mem_system_tb/mem_dut/cache_ctrl/tag_out[11]} {-height 15 -radix hexadecimal -radixshowbase 1} {/mem_system_tb/mem_dut/cache_ctrl/tag_out[10]} {-height 15 -radix hexadecimal -radixshowbase 1} {/mem_system_tb/mem_dut/cache_ctrl/tag_out[9]} {-height 15 -radix hexadecimal -radixshowbase 1} {/mem_system_tb/mem_dut/cache_ctrl/tag_out[8]} {-height 15 -radix hexadecimal -radixshowbase 1} {/mem_system_tb/mem_dut/cache_ctrl/tag_out[7]} {-height 15 -radix hexadecimal -radixshowbase 1} {/mem_system_tb/mem_dut/cache_ctrl/tag_out[6]} {-height 15 -radix hexadecimal -radixshowbase 1} {/mem_system_tb/mem_dut/cache_ctrl/tag_out[5]} {-height 15 -radix hexadecimal -radixshowbase 1} {/mem_system_tb/mem_dut/cache_ctrl/tag_out[4]} {-height 15 -radix hexadecimal -radixshowbase 1} {/mem_system_tb/mem_dut/cache_ctrl/tag_out[3]} {-height 15 -radix hexadecimal -radixshowbase 1} {/mem_system_tb/mem_dut/cache_ctrl/tag_out[2]} {-height 15 -radix hexadecimal -radixshowbase 1} {/mem_system_tb/mem_dut/cache_ctrl/tag_out[1]} {-height 15 -radix hexadecimal -radixshowbase 1} {/mem_system_tb/mem_dut/cache_ctrl/tag_out[0]} {-height 15 -radix hexadecimal -radixshowbase 1}} /mem_system_tb/mem_dut/cache_ctrl/tag_out
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/currentState
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/nextState
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/FloppedDataIn
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/FloppedAddressIn
add wave -noupdate -expand -group {All Cache Control} -radix hexadecimal -radixshowbase 1 /mem_system_tb/mem_dut/cache_ctrl/Rd
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/en
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/clk
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/rst_n
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/index
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/offset
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/comp
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/wr
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/tag_in
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/data_in
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/valid_in
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/hit
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/dirty
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/tag_out
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/data_out
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/valid
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/replaceLine
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/cl_in
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/cl_out
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/w0
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/w1
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/w2
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/w3
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/w4
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/w5
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/w6
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/w7
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/w8
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/w9
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/w10
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/w11
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/w12
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/w13
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/w14
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/w15
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/go
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/match
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/wr_word0
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/wr_word1
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/wr_word2
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/wr_word3
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/wr_word4
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/wr_word5
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/wr_word6
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/wr_word7
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/wr_word8
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/wr_word9
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/wr_word10
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/wr_word11
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/wr_word12
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/wr_word13
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/wr_word14
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/wr_word15
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/wr_dirty
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/wr_tag
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/wr_valid
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/dirty_in
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/dirtybit
add wave -noupdate -expand -group {All Cache} -radix hexadecimal /mem_system_tb/mem_dut/c0/validbit
add wave -noupdate -group {Datas Addr Hit and Done} /mem_system_tb/Addr
add wave -noupdate -group {Datas Addr Hit and Done} /mem_system_tb/DataIn
add wave -noupdate -expand -group {CL Replace Data_Ins} -radix hexadecimal -childformat {{{/mem_system_tb/mem_dut/c0/data_in_i[15]} -radix hexadecimal} {{/mem_system_tb/mem_dut/c0/data_in_i[14]} -radix hexadecimal} {{/mem_system_tb/mem_dut/c0/data_in_i[13]} -radix hexadecimal} {{/mem_system_tb/mem_dut/c0/data_in_i[12]} -radix hexadecimal} {{/mem_system_tb/mem_dut/c0/data_in_i[11]} -radix hexadecimal} {{/mem_system_tb/mem_dut/c0/data_in_i[10]} -radix hexadecimal} {{/mem_system_tb/mem_dut/c0/data_in_i[9]} -radix hexadecimal} {{/mem_system_tb/mem_dut/c0/data_in_i[8]} -radix hexadecimal} {{/mem_system_tb/mem_dut/c0/data_in_i[7]} -radix hexadecimal} {{/mem_system_tb/mem_dut/c0/data_in_i[6]} -radix hexadecimal} {{/mem_system_tb/mem_dut/c0/data_in_i[5]} -radix hexadecimal} {{/mem_system_tb/mem_dut/c0/data_in_i[4]} -radix hexadecimal} {{/mem_system_tb/mem_dut/c0/data_in_i[3]} -radix hexadecimal} {{/mem_system_tb/mem_dut/c0/data_in_i[2]} -radix hexadecimal} {{/mem_system_tb/mem_dut/c0/data_in_i[1]} -radix hexadecimal} {{/mem_system_tb/mem_dut/c0/data_in_i[0]} -radix hexadecimal}} -expand -subitemconfig {{/mem_system_tb/mem_dut/c0/data_in_i[15]} {-height 15 -radix hexadecimal} {/mem_system_tb/mem_dut/c0/data_in_i[14]} {-height 15 -radix hexadecimal} {/mem_system_tb/mem_dut/c0/data_in_i[13]} {-height 15 -radix hexadecimal} {/mem_system_tb/mem_dut/c0/data_in_i[12]} {-height 15 -radix hexadecimal} {/mem_system_tb/mem_dut/c0/data_in_i[11]} {-height 15 -radix hexadecimal} {/mem_system_tb/mem_dut/c0/data_in_i[10]} {-height 15 -radix hexadecimal} {/mem_system_tb/mem_dut/c0/data_in_i[9]} {-height 15 -radix hexadecimal} {/mem_system_tb/mem_dut/c0/data_in_i[8]} {-height 15 -radix hexadecimal} {/mem_system_tb/mem_dut/c0/data_in_i[7]} {-height 15 -radix hexadecimal} {/mem_system_tb/mem_dut/c0/data_in_i[6]} {-height 15 -radix hexadecimal} {/mem_system_tb/mem_dut/c0/data_in_i[5]} {-height 15 -radix hexadecimal} {/mem_system_tb/mem_dut/c0/data_in_i[4]} {-height 15 -radix hexadecimal} {/mem_system_tb/mem_dut/c0/data_in_i[3]} {-height 15 -radix hexadecimal} {/mem_system_tb/mem_dut/c0/data_in_i[2]} {-height 15 -radix hexadecimal} {/mem_system_tb/mem_dut/c0/data_in_i[1]} {-height 15 -radix hexadecimal} {/mem_system_tb/mem_dut/c0/data_in_i[0]} {-height 15 -radix hexadecimal}} /mem_system_tb/mem_dut/c0/data_in_i
add wave -noupdate -expand -group Cache_RAM -radix hexadecimal /mem_system_tb/mem_dut/c0/mem_w0/rst_n
add wave -noupdate -expand -group Cache_RAM /mem_system_tb/mem_dut/c0/mem_w0/mem
add wave -noupdate -expand -group Cache_RAM -radix hexadecimal /mem_system_tb/mem_dut/c0/mem_w0/clk
add wave -noupdate -expand -group Cache_RAM -radix hexadecimal /mem_system_tb/mem_dut/c0/mem_w0/addr
add wave -noupdate -expand -group Cache_RAM -radix hexadecimal /mem_system_tb/mem_dut/c0/mem_w0/d
add wave -noupdate -expand -group Cache_RAM -radix hexadecimal /mem_system_tb/mem_dut/c0/mem_w0/WrEn
add wave -noupdate -expand -group Cache_RAM -radix hexadecimal /mem_system_tb/mem_dut/c0/mem_w0/q
add wave -noupdate -expand -group Cache_RAM -radix hexadecimal /mem_system_tb/mem_dut/c0/mem_w0/i
add wave -noupdate -expand -group Cache_RAM -radix hexadecimal /mem_system_tb/mem_dut/c0/mem_w1/rst_n
add wave -noupdate -expand -group Cache_RAM -radix hexadecimal /mem_system_tb/mem_dut/c0/mem_w1/clk
add wave -noupdate -expand -group Cache_RAM -radix hexadecimal /mem_system_tb/mem_dut/c0/mem_w1/addr
add wave -noupdate -expand -group Cache_RAM -radix hexadecimal /mem_system_tb/mem_dut/c0/mem_w1/d
add wave -noupdate -expand -group Cache_RAM -radix hexadecimal /mem_system_tb/mem_dut/c0/mem_w1/WrEn
add wave -noupdate -expand -group Cache_RAM -radix hexadecimal /mem_system_tb/mem_dut/c0/mem_w1/q
add wave -noupdate -expand -group Cache_RAM -radix hexadecimal /mem_system_tb/mem_dut/c0/mem_w1/i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {372 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {240 ps} {514 ps}
