// Name: control_unit.v
// Module: CONTROL_UNIT
// Output: RF_DATA_W  : Data to be written at register file address RF_ADDR_W
//         RF_ADDR_W  : Register file address of the memory location to be written
//         RF_ADDR_R1 : Register file address of the memory location to be read for RF_DATA_R1
//         RF_ADDR_R2 : Registere file address of the memory location to be read for RF_DATA_R2
//         RF_READ    : Register file Read signal
//         RF_WRITE   : Register file Write signal
//         ALU_OP1    : ALU operand 1
//         ALU_OP2    : ALU operand 2
//         ALU_OPRN   : ALU operation code
//         MEM_ADDR   : Memory address to be read in
//         MEM_READ   : Memory read signal
//         MEM_WRITE  : Memory write signal
//         
// Input:  RF_DATA_R1 : Data at ADDR_R1 address
//         RF_DATA_R2 : Data at ADDR_R1 address
//         ALU_RESULT    : ALU output data
//         CLK        : Clock signal
//         RST        : Reset signal
//
// INOUT: MEM_DATA    : Data to be read in from or write to the memory
//
// Notes: - Control unit synchronize operations of a processor
//
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
//  1.0     Sep 10, 2014	Kaushik Patra	kpatra@sjsu.edu		Initial creation
//  1.1     Oct 19, 2014        Kaushik Patra   kpatra@sjsu.edu         Added ZERO status output
//------------------------------------------------------------------------------------------
`include "prj_definition.v"
module CONTROL_UNIT(MEM_DATA, RF_DATA_W, RF_ADDR_W, RF_ADDR_R1, RF_ADDR_R2, RF_READ, RF_WRITE,
                    ALU_OP1, ALU_OP2, ALU_OPRN, MEM_ADDR, MEM_READ, MEM_WRITE,
                    RF_DATA_R1, RF_DATA_R2, ALU_RESULT, ZERO, CLK, RST); 

// Output signals
// Outputs for register file 
output [`DATA_INDEX_LIMIT:0] RF_DATA_W;
output [`REG_ADDR_INDEX_LIMIT:0] RF_ADDR_W, RF_ADDR_R1, RF_ADDR_R2;
output RF_READ, RF_WRITE;
// Outputs for ALU
output [`DATA_INDEX_LIMIT:0]  ALU_OP1, ALU_OP2;
output  [`ALU_OPRN_INDEX_LIMIT:0] ALU_OPRN;
// Outputs for memory
output [`ADDRESS_INDEX_LIMIT:0]  MEM_ADDR;
output MEM_READ, MEM_WRITE;

// Input signals
input [`DATA_INDEX_LIMIT:0] RF_DATA_R1, RF_DATA_R2, ALU_RESULT;
input ZERO, CLK, RST;

// Inout signal
inout [`DATA_INDEX_LIMIT:0] MEM_DATA;

// State nets
wire [2:0] proc_state;

PROC_SM state_machine(.STATE(proc_state),.CLK(CLK),.RST(RST));

//output registers for register file
reg [`DATA_INDEX_LIMIT:0] RF_DATA_W_SET;
reg [`REG_ADDR_INDEX_LIMIT:0] RF_ADDR_W_SET, RF_ADDR_R1_SET, RF_ADDR_R2_SET;
reg RF_READ_SET, RF_WRITE_SET;
assign RF_DATA_W = RF_DATA_W_SET; 
assign RF_ADDR_W = RF_ADDR_W_SET; assign RF_ADDR_R1 = RF_ADDR_R1_SET; assign RF_ADDR_R2 = RF_ADDR_R2_SET;
assign RF_READ = RF_READ_SET; assign RF_WRITE = RF_WRITE_SET;

//output registers for ALU
reg [`DATA_INDEX_LIMIT:0]  ALU_OP1_SET, ALU_OP2_SET;
reg [`ALU_OPRN_INDEX_LIMIT:0] ALU_OPRN_SET;
assign ALU_OP1 = ALU_OP1_SET; assign ALU_OP2 = ALU_OP2_SET;
assign ALU_OPRN = ALU_OPRN_SET; 

//output registers for memory
reg [`ADDRESS_INDEX_LIMIT:0]  MEM_ADDR_SET;
reg MEM_READ_SET, MEM_WRITE_SET;
assign MEM_ADDR = MEM_ADDR_SET;
assign MEM_READ =  MEM_READ_SET; assign  MEM_WRITE =  MEM_WRITE_SET;

//inout data register
reg [`DATA_INDEX_LIMIT:0] MEM_DATA_SET;
assign MEM_DATA = ((MEM_READ_SET===1'b0)&&(MEM_WRITE_SET==1'b1))?MEM_DATA_SET:{`DATA_WIDTH{1'bz} };

//internal registers
reg [`DATA_INDEX_LIMIT:0] PC_REG, SP_REG;
reg [`DATA_INDEX_LIMIT:0] INST_REG;

reg [5:0] opcode;
reg [4:0] rs; 
reg [4:0] rt; 
reg [4:0] rd; 
reg [4:0] shamt; 
reg [5:0] funct; 
reg [15:0] immediate; 
reg [25:0] address;
reg [`DATA_INDEX_LIMIT:0] sign_extension;
reg [`DATA_INDEX_LIMIT:0] zero_extension;
reg [`DATA_INDEX_LIMIT:0] LUI;
reg [`DATA_INDEX_LIMIT:0] jump_address;

initial 
begin
  PC_REG = `INST_START_ADDR;
  SP_REG = `INIT_STACK_POINTER;
end
always @ (proc_state)
begin
	if(proc_state === `PROC_FETCH)
	begin
	  MEM_ADDR_SET = PC_REG; 
	  MEM_READ_SET = 1'b1; MEM_WRITE_SET = 1'b0;
	  RF_READ_SET = 1'b0; RF_WRITE_SET = 1'b0;
	end
	else if(proc_state === `PROC_DECODE)
	begin
	  INST_REG = MEM_DATA;
	  // parse the instruction 
	  // R-type 
	  {opcode, rs, rt, rd, shamt, funct} = INST_REG; 
	  // I-type 
	  {opcode, rs, rt, immediate} = INST_REG; 
	  // J-type 
	  {opcode, address} = INST_REG; 
	  sign_extension = {{16{immediate[15]}}, immediate};
	  zero_extension = {{16{1'b0}}, immediate};
	  LUI = {immediate, {16{1'b0}}};
	  jump_address = {{6{1'b0}}, address};
	  RF_ADDR_R1_SET = rs;
	  RF_ADDR_R2_SET = rt;
	  RF_READ_SET = 1'b1;
	end
	else if(proc_state === `PROC_EXE)
	begin
	  case(opcode)
		//R type
		6'h00:
	 	begin
		  ALU_OP1_SET = RF_DATA_R1;
   		  ALU_OP2_SET = RF_DATA_R2;
		  case(funct)
		    6'h20: ALU_OPRN_SET = 'h01;
		    6'h22: ALU_OPRN_SET = 'h02;
		    6'h2c: ALU_OPRN_SET = 'h03;
		    6'h24: ALU_OPRN_SET = 'h06;
		    6'h25: ALU_OPRN_SET = 'h07;
		    6'h27: ALU_OPRN_SET = 'h08;
		    6'h2a: ALU_OPRN_SET = 'h09;
		    6'h01: begin ALU_OPRN_SET = 'h04; ALU_OP2_SET = shamt; end
		    6'h02: begin ALU_OPRN_SET = 'h05; ALU_OP2_SET = shamt; end
		    6'h08: PC_REG = RF_DATA_R1;
		    default: $write("There is no such r type instruction.");
		  endcase
		end
		//I type
		6'h08:
		begin
		  ALU_OP1_SET = RF_DATA_R1;
   		  ALU_OP2_SET = sign_extension;
		  ALU_OPRN_SET = 'h01;
		end
		6'h1d:
		begin
		  ALU_OP1_SET = RF_DATA_R1;
   		  ALU_OP2_SET = sign_extension;
		  ALU_OPRN_SET = 'h03;
		end
		6'h0c:
		begin
		  ALU_OP1_SET = RF_DATA_R1;
   		  ALU_OP2_SET = zero_extension;
		  ALU_OPRN_SET = 'h06;
		end
		6'h0d:
		begin
		  ALU_OP1_SET = RF_DATA_R1;
   		  ALU_OP2_SET = zero_extension;
		  ALU_OPRN_SET = 'h07;
		end
		6'h0f:
		begin
		end
		6'h0a:
		begin
		  ALU_OP1_SET = RF_DATA_R1;
   		  ALU_OP2_SET = sign_extension;
		  ALU_OPRN_SET = 'h09;
		end
		6'h04:
		// for ZERO flag
		begin
		  ALU_OP1_SET = RF_DATA_R1;
   		  ALU_OP2_SET = RF_DATA_R2;
		  ALU_OPRN_SET = 'h02;
		end
		6'h05:
		begin
		  ALU_OP1_SET = RF_DATA_R1;
   		  ALU_OP2_SET = RF_DATA_R2;
		  ALU_OPRN_SET = 'h02;
		end
		6'h23:
		begin
		  ALU_OP1_SET = RF_DATA_R1;
   		  ALU_OP2_SET = sign_extension;
		  ALU_OPRN_SET = 'h01;
		end
		6'h2d:
		begin
		  ALU_OP1_SET = RF_DATA_R1;
   		  ALU_OP2_SET = sign_extension;
		  ALU_OPRN_SET = 'h01;
		end
		//J type
		6'h02:
		begin
		end
		6'h03:
		begin
		end
		6'h1b:
		begin 
		  RF_ADDR_R1_SET = 0;
		  ALU_OP1_SET = SP_REG;
   		  ALU_OP2_SET = 1;
		  ALU_OPRN_SET = 'h02;
		end
		6'h1c:
		begin
	          RF_ADDR_W_SET = 0;
		  ALU_OP1_SET = SP_REG;
   		  ALU_OP2_SET = 1;
		  ALU_OPRN_SET = 'h01;
		end
	  endcase
	end
	else if(proc_state === `PROC_MEM)
	begin
	  MEM_READ_SET = 1'b0;
	  MEM_WRITE_SET = 1'b0;
	  case(opcode)
	  6'h23:
	  begin
	    MEM_READ_SET = 1'b1;
	    MEM_WRITE_SET = 1'b0;
	    MEM_ADDR_SET = ALU_RESULT;
	  end
	  6'h2b:
	  begin
	    MEM_READ_SET = 1'b0;
	    MEM_WRITE_SET = 1'b1;
	    MEM_ADDR_SET = ALU_RESULT;
	    MEM_DATA_SET = RF_DATA_R2; 
	  end
	  6'h1b:
	  begin
	    MEM_READ_SET = 1'b0;
	    MEM_WRITE_SET = 1'b1;
	    MEM_ADDR_SET = SP_REG;
	    MEM_DATA_SET = RF_DATA_R1;
	    SP_REG = ALU_RESULT;
	  end
	  6'h1c:
	  begin
	    MEM_READ_SET = 1'b1;
	    MEM_WRITE_SET = 1'b0;
	    SP_REG = ALU_RESULT;
	    MEM_ADDR_SET = SP_REG;
	  end
	  endcase
	end
	//Write back to some RF or PC_REG which are not done yet.
	else if(proc_state === `PROC_WB)
	begin
	  PC_REG = PC_REG + 1;
	  RF_READ_SET = 1'b0;
	  RF_WRITE_SET = 1'b1;
	  MEM_WRITE_SET = 1'b0;
	  MEM_READ_SET = 1'b0;
	  case(opcode)
	    6'h00:
	    begin
	      if(funct != 6'h08)
	      begin
	  	RF_ADDR_W_SET = rd;
		RF_DATA_W_SET = ALU_RESULT;
	      end
  	    end
		6'h08:
		begin
		  RF_ADDR_W_SET = rt;
		  RF_DATA_W_SET = ALU_RESULT; 
		end
		6'h1d:
		begin
		  RF_ADDR_W_SET = rt;
		  RF_DATA_W_SET = ALU_RESULT;
		end
		6'h0c:
		begin
		  RF_ADDR_W_SET = rt;
		  RF_DATA_W_SET = ALU_RESULT;
		end
		6'h0d:
		begin
		  RF_ADDR_W_SET = rt;
		  RF_DATA_W_SET = ALU_RESULT;
		end
		6'h0f:
		begin
		  RF_ADDR_W_SET = rt;
		  RF_DATA_W_SET = LUI;
		end
		6'h0a:
		begin
		  RF_ADDR_W_SET = rt;
		  RF_DATA_W_SET = ALU_RESULT;
		end
		6'h04:
		begin
		  if(ZERO === 1)
		  begin
		    PC_REG = sign_extension + PC_REG;
		  end
		end
		6'h05:
		begin
  		  if(ZERO === 0)  
		    begin
		      PC_REG = sign_extension + PC_REG;
		    end
		end
	  6'h02:
	  begin
	    PC_REG = jump_address;
	  end
	  6'h03:
	  begin
	    RF_ADDR_W_SET = 31;
	    RF_DATA_W_SET = PC_REG;
	    PC_REG = jump_address;
	  end
	  6'h23:
	  begin
	    RF_ADDR_W_SET = rt;
	    RF_DATA_W_SET = MEM_DATA;
	  end
	  6'h1c:
	  begin
	    RF_DATA_W_SET = MEM_DATA;
	  end
	  endcase
	end
end
endmodule;

//------------------------------------------------------------------------------------------
// Module: CONTROL_UNIT
// Output: STATE      : State of the processor
//         
// Input:  CLK        : Clock signal
//         RST        : Reset signal
//
// INOUT: MEM_DATA    : Data to be read in from or write to the memory
//
// Notes: - Processor continuously cycle witnin fetch, decode, execute, 
//          memory, write back state. State values are in the prj_definition.v
//
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
//  1.0     Sep 10, 2014	Kaushik Patra	kpatra@sjsu.edu		Initial creation
//------------------------------------------------------------------------------------------
module PROC_SM(STATE,CLK,RST);
// list of inputs
input CLK, RST;
// list of outputs
output [2:0] STATE;
reg [2:0] state;
reg [2:0] next_state;

assign STATE = state;

initial
begin
  state = 3'bxx;
  next_state = `PROC_FETCH;
end

always @ (negedge RST)
begin
  state = 3'bxx;
  next_state = `PROC_FETCH;
end

always @ (posedge CLK)
begin
  case(next_state)
	`PROC_FETCH: begin state = next_state; next_state = `PROC_DECODE; end
	`PROC_DECODE: begin state = next_state; next_state = `PROC_EXE; end
	`PROC_EXE: begin state = next_state; next_state = `PROC_MEM; end
	`PROC_MEM: begin state = next_state; next_state = `PROC_WB; end
	`PROC_WB: begin state = next_state; next_state = `PROC_FETCH; end
  endcase
  
end

endmodule;