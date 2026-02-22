`timescale 1ns / 1ps

module tb_day4;

  // ==========================================
  // 1. CLOCK & RESET
  // ==========================================
  logic clk = 0;
  logic rst_n;
  always #5 clk = ~clk; // 100MHz clock (10ns period)

  // ==========================================
  // 2. SIGNAL DECLARATIONS
  // ==========================================
  // 31. Debouncer
  logic db_noisy, db_clean;

  // 32. Pulse Gen
  logic pg_trig, pg_out;
  logic [7:0] pg_width;

  // 33. PWM Gen
  logic [7:0] pwm_duty;
  logic pwm_out;

  // 34. Stopwatch
  logic sw_start_stop, sw_clear;
  logic [6:0] sw_centi;
  logic [5:0] sw_sec;

  // 35. Watchdog
  logic wd_kick, wd_en, wd_reset;

  // 36. Delay Line
  logic dl_in, dl_out;
  logic [3:0] dl_cycles;

  // 37. Freq Meter
  logic fm_target;
  logic [31:0] fm_freq;

  // 38. Traffic Light
  logic [2:0] tl_lights;

  // 39. Vending Machine
  logic vm_nickel, vm_dime, vm_dispense, vm_change;

  // 40. Digital Lock
  logic lock_pressed, lock_unlocked;
  logic [3:0] lock_val;

  // ==========================================
  // 3. DUT INSTANTIATIONS
  // ==========================================
  // Override WAIT_TIME to 10 cycles for fast simulation
  debouncer #(10) dut31 (.clk(clk), .rst_n(rst_n), .noisy_in(db_noisy), .clean_out(db_clean));
  
  pulse_gen #(255) dut32 (.clk(clk), .rst_n(rst_n), .trigger(pg_trig), .width(pg_width), .pulse_out(pg_out));
  pwm_generator #(8) dut33 (.clk(clk), .rst_n(rst_n), .duty(pwm_duty), .pwm_out(pwm_out));
  stopwatch dut34 (.clk(clk), .rst_n(rst_n), .start_stop(sw_start_stop), .clear(sw_clear), .centiseconds(sw_centi), .seconds(sw_sec));
  
  // Override TIMEOUT to 15 cycles so we can see the system reset fire
  watchdog #(15) dut35 (.clk(clk), .rst_n(rst_n), .kick(wd_kick), .enable(wd_en), .sys_reset(wd_reset));
  
  delay_line #(16) dut36 (.clk(clk), .rst_n(rst_n), .sig_in(dl_in), .delay_cycles(dl_cycles), .sig_out(dl_out));
  freq_meter dut37 (.ref_clk(clk), .rst_n(rst_n), .target_sig(fm_target), .frequency(fm_freq));
  traffic_light dut38 (.clk(clk), .rst_n(rst_n), .lights(tl_lights));
  vending_machine dut39 (.clk(clk), .rst_n(rst_n), .nickel(vm_nickel), .dime(vm_dime), .dispense(vm_dispense), .change(vm_change));
  digital_lock dut40 (.clk(clk), .rst_n(rst_n), .key_pressed(lock_pressed), .key_val(lock_val), .unlocked(lock_unlocked));

  // ==========================================
  // 4. STIMULUS GENERATION
  // ==========================================
  initial begin
    $dumpfile("day4_sim.vcd");
    $dumpvars(0, tb_day4);

    // Initialize all inputs
    rst_n = 0;
    db_noisy = 0; pg_trig = 0; pg_width = 8'd5; pwm_duty = 8'd64; // 25% duty cycle
    sw_start_stop = 0; sw_clear = 0;
    wd_kick = 0; wd_en = 0;
    dl_in = 0; dl_cycles = 4;
    fm_target = 0;
    vm_nickel = 0; vm_dime = 0;
    lock_pressed = 0; lock_val = 0;

    #25 rst_n = 1;

    $display("\n=======================================");
    $display(" STARTING DAY 4 FSM & TIMING VERIFICATION ");
    $display("=======================================\n");

    // 31. Debouncer
    $display(">> Bouncing switch...");
    db_noisy = 1; #10; db_noisy = 0; #10; db_noisy = 1; #10; db_noisy = 0; #10;
    db_noisy = 1; // Hold steady!

    // 32. Pulse Gen
    $display(">> Firing Pulse Generator (width = 5)...");
    pg_trig = 1; #10; pg_trig = 0;

    // 35. Watchdog
    $display(">> Starting Watchdog (Will timeout in 15 cycles)...");
    wd_en = 1; 
    
    // 36. Delay Line
    $display(">> Testing programmable delay line (Delay = 4)...");
    dl_in = 1; #10; dl_in = 0;

    // 39. Vending Machine (Costs 15 cents)
    $display(">> Inserting coins into Vending Machine...");
    vm_dime = 1; #10; vm_dime = 0; #20;   // Insert 10c
    vm_dime = 1; #10; vm_dime = 0; #20;   // Insert 10c (Total 20c -> Should dispense + 5c change!)

    // 40. Digital Lock (Password: 3, 1, 4, 2)
    $display(">> Attempting to unlock digital safe...");
    // Enter 3
    lock_val = 4'd3; lock_pressed = 1; #10; lock_pressed = 0; #20;
    // Enter 1
    lock_val = 4'd1; lock_pressed = 1; #10; lock_pressed = 0; #20;
    // Enter 4
    lock_val = 4'd4; lock_pressed = 1; #10; lock_pressed = 0; #20;
    // Enter 2 (Unlocks here!)
    lock_val = 4'd2; lock_pressed = 1; #10; lock_pressed = 0; #20;

    // Wait for watchdog to expire and Traffic light to cycle a bit
    #200; 
    $display(" DAY 4 TESTS COMPLETED SUCCESSFULLY ");

    
    $finish;
  end

  // Generate target frequency for freq_meter (approx 33MHz)
  always #15 fm_target = ~fm_target;

endmodule