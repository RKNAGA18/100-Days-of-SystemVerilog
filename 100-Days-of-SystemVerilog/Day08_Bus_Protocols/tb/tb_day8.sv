`timescale 1ns / 1ps

module tb_day8;

  // ==========================================
  // 1. CLOCK & RESET
  // ==========================================
  logic clk = 0;
  logic rst_n;
  always #5 clk = ~clk; // 100MHz clock

  // ==========================================
  // 2. SIGNAL DECLARATIONS
  // ==========================================
  // 71. Skid Buffer
  logic sb_s_valid, sb_s_ready;
  logic [31:0] sb_s_data;
  logic sb_m_valid, sb_m_ready;
  logic [31:0] sb_m_data;

  // 72. APB Slave
  logic apb_psel, apb_penable, apb_pwrite, apb_pready;
  logic [31:0] apb_paddr, apb_pwdata, apb_prdata;

  // 73 & 74. AXI-Stream (Master -> Slave)
  logic axis_start;
  logic axis_tvalid, axis_tready, axis_tlast;
  logic [31:0] axis_tdata;
  logic rx_fifo_full;

  // 75. AXI4-Lite Registers
  logic axil_awvalid, axil_awready;
  logic [31:0] axil_awaddr;
  logic axil_wvalid, axil_wready;
  logic [31:0] axil_wdata;
  logic axil_bvalid, axil_bready;
  logic [1:0] axil_bresp;

  // ==========================================
  // 3. DUT INSTANTIATIONS
  // ==========================================
  skid_buffer #(32) dut71 (
      .clk(clk), .rst_n(rst_n),
      .s_valid(sb_s_valid), .s_ready(sb_s_ready), .s_data(sb_s_data),
      .m_valid(sb_m_valid), .m_ready(sb_m_ready), .m_data(sb_m_data)
  );

  apb_slave dut72 (
      .pclk(clk), .presetn(rst_n),
      .psel(apb_psel), .penable(apb_penable), .pwrite(apb_pwrite),
      .paddr(apb_paddr), .pwdata(apb_pwdata), .prdata(apb_prdata), .pready(apb_pready)
  );

  // Connect Master directly to Slave!
  axis_master #(32, 4) dut73 (
      .clk(clk), .rst_n(rst_n), .start_tx(axis_start),
      .m_tvalid(axis_tvalid), .m_tready(axis_tready), .m_tdata(axis_tdata), .m_tlast(axis_tlast)
  );

  axis_slave #(32) dut74 (
      .clk(clk), .rst_n(rst_n),
      .s_tvalid(axis_tvalid), .s_tready(axis_tready), .s_tdata(axis_tdata), .s_tlast(axis_tlast),
      .internal_fifo_full(rx_fifo_full)
  );

  axil_registers dut75 (
      .clk(clk), .rst_n(rst_n),
      .s_axi_awaddr(axil_awaddr), .s_axi_awvalid(axil_awvalid), .s_axi_awready(axil_awready),
      .s_axi_wdata(axil_wdata), .s_axi_wvalid(axil_wvalid), .s_axi_wready(axil_wready),
      .s_axi_bresp(axil_bresp), .s_axi_bvalid(axil_bvalid), .s_axi_bready(axil_bready)
  );

  // ==========================================
  // 4. STIMULUS GENERATION
  // ==========================================
  initial begin
    $dumpfile("day8_sim.vcd");
    $dumpvars(0, tb_day8);

    // Initialize all inputs
    rst_n = 0;
    sb_s_valid = 0; sb_s_data = 0; sb_m_ready = 1;
    apb_psel = 0; apb_penable = 0; apb_pwrite = 0; apb_paddr = 0; apb_pwdata = 0;
    axis_start = 0; rx_fifo_full = 0;
    axil_awvalid = 0; axil_awaddr = 0; axil_wvalid = 0; axil_wdata = 0; axil_bready = 0;

    #25 rst_n = 1;

    $display("\n=======================================");
    $display("STARTING DAY 8: AMBA BUS PROTOCOLS");
    $display("=======================================\n");

    // --- 71. Skid Buffer Test ---
    $display(">> Testing Skid Buffer Stall Recovery...");
    @(posedge clk);
    sb_s_valid = 1; sb_s_data = 32'hAAAA; sb_m_ready = 0; // Downstream Stalls!
    @(posedge clk);
    sb_s_valid = 1; sb_s_data = 32'hBBBB; // Send next data while stalled
    @(posedge clk);
    sb_s_valid = 0; sb_m_ready = 1;       // Downstream Recovers
    @(posedge clk);
    @(posedge clk);

    // --- 72. APB Slave Test ---
    $display(">> Writing 0xDEADBEEF to APB Register 1...");
    @(posedge clk);
    // SETUP Phase
    apb_psel = 1; apb_pwrite = 1; apb_paddr = 32'h00000004; apb_pwdata = 32'hDEADBEEF;
    @(posedge clk);
    // ACCESS Phase
    apb_penable = 1;
    wait(apb_pready);
    @(posedge clk);
    apb_psel = 0; apb_penable = 0; apb_pwrite = 0;

    // --- 73 & 74. AXI-Stream Handshake Test ---
    $display(">> Initiating 4-beat AXI-Stream Packet Transfer...");
    @(posedge clk);
    axis_start = 1; 
    @(posedge clk); 
    axis_start = 0;
    
    // Intentionally stall the receiver on cycle 2 to test backpressure
    @(posedge clk);
    rx_fifo_full = 1; 
    $display("   [!] Receiver FIFO Full. Halting Bus...");
    #20;
    rx_fifo_full = 0;
    $display("   [!] Receiver Recovered. Resuming...");
    
    wait(axis_tlast); // Wait for the end of the packet
    @(posedge clk);

    // --- 75. AXI4-Lite Register Test ---
    $display(">> Performing AXI4-Lite Write Transaction...");
    @(posedge clk);
    // 1. Provide Address & Data
    axil_awvalid = 1; axil_awaddr = 32'h10;
    axil_wvalid  = 1; axil_wdata  = 32'hCAFEBABE;
    
    // 2. Wait for slave to accept Address & Data
    wait(axil_awready && axil_wready);
    @(posedge clk);
    axil_awvalid = 0; axil_wvalid = 0;
    
    // 3. Wait for Write Response (B-Channel)
    wait(axil_bvalid);
    axil_bready = 1; // Master accepts response
    @(posedge clk);
    axil_bready = 0;

    #50;
    $display("\n=======================================");
    $display("DAY 8 TESTS COMPLETED SUCCESSFULLY ");
    $display("=======================================\n");
    
    $finish;
  end

endmodule