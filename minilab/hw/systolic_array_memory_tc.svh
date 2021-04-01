`include "systolic_array_tc.svh"
class systolic_array_memory_tc #(parameter BITS_AB=8, parameter DIM=8) extends systolic_array_tc #(.BITS_AB(BITS_AB), .DIM(DIM)); 
   function void dump();
      // display A,B for debugging purposes
      $display("	A	|	B	");
      for(int Row=0;Row<DIM;++Row) begin
         $write(" ");
         for(int Col=0;Col<DIM;++Col) begin
            $write("%4d ",A[Row][Col]);
         end
         $write(" ");
         for(int Col=0;Col<DIM;++Col) begin
            $write("%4d ",B[Row][Col]);
         end
         $write("\n");
      end // for (int Row=0;Row<DIM;++Row)
   endfunction: dump // dump
   
endclass; // systolic_array_memory_tc
