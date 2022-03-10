`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2022 06:26:10 PM
// Design Name: 
// Module Name: MCP_ALU
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


module MCP_ALU #(parameter WL = 32)
           (input wire [3:0] ALUSel, 
            input wire [4:0] shamt,
            input wire signed [WL-1:0] ALUIN1, ALUIN2,
            output reg zero, OVF_F,
            output reg signed [WL-1:0] ALUOut);     //FIXME: should ALUOut be WL bits and not WL - 1? For add ops it should right?
    
    //ALU Table of contents
    //ALUSel    Operation
    // 0000     Add
    // 0001     Sub
    // 0010     LSL     (Logical Left Shift)
    // 0011     LSR     (Logical Right Shift)
    // 0100     LSVL    (Logical Variable Left Shift)
    // 0101     LSVR    (Logical Variable Right Shift)
    // 0110     AVSR    (Arithmetic Variable Right shift)
    // 0111     bitwise AND     (&)
    // 1000     bitwise OR      (|)
    // 1001     bitwise XOR     (^)
    // 1010     bitwise XNOR    (~^)

    
    
    
    always @(shamt, ALUSel, ALUIN1, ALUIN2)
    begin
        case(ALUSel)
            4'b0000:
            begin
                //ADDITION
                ALUOut = ALUIN1 + ALUIN2;
                //OVF check
                if((ALUIN1 && ALUIN2 && !ALUOut) || //ADD OVF case 1: pos + pos = neg
                   (!ALUIN1 && !ALUIN2 && ALUOut))  //ADD OVF case 2: neg + neg = pos
                    OVF_F = 1'b1;   
                else
                    OVF_F = 1'b0;
            end
            4'b0001:
            begin
                //SUBTRACTION
                ALUOut = ALUIN1 - ALUIN2;
                //OVF check
                if((ALUIN1 && !ALUIN2 && !ALUOut) || //SUB OVF case 1: pos - neg = neg
                   (!ALUIN1 && ALUIN2 && ALUOut))    //SUB OVF case 2: neg - pos = pos
                    OVF_F = 1'b1;
                else
                    OVF_F = 1'b0;
            end
            4'b0010:
            begin
                //LOGICAL LEFT SHIFT
                ALUOut = ALUIN2 << shamt;   
                OVF_F = 1'b0;
            end
            4'b0011:
            begin
                //LOGICAL RIGHT SHIFT
                ALUOut = ALUIN2 >> shamt;
                OVF_F = 1'b0;
            end
            4'b0100:
            begin
                //logical variable shift left
                ALUOut = ALUIN2 << ALUIN1;
                OVF_F = 1'b0;
            end
            4'b0101:
            begin
                //logical variable shift right
                ALUOut = ALUIN2 >> ALUIN1;
                OVF_F = 1'b0;
            end
            4'b0110:
            begin
                //arithmetic variable shift right
                ALUOut = ALUIN2 >>> ALUIN1;
                OVF_F = 1'b0;
            end
            4'b0111:
            begin
                //bitwise AND (&)
                ALUOut = ALUIN1 & ALUIN2;
                OVF_F = 1'b0;
            end
            4'b1000:
            begin
                //bitwise OR (|)
                ALUOut = ALUIN1 | ALUIN2;
                OVF_F = 1'b0;
            end
            4'b1001:
            begin
                //BITWISE XOR (^)
                ALUOut = ALUIN1 ^ ALUIN2;
                OVF_F = 1'b0;
            end
            4'b1010:
            begin
                //BITWISE XNOR
                ALUOut = ALUIN1 ~^ ALUIN2;
                OVF_F = 1'b0;
            end
            default : //Nah, instead lets say ALUOut keeps its values   //raise to X's
            begin
                ALUOut = ALUOut;    //32'hXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX;
                zero = 1'bX;
                OVF_F = 1'bX;
            end
        endcase
        if(ALUOut == 0)
            zero = 1'b1;
        else
            zero = 1'b0;
    end
endmodule
