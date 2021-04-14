module alu (A, B, Op, Out);

    input [31:0] A;
    input [31:0] B;
    input Cin;
    input [3:0] Op;
    input invA;
    input invB;
    input sign;
    output [15:0] Out;
    // output Cout;
    output eq, ne, lt, geq;

    always_comb begin
        casex (Op)
            4'b000x: Out = A + B;
            4'b001x: Out = A - B;
            4'b0100: Out = A & B;
            4'b0101: Out = A | B;
            4'b0110: Out = A ^ B;
            4'b0111: Out = ~A;
            4'b1000: begin
                if(B <= 32'd32)
                    Out = A << B[5:0];
                else
                    Out = '0;
            end
            4'b1001: begin
                if(B <= 32'd32)
                    Out = A >> B[5:0];
                else
                    Out = '0;
            end
            4'b1010: begin
                if(B <= 32'd32)
                    Out = A >>> B[5:0];
                else
                    Out = {32{A[31]}};
            end
            default : /* default */;
        endcase
    end

endmodule

