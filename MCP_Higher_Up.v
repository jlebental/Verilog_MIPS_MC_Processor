`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2022 07:01:56 PM
// Design Name: 
// Module Name: MCP_Higher_Up
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
//    //module instantiation template
//    MCP_Higher_Up #(    .WL(), 
//                        .RF_AL(), 
//                        .MEM_INIT(), 
//                        .MEM_AL()         ) 
//        MCP_call(   .CLK(), 
//                    .RST()   );
//

module MCP_Higher_Up #(parameter WL = 32, RF_AL = 5, MEM_AL = 8,
                        MEM_INIT = "COMPE475_Ass3_ProgA_Mem_Init.mem")// AL = 6) 
                    (input wire CLK, RST);
    //internal signals
    //PC signals
    wire [WL - 1:0] PC_in, PC_out, Addr;
    //Memory Signal
    wire [WL - 1:0] MRD, Instr, Data, DM_Addr;
    wire DM_ADDER_OVF_F;
    //Control Unit Signals
    wire Jump, MtoRFSel, RFDSel, IDSel, ALUIn1Sel, IRWE, MWE, PCWE, branch, RFWE, DRWE;     //fixme adding DRWE
    wire [1:0] PCSel, ALUIn2Sel;
    wire [3:0] ALUSel;
    //Decoded instruction signals
    wire [5:0] opcode, funct;
    wire [RF_AL - 1:0] rs, rt, rd;
    wire [4:0] shamt;
    wire [15:0] Imm;
    wire [25:0] jumpt;
    //Register File signals
    wire [5:0] RFWA;
    wire [WL - 1:0] RFWD, RFRD1, RFRD2, RFRD1A, RFRD2B;
    //ALU signals
    wire [WL - 1:0] SImm, ALUIn1, ALUIn2, ALUOut, ALUOutR;
    wire zero, OVF_F;
    //PCEN and PC_in signals
    wire between_AND_OR, PCEN;
    wire [WL - 1:0] jaddr;
    
    
    //module calls
    //PC
    MCP_Register #(.WL(WL)) PC_reg_call(CLK, RST, PCEN, PC_in, PC_out);     //Only the PC and Control Unit is wired to RST
        //I have no clue if this is right
        //but its tripping me up that DM and Im are mixed.
        //I'm adding an adder that adds 50 to any DM addr
        //In my mem file I'll start DM at the 51st line.
    MCP_Adder #(.WL(WL)) DM_addr_solution_Adder_call(ALUOutR, 50, DM_Addr, DM_ADDER_OVF_F); //just trust me its 51, not 50
    MCP_MUX2 #(.WL(WL)) MUX_for_MRA_call(IDSel, PC_out, DM_Addr, Addr);     
    MCP_Memory #(.WL(WL), 
                .AL(MEM_AL),
                .MEM_INIT(MEM_INIT)) 
    Memory_call(.CLK(CLK), 
                        .MWE(MWE), 
                        .MRA(Addr), 
                        .MWD(RFRD2B), 
                        .MRD(MRD));         
                                         
    
    //Post Memory intermediary registers
    MCP_Register #(.WL(WL)) Instr_Reg_call(CLK, 0, IRWE, MRD, Instr);       //hardwire RST lo
    MCP_Register Data_Reg_call(CLK, 0, DRWE, MRD, Data);                       //Hardwire RST lo
    
    //Instruction Decode
    MCP_Instr_Decoder Instr_decoder_call(Instr, opcode, funct, rs, rt, rd, shamt, Imm, jumpt);
    
    //Control Unit
       MCP_Control_Unit Control_Unit_call
                        ( .CLK(CLK), 
                          .RST(RST),
                          .opcode(opcode), 
                          .funct(funct),
                          .MtoRFSel(MtoRFSel), 
                          .RFDSel(RFDSel), 
                          .IDSel(IDSel), 
                          .ALUIn1Sel(ALUIn1Sel), 
                          .PCSel(PCSel), 
                          .ALUIn2Sel(ALUIn2Sel),
                          .IRWE(IRWE), 
                          .MWE(MWE), 
                          .PCWE(PCWE), 
                          .branch(branch), 
                          .RFWE(RFWE), 
                          .DRWE(DRWE),
                          .ALUSel(ALUSel)   );
    
    
    //Register File
    MCP_MUX2 #(.WL(RF_AL)) MUX_for_RFWA_call(RFDSel, rt, rd, RFWA);
    MCP_MUX2 #(.WL(WL)) MUX_for_RFWD(MtoRFSel, ALUOutR, Data, RFWD);   
    MCP_RF #(.WL(WL), .AL(RF_AL)) RF_call(CLK, RFWE, rs, rt, RFWA, RFWD, RFRD1, RFRD2);
    
    //Post Register File Intermediary registers
    MCP_Register #(.WL(WL)) RFRD1_Reg_call(CLK, 0, 1, RFRD1, RFRD1A);    //Hardwire RST lo, EN hi
    MCP_Register #(.WL(WL)) RFRD2_Reg_call(CLK, 0, 1, RFRD2, RFRD2B);    //Hardwire RST lo, EN hi
    
    //ALU
    MCP_Sign_Extens_Unit #(.WL(WL)) SE_call(Imm, SImm);
    MCP_MUX2 #(.WL(WL)) MUX_for_ALUIn1_call(ALUIn1Sel, PC_out, RFRD1A, ALUIn1);
    MCP_MUX3 #(.WL(WL)) MUX_for_ALUIn2_call(ALUIn2Sel, RFRD2B, 1, SImm, ALUIn2);
    MCP_ALU #(.WL(WL)) ALU_call(ALUSel, shamt, ALUIn1, ALUIn2, zero, OVF_F, ALUOut);
    
    //PCEN and PC_in control
    //NOTE: Jump control signal not implemented anywhere yet
    MCP_AND_Gate AND_gate_call(zero, branch, between_AND_OR);
    MCP_OR_Gate OR_gate_call(PCWE, between_AND_OR, PCEN);
    MCP_Register #(.WL(WL)) ALUOut_Reg_call(CLK, 0, 1, ALUOut, ALUOutR);          //hardwire RST lo, EN hi
    MCP_Jump_Encoder #(.WL(WL)) Jump_Encoder_call(jumpt, PC_out, jaddr);            //PC_out is PCp1 until the next fetch instr. 
    MCP_MUX3 #(.WL(WL)) MUX_for_PC_in_call(PCSel, ALUOut, ALUOutR, jaddr, PC_in);  
endmodule
