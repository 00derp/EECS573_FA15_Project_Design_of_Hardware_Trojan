/////////////////////////////////////////////////////////////////////////
//                                                                     //
//                                                                     //
//   Modulename :  visual_testbench.v                                  //
//                                                                     //
//  Description :  Testbench module for the verisimple pipeline        //
//                   for the visual debugger                           //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps

extern void initcurses(int,int,int,int,int,int,int,int,int,int);
extern void flushpipe();
extern void waitforresponse();
extern void initmem();
extern int get_instr_at_pc(int);
extern int not_valid_pc(int);

module testbench();
	// Registers and wires used in the testbench
	logic        clock;
	logic        reset;
	logic [31:0] clock_count;
	logic [31:0] instr_count;
	int          wb_fileno;

	logic  [1:0] proc2mem_command;
	logic [63:0] proc2mem_addr;
	logic [63:0] proc2mem_data;
	logic  [3:0] mem2proc_response;
	logic [63:0] mem2proc_data;
	logic  [3:0] mem2proc_tag;

	logic  [3:0] pipeline_completed_insts;
	logic  [3:0] pipeline_error_status;
	logic  [4:0] pipeline_commit_wr_idx;
	logic [63:0] pipeline_commit_wr_data;
	logic        pipeline_commit_wr_en;
	logic [63:0] pipeline_commit_NPC;


	logic [63:0] if_NPC_out;
	logic [31:0] if_IR_out;
	logic        if_valid_inst_out;
	logic [63:0] if_id_NPC;
	logic [31:0] if_id_IR;
	logic        if_id_valid_inst;
	logic [63:0] id_rs_NPC;
	logic [31:0] id_rs_IR;
	logic        id_rs_valid_inst;
	logic [63:0] rs_ex_NPC;
	logic [31:0] rs_ex_IR;
	logic        rs_ex_valid_inst;
	logic [63:0] ex_mem_NPC;
	logic [31:0] ex_mem_IR;
	logic        ex_mem_valid_inst;

	// Strings to hold instruction opcode
	logic  [8*7:0] if_instr_str;
	logic  [8*7:0] id_instr_str;
	logic  [8*7:0] ex_instr_str;
	logic  [8*7:0] mem_instr_str;
	logic  [8*7:0] wb_instr_str;


	// Instantiate the Pipeline
	`DUT(pipeline) pipeline_0 (// Inputs
					   .clock             (clock),
					   .reset             (reset),
					   .mem2proc_response (mem2proc_response),
					   .mem2proc_data     (mem2proc_data),
					   .mem2proc_tag      (mem2proc_tag),

						// Outputs
					   .proc2mem_command  (proc2mem_command),
					   .proc2mem_addr     (proc2mem_addr),
					   .proc2mem_data     (proc2mem_data),

					   .pipeline_completed_insts(pipeline_completed_insts),
					   .pipeline_error_status(pipeline_error_status),
					   .pipeline_commit_wr_data(pipeline_commit_wr_data),
					   .pipeline_commit_wr_idx(pipeline_commit_wr_idx),
					   .pipeline_commit_wr_en(pipeline_commit_wr_en),
					   .pipeline_commit_NPC(pipeline_commit_NPC),

					   .if_NPC_out(if_NPC_out),
					   .if_IR_out(if_IR_out),
					   .if_valid_inst_out(if_valid_inst_out),
					   .if_id_NPC(if_id_NPC),
					   .if_id_IR(if_id_IR),
					   .if_id_valid_inst(if_id_valid_inst),
					   .id_rs_NPC(id_rs_NPC),
					   .id_rs_IR(id_rs_IR),
					   .id_rs_valid_inst(id_rs_valid_inst),
					   .rs_ex_NPC(rs_ex_NPC),
					   .rs_ex_IR(rs_ex_IR),
					   .rs_ex_valid_inst(rs_ex_valid_inst),
					   .ex_mem_NPC(ex_mem_NPC),
					   .ex_mem_IR(ex_mem_IR),
					   .ex_mem_valid_inst(ex_mem_valid_inst)
					  );


	// Instantiate the Data Memory
	mem memory (// Inputs
			.clk               (clock),
			.proc2mem_command  (proc2mem_command),
			.proc2mem_addr     (proc2mem_addr),
			.proc2mem_data     (proc2mem_data),

			 // Outputs

			.mem2proc_response (mem2proc_response),
			.mem2proc_data     (mem2proc_data),
			.mem2proc_tag      (mem2proc_tag)
		   );

  // Generate System Clock
  always
  begin
    #(`VERILOG_CLOCK_PERIOD/2.0);
    clock = ~clock;
  end

  // Count the number of posedges and number of instructions completed
  // till simulation ends
  always @(posedge clock)
  begin
    if(reset)
    begin
      clock_count <= `SD 0;
      instr_count <= `SD 0;
    end
    else
    begin
      clock_count <= `SD (clock_count + 1);
      instr_count <= `SD (instr_count + pipeline_completed_insts);
    end
  end  

  initial
  begin
    clock = 0;
    reset = 0;

    // Call to initialize visual debugger
    // *Note that after this, all stdout output goes to visual debugger*
    // each argument is number of registers/signals for the group
    // (IF, IF/ID, ID, ID/RS, RS, RS/EX, EX, EX/MEM, MEM, Misc)
    initcurses(8,5,20,23,33,19,13,8,13,2);

    // Pulse the reset signal
    reset = 1'b1;
    @(posedge clock);
    @(posedge clock);

    // Read program contents into memory array
    $readmemh("program.mem", memory.unified_memory);

    @(posedge clock);
    @(posedge clock);
    `SD;
    // This reset is at an odd time to avoid the pos & neg clock edges
    reset = 1'b0;
  end

  always @(negedge clock)
  begin
    if(!reset)
    begin
      `SD;
      `SD;

      // deal with any halting conditions
      if(pipeline_error_status!=`NO_ERROR)
      begin
        #100
        $display("\nDONE\n");
        waitforresponse();
        flushpipe();
        $finish;
      end

    end
  end 

  // This block is where we dump all of the signals that we care about to
  // the visual debugger.  Notice this happens at *every* clock edge.
  integer i;
  always @(clock) begin
    #2;

    // Dump clock and time onto stdout
    $display("c%h%7.0d",clock,clock_count);
    $display("t%8.0f",$time);
    $display("z%h",reset);

    // dump PRF contents
    $write("a");
    for(i = 0; i < `PRF_size; i=i+1)
    begin
      $write("%h", pipeline_0.ex_stage_0.regfile.registers[i]);
    end
    $display("");

    // dump IR information so we can see which instruction
    // is in each stage
    $write("p");
    $write("%h%h%h%h%h%h%h%h%h%h ",
            pipeline_0.if_IR_out, pipeline_0.if_valid_inst_out,
            pipeline_0.if_id_IR,  pipeline_0.if_id_valid_inst,
            pipeline_0.id_rs_IR,  pipeline_0.id_rs_valid_inst,
            pipeline_0.rs_ex_IR, pipeline_0.rs_ex_valid_inst,
            pipeline_0.ex_mem_IR, pipeline_0.ex_mem_valid_inst);
    $display("");
    
    // Dump interesting register/signal contents onto stdout
    // format is "<reg group prefix><name> <width in hex chars>:<data>"
    // Current register groups (and prefixes) are:
    // f: IF   d: ID   r: RS e: EX   m: MEM    v: misc. reg
    // g: IF/ID   h: ID/RS  i: RS/EX  j: EX/MEM

    // IF signals (8) - prefix 'f'
    $display("fNPC 16:%h",          pipeline_0.if_NPC_out);
    $display("fIR 8:%h",            pipeline_0.if_IR_out);
    $display("fImem_addr 16:%h",    pipeline_0.if_stage_0.proc2Imem_addr);
    $display("fif_valid 1:%h",      pipeline_0.if_valid_inst_out);
    $display("fif_pred_target 4:%h", pipeline_0.if_predicted_target_addr_out);
    $display("fif_pred_taken 1:%h",  pipeline_0.if_predicted_taken_out);
    $display("fPC_en 1:%h",         pipeline_0.if_stage_0.PC_enable);
    $display("fPC_reg 16:%h",       pipeline_0.if_stage_0.PC_reg);

    // IF/ID signals (5) - prefix 'g'
    $display("genable 1:%h",        pipeline_0.if_id_enable);
    $display("gNPC 16:%h",          pipeline_0.if_id_NPC);
    $display("gIR 8:%h",            pipeline_0.if_id_IR);
    $display("gvalid 1:%h",         pipeline_0.if_id_valid_inst);
    $display("gpred_target 4:%h",   pipeline_0.if_id_predicted_target_addr);

    // ID signals (20) - prefix 'd'
    $display("dopa_sel 1:%h",       pipeline_0.id_opa_select_out);
    $display("dopb_sel 1:%h",       pipeline_0.id_opb_select_out);
    $display("dsrcA_PRF 16:%h",     pipeline_0.id_srcA_PRF_num_out);
    $display("dsrcB_PRF 16:%h",     pipeline_0.id_srcB_PRF_num_out);
    $display("dARF_num 16:%h",      pipeline_0.id_ARF_num_out);
    $display("ddest_PRF 16:%h",     pipeline_0.id_dest_PRF_num_out);
    $display("dsrcA_valid 1:%h",    pipeline_0.id_srcA_valid_out);
    $display("dsrcB_valid 1:%h",    pipeline_0.id_srcB_valid_out);
    $display("dalu_func 2:%h",      pipeline_0.id_alu_func_out);
    $display("drd_mem 1:%h",        pipeline_0.id_rd_mem_out);
    $display("dwr_mem 1:%h",        pipeline_0.id_wr_mem_out);
    $display("dldl_mem 1:%h",       pipeline_0.id_ldl_mem_out);
    $display("dstc_mem 1:%h",       pipeline_0.id_stc_mem_out);
    $display("dcond_br 1:%h",       pipeline_0.id_cond_branch_out);
    $display("duncond_br 1:%h",     pipeline_0.id_uncond_branch_out);
    $display("dhalt 1:%h",          pipeline_0.id_halt_out);
    $display("dcpuid 1:%h",         pipeline_0.id_cpuid_out);
    $display("dillegal 1:%h",       pipeline_0.id_illegal_out);
    $display("dvalid 1:%h",         pipeline_0.id_valid_inst_out);
    $display("dno_PRF 1:%h",        pipeline_0.id_no_free_PRF_out);

    // ID/RS signals (23) - prefix 'h'
    $display("henable 1:%h",        pipeline_0.id_rs_enable);
    $display("hvalid 1:%h",         pipeline_0.id_rs_valid_inst);
    $display("hIR 8:%h",            pipeline_0.id_rs_IR); 
    $display("hNPC 16:%h",          pipeline_0.id_rs_NPC); 
    $display("hopa_sel 1:%h",       pipeline_0.id_rs_opa_select);
    $display("hopb_sel 1:%h",       pipeline_0.id_rs_opb_select);
    $display("hsrcA_PRF 16:%h",     pipeline_0.id_rs_srcA_PRF_num);
    $display("hsrcB_PRF 16:%h",     pipeline_0.id_rs_srcB_PRF_num);
    $display("hARF_num 16:%h",      pipeline_0.id_rs_ARF_num);
    $display("hdest_PRF 16:%h",     pipeline_0.id_rs_dest_PRF_num);
    $display("hsrcA_valid 1:%h",    pipeline_0.id_rs_srcA_valid);
    $display("hsrcB_valid 1:%h",    pipeline_0.id_rs_srcB_valid);
    $display("halu_func 2:%h",      pipeline_0.id_rs_alu_func);
    $display("hrd_mem 1:%h",        pipeline_0.id_rs_rd_mem);
    $display("hwr_mem 1:%h",        pipeline_0.id_rs_wr_mem);
    $display("hldl_mem 1:%h",       pipeline_0.id_rs_ldl_mem);
    $display("hstc_mem 1:%h",       pipeline_0.id_rs_stc_mem);
    $display("hcond_br 1:%h",       pipeline_0.id_rs_cond_branch);
    $display("huncond_br 1:%h",     pipeline_0.id_rs_uncond_branch);
    $display("hhalt 1:%h",          pipeline_0.id_rs_halt);
    $display("hcpuid 1:%h",         pipeline_0.id_rs_cpuid);
    $display("hillegal 1:%h",       pipeline_0.id_rs_illegal);
    $display("hpred_target 4:%h",   pipeline_0.id_rs_predicted_target_addr);

    // RS signals (33) - prefix 'r'
    $display("rRS_full 1:%h",        pipeline_0.RS_full_out);
    $display("rRS_valid_inst 1:%h",  pipeline_0.RS_valid_inst_out);
    $display("rRS_uncond_br 16:%h",  pipeline_0.RS_uncond_branch_out);
    $display("rRS_cond_br 16:%h",    pipeline_0.RS_cond_branch_out);
    $display("rRS_rd_mem 16:%h",     pipeline_0.RS_rd_mem_out);
    $display("rRS_wr_mem 16:%h",     pipeline_0.RS_wr_mem_out);
    $display("rRS_ldl 1:%h",         pipeline_0.RS_ldl_out);
    $display("rRS_stc 1:%h",         pipeline_0.RS_stc_out);
    $display("rRS_cpuid 2:%h",       pipeline_0.RS_cpuid_out);
    $display("rRS_opa_sel 1:%h",     pipeline_0.RS_opa_select_out);
    $display("rRS_opb_sel 1:%h",     pipeline_0.RS_opb_select_out);
    $display("rRS_opcode 2:%h",      pipeline_0.RS_opcode_out);
    $display("rRS_IR 8:%h",          pipeline_0.RS_IR_out);
    $display("rRS_PC_plus_4 4:%h",   pipeline_0.RS_PC_plus_4_out);
    $display("rRS_pred_addr 4:%h",   pipeline_0.RS_predicted_target_addr_out);
    $display("rRS_srcA_PRF 16:%h",   pipeline_0.RS_srcA_PRF_num_out);
    $display("rRS_srcB_PRF 16:%h",   pipeline_0.RS_srcB_PRF_num_out);
    $display("rRS_dest_PRF 16:%h",   pipeline_0.RS_dest_PRF_num_out);
    $display("rRS_ROB_num 16:%h",    pipeline_0.RS_ROB_num_out);
    $display("rROB_ARF_num 16:%h",   pipeline_0.ROB_ARF_num_out);
    $display("rROB_PRF_num 16:%h",   pipeline_0.ROB_PRF_num_out);
    $display("rROB_PC_plus_4 4:%h",  pipeline_0.ROB_PC_plus_4_out);
    $display("rROB_NPC 4:%h",        pipeline_0.ROB_NPC_out);
    $display("rROB_br_mispred 16:%h",pipeline_0.ROB_branch_mispredict_out);
    $display("rROB_is_store 16:%h",  pipeline_0.ROB_is_store_inst_out);
    $display("rROB_is_branch 16:%h", pipeline_0.ROB_is_branch_inst_out);
    $display("rROB_commit 1:%h",     pipeline_0.ROB_commit_out);
    $display("rROB_dispatch_disable 1:%h",    pipeline_0.ROB_dispatch_disable);
    $display("rROB_head 16:%h",      pipeline_0.ROB_head);
    $display("rROB_tail 16:%h",      pipeline_0.ROB_tail);
    $display("rROB_illegal 1:%h",    pipeline_0.ROB_illegal_out);
    $display("rROB_halt 1:%h",       pipeline_0.ROB_halt_out);
    $display("rmem_inst_dispatch_disable 1:%h",       pipeline_0.mem_inst_dispatch_disable);

    // RS/EX signals (19) - prefix 'i'
    $display("ienable 1:%h",        pipeline_0.rs_ex_enable);
    $display("icond_br 1:%h",       pipeline_0.rs_ex_cond_branch);
    $display("iuncond_br 1:%h",     pipeline_0.rs_ex_uncond_branch);
    $display("ild_inst 1:%h",       pipeline_0.rs_ex_ld_inst);
    $display("ist_inst 1:%h",       pipeline_0.rs_ex_st_inst);
    $display("ildl_inst 1:%h",      pipeline_0.rs_ex_ldl_inst);
    $display("istc_inst 1:%h",      pipeline_0.rs_ex_stc_inst);
    $display("icpuid 1:%h",         pipeline_0.rs_ex_cpuid);
    $display("iopa_sel 1:%h",       pipeline_0.rs_ex_opa_select);
    $display("iopb_sel 1:%h",       pipeline_0.rs_ex_opb_select);
    $display("iopcode 16:%h",       pipeline_0.rs_ex_opcode);
    $display("ipred_target 4:%h",   pipeline_0.rs_ex_predicted_target_addr);
    $display("isrcA_PRF 16:%h",     pipeline_0.rs_ex_srcA_PRF_num);
    $display("isrcB_PRF 16:%h",     pipeline_0.rs_ex_srcB_PRF_num);
    $display("idest_PRF 16:%h",     pipeline_0.rs_ex_dest_PRF_num);
    $display("iROB_num 16:%h",      pipeline_0.rs_ex_ROB_num); 
    $display("iNPC 16:%h",          pipeline_0.rs_ex_NPC); 
    $display("iIR 8:%h",            pipeline_0.rs_ex_IR); 
    $display("ivalid 1:%h",         pipeline_0.rs_ex_valid_inst);

    // EX signals (13) - prefix 'e'
    $display("eMULT_busy 1:%h",     pipeline_0.ex_MULT_busy_out);
    $display("eCDB_arb_stall 1:%h", pipeline_0.ex_CDB_arb_stall_out);
    $display("ebranch_mispredict 1:%h",   pipeline_0.ex_branch_mispredict_out);
    $display("ebranch_inst 1:%h",   pipeline_0.ex_branch_inst_out);
    $display("ebranch_taken 1:%h",  pipeline_0.ex_branch_taken_out);
    $display("eex_CDB_tag 16:%h",   pipeline_0.ex_CDB_tag_out);
    $display("eex_result 16:%h",    pipeline_0.ex_result_out);
    $display("eex_NPC 4:%h",        pipeline_0.ex_NPC_out);
    $display("ememory_data 16:%h",  pipeline_0.ex_memory_data_out);
    $display("ememory_addr 16:%h",  pipeline_0.ex_memory_addr_out);
    $display("edebug 16:%h",        pipeline_0.debug_out);
    $display("eopa_mux 16:%h",      pipeline_0.ex_stage_0.opa_mux_out);
    $display("eopb_mux 16:%h",      pipeline_0.ex_stage_0.opb_mux_out);

    // EX/MEM signals (8) - prefix 'j'
    $display("jNPC 16:%h",          pipeline_0.ex_mem_NPC);
    $display("jIR 8:%h",            pipeline_0.ex_mem_IR);
    $display("jvalid 1:%h",         pipeline_0.ex_mem_valid_inst);
    $display("jDcache_addr 16:%h",  pipeline_0.ex_mem_proc2Dcache_addr);
    $display("jDcache_data 16:%h",  pipeline_0.ex_mem_proc2Dcache_data);
    $display("jDcache_command 16:%h",  pipeline_0.ex_mem_proc2Dcache_command);
    $display("jPRF_num 16:%h",      pipeline_0.ex_mem_PRF_num);
    $display("jROB_num 16:%h",      pipeline_0.ex_mem_ROB_num);

    // MEM signals (13) - prefix 'm'
    $display("mDcache_done 1:%h",   pipeline_0.Dcache_done);
    $display("mDcache_data 16:%h",  pipeline_0.Dcache_data);
    $display("mDcache2mem_command 1:%h",  pipeline_0.Dcache2mem_command);
    $display("mDcache2mem_addr 16:%h",    pipeline_0.Dcache2mem_addr);
    $display("mDcache2mem_data 16:%h",    pipeline_0.Dcache2mem_data);
    $display("mwrite 16:%h",        pipeline_0.D_data_write);
    $display("mcurrent_index 1:%h", pipeline_0.D_current_index);
    $display("mcurrent_tag 3:%h",   pipeline_0.D_current_tag);
    $display("mlast_index 1:%h",    pipeline_0.D_last_index);
    $display("mlast_tag 3:%h",      pipeline_0.D_last_tag);
    $display("mwrite_enable 1:%h",  pipeline_0.D_data_write_enable);
    $display("mdirty_en 1:%h",      pipeline_0.D_dirty_en);
    $display("mdirty_wr 1:%h",      pipeline_0.D_dirty_wr);

    // Misc signals (2) - prefix 'v'
    $display("vcompleted 1:%h",     pipeline_0.pipeline_completed_insts);
    $display("vpipe_err 1:%h",      pipeline_error_status);
    /*$display("vI$_data 16:%h",      pipeline_0.Icache_data_out);
    $display("vI$_valid 1:%h",      pipeline_0.Icache_valid_out);
    $display("vI$_rd_idx 2:%h",     pipeline_0.Icache_rd_idx);
    $display("vI$_rd_tag 6:%h",     pipeline_0.Icache_rd_tag);
    $display("vI$_wr_idx 2:%h",     pipeline_0.Icache_wr_idx);
    $display("vI$_wr_tag 6:%h",     pipeline_0.Icache_wr_tag);
    $display("vI$_wr_en 1:%h",      pipeline_0.Icache_wr_en);
*/

    // must come last
    $display("break");

    // This is a blocking call to allow the debugger to control when we
    // advance the simulation
    waitforresponse();
  end
endmodule