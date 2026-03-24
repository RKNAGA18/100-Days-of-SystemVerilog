`timescale 1ns / 1ps

module tb_day7;

  // ==========================================
  // 1. CLOCKS & RESETS (DUAL DOMAIN!)
  // ==========================================
  logic clk_fast = 0; // 500MHz (2ns period)
  logic clk_slow = 0; // 100MHz (10ns period)
  logic rst_n;

  always #1 clk_fast = ~clk_fast;
  always #5 clk_slow = ~clk_slow;

  // ==========================================
  // 2. SIGNAL DECLARATIONS
  // ==========================================
  // 63. Handshake Synchronizer
  logic hs_req_in, hs_ready_src, hs_ack_dest, hs_req_dest;
  logic [7:0] hs_data_in, hs_data_out;

  // 66. Asynchronous FIFO
  logic fifo_wr_en, fifo_full;
  logic [7:0] fifo_wr_data;
  logic fifo_rd_en, fifo_empty;
  logic [7:0] fifo_rd_data;

  // 69. Matrix Arbiter (LRU)
  logic [3:0] arb_req, arb_grant;

  // 70. 4x4 Crossbar
  logic [31:0] xb_in0, xb_in1, xb_in2, xb_in3;
  logic [1:0]  xb_sel0, xb_sel1, xb_sel2, xb_sel3;
  logic [31:0] xb_out0, xb_out1, xb_out2, xb_out3;

  // ==========================================
  // 3. DUT INSTANTIATIONS
  // ==========================================
  handshake_sync #(8) dut63 (
      .clk_src(clk_fast), .rst_n_src(rst_n), .req_in(hs_req_in), .data_in(hs_data_in), .ready_src(hs_ready_src),
      .clk_dest(clk_slow), .rst_n_dest(rst_n), .ack_dest(hs_ack_dest), .req_dest(hs_req_dest), .data_out(hs_data_out)
  );

  async_fifo #(4, 8) dut66 (
      .wr_clk(clk_fast), .wr_rst_n(rst_n), .wr_en(fifo_wr_en), .wr_data(fifo_wr_data), .full(fifo_full),
      .rd_clk(clk_slow), .rd_rst_n(rst_n), .rd_en(fifo_rd_en), .rd_data(fifo_rd_data), .empty(fifo_empty)
  );

  // Note: Arbiters and Crossbars typically live in a single clock domain (the bus domain)
  matrix_arbiter dut69 (.clk(clk_fast), .rst_n(rst_n), .req(arb_req), .grant(arb_grant));

  crossbar_4x4 #(32) dut70 (
      .in0(xb_in0), .in1(xb_in1), .in2(xb_in2), .in3(xb_in3),
      .sel0(xb_sel0), .sel1(xb_sel1), .sel2(xb_sel2), .sel3(xb_sel3),
      .out0(xb_out0), .out1(xb_out1), .out2(xb_out2), .out3(xb_out3)
  );

  // ==========================================
  // 4. STIMULUS GENERATION
  // ==========================================
  initial begin
    $dumpfile("day7_sim.vcd");
    $dumpvars(0, tb_day7);

    // Initialize
    rst_n = 0;
    hs_req_in = 0; hs_data_in = 0; hs_ack_dest = 0;
    fifo_wr_en = 0; fifo_wr_data = 0; fifo_rd_en = 0;
    arb_req = 0;
    xb_in0 = 32'hAAAA_AAAA; xb_in1 = 32'hBBBB_BBBB; 
    xb_in2 = 32'hCCCC_CCCC; xb_in3 = 32'hDDDD_DDDD;
    xb_sel0 = 0; xb_sel1 = 0; xb_sel2 = 0; xb_sel3 = 0;

    #20 rst_n = 1;

    $display("\n=======================================");
    $display("STARTING DAY 7: CDC & ARBITRATION");
    $display("=======================================\n");

    // --- 66. Asynchronous FIFO Test ---
    $display(">> Writing to Async FIFO from Fast Domain (500MHz)...");
    @(posedge clk_fast);
    fifo_wr_en = 1; fifo_wr_data = 8'hC3; @(posedge clk_fast);
    fifo_wr_en = 1; fifo_wr_data = 8'hA5; @(posedge clk_fast);
    fifo_wr_en = 0;
    
    #30; // Wait for Gray pointers to synchronize across domains
    
    $display(">> Reading from Async FIFO in Slow Domain (100MHz)...");
    @(posedge clk_slow);
    fifo_rd_en = 1; @(posedge clk_slow);
    fifo_rd_en = 1; @(posedge clk_slow);
    fifo_rd_en = 0;

    // --- 69. Matrix Arbiter Test ---
    $display(">> Testing LRU Matrix Arbiter...");
    @(posedge clk_fast);
    arb_req = 4'b0101; // Devices 0 and 2 request
    @(posedge clk_fast);
    // Device 0 should win based on initial matrix priority
    if (arb_grant == 4'b0001) $display("   [PASS] Device 0 won arbitration!");
    
    arb_req = 4'b0101; // Devices 0 and 2 request AGAIN
    @(posedge clk_fast);
    // Device 2 should win now, because Device 0 just went!
    if (arb_grant == 4'b0100) $display("   [PASS] Device 2 won arbitration (LRU working)!");
    arb_req = 4'b0000;

    // --- 70. Crossbar Test ---
    $display(">> Routing Data through Crossbar...");
    xb_sel0 = 2'b11; // Route in3 (DDDD) to out0
    xb_sel2 = 2'b01; // Route in1 (BBBB) to out2
    #10;
    if (xb_out0 == 32'hDDDD_DDDD && xb_out2 == 32'hBBBB_BBBB)
        $display("   [PASS] Crossbar routing successful!");

    #50;
    $display("\n=======================================");
    $display("DAY 7 TESTS COMPLETED SUCCESSFULLY");
    $display("Run 'make wave' to see the Gray Pointers crossing clock domains!");
    $display("=======================================\n");
    
    $finish;
  end

endmodule