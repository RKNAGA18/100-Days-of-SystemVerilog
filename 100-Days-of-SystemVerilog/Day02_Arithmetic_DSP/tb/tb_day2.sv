`timescale 1ns / 1ps

module tb_day2;

  // ==========================================
  // 1. CLOCK & RESET
  // ==========================================
  logic clk = 0; // FIX: Initialize clock to 0!
  logic rst_n;
  always #5 clk = ~clk; // 100MHz clock

  // ==========================================
  // 2. SIGNAL DECLARATIONS
  // ==========================================
  
  // 11. Subtractor
  logic [31:0] sub_a, sub_b, sub_diff;
  logic sub_borrow;

  // 12. Array Multiplier
  logic [3:0] am_a, am_b;
  logic [7:0] am_prod;

  // 13. Sequential Multiplier
  logic seq_start, seq_ready;
  logic [15:0] seq_a, seq_b;
  logic [31:0] seq_prod;

  // 14. Restoring Divison
  logic rdiv_start, rdiv_ready;
  logic [15:0] rdiv_num, rdiv_den, rdiv_quo, rdiv_rem;

  // 15. Non-Restoring Division
  logic ndiv_start, ndiv_ready;
  logic [15:0] ndiv_num, ndiv_den, ndiv_quo, ndiv_rem;

  // 16. MAC Unit
  logic mac_clear;
  logic [15:0] mac_a, mac_b;
  logic [31:0] mac_accum;

  // 17. FIR Filter
  logic [15:0] fir_data [4];
  logic [15:0] fir_coeffs [4];
  logic [31:0] fir_out;

  // 18. FP Adder (Align stage)
  logic [15:0] fp_a, fp_b;
  logic [10:0] fp_man_a, fp_man_b;
  logic [4:0]  fp_exp;

  // 19. Leading Zero Counter
  logic [31:0] lzc_data;
  logic [5:0]  lzc_count;

  // 20. Popcount
  logic [31:0] pop_data;
  logic [5:0]  pop_count;

  // ==========================================
  // 3. DUT INSTANTIATIONS
  // ==========================================
  nbit_subtractor #(32) dut11 (.a(sub_a), .b(sub_b), .diff(sub_diff), .borrow_out(sub_borrow));
  array_multiplier #(4) dut12 (.a(am_a), .b(am_b), .prod(am_prod));
  seq_multiplier #(16)  dut13 (.clk(clk), .rst_n(rst_n), .start(seq_start), .a(seq_a), .b(seq_b), .prod(seq_prod), .ready(seq_ready));
  restoring_div #(16)   dut14 (.clk(clk), .rst_n(rst_n), .start(rdiv_start), .dividend(rdiv_num), .divisor(rdiv_den), .quotient(rdiv_quo), .remainder(rdiv_rem), .ready(rdiv_ready));
  non_restoring_div #(16) dut15 (.clk(clk), .rst_n(rst_n), .start(ndiv_start), .dividend(ndiv_num), .divisor(ndiv_den), .quotient(ndiv_quo), .remainder(ndiv_rem), .ready(ndiv_ready));
  mac_unit #(16)        dut16 (.clk(clk), .rst_n(rst_n), .clear(mac_clear), .a(mac_a), .b(mac_b), .accum(mac_accum));
  fir_filter #(4,16)    dut17 (.data_in(fir_data), .coeffs(fir_coeffs), .filter_out(fir_out));
  fp_adder_align        dut18 (.a(fp_a), .b(fp_b), .aligned_mantissa_a(fp_man_a), .aligned_mantissa_b(fp_man_b), .common_exp(fp_exp));
  lzc #(32)             dut19 (.data(lzc_data), .count(lzc_count));
  popcount #(32)        dut20 (.data(pop_data), .count(pop_count));

  // ==========================================
  // 4. STIMULUS GENERATION
  // ==========================================
  initial begin
    $dumpfile("day2_sim.vcd");
    $dumpvars(0, tb_day2);

    // Initialize
    rst_n = 0;
    seq_start = 0; rdiv_start = 0; ndiv_start = 0; mac_clear = 0;
    
    #20 rst_n = 1; // Release reset

    $display("\n=======================================");
    $display(" STARTING DAY 2 ARITHMETIC VERIFICATION ");
    $display("=======================================\n");

    // 11. Subtractor
    sub_a = 100; sub_b = 25; #10;
    $display("11. Subtractor: %0d - %0d = %0d (Borrow: %b)", sub_a, sub_b, sub_diff, sub_borrow);

    // 12. Array Multiplier
    am_a = 4'd7; am_b = 4'd5; #10;
    $display("12. Array Mult: %0d * %0d = %0d", am_a, am_b, am_prod);

    // 13. Seq Multiplier
    seq_a = 16'd120; seq_b = 16'd5; seq_start = 1;
    #20 seq_start = 0; // FIX: Hold for 2 clock cycles
    wait(seq_ready);
    $display("13. Seq Mult  : %0d * %0d = %0d", seq_a, seq_b, seq_prod);

    // 14. Restoring Div
    rdiv_num = 16'd150; rdiv_den = 16'd12; rdiv_start = 1;
    #20 rdiv_start = 0; // FIX: Hold for 2 clock cycles
    wait(rdiv_ready);
    $display("14. Restoring Div : 150 / 12 = %0d (Rem: %0d)", rdiv_quo, rdiv_rem);

    // 15. Non-Restoring Div
    ndiv_num = 16'd200; ndiv_den = 16'd15; ndiv_start = 1;
    #20 ndiv_start = 0; // FIX: Hold for 2 clock cycles
    wait(ndiv_ready);
    $display("15. Non-Restoring : 200 / 15 = %0d (Rem: %0d)", ndiv_quo, ndiv_rem);

    // 16. MAC Unit
    mac_clear = 1; #20; mac_clear = 0; // FIX: Hold for 2 clock cycles
    mac_a = 5; mac_b = 4; #20; // Accum = 20
    mac_a = 2; mac_b = 3; #20; // Accum = 20 + 6 = 26
    $display("16. MAC Unit  : Final Accum = %0d", mac_accum);

    // 17. FIR Filter
    fir_data[0] = 1; fir_coeffs[0] = 2;
    fir_data[1] = 2; fir_coeffs[1] = 2;
    fir_data[2] = 3; fir_coeffs[2] = 2;
    fir_data[3] = 4; fir_coeffs[3] = 2; #10;
    $display("17. FIR Filter: Out = %0d", fir_out);

    // 19. LZC
    lzc_data = 32'h000F_0000; #10;
    $display("19. LZC       : Zeros before first 1 = %0d", lzc_count);

    // 20. Popcount
    pop_data = 32'b1010_1010_1111_0000_1111_1111_0000_1111; #10;
    $display("20. Popcount  : Total 1s = %0d", pop_count);

    $display("\n=======================================");
    $display(" DAY 2 TESTS COMPLETED SUCCESSFULLY ");
    $display("=======================================\n");
    $finish;
  end

endmodule