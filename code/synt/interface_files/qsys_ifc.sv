//////////////////////////////////////////////////////
//Name File     : qsys_ifc                          //
//Author        : Andrey Papushin                   //
//Email         : andrey.papushin@gmail.com         //
//Standart      : IEEE 1800—2009(SystemVerilog-2009)//
//Start design  : 03.08.2019                        //
//Last revision : 05.10.2019                        //
//////////////////////////////////////////////////////
module qsys_ifc
(
	input wire                              clock_50_b3b              , 
	input wire                              CLOCK_50_B5B              , 
	input wire                              clk_ddr3                  ,
	input wire                              clk_dsp                   ,
	input wire                              clk_result                ,
	output wire                             global_reset_n            ,
	output wire                             clk_100                   ,
	output wire                             clk_200                   ,
	                                                                  
	avl_stream_ifc.avl_stream_master_port   avl_stream_rgb_data_in    ,
	avl_stream_ifc.avl_stream_slave_port    avl_stream_rgb_data_result,
	avl_ifc.avl_master_port                 avl_ctrl_registers        ,
	pcie_ifc.pcie_port                      pcie                      ,
	ddr3_ifc.ddr3_port                      ddr3_mem                  
);
avl_ifc  #( 20, 32, 4)     avl_mm_rgb_data_in(); 
avl_ifc  #( 17, 32, 4)     avl_mm_mem_result();
//=======================================================
//  REG/WIRE declarations
//=======================================================
wire [3:0]	pio_led;
wire [3:0]	pio_button;
wire [31:0] pcie_hip_ctrl_test_in;//           .test_in
wire        pld_clk_clk;

//////////////////////
// PCIE RESET
wire        any_rstn;
reg         any_rstn_r /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=R102"  */;
reg         any_rstn_rr /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=R102"  */;
wire 			reconfig_xcvr_clk;
wire [5:0]  ltssm;
//=======================================================
//  Structural coding
//=======================================================

assign	pcie_hip_ctrl_test_in[4:0]  =  5'b01000;
assign	pcie_hip_ctrl_test_in[31:5] =  27'h5;
assign 	pcie.wake_n = 1'b1;
assign 	FAN_CTRL = 1'b1;
assign 	any_rstn = pcie.perst_n;

//reset Synchronizer
  always @(posedge reconfig_xcvr_clk or negedge any_rstn)
    begin
      if (any_rstn == 0)
        begin
          any_rstn_r <= 0;
          any_rstn_rr <= 0;
        end
      else
        begin
          any_rstn_r <= 1;
          any_rstn_rr <= any_rstn_r;
        end
    end

assign reconfig_xcvr_clk = clock_50_b3b;
  
assign avl_stream_rgb_data_in.data  = avl_mm_rgb_data_in.writedata[7:0];
assign avl_stream_rgb_data_in.valid = avl_mm_rgb_data_in.write;
assign avl_stream_rgb_data_in.sop   = avl_mm_rgb_data_in.write;
assign avl_stream_rgb_data_in.eop   = avl_mm_rgb_data_in.write;
assign avl_stream_rgb_data_in.sof   = avl_mm_rgb_data_in.write;
assign avl_stream_rgb_data_in.eof   = avl_mm_rgb_data_in.write;



assign avl_mm_mem_result.address    = avl_stream_rgb_data_result.data ;
assign avl_mm_mem_result.chipselect = avl_stream_rgb_data_result.valid;
assign avl_mm_mem_result.clken      = avl_stream_rgb_data_result.valid;
assign avl_mm_mem_result.write      = avl_stream_rgb_data_result.valid;
assign avl_mm_mem_result.writedata  = avl_stream_rgb_data_result.data ;
assign avl_mm_mem_result.byteenable = 4'b0001                         ;
wire clk_user_out;





