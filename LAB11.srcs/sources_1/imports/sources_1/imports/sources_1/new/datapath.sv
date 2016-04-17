`timescale 1ns / 1ps
`default_nettype none

//   datapath #(5, 32, 32) dp(.clk(clk), .reset(reset), 
//                  .pc(pc), .instr(instr),
//                  .pcsel(pcsel), .wasel(wasel[1:0]), .sext(sext), .bsel(bsel), 
//                  .wdsel(wdsel), .alufn(alufn), .werf(werf), .asel(asel),
//                  .Z(Z), .mem_addr(mem_addr), .mem_writedata(mem_writedata), .mem_readdata(mem_readdata));

module datapath #(
    parameter Abits = 5, //number of address bits
    parameter Dbits = 32, //number of bits on the memory wires.
    parameter Nloc = 32  //number of memory locations.
    )(
    input wire clk,
    input wire reset,
    output logic [Dbits-1:0] pc = 32'b0, 
    input wire [Dbits-1:0] instr,
    input wire [1:0] pcsel, wdsel, wasel, asel,
    input wire sext, bsel, dmem_wr, werf,
    //input wire RegWrite,
    //input wire [Abits-1:0] ReadAddr1, ReadAddr2, WriteAddr, 
    input wire [4:0] alufn, 
    //input wire [Dbits-1:0] WriteData, 
    //output wire [Dbits-1:0] ReadData1, ReadData2,
    //    output wire [Dbits-1:0] alu_result,
    output wire Z, 
    output logic [Dbits-1:0] mem_addr,
    output logic [Dbits-1:0] mem_writedata,
    input wire [Dbits-1:0] mem_readdata
    );
//    wire [31:0] ReadData1      =uut.mips.dp.ReadData1;       // Reg[rs]
//    wire [31:0] ReadData2      =uut.mips.dp.ReadData2;       // Reg[rt]
//    wire [31:0] alu_result     =uut.mips.dp.alu_result;      // ALU's output
//    wire [4:0]  reg_writeaddr  =uut.mips.dp.reg_writeaddr;   // destination register
//    wire [31:0] reg_writedata  =uut.mips.dp.reg_writedata;   // write data for register file
//    wire [31:0] signImm        =uut.mips.dp.signImm;         // sign-/zero-extended immediate
//    wire [31:0] aluA           =uut.mips.dp.aluA;            // operand A for ALU
//    wire [31:0] aluB           =uut.mips.dp.aluB; 
    
    logic [Dbits-1:0] pcPlus4;
    logic [Abits-1:0] RA1, RA2;
    logic [Abits-1:0] reg_writeaddr; //reg_write_address
    logic [Dbits-1:0] reg_writedata;
    logic [Dbits-1:0] ReadData1, ReadData2;
    
    logic [Dbits-1:0] aluA, aluB;
    logic [Dbits-1:0] alu_result;
    logic [Dbits-1:0] signImm;
    logic [Dbits-1:0] JT, BT, newPC;

    
    /*
     * Deal with the Program Counter on each clock edge
     *
     */
     
    always_ff @(posedge clk) begin
        pc <= reset ? 0 : newPC;
    end
    
    //PC plus 4
    assign pcPlus4 = pc + 4;
    
    //newPC mux
    always_comb
        case (pcsel)
            0: newPC <= pcPlus4;
            1: newPC <= BT;
            2: newPC <= { pc[31:28], instr[25:0], 2'b0 };
            3: newPC <= JT;
            default: newPC <= 32'bx;
        endcase
    
    /*
     * Register File Inputs
     *
     */
    
    //start with the inputs to the register file.
    assign RA1 = instr[25:21];
    assign RA2 = instr[20:16];
    
    //Write Address assign
    always_comb
        case (wasel)
            0: reg_writeaddr <= instr[15:11];
            1: reg_writeaddr <= instr[20:16];
            2: reg_writeaddr <= 5'b11111; //31
            default: reg_writeaddr <= 5'bx;
        endcase
    
    //WriteData assign
    always_comb
        case (wdsel)
            0: reg_writedata <= pcPlus4;
            1: reg_writedata <= alu_result;
            2: reg_writedata <= mem_readdata;
            default: reg_writedata <= 32'bx;//pcPlus4;//
        endcase
    
    register_file #(Nloc, Dbits) ref_file(clk, werf, RA1, RA2, reg_writeaddr, reg_writedata, ReadData1, ReadData2);
    
    assign mem_writedata = ReadData2;
    assign mem_addr = alu_result;
    
    /*
     * ALU INPUTS
     *
     */
     
//    //Sign-extend
//    always_comb
//        case (sext)
//            0: signImm <= (instr[15] == 1 ? {16'b1, instr[15:0] } : {16'b0 , instr[15:0] } ); //pad with sign
//            1: signImm <= { 16'b0, instr[15:0] }; //pad with 0s
//            default: signImm <= 32'bx;
//        endcase 
    assign signImm = {{16{sext & instr[15]}}, instr[15:0]};
    
    //BT
    assign BT = (signImm<<2) + pcPlus4;
    
    //JT
    assign JT = ReadData1; 
    
    //AluA
    always_comb
        case (asel)
            0: aluA <= ReadData1;
            1: aluA <= instr[10:6]; // left pad with 0
            2: aluA <= 5'b10000;
            default: aluA <= 32'bx;//ReadData1;//
        endcase
    
    //AluB
    always_comb
        case (bsel)
            0: aluB <= ReadData2;
            1: aluB <= signImm;
            default: aluB <= 8'h0000000x;//ReadData2;//
        endcase
    
    //ALU output - Z
    ALU #(Dbits) alu(aluA, aluB, alu_result, alufn, Z);
    
endmodule
