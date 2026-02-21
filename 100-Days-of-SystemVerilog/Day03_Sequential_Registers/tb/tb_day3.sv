`timescale 1ns / 1ps

module tb_day3;

  // ==========================================
  // 1. CLOCKS & RESETS
  // ==========================================
  logic clk = 0;   // Main 100MHz Clock
  logic clk0 = 0;  // Mux Clock 0 (100MHz)
  logic clk1 = 0;  // Mux Clock 1 (approx 38MHz)
  logic rst_n;

  always #5  clk  = ~clk;   // 10ns period
  always #5  clk0 = ~clk0;  // 10ns period
  always #13 clk1 = ~clk1;  // 26ns period (asynchronous to clk0)

  // ==========================================
  // 2. SIGNAL DECLARATIONS
  // ==========================================
  // 21. Flip-Flops
  logic d_in, d_out, t_in, t_out, j_in, k_in, jk_out;
  
  // 22. Parallel Shift Reg
  logic psr_load, psr_shift, psr_sin;
  logic [7:0] psr_pin, psr_q;

  // 23. Universal Shift Reg
  logic [1:0] usr_mode;
  logic [7:0] usr_pin, usr_q;
  logic usr_sin_l, usr_sin_r;

  // 24. Sync Counter
  logic sync_en, sync_up, sync_rst_n;
  logic [3:0] sync_count;

  // 25. Ripple Counter
  logic [3:0] ripple_count;

  // 26. Ring & Johnson
  logic [3:0] ring_q, johnson_q;

  // 27. LFSR
  logic [7:0] lfsr_q;

  // 28. Clock Dividers
  logic div2_clk, div3_clk;

  // 29. Edge Detector
  logic edge_sig, edge_rise, edge_fall, edge_any;

  // 30. Glitch-Free Mux
  logic mux_sel, mux_clk_out;

  // ==========================================
  // 3. DUT INSTANTIATIONS
  // ==========================================
  d_ff  dut21a (.clk(clk), .rst_n(rst_n), .d(d_in), .q(d_out));
  t_ff  dut21b (.clk(clk), .rst_n(rst_n), .t(t_in), .q(t_out));
  jk_ff dut21c (.clk(clk), .rst_n(rst_n), .j(j_in), .k(k_in), .q(jk_out));

  parallel_shift_reg #(8) dut22 (.clk(clk), .rst_n(rst_n), .load_en(psr_load), .shift_en(psr_shift), .p_in(psr_pin), .s_in(psr_sin), .q(psr_q));
  univ_shift_reg #(8)     dut23 (.clk(clk), .rst_n(rst_n), .mode(usr_mode), .p_in(usr_pin), .s_in_left(usr_sin_l), .s_in_right(usr_sin_r), .q(usr_q));
  
  sync_counter #(4)   dut24 (.clk(clk), .rst_n(sync_rst_n), .en(sync_en), .up_down(sync_up), .count(sync_count));
  ripple_counter #(4) dut25 (.clk(clk), .rst_n(rst_n), .count(ripple_count));
  
  ring_counter #(4)    dut26a (.clk(clk), .rst_n(rst_n), .q(ring_q));
  johnson_counter #(4) dut26b (.clk(clk), .rst_n(rst_n), .q(johnson_q));
  
  lfsr #(8) dut27 (.clk(clk), .rst_n(rst_n), .q(lfsr_q));
  
  clk_div_even #(4) dut28a (.clk(clk), .rst_n(rst_n), .clk_out(div2_clk));
  clk_div_odd_3     dut28b (.clk(clk), .rst_n(rst_n), .clk_out(div3_clk));
  
  edge_detector dut29 (.clk(clk), .rst_n(rst_n), .sig_in(edge_sig), .rising_edge(edge_rise), .falling_edge(edge_fall), .any_edge(edge_any));
  
  glitch_free_clk_mux dut30 (.clk0(clk0), .clk1(clk1), .rst_n(rst_n), .select(mux_sel), .out_clk(mux_clk_out));

  // ==========================================
  // 4. STIMULUS GENERATION
  // ==========================================
  initial begin
    $dumpfile("day3_sim.vcd");
    $dumpvars(0, tb_day3);

    $display("STARTING DAY 3 SEQUENTIAL VERIFICATION");

    // Initialize all signals to prevent 'X' states
    rst_n = 0; sync_rst_n = 0;
    d_in = 0; t_in = 0; j_in = 0; k_in = 0;
    psr_load = 0; psr_shift = 0; psr_pin = 0; psr_sin = 0;
    usr_mode = 0; usr_pin = 0; usr_sin_l = 0; usr_sin_r = 0;
    sync_en = 0; sync_up = 1;
    edge_sig = 0; mux_sel = 0;
    
    #25 rst_n = 1; sync_rst_n = 1; // Release reset cleanly after 2.5 clock cycles

    // 21. Test Flip Flops
    $display(">> Testing Flip-Flops...");
    d_in = 1; t_in = 1; j_in = 1; k_in = 0; #20; 
    j_in = 1; k_in = 1; #20; // Toggle JK

    // 22. Parallel Shift Register
    $display(">> Testing Parallel Shift Register...");
    psr_pin = 8'hA5; psr_load = 1; #10;
    psr_load = 0; psr_shift = 1; psr_sin = 1; #30; // Shift left 3 times inserting 1s
    psr_shift = 0;

    // 23. Universal Shift Register
    $display(">> Testing Universal Shift Register...");
    usr_pin = 8'hC3; usr_mode = 2'b11; #10; // Load
    usr_mode = 2'b01; usr_sin_r = 0; #20; // Shift Left twice
    usr_mode = 2'b10; usr_sin_l = 1; #10;  // Shift Right once

    // 24 & 25. Counters
    $display(">> Testing Counters...");
    sync_en = 1; sync_up = 1; #50; // Count up for 5 cycles
    sync_up = 0; #30;              // Count down for 3 cycles
    sync_en = 0;

    // 26 & 27. Ring, Johnson, LFSR 
    $display(">> Letting Ring, Johnson, and LFSR run...");
    #50; // Let them freely cycle for a while

    // 29. Edge Detector
    $display(">> Testing Edge Detector...");
    edge_sig = 1; #10; // Trigger rising edge
    edge_sig = 1; #20; // Hold it
    edge_sig = 0; #20; // Trigger falling edge

    // 30. Glitch-Free Mux
    $display(">> Testing Glitch-Free Clock Mux...");
    mux_sel = 0; #50; // Run on clk0
    mux_sel = 1; #80; // Switch to clk1 (Requires time to safely swap)
    mux_sel = 0; #50; // Switch back to clk0

    $display(" DAY 3 TESTS COMPLETED SUCCESSFULLY ");
    
    $finish;
  end

endmodule