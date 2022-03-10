`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2022 08:51:23 PM
// Design Name: 
// Module Name: MCP_ALU_Decoder
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


module MCP_ALU_Decoder (input wire [1:0] ALUOp,
                   input wire [5:0] funct,
                   output reg [3:0] ALUSel);    //ALUSEL is 4 bits because ALU has a case statement that needs a 4 bit value

    //ALU Table of contents/SEL values
    localparam ALU_Add  = 4'b0000;  // +
    localparam ALU_Sub  = 4'b0001;  // -
    localparam ALU_SLL  = 4'b0010;  // <<
        // 0011     LSR     (Logical Right Shift)   // >>
    localparam ALU_SLLV = 4'b0100;  // <<
        // 0101     LSVR    (Logical Variable Right Shift)  // >>
    localparam ALU_SRAV = 4'b0110;  // >>>
        // 0111     bitwise AND     (&)
        // 1000     bitwise OR      (|)
        // 1001     bitwise XOR     (^)
        // 1010     bitwise XNOR    (~^)

    //R Type instruction funct codes
    localparam ADD = 6'b100000;
    localparam SUB = 6'b100010;
    localparam SLL = 6'b000000;
    localparam SLLV = 6'b000100;
    localparam SRAV = 6'b000111;

    //ALUOp States
    //eh, If I can think of a clever name I'll do it later.

    //sUse ALUOp to set ALUSel
    always @*
    begin
        case(ALUOp)
            2'b00: ALUSel = ALU_Add;    //Add case for ALU is 4'b0000. Instr is I type
            2'b01: ALUSel = ALU_Sub;    //Sub case for ALU is 4'b0001. Instr is I type
            2'b11:                      //R type instruction. We must look at funct to set ALUSel
            begin
                case(funct)
                    SRAV: ALUSel = ALU_SRAV;     //SRAV Shift right arithmetic variable
                    SLLV: ALUSel = ALU_SLLV;     //SLLV Shift Logical Left variable
                    SLL: ALUSel = ALU_SLL;      //Shift logical left
                    SUB: ALUSel = ALU_Sub;      //subtraction
                    ADD: ALUSel = ALU_Add;      //add
                    default: ALUSel = 4'bZZZZ;  //for unrecognized funct codes
                endcase
            end
            default: ALUSel = 4'bZZZZ;
        endcase
    end
endmodule