q_sys q_sys_inst
(
	.alt_xcvr_reconfig_0_mgmt_clk_clk_clk                     (reconfig_xcvr_clk),
	.alt_xcvr_reconfig_0_mgmt_rst_reset_reset                 (!fixedclk_locked),
	.alt_xcvr_reconfig_0_reconfig_mgmt_address                (7'h0  ),
	.alt_xcvr_reconfig_0_reconfig_mgmt_read                   (1'b0  ),
	.alt_xcvr_reconfig_0_reconfig_mgmt_readdata               (32'h0 ),
	.alt_xcvr_reconfig_0_reconfig_mgmt_waitrequest            (1'b0  ),
	.alt_xcvr_reconfig_0_reconfig_mgmt_write                  (1'b0  ),
	.alt_xcvr_reconfig_0_reconfig_mgmt_writedata              (32'h0 ),
	
	.clk_dsp_clk                                              (clk_dsp        ), // <- обмен данными с ддр
	.clk_user_ddr3_clk                                        (clk_ddr3        ), // <-
	.clk_result_clk                                           (clk_result     ), // <- запись результата в память onchip
	.clk_user_out_clk                                         (clk_user_out   ), // ->
	
	.user_reset_reset_n                                       (global_reset_n), // ->
	
	.reset_reset_n                                            (global_reset_n) , //<-          
	.reset_result_reset                                     (global_reset_n),  //<-  
	//.reset_result_reset_req                                     (global_reset_n),  //<-  
	/////////////////
	.ctrl_registers_write                                     (avl_ctrl_registers.write     ),
	.ctrl_registers_chipselect                                (avl_ctrl_registers.chipselect),
	.ctrl_registers_address                                   (avl_ctrl_registers.address   ),
	.ctrl_registers_readdata                                  (avl_ctrl_registers.readdata  ),
	.ctrl_registers_writedata                                 (avl_ctrl_registers.writedata ),
	///////////////
	.rgb_data_in_write                                        (avl_mm_rgb_data_in.write     ),
	.rgb_data_in_chipselect                                   (avl_mm_rgb_data_in.chipselect),
	.rgb_data_in_address                                      (avl_mm_rgb_data_in.address   ),
	.rgb_data_in_readdata                                     (avl_mm_rgb_data_in.readdata  ),
	.rgb_data_in_writedata                                    (avl_mm_rgb_data_in.writedata ),
    ///////////////
	.mem_result_address                                       (avl_mm_mem_result.address    ),
	.mem_result_chipselect                                    (avl_mm_mem_result.chipselect ),
	.mem_result_clken                                         (avl_mm_mem_result.clken      ),
	.mem_result_write                                         (avl_mm_mem_result.write      ),
	.mem_result_readdata                                      (avl_mm_mem_result.readdata   ),
	.mem_result_writedata                                     (avl_mm_mem_result.writedata  ),
	.mem_result_byteenable                                    (avl_mm_mem_result.byteenable ),
	
	
	.ddr_mem_dsp_waitrequest_n                                (), 
	.ddr_mem_dsp_beginbursttransfer                           (),
	.ddr_mem_dsp_address                                      (),
	.ddr_mem_dsp_readdatavalid                                (),
	.ddr_mem_dsp_readdata                                     (),
	.ddr_mem_dsp_writedata                                    (),
	.ddr_mem_dsp_read                                         (),
	.ddr_mem_dsp_write                                        (),
	.ddr_mem_dsp_burstcount                                   (),
	.ddr_mem_dsp_byteenable                                   (),
	
	
	
	.pll_0_refclk_clk                                         (CLOCK_50_B5B),
	.clk_100_clk                                              (clk_100),
	.clk_200_clk                                              (clk_200),
	
	///////////////////////
	.memory_mem_a                                             (ddr3_mem.a             ), 
	.memory_mem_ba                                            (ddr3_mem.ba            ),
	.memory_mem_ck                                            (ddr3_mem.ck            ),
	.memory_mem_ck_n                                          (ddr3_mem.ck_n          ),
	.memory_mem_cke                                           (ddr3_mem.cke           ),
	.memory_mem_cs_n                                          (ddr3_mem.cs_n          ),
	.memory_mem_dm                                            (ddr3_mem.dm            ),
	.memory_mem_ras_n                                         (ddr3_mem.ras_n         ),
	.memory_mem_cas_n                                         (ddr3_mem.cas_n         ),
	.memory_mem_we_n                                          (ddr3_mem.we_n          ),
	.memory_mem_reset_n                                       (ddr3_mem.reset_n       ),
	.memory_mem_dq                                            (ddr3_mem.dq            ),
	.memory_mem_dqs                                           (ddr3_mem.dqs           ),
	.memory_mem_dqs_n                                         (ddr3_mem.dqs_n         ),
	.memory_mem_odt                                           (ddr3_mem.odt           ),
	.oct_rzqin                                                (ddr3_mem.rzq           ),
	
	.pcie_cv_hip_avmm_0_hip_ctrl_test_in                      (pcie_hip_ctrl_test_in),
	.pcie_cv_hip_avmm_0_hip_ctrl_simu_mode_pipe               (1'b0),
	.pcie_cv_hip_avmm_0_hip_pipe_sim_pipe_pclk_in             (1'b0),
	.pcie_cv_hip_avmm_0_hip_pipe_sim_pipe_rate                (),
	.pcie_cv_hip_avmm_0_hip_pipe_sim_ltssmstate               (),
	.pcie_cv_hip_avmm_0_hip_pipe_eidleinfersel0               (),
	.pcie_cv_hip_avmm_0_hip_pipe_eidleinfersel1               (),
	.pcie_cv_hip_avmm_0_hip_pipe_eidleinfersel2               (),
	.pcie_cv_hip_avmm_0_hip_pipe_eidleinfersel3               (),
	.pcie_cv_hip_avmm_0_hip_pipe_powerdown0                   (),
	.pcie_cv_hip_avmm_0_hip_pipe_powerdown1                   (),
	.pcie_cv_hip_avmm_0_hip_pipe_powerdown2                   (),
	.pcie_cv_hip_avmm_0_hip_pipe_powerdown3                   (),
	.pcie_cv_hip_avmm_0_hip_pipe_rxpolarity0                  (),
	.pcie_cv_hip_avmm_0_hip_pipe_rxpolarity1                  (),
	.pcie_cv_hip_avmm_0_hip_pipe_rxpolarity2                  (),
	.pcie_cv_hip_avmm_0_hip_pipe_rxpolarity3                  (),
	.pcie_cv_hip_avmm_0_hip_pipe_txcompl0                     (),
	.pcie_cv_hip_avmm_0_hip_pipe_txcompl1                     (),
	.pcie_cv_hip_avmm_0_hip_pipe_txcompl2                     (),
	.pcie_cv_hip_avmm_0_hip_pipe_txcompl3                     (),
	.pcie_cv_hip_avmm_0_hip_pipe_txdata0                      (),
	.pcie_cv_hip_avmm_0_hip_pipe_txdata1                      (),
	.pcie_cv_hip_avmm_0_hip_pipe_txdata2                      (),
	.pcie_cv_hip_avmm_0_hip_pipe_txdata3                      (),
	.pcie_cv_hip_avmm_0_hip_pipe_txdatak0                     (),
	.pcie_cv_hip_avmm_0_hip_pipe_txdatak1                     (),
	.pcie_cv_hip_avmm_0_hip_pipe_txdatak2                     (),
	.pcie_cv_hip_avmm_0_hip_pipe_txdatak3                     (),
	.pcie_cv_hip_avmm_0_hip_pipe_txdetectrx0                  (),
	.pcie_cv_hip_avmm_0_hip_pipe_txdetectrx1                  (),
	.pcie_cv_hip_avmm_0_hip_pipe_txdetectrx2                  (),
	.pcie_cv_hip_avmm_0_hip_pipe_txdetectrx3                  (),
	.pcie_cv_hip_avmm_0_hip_pipe_txelecidle0                  (),
	.pcie_cv_hip_avmm_0_hip_pipe_txelecidle1                  (),
	.pcie_cv_hip_avmm_0_hip_pipe_txelecidle2                  (),
	.pcie_cv_hip_avmm_0_hip_pipe_txelecidle3                  (),
	.pcie_cv_hip_avmm_0_hip_pipe_txswing0                     (),
	.pcie_cv_hip_avmm_0_hip_pipe_txswing1                     (),
	.pcie_cv_hip_avmm_0_hip_pipe_txswing2                     (),
	.pcie_cv_hip_avmm_0_hip_pipe_txswing3                     (),
	.pcie_cv_hip_avmm_0_hip_pipe_txmargin0                    (),
	.pcie_cv_hip_avmm_0_hip_pipe_txmargin1                    (),
	.pcie_cv_hip_avmm_0_hip_pipe_txmargin2                    (),
	.pcie_cv_hip_avmm_0_hip_pipe_txmargin3                    (),
	.pcie_cv_hip_avmm_0_hip_pipe_txdeemph0                    (),
	.pcie_cv_hip_avmm_0_hip_pipe_txdeemph1                    (),
	.pcie_cv_hip_avmm_0_hip_pipe_txdeemph2                    (),
	.pcie_cv_hip_avmm_0_hip_pipe_txdeemph3                    (),
	.pcie_cv_hip_avmm_0_hip_pipe_phystatus0                   (),
	.pcie_cv_hip_avmm_0_hip_pipe_phystatus1                   (),
	.pcie_cv_hip_avmm_0_hip_pipe_phystatus2                   (),
	.pcie_cv_hip_avmm_0_hip_pipe_phystatus3                   (),
	.pcie_cv_hip_avmm_0_hip_pipe_rxdata0                      (),
	.pcie_cv_hip_avmm_0_hip_pipe_rxdata1                      (),
	.pcie_cv_hip_avmm_0_hip_pipe_rxdata2                      (),
	.pcie_cv_hip_avmm_0_hip_pipe_rxdata3                      (),
	.pcie_cv_hip_avmm_0_hip_pipe_rxdatak0                     (),
	.pcie_cv_hip_avmm_0_hip_pipe_rxdatak1                     (),
	.pcie_cv_hip_avmm_0_hip_pipe_rxdatak2                     (),
	.pcie_cv_hip_avmm_0_hip_pipe_rxdatak3                     (),
	.pcie_cv_hip_avmm_0_hip_pipe_rxelecidle0                  (),
	.pcie_cv_hip_avmm_0_hip_pipe_rxelecidle1                  (),
	.pcie_cv_hip_avmm_0_hip_pipe_rxelecidle2                  (),
	.pcie_cv_hip_avmm_0_hip_pipe_rxelecidle3                  (),
	.pcie_cv_hip_avmm_0_hip_pipe_rxstatus0                    (),
	.pcie_cv_hip_avmm_0_hip_pipe_rxstatus1                    (),
	.pcie_cv_hip_avmm_0_hip_pipe_rxstatus2                    (),
	.pcie_cv_hip_avmm_0_hip_pipe_rxstatus3                    (),
	.pcie_cv_hip_avmm_0_hip_pipe_rxvalid0                     (),
	.pcie_cv_hip_avmm_0_hip_pipe_rxvalid1                     (),
	.pcie_cv_hip_avmm_0_hip_pipe_rxvalid2                     (),
	.pcie_cv_hip_avmm_0_hip_pipe_rxvalid3                     (),
	
	.pcie_cv_hip_avmm_0_hip_serial_rx_in0                     (pcie.rx_p[0]),
	.pcie_cv_hip_avmm_0_hip_serial_rx_in1                     (pcie.rx_p[1]),
	.pcie_cv_hip_avmm_0_hip_serial_rx_in2                     (pcie.rx_p[2]),
	.pcie_cv_hip_avmm_0_hip_serial_rx_in3                     (pcie.rx_p[3]),
	
	.pcie_cv_hip_avmm_0_hip_serial_tx_out0                    (pcie.tx_p[0]),
	.pcie_cv_hip_avmm_0_hip_serial_tx_out1                    (pcie.tx_p[1]),
	.pcie_cv_hip_avmm_0_hip_serial_tx_out2                    (pcie.tx_p[2]),
	.pcie_cv_hip_avmm_0_hip_serial_tx_out3                    (pcie.tx_p[3]),
	
	.pcie_cv_hip_avmm_0_npor_npor                             (any_rstn_rr),
	.pcie_cv_hip_avmm_0_npor_pin_perst                        (pcie.perst_n),
	.pcie_cv_hip_avmm_0_reconfig_clk_locked_fixedclk_locked   (fixedclk_locked),
	.pcie_cv_hip_avmm_0_refclk_clk                            (pcie.refclk_p), // <-
	
	.pio_key_external_connection_export                       (),
	.pio_led_external_connection_export                       ()
);



endmodule