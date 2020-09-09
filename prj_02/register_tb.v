
// Name: proj_2_tb.v
// Module: DA_VINCI_TB
// 
//
// Monitors:  DATA_W: Data to be written at address ADDR_W
//            ADDR_W : Address of the memory location to be accessed
//	      ADDR_R1: Memory location to be read at ADDR_R1
//	      ARRR_R2: Memory location to be read at ADDR_R2
//            READ : Read signal
//            WRITE: Write signal
//
// Input:   CLK  : Clock signal
//          RST  : Reset signal
//	    DATA_R1: Data at R1 address
//	    DATA_R2: Data at R2 address
//
// Notes: - Testbench for  register system
//
// Revision History:
//
// Version	Date		Who		email			note
//------------------------------------------------------------------------------------------
// 1.0          10/18/2019      Shuang Pan	shuang.pan@sjsu.edu	Test bench for regs
//------------------------------------------------------------------------------------------
`include "prj_definition.v"
module REGISTER_TB;
// read address
reg [`REG_ADDR_INDEX_LIMIT:0] ADDR_R1;
reg [`REG_ADDR_INDEX_LIMIT:0] ADDR_R2;
//write
reg [`REG_ADDR_INDEX_LIMIT:0] ADDR_W;
reg [`DATA_INDEX_LIMIT:0] DATA_W;

// reset
reg READ, WRITE, RST;
// data register
integer i; // index for memory operation
integer no_of_test, no_of_pass;

// wire lists
wire  CLK;
wire [`DATA_INDEX_LIMIT:0] DATA_R1;
wire [`DATA_INDEX_LIMIT:0] DATA_R2;

// Clock generator instance
CLK_GENERATOR clk_gen_inst(.CLK(CLK));

// Register Instance
REGISTER_FILE_32x32 reg_inst(.DATA_R1(DATA_R1), .DATA_R2(DATA_R2), .ADDR_R1(ADDR_R1), .ADDR_R2(ADDR_R2), 
                      .DATA_W(DATA_W), .ADDR_W(ADDR_W), .READ(READ), .WRITE(WRITE), .CLK(CLK), .RST(RST));

initial
begin
RST = 1'b1;
READ = 1'b0;
WRITE = 1'b0;
no_of_test = 0;
no_of_pass = 0;

// Start the operation
#10    RST = 1'b0;
#10    RST = 1'b1;
// Write cycle
for(i = 1;i < 10; i = i + 1)
begin
#10   DATA_W = i; READ = 1'b0; WRITE = 1'b1; ADDR_W = i;
end
//read cycle
#10   READ=1'b0; WRITE=1'b0;
#5    no_of_test = no_of_test + 1;
      if (DATA_R1 !== {`DATA_WIDTH{1'bz}} && DATA_R2 !== {`DATA_WIDTH{1'bz}})
        $write("[TEST] Read %1b, Write %1b, expecting 32'hzzzzzzzz, got %8h [FAILED]\n", READ, WRITE, DATA_R1);
      else 
	no_of_pass  = no_of_pass + 1;

//test write data from address R1
for(i = 1; i < 10; i = i + 1)
begin
#5      READ=1'b1; WRITE=1'b0; ADDR_R1 = i;
#5      no_of_test = no_of_test + 1;
        if (DATA_R1 !== i)
	    $write("[TEST] Read %1b, Write %1b, expecting %8h, got %8h [FAILED]\n", READ, WRITE, i, DATA_R1);
        else 
	    no_of_pass  = no_of_pass + 1;
end
#20
//test write data from address R2
for(i = 1; i < 10; i = i + 1)
begin
#5      READ = 1'b1; WRITE = 1'b0; ADDR_R2 = i;
#5      no_of_test = no_of_test + 1;
        if (DATA_R2 !== i)
	    $write("[TEST] Read %1b, Write %1b, expecting %8h, got %8h [FAILED]\n", READ, WRITE, i, DATA_R2);
        else 
	    no_of_pass  = no_of_pass + 1;
end

#10    READ = 1'b0; WRITE = 1'b0; // No op

#10 $write("\n");
    $write("\tTotal number of tests %d\n", no_of_test);
    $write("\tTotal number of pass  %d\n", no_of_pass);
    $write("\n");
    $stop;
end
endmodule;
