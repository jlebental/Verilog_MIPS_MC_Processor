`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2022 06:22:15 PM
// Design Name: 
// Module Name: MCP_RF
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


module MCP_RF #(parameter WL = 32, AL = 5)
                      (input CLK, RFWE,
                       input [AL - 1:0] RFR1, RFR2, RFWA,
                       input signed [WL - 1:0] RFWD,
                       output signed [WL - 1:0] RFRD1, RFRD2);
    //initialize 32 registers for our RF
    reg [WL-1:0] RF_Array [(2 ** AL) - 1:0]; //this is our 32 memory lovation, each set to our data's length in bits
    
    //MIPS RF   name        definition
    //reg 0     ($0)        holds constant value 0
    //reg 1     ($at)       reserved for assembler
    //reg 2-3   ($v0-$v1)   procedure return values
    //reg 4-7   ($a0-$a3)   procedure arguments
    //reg 8-15  ($t0-$t7)   temporaries
    //reg 16-23 ($s0-$s7)   saved variables (callee)
    //reg 24-25 ($t8-$t9)   more temporaries
    //reg 26-27 ($k0-$k1)   reserved for OS Kernel
    //reg 28    ($gp)       pointer to global data
    //reg 29    ($sp)       stack pointer
    //reg 30    ($fp)       frame pointer
    //reg 31    ($ra)       procedure return address
    
    //initialize RF with some preset MIPS details
    initial
    begin
        RF_Array[0] = 0;
    end
    
    //heres our synchronous write functionality
    always @(posedge CLK)
    begin
        if(RFWE)
        begin
            RF_Array[RFWA] <= RFWD;
        end
    end
    //heres our asynchronous read functionality
    assign RFRD1 = RF_Array[RFR1];
    assign RFRD2 = RF_Array[RFR2];
    
    //
    //FIXME: what is meant by Write First Mode?
    //I understand WF mode means the data gets written and then read.
    //the edge case where you W and R the same addr means you read whatever you'll write
    //
endmodule
