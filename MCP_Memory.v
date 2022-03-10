`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2022 06:16:08 PM
// Design Name: 
// Module Name: MCP_Memory
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


module MCP_Memory   #(parameter WL = 32, AL = 9, MEM_INIT = "COMPE475_Ass3_ProgA_Mem_Init.mem")
                (input wire CLK, MWE,
                 input wire [AL - 1:0] MRA,     //AL bit long
                 input wire signed [WL-1:0] MWD,
                 output reg signed [WL-1:0] MRD);
    //memory locations
    reg [WL-1:0] Mem_Locations [(2 ** AL)-1:0];     //2^AL locations of WL bits //FIXME:replacing WL-1 (2**AL)-1 and w 32
    
    //initialize Data Memory
    initial
    begin
        $readmemb(MEM_INIT, Mem_Locations);
    end
    
    //write functionality bound by clk (synchronous)
    always @(posedge CLK)
    begin
        if(MWE)
            Mem_Locations[MRA] <= MWD;
    end
    //read functionality not bound by clk (asynchronous)
    always @*
    begin
        MRD = Mem_Locations[MRA]; 
    end
endmodule
