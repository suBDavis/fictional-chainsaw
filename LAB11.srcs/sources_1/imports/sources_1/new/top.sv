//////////////////////////////////////////////////////////////////////////////////
//
// Montek Singh
// 10/30/2015 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none

module top #(
    parameter imem_init="sqr_imem.txt",
    parameter dmem_init="sqr_dmem.txt"
)(
    input wire clk, reset
);
   
   wire [31:0] pc, instr, mem_readdata, mem_writedata, mem_addr;
   wire mem_wr;

   mips mips(clk, reset, pc, instr, mem_wr, mem_addr, mem_writedata, mem_readdata);
   imem #(32, 32, 32, imem_init) imem(pc[31:0], instr);
   dmem #(32, 32, 32, dmem_init) dmem(clk, mem_wr, mem_addr, mem_writedata, mem_readdata);

endmodule