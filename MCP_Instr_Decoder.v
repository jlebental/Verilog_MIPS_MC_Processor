`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2022 06:17:57 PM
// Design Name: 
// Module Name: MCP_Instr_Decoder
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


module MCP_Instr_Decoder    #(parameter WL = 32)
                      (input wire [WL - 1:0] Instr,
                       output reg [5:0] opcode, funct,
                       output reg [4:0] rs, rt, rd, shamt,
                       output reg [15:0] Imm,
                       output reg [25:0] jumpt);
//Deconstructs the instruction

    always @(Instr)
    begin
        // all instructions
        opcode = Instr[WL - 1: WL - 6];
        
        //R and I instr
        rs = Instr[WL - 7: WL - 11];
        rt = Instr[WL - 12: WL - 16];
        
        //R type instr
        rd      = Instr[WL - 17: WL - 21];
        shamt   = Instr[WL - 22: WL - 26];
        funct   = Instr[WL - 27: WL - 32];
        
        //I type instr
        Imm = {rd, shamt, funct};   //should concatenate correctly
        
        //j type instructions
        jumpt = {rs, rt, Imm};      //should concatenate correctly
    end
endmodule
