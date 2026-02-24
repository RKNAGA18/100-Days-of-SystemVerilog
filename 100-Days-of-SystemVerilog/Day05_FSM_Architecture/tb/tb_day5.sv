`timescale 1ns / 1ps

module tb_day5;

  // ==========================================
  // 1. CLOCK & RESET
  // ==========================================
  logic clk = 0;
  logic rst_n;
  always #5 clk = ~clk; // 100MHz clock (10ns period)

  // ==========================================
  // 2. SIGNAL DECLARATIONS
  // ==========================================
  // 41 & 42. Sequence Detectors
  logic seq_in, moore_det, mealy_det;

  // 43. CPU Control FSM
  logic [6:0] cpu_opcode;
  logic fetch_en, decode_en, exec_en, mem_en, wb_en;

  // 44. Packet Parser
  logic rx_valid, pkt_valid, pkt_err;
  logic [7:0] rx_byte, pkt_payload;

  // 45. I2C Arbiter
  logic i2c_sda_in, i2c_tx_bit, i2c_tx_en;
  logic i2c_sda_out, i2c_arb_lost;

  // 46, 47, 48. UART Subsystem (Loopback)
  logic baud_tick, uart_tx_wire, uart_busy, uart_rx_done;
  logic uart_start;
  logic [7:0] uart_tx_data, uart_rx_data;

  // 49 & 50. SPI Subsystem (Master talks to Slave)
  logic spi_start, spi_tx_done, spi_rx_valid;
  logic [7:0] spi_master_tx, spi_master_rx;
  logic [7:0] spi_slave_tx, spi_slave_rx;
  logic spi_sclk, spi_mosi, spi_miso, spi_cs_n;

  // ==========================================
  // 3. DUT INSTANTIATIONS
  // ==========================================
  moore_1011 dut41 (.clk(clk), .rst_n(rst_n), .seq_in(seq_in), .detected(moore_det));
  mealy_1011 dut42 (.clk(clk), .rst_n(rst_n), .seq_in(seq_in), .detected(mealy_det));
  
  cpu_control_fsm dut43 (.clk(clk), .rst_n(rst_n), .opcode(cpu_opcode), 
                         .fetch_en(fetch_en), .decode_en(decode_en), .exec_en(exec_en), 
                         .mem_en(mem_en), .wb_en(wb_en));

  packet_parser dut44 (.clk(clk), .rst_n(rst_n), .rx_valid(rx_valid), .rx_data(rx_byte),
                       .payload(pkt_payload), .payload_valid(pkt_valid), .error_flag(pkt_err));

  i2c_arbiter dut45 (.clk(clk), .rst_n(rst_n), .sda_in(i2c_sda_in), .tx_bit(i2c_tx_bit),
                     .transmit_en(i2c_tx_en), .sda_out(i2c_sda_out), .arb_lost(i2c_arb_lost));

  // UART System (Speeding up baud rate for fast simulation: Max Count = 4)
  uart_baud #(400, 100) dut46 (.clk(clk), .rst_n(rst_n), .baud_tick(baud_tick));
  
  uart_tx dut47 (.clk(clk), .rst_n(rst_n), .baud_tick(baud_tick), .tx_start(uart_start),
                 .tx_data(uart_tx_data), .tx_pin(uart_tx_wire), .tx_busy(uart_busy));
                 
  uart_rx dut48 (.clk(clk), .rst_n(rst_n), .baud_tick(baud_tick), .rx_pin(uart_tx_wire), // LOOPBACK!
                 .rx_data(uart_rx_data), .rx_done(uart_rx_done));

  // SPI System (Master connected directly to Slave)
  spi_master dut49 (.clk(clk), .rst_n(rst_n), .start_tx(spi_start), .tx_data(spi_master_tx),
                    .rx_data(spi_master_rx), .sclk(spi_sclk), .mosi(spi_mosi), .cs_n(spi_cs_n),
                    .miso(spi_miso), .tx_done(spi_tx_done));
                    
  spi_slave dut50 (.clk(clk), .rst_n(rst_n), .sclk(spi_sclk), .mosi(spi_mosi), .cs_n(spi_cs_n),
                   .tx_data(spi_slave_tx), .miso(spi_miso), .rx_data(spi_slave_rx), .rx_valid(spi_rx_valid));

  // ==========================================
  // 4. STIMULUS GENERATION
  // ==========================================
  initial begin
    $dumpfile("day5_sim.vcd");
    $dumpvars(0, tb_day5);

    // Initialize all inputs
    rst_n = 0;
    seq_in = 0; cpu_opcode = 0;
    rx_valid = 0; rx_byte = 0;
    i2c_sda_in = 1; i2c_tx_bit = 1; i2c_tx_en = 0;
    uart_start = 0; uart_tx_data = 0;
    spi_start = 0; spi_master_tx = 0; spi_slave_tx = 0;

    #25 rst_n = 1;

    $display("\n=======================================");
    $display("STARTING DAY 5: FSMs & PROTOCOLS");
    $display("=======================================\n");

    // 41 & 42. Sequence Detectors (Input: 1 0 1 1)
    $display(">> Injecting sequence 1-0-1-1 into Moore/Mealy Detectors...");
    #10 seq_in = 1; #10 seq_in = 0; #10 seq_in = 1; #10 seq_in = 1; #10 seq_in = 0; #20;

    // 43. CPU Control FSM
    $display(">> Simulating CPU Opcode Decode (Load Instruction)...");
    cpu_opcode = 7'b0000011; // RISC-V Load (needs MEMORY stage)
    #60; // Wait for FSM to cycle through Fetch -> Decode -> Exec -> Mem -> WB
    cpu_opcode = 7'b0110011; // RISC-V R-Type (skips MEMORY stage)
    #50;

    // 44. Packet Parser
    $display(">> Sending data packet to parser...");
    rx_valid = 1; rx_byte = 8'hAA; #10; // Start
    rx_valid = 1; rx_byte = 8'h01; #10; // Length = 1 byte
    rx_valid = 1; rx_byte = 8'h55; #10; // Payload = 0x55
    rx_valid = 1; rx_byte = 8'h55; #10; // CRC (0x00 ^ 0x55 = 0x55)
    rx_valid = 0; #20;

    // 45. I2C Arbiter
    $display(">> Simulating I2C Bus Collision...");
    i2c_tx_en = 1; i2c_tx_bit = 1; i2c_sda_in = 0; // We send 1, but wire is pulled to 0!
    #20; i2c_tx_en = 0; #20;

    // 46-48. UART Subsystem
    $display(">> Transmitting 0xC3 over UART Loopback...");
    uart_tx_data = 8'hC3;
    uart_start = 1; #10; uart_start = 0;
    wait(uart_rx_done == 1'b1); // Wait dynamically for the receiver to finish!
    #50;

    // 49-50. SPI Subsystem
    $display(">> Initiating SPI Master-to-Slave Exchange...");
    spi_master_tx = 8'hA5; // Master sends A5
    spi_slave_tx  = 8'h3C; // Slave replies with 3C
    spi_start = 1; #10; spi_start = 0;
    wait(spi_tx_done == 1'b1);
    #50;

    $display("\n=======================================");
    $display("DAY 5 TESTS COMPLETED SUCCESSFULLY");
    $display("Run 'make wave' to view the UART and SPI loopbacks!");
    $display("=======================================\n");
    
    $finish;
  end

endmodule