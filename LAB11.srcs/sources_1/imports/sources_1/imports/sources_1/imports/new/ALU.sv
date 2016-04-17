`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/29/2016 10:59:20 AM
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU #(parameter N=32)(
    input wire [N-1:0] A,B,
    output wire [N-1:0] R,
    input wire [4:0] ALUfn,
    output wire FlagZ
    );
    //define the flags for Neg, Carry, Overflow
    wire FlagN, FlagC, FlagV;
    
    wire subtract, bool1, bool0, shft, math;
    assign {subtract, bool1, bool0, shft, math} = ALUfn[4:0];
    
    //the outputs
    wire [N-1:0] addsubResult, shiftResult, logicalResult;
    wire comparatorResult;
    
    addsub #(N) AS(A, B, subtract, addsubResult, FlagN, FlagC, FlagV);
    shifter #(N) S(B, A[$clog2(N)-1:0], !bool1, !bool0, shiftResult);
    logical #(N) L(A, B, {bool1, bool0}, logicalResult);
    comparator C(FlagN, FlagC, FlagV, bool0, comparatorResult);
    
    assign R = (~shft & math) ? addsubResult :
               (shft & ~math) ? shiftResult :
               (~shft & ~math)? logicalResult : 
               (shft & math) ? { {(N-1) {1'b0}} , comparatorResult }: 
               0;
    
    assign FlagZ = !R;

endmodule
