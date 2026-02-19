`timescale 1ns / 1ps
import alu_pkg::*; // Import your ALU opcodes

module tb_day1;

  // --- Signals for ALU ---
  logic [31:0] alu_a, alu_b, alu_out;
  alu_op_e     alu_op;
  logic        alu_zero;

  // --- Signals for Gray Converter ---
  logic [3:0] bin_in, gray_out, bin_out;
  logic [3:0] gray_in; // dummy signal for the converter input

  // --- Signals for Priority Encoder ---
  logic [7:0] req_in;
  logic [2:0] grant_out;
  logic       any_req_out;

  // --- Instantiations ---
  alu_core #(32) dut_alu (
    .a(alu_a), .b(alu_b), .op(alu_op), 
    .result(alu_out), .zero_flag(alu_zero)
  );

  gray_converter #(4) dut_gray (
    .bin_in(bin_in), .gray_in(gray_out), 
    .bin_out(bin_out), .gray_out(gray_out)
  );

  priority_encoder_8to3 dut_arbiter (
    .req(req_in), .grant(grant_out), .any_req(any_req_out)
  );

  // --- Stimulus Generation ---
  initial begin
    // Setup waveform dumping for GTKWave
    $dumpfile("day1_sim.vcd");
    $dumpvars(0, tb_day1);

    $display("=== STARTING DAY 1 VERIFICATION ===");

    // 1. Test ALU with Randomization
    $display("Testing ALU...");
    for (int i = 0; i < 5; i++) begin
      alu_a  = $urandom();
      alu_b  = $urandom();
      // Cast a random 3-bit number to the enum type
      alu_op = alu_op_e'($urandom_range(0, 6)); 
      #10; // Wait 10ns for propagation
      $display("ALU: A=%h, B=%h, OP=%s -> OUT=%h", alu_a, alu_b, alu_op.name(), alu_out);
    end

    // 2. Test Gray Converter
    $display("\nTesting Binary <-> Gray Converter...");
    for (int i = 0; i < 4; i++) begin
      bin_in = i[3:0];
      #10;
      $display("BIN: %b -> GRAY: %b -> BACK_TO_BIN: %b", bin_in, gray_out, bin_out);
      if (bin_in !== bin_out) $error("Gray conversion mismatch!");
    end

    // 3. Test Priority Encoder
    $display("\nTesting Priority Encoder...");
    req_in = 8'b0001_0000; #10;
    $display("REQ: %b -> GRANT: %d (Expected 4)", req_in, grant_out);
    
    req_in = 8'b1010_1000; #10; // Multiple requests
    $display("REQ: %b -> GRANT: %d (Expected 3, lowest bit wins)", req_in, grant_out);

    $display("=== SIMULATION COMPLETE ===");
    $finish;
  end
endmodule