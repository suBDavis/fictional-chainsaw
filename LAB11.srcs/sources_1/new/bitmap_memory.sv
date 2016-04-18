//////////////////////////////////////////////////////////////////////////////////
//
// Montek Singh
// 3/22/2016 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none

module bitmapmem #(
   parameter Nloc = 4096,                      // Number of memory locations (16 characters * 16x16 patterns)
   parameter Dbits = 12,                       // Number of bits in data 4 for r g b
   parameter initfile = "bmem.txt"  // Name of file with initial values
   )(
   input wire [$clog2(Nloc)-1 : 0] ReadAddr1,
   output logic [Dbits-1 : 0] ReadData1
   );

   logic [Dbits-1 : 0] rf [Nloc-1 : 0];            // The actual registers where data is stored
   initial $readmemh(initfile, rf, 0, Nloc-1);     // Data to initialize registers

   // MODIFY the two lines below so if register 0 is being read, then the output
   // is 0 regardless of the actual value stored in register 0
   
   assign ReadData1 = rf[ReadAddr1];                  // First output port
   
endmodule