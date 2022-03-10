`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2022 06:32:29 PM
// Design Name: 
// Module Name: MCP_Control_Unit
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

//
//  Module Instantiation Template
//
//   MCP_Control_Unit ( .CLK(), 
//                          .RST(),
//                          .opcode(), 
//                          .funct(),
//                          .MtoRFSel(), 
//                          .RFDSel(), 
//                          .IDSel(), 
//                          .ALUIn1Sel(), 
//                          .PCSel(), 
//                          .ALUIn2Sel(),
//                          .IRWE(), 
//                          .MWE(), 
//                          .PCWE(), 
//                          .branch(), 
//                          .RFWE(), 
//                          .DRWE(),
//                          .ALUSel());

module MCP_Control_Unit (input wire CLK, RST,
                         input wire [5:0] opcode, funct,
                         output wire MtoRFSel, RFDSel, IDSel, ALUIn1Sel, 
                         output wire [1:0] PCSel, ALUIn2Sel,
                         output wire IRWE, MWE, PCWE, branch, RFWE, DRWE,
                         output wire [3:0] ALUSel);
//effectively this will
//1 - Decode opcode, 2 pass to alludecoder, 3 etermine aluop from alu decoder, 4 output all signals.

    //outputs as wire
    wire [1:0] ALUOp;

    //module calls
    MCP_Opcode_Decoder_FSM FSM_call(
                              .CLK(CLK),
                              .RST(RST),
                              .opcode(opcode),
                              .MtoRFSel(MtoRFSel),
                              .RFDSel(RFDSel),
                              .IDSel(IDSel),
                              .ALUIn1Sel(ALUIn1Sel),
                              .PCSel(PCSel),
                              .ALUIn2Sel(ALUIn2Sel),
                              .IRWE(IRWE),
                              .MWE(MWE),
                              .PCWE(PCWE),
                              .Branch(branch),
                              .RFWE(RFWE),
                              .DRWE(DRWE),
                              .ALUOp(ALUOp)    );
    MCP_ALU_Decoder ALU_Decode_call(ALUOp, funct, ALUSel);
endmodule
