module tpuv1
  #(
    parameter BITS_AB=8,
    parameter BITS_C=16,
    parameter DIM=8,
    parameter ADDRW=16,
    parameter DATAW=64
    )
   (
    input clk, rst_n, r_w, // r_w=0 read, =1 write
    input [DATAW-1:0] dataIn,
    output [DATAW-1:0] dataOut,
    input [ADDRW-1:0] addr
   );

//Support logic
logic matMul, en, A_WrEn, C_WrEn;
logic [$clog2(DIM*3-2):0] shiftCounter;
logic [$clog2(DIM)-1:0] Arow_in, Crow_in;
logic signed [BITS_AB-1:0] Aout [DIM-1:0];
logic signed [BITS_AB-1:0] Bout [DIM-1:0];
logic signed [BITS_AB-1:0] Ain [DIM-1:0];
logic signed [BITS_AB-1:0] Bin [DIM-1:0];
logic signed [BITS_C-1:0] Cin [DIM-1:0];
logic signed [BITS_C-1:0] Cout [DIM-1:0];
logic signed [BITS_C-1:0] Data_C_transform [3:0];

genvar i;

//instantiate modules
memA #(.BITS_AB(BITS_AB), .DIM(DIM)) 
				memA_inst(.clk(clk), .rst_n(rst_n), .en(en), .WrEn(A_WrEn), 
				.Ain(Ain), .Arow(Arow_in), .Aout(Aout));

memB #(.BITS_AB(BITS_AB), .DIM(DIM)) 
				memB_inst(.clk(clk), .rst_n(rst_n), .en(en | B_WrEn),  
				.Bin(Bin), .Bout(Bout));

//Depending on row, feed back in {dataIn, Cout} 
systolic_array #(.BITS_AB(BITS_AB), .BITS_C(BITS_C), .DIM(DIM)) 
				arr_inst(.clk(clk), .rst_n(rst_n), .wrEn(C_WrEn), .en(en), 
				.A(Aout), .B(Bout), .Cin(Cin), .Crow(Crow_in), .Cout(Cout));

//Control signals
assign matMul = r_w & {addr[10]}; //write to 0x0400
assign A_WrEn = r_w & ({addr[9:8]} == 2'b01);
assign B_WrEn = r_w & ({addr[9:8]} == 2'b10);
assign C_WrEn = r_w & ({addr[9:8]} == 2'b11);

assign Arow_in = {addr[5:3]};
assign Crow_in = {addr[6:4]};

generate
	for(i = 0; i<8; i++)begin
		assign Ain[i] = A_WrEn ? dataIn[(8 * (i+1))-1 : (8 *i)] : 8'h00; 
		assign Bin[i] = B_WrEn ? dataIn[(8 * (i+1))-1 : (8 *i)] : 8'h00; 
	end
	for(i = 0; i<4; i++)begin
		assign dataOut[(16 * (i+1))-1 : (16 *i)] = addr[3] ? Cout[i+4] : Cout[i];
		assign Data_C_transform[i] = dataIn[(16 * (i+1))-1 : (16 *i)];
	end
endgenerate

//Load upper half: Load lower half
assign Cin = addr[3] ? {Data_C_transform, Cout[3:0]} : {Cout[7:4], Data_C_transform}; 

//DIM*3-2 enable logic
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		shiftCounter <= 0;
		en <= 0;
	end else if(shiftCounter == (DIM*3-2)) begin //Calculation finished
		en <= 0;
		shiftCounter <= 0;
	end else if(matMul || en) begin
		shiftCounter <= shiftCounter + 1;
		en <= 1;
	end else begin
		shiftCounter <= shiftCounter;
		en <= en;
	end
end

endmodule
