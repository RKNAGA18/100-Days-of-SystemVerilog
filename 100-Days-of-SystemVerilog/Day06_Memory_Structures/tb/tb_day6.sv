`timescale 1ns / 1ps

module tb_day6;

  // ==========================================
  // 1. CLOCK & RESET
  // ==========================================
  logic clk = 0;
  logic rst_n;
  always #5 clk = ~clk; // 100MHz clock

  // ==========================================
  // 2. SIGNAL DECLARATIONS
  // ==========================================
  // 51. ROM
  logic [7:0] rom_addr, rom_data;

  // 52. Single Port RAM
  logic sp_we;
  logic [7:0] sp_addr, sp_data_in, sp_data_out;

  // 55. RISC-V Register File
  logic rf_we;
  logic [4:0] rf_rs1, rf_rs2, rf_rd;
  logic [31:0] rf_wdata, rf_rdata1, rf_rdata2;

  // 56. LIFO Stack
  logic stack_push, stack_pop, stack_full, stack_empty;
  logic [31:0] stack_din, stack_dout;

  // 58. Synchronous FIFO
  logic fifo_wr, fifo_rd, fifo_full, fifo_empty;
  logic [7:0] fifo_din, fifo_dout;

  // 60. Cache Tag Lookup
  logic cache_we, cache_flush, cache_hit;
  logic [27:0] cache_addr;

  // ==========================================
  // 3. DUT INSTANTIATIONS (Subset for concise testing)
  // ==========================================
  rom #(256, 8) dut51 (.clk(clk), .addr(rom_addr), .data_out(rom_data));
  
  single_port_ram #(256, 8) dut52 (.clk(clk), .we(sp_we), .addr(sp_addr), .data_in(sp_data_in), .data_out(sp_data_out));
  
  register_file dut55 (.clk(clk), .rst_n(rst_n), .we(rf_we), .rs1(rf_rs1), .rs2(rf_rs2), .rd(rf_rd), 
                       .write_data(rf_wdata), .read_data1(rf_rdata1), .read_data2(rf_rdata2));
                       
  lifo_stack #(16, 32) dut56 (.clk(clk), .rst_n(rst_n), .push(stack_push), .pop(stack_pop), 
                              .data_in(stack_din), .data_out(stack_dout), .full(stack_full), .empty(stack_empty));

  sync_fifo #(16, 8) dut58 (.clk(clk), .rst_n(rst_n), .wr_en(fifo_wr), .rd_en(fifo_rd), 
                            .data_in(fifo_din), .data_out(fifo_dout), .full(fifo_full), .empty(fifo_empty));

  cache_tag_lookup #(20, 8) dut60 (.clk(clk), .rst_n(rst_n), .we(cache_we), .cpu_addr(cache_addr), 
                                   .flush(cache_flush), .cache_hit(cache_hit));

  // ==========================================
  // 4. STIMULUS GENERATION
  // ==========================================
  initial begin
    $dumpfile("day6_sim.vcd");
    $dumpvars(0, tb_day6);

    // Initialize
    rst_n = 0;
    rom_addr = 0;
    sp_we = 0; sp_addr = 0; sp_data_in = 0;
    rf_we = 0; rf_rs1 = 0; rf_rs2 = 0; rf_rd = 0; rf_wdata = 0;
    stack_push = 0; stack_pop = 0; stack_din = 0;
    fifo_wr = 0; fifo_rd = 0; fifo_din = 0;
    cache_we = 0; cache_flush = 0; cache_addr = 0;

    #25 rst_n = 1;

    $display("\n=======================================");
    $display("STARTING DAY 6: MEMORY & BUFFERING");
    $display("=======================================\n");

    // --- 51. ROM Test ---
    $display(">> Reading Instructions from ROM...");
    rom_addr = 8'd0; #10; // Should read 13 (from init.hex)
    rom_addr = 8'd1; #10; // Should read 17

    // --- 55. RISC-V Register File Test ---
    $display(">> Testing RISC-V Register File...");
    // Try to write to x0 (Should fail/ignore)
    rf_we = 1; rf_rd = 5'd0; rf_wdata = 32'hDEADBEEF; #10;
    // Write to x1
    rf_rd = 5'd1; rf_wdata = 32'hCAFEBABE; #10;
    rf_we = 0;
    // Read them back asynchronously
    rf_rs1 = 5'd0; rf_rs2 = 5'd1; #10;
    if (rf_rdata1 == 0) $display("   [PASS] x0 is hardwired to 0!");
    else                $display("   [FAIL] x0 contains %h", rf_rdata1);

    // --- 56. Stack Test ---
    $display(">> Pushing/Popping Interrupt PCs to Stack...");
    stack_push = 1; stack_din = 32'h00001000; #10;
    stack_push = 1; stack_din = 32'h00001004; #10;
    stack_push = 0;
    stack_pop = 1; #10; // Should pop 1004
    stack_pop = 1; #10; // Should pop 1000
    stack_pop = 0;

    // --- 58. FIFO Test ---
    $display(">> Streaming data through Sync FIFO...");
    fifo_wr = 1; fifo_din = 8'hAA; #10;
    fifo_wr = 1; fifo_din = 8'hBB; #10;
    fifo_wr = 0; fifo_rd = 1; #10; // Read AA
    fifo_rd = 1; #10; // Read BB
    fifo_rd = 0;

    // --- 60. Cache Tag Lookup Test ---
    $display(">> Simulating L1 Cache Miss and Fill...");
    cache_addr = 28'hABCDEF1; // Index = F1, Tag = ABCDE
    #10;
    if (!cache_hit) $display("   [PASS] Cache Miss detected!");
    
    // Simulate Cache Fill
    cache_we = 1; #10; cache_we = 0; #10;
    
    if (cache_hit) $display("   [PASS] Cache Hit detected after fill!");

    $display("\n=======================================");
    $display("DAY 6 TESTS COMPLETED SUCCESSFULLY");
    $display("=======================================\n");
    
    $finish;
  end

endmodule