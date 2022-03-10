`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2022 06:35:22 PM
// Design Name: 
// Module Name: MCP_Opcode_Decoder_FSM
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

//Module instantiation template
//
// MCP_Opcode_Decoder_FSM(
//  .CLK(),
//  .RST(),
//  .opcode(),
//  .MtoRFSel(),
//  .RFDSel(),
//  .IDSel(),
//  .ALUIn1Sel(),
//  .PCSel(),
//  .ALUIn2Sel(),
//  .IRWE(),
//  .MWE(),
//  .PCWE(),
//  .Branch(),
//  .RFWE(),
//  .DRWE(),
//  .ALUOp()    )
//

module MCP_Opcode_Decoder_FSM(input wire CLK, RST,
                              input wire [5:0] opcode,
                              output reg MtoRFSel, RFDSel, IDSel, ALUIn1Sel, 
                              output reg [1:0] PCSel, ALUIn2Sel,
                              output reg IRWE, MWE, PCWE, Branch, RFWE, DRWE,
                              output reg [1:0] ALUOp);
    //states
    localparam S0 = 4'b0000, S1 = 4'b0001, S2 = 4'b0010, S3 = 4'b0011,
               S4 = 4'b0100, S5 = 4'b0101, S6 = 4'b0110, S7 = 4'b0111,
               S8 = 4'b1000, S9 = 4'b1001, S10 = 4'b1010;
    //opcodes
    localparam LW       = 6'b100011;
    localparam SW       = 6'b101011;  
    localparam R_TYPE   = 6'b000000;
    localparam ADDI     = 6'b001000;
    localparam BEQ      = 6'b000100;
    localparam J        = 6'b000010;
    //internal FSM registers
    reg [3:0] state, next_state;
    
    //this block controls state transitions
    always @(posedge CLK)    //I think this will work without adding opcode to the sensitivity list
    begin
        if(RST) state <= S0;            //S0 is Fetch state
        else    state <= next_state;
    end
    
    //this block controls next state logic
    always @(state or opcode)
    begin
        case(state)
            S0: next_state = S1;            //S0 is fetch. The next state is always decode
            S1:                             //S1 is decode. next_state depends on opcode
            begin
                case(opcode)                        
                    LW:         next_state = S2;            //LW sequence: S2, S3, S4 -> Fetch
                    SW:         next_state = S2;            //SW sequence: S2, S5 -> Fetch
                    R_TYPE:     next_state = S6;            //R_TYPE sequence: S6, S7 -> Fetch
                    ADDI:       next_state = S2;            //ADDI sequence: S2, S8 -> Fetch
                    BEQ:        next_state = S9;            //BEQ sequence: (S1) -> S9 -> Fetch
                    J:          next_state = S10;           //J sequence: S10 -> Fetch
                    default:    next_state = 4'bZZZZ;  //default will handle garbage opcodes. Enters a loop of hi imp.
                endcase
            end
            S2:                             //(LW/SW/ADDI) MemAddr calculation
            begin
                case(opcode)
                    LW:     next_state = S3;
                    SW:     next_state = S5;    
                    ADDI:   next_state = S8;
                endcase
            end
            S3:     next_state = S4;     //(LW) MemRead
            S4:     next_state = S0;     //(LW) MemWriteback
            S5:     next_state = S0;     //(SW) DM Write
            S6:     next_state = S7;     //(R_TYPE) Execute
            S7:     next_state = S0;     //(R_TYPE) ALU Writeback (rd)
            S8:     next_state = S0;     //(ADDI) ALU Writeback (rt)
            S9:     next_state = S0;     //(BEQ) Branch
            S10:    next_state = S0;     //(J) Jump
        endcase
    end
    
    
    
    //this block controls outputs (Control Signals) based on state. 
    // See Description of Control Signals below
    always @(state)
    begin
        case(state)
        //S0 is Fetch State.
        //Updates Instr reg and PC with instr and PCp1
            S0: 
            begin
                //fetch signals
                IDSel       = 1'b0;     //Mem addr is taken from PC
                ALUIn1Sel   = 1'b0;     //ALUIn1 gets PC_out
                ALUIn2Sel   = 2'b01;    //ALUIn2 gets 1
                ALUOp       = 2'b00;    //ALU performs addition
                PCSel       = 2'b00;    //PC_in gets ALUOut
                IRWE        = 1'b1;     //Instr reg is updated
                PCWE        = 1'b1;     //PC reg is updated
                //disabling signals from other states
                RFWE        = 1'b0;     //(LW) disables Register File updates
                MWE         = 1'b0;     //(SW) disables Memory updates
                DRWE        = 1'b0;     //disables Data register updates
                Branch      = 1'b0;     //disables Branching
            end
        
        //S1 is Decode State. 
        //Stops PC updates. Should also stop Instr reg updates
        //Asynchronous propagations: 
        //  --- Imm becomes Simm, Control Signals propogated, 
        //  --- RFRD1 and 2 fill A and B regs filled with RF data from rs and rt respectively
            S1:
            begin 
                PCWE        = 1'b0;     //disables PC register updates
                IRWE        = 1'b0;     //disables Instruction Register updates
                //ALUOp       = 2'b00;    // Set in previous state. Enables BTA calculations for branch instruction. Addition in ALU.
                //ALUIn1Sel   = 1'b0;     // Set in previous state. ALUIn1 gets PC_out.
                ALUIn2Sel   = 2'b10;    //ALUIn2 gets SImm
            end
            
       //S2 is MemAddr(LW/SW). 
       //Computes effective addr. Stores in ALUOut Register.
            S2:
            begin
                ALUIn1Sel   = 1'b1;     //ALUIn1 gets RFRD2
                ALUIn2Sel   = 2'b10;    //ALUIn2 gets SImm
                ALUOp       = 2'b00;    //Addition performed in ALU.
            end
            
        //S3 is MemRead(LW). 
        //Memory is read from calculated addr and propogates to Data register
            S3: 
            begin
                IDSel       = 1'b1;         //Read from Data memory
                DRWE        = 1'b1;         //Enables Data register updates
            end
                
        //S4 is MemWriteback(LW)
        //Data Register written into RF
            S4: 
            begin
                DRWE        = 1'b0;     //disables Data Register updates
                RFDSel      = 1'b0;     //sets rt as destination reg in RF
                MtoRFSel    = 1'b1;     //sets data reg as RFWD
                RFWE        = 1'b1;     //enables writing to RF
            end
            
        //S5 is DM Write
        //Mem_Locations[ALUOutR] = RFRD2B
        //DM Target Address gets value in register rt from instr
            S5:
            begin
                MWE = 1'b1;     //Enables Memory update
                IDSel = 1'b1;   //Indicates Data Memory Address
            end
            
        //S6 is Execute
        //ALUOutR gets result of R type instruction
        //ALUIn1 gets RFRD1A (thats rs reg)
        //ALUIn2 gets RFRD1B (thats rt reg)
        //ALUOp tells ALUDecoder to look at funct to set ALUSel
            S6:
            begin
                ALUIn1Sel = 1'b1;   //ALUIn1 gets RFRD1A
                ALUIn2Sel = 2'b00;  //ALUIn2 gets RFRD2B
                ALUOp     = 2'b11;  //ALU Decoder will look at funct to select ALU Operation
            end
            
        //S7 is ALU Writeback (rd)
        //ALUOutR written into Register file at RF_Array[rd]
            S7:
            begin
                MtoRFSel = 1'b0;    //ALUOutR is the data written to RF
                RFWE = 1'b1;        //Enables Register File updates
                RFDSel = 1'b1;      //Sets destination reg to rd
            end
            
        //S8 is ALU Writeback (rt)
        //ALUOutR written into Register file at RF_Array[rt]
            S8:
            begin
                MtoRFSel = 1'b0;    //ALUOutR is the data written to RF
                RFWE     = 1'b1;    //enables RF updates
                RFDSel   = 1'b0;    //Sets destination reg to rt
            end
            
        //S9 is Branch
        // Compares the source register in ALU. Jumps to ALUOutR in Instruction memory if equal.
            S9:
            begin
                Branch      = 1'b1;     //Enables Branch
                ALUOp       = 2'b01;    //sets ALU for subtraction
                ALUIn1Sel   = 1'b1;     //ALUIn1 gets RFRD1A
                ALUIn2Sel   = 2'b00;    //ALUIn2 gets RFRD2B
                PCSel       = 2'b01;    //PC gets ALUOutR
            end
            
        //S10 is Jump
        // sets the PC to jaddr
            S10:
            begin
                PCSel = 2'b10;  //PC gets jaddr
                PCWE = 1'b1;    //enables PC updates
            end
            
        //default is meant for garbage opcodes
        //I could set all signals to hiZ
            default:    
            begin
                MtoRFSel    = 1'bZ;
                RFDSel      = 1'bZ;
                IDSel       = 1'bZ;
                PCSel       = 2'bZZ;
                ALUIn1Sel   = 1'bZ;
                ALUIn2Sel   = 2'bZZ;
                IRWE        = 1'bZ;
                MWE         = 1'bZ;
                PCWE        = 1'bZ;
                Branch      = 1'bZ;
                RFWE        = 1'bZ;
                ALUOp       = 2'bZZ;
                DRWE        = 1'bZ;
            end
        endcase
    end
endmodule
//Control Signals Description
// Jump         --- hi: indicates a jump
//              --- lo: indicates not a jump
//              NOTE: Jump isn't anywhere on my implementation right now.

// MtoRFSel     --- hi: RFWD gets Data. Some data from Memory is entering the RF
//              --- lo: RFWD gets RFRDB2. ALU is writing some calculation into RF

// RFDSel       --- hi: RFWA gets rd
//              --- lo: RFWA gets rt

// IDSel        --- hi: MRA gets ALUOutR + 50 (DM_Addr). Means we're reading from data memory
//              --- lo: MRA gets PC_out. Indicates reading instruction memory

// PCSel        --- 2'b10: PC_in gets jaddr.
//              --- 2'b01: PC_in gets ALUOutR.
//              --- 2'b00: PC_in gets ALUOut.

// ALUIn1Sel    --- hi: ALUIn1 gets RFRD1A
//              --- lo: ALUin1 gets PC_out

// ALUIn2Sel    --- 2'b10: ALUIn2 gets SImm
//              --- 2'b01: ALUIn2 gets 1
//              --- 2'b00: ALUIn2 gets RFRD2B

// IRWE         --- hi: Enables writing to Instruction register
//              --- lo: Disables writing to Instruction register

// MWE          --- hi: Enables writing to Memory
//              --- lo: Disables writing to Memory

// PCWE         --- hi: Enables writing to the Program Counter register
//              --- lo: Disable writing to the Program Counter register

// Branch       --- hi: indicates a branch
//              --- lo: indicates not a branch

// RFWE         --- hi: Enables writing to RF
//              --- lo: Disables writing to RF

// DRWE         --- hi: Enables writing to Data Register
//              --- lo: Disables writing to Data Register

// ALUOp        --- 2'b10: For R types. Makes the ALU Decoder examine funct
//              --- 2'b01: For non R type ALU needs. Makes the ALU Decoder tell the ALU to perform subtraction
//              --- 2'b00: For non R type ALU needs. Makes the ALU Decoder tell the ALU to perform addition

