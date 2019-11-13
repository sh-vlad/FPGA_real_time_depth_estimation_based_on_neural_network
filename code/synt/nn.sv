//Author: Vlad Sharshin 
//e-mail: shvladspb@gmail.com
module nn
#(
    parameter DATA_WIDTH    = 8
)
(
    input wire                                  clk,
    
    input wire                                  reset_n,
	input wire signed  [DATA_WIDTH-1:0]          data_i/*[STRING2MATRIX_CHAN_NUM]*/, 
    input wire                                  data_valid_i,    
    input wire						            sop_i,
    input wire						            eop_i,
    input wire						            sof_i,
    input wire						            eof_i,   

    output logic signed [DATA_WIDTH-1:0]        data_o,
    output logic                                data_valid_o,
	output logic					            sop_o,
    output logic					            eop_o,
    output logic					            sof_o,
    output logic					            eof_o                                                        
);
wire afi_half_clk;


wire signed [7:0]                 data_to7                ;
wire                              data_valid_to7          ;   
wire                              sop_to7                 ;
wire                              eop_to7                 ;
wire                              sof_to7                 ;
wire                              eof_to7                 ;

wire signed [7:0]                 data_from7              ;
wire                              data_valid_from7        ;   
wire                              sop_from7               ;
wire                              eop_from7               ;
wire                              sof_from7               ;
wire                              eof_from7               ;

wire signed [7:0]                 data              ;
wire                              data_valid        ;   
wire                              sop               ;
wire                              eop               ;
wire                              sof               ;
wire                              eof               ;

wire [5:0]                        ddr_fifo_rd;
wire [5:0]                        ddr_fifo_afull;  
wire [5:0]                        ddr_fifo_aempty;

//
	wire         avl_beginbursttransfer; // mm_interconnect_0:if0_avl_0_beginbursttransfer -> if0:avl_burstbegin_0
	wire  [63:0] avl_readdata;           // if0:avl_rdata_0 -> mm_interconnect_0:if0_avl_0_readdata
	wire         avl_waitrequest;        // if0:avl_ready_0 -> mm_interconnect_0:if0_avl_0_waitrequest
	wire  [26:0] avl_address;            // mm_interconnect_0:if0_avl_0_address -> if0:avl_addr_0
	wire         avl_read;               // mm_interconnect_0:if0_avl_0_read -> if0:avl_read_req_0
	wire   [7:0] avl_byteenable;         // mm_interconnect_0:if0_avl_0_byteenable -> if0:avl_be_0
	wire         avl_readdatavalid;      // if0:avl_rdata_valid_0 -> mm_interconnect_0:if0_avl_0_readdatavalid
	wire         avl_write;              // mm_interconnect_0:if0_avl_0_write -> if0:avl_write_req_0
	wire  [63:0] avl_writedata;          // mm_interconnect_0:if0_avl_0_writedata -> if0:avl_wdata_0
	wire   [7:0] avl_burstcount;         // mm_interconnect_0:if0_avl_0_burstcount -> if0:avl_size_0

//
conv_nn                          
#(                               
    .DATA_WIDTH    ( 8 )         
)                                
conv_nn_inst                     
(                                
	.clk                         ( clk          ),
    .reset_n                     ( reset_n          ),
    .data_valid_i                ( data_valid_i           ),
	.data_i                      ( data_i           ),
    .sop_i                       ( sop_i            ),
    .eop_i                       ( eop_i            ),
    .sof_i                       ( sof_i            ),
    .eof_i                       ( eof_i            ),
    .data_o                      ( data_to7             ),
    .data_valid_o                ( data_valid_to7       ),
	.sop_o                       ( sop_to7              ),
    .eop_o                       ( eop_to7              ),
    .sof_o                       ( sof_to7              ),
    .eof_o                       ( eof_to7              ),
    .ddr_fifo_rd                 ( ddr_fifo_rd      ), 
    .ddr_fifo_afull              ( ddr_fifo_afull   ) 
);                                                  
//
max_pool_7
#(
    .DATA_WIDTH     ( 8         ),
    .CHANNEL_NUM    ( 256       ),
    .HOLD_DATA      ( 8         ),
    .STRING_LEN     ( 7         )
)
max_pool_7_inst
(
    .clk            ( clk                ),
    .reset_n        ( reset_n            ),
    .data_i         ( data_to7           ),  
	.valid_i        ( data_valid_to7     ),    
    .sop_i          ( sop_to7            ),
    .eop_i          ( eop_to7            ),
    .sof_i          ( sof_to7            ),
    .eof_i          ( eof_to7            ),   
    .data_o         ( data_from7         ),
    .data_valid_o   ( data_valid_from7   ),
    .sop_o          ( sop_from7          ),
    .eop_o          ( eop_from7          ),
    .sof_o          ( sof_from7          ),
    .eof_o          ( eof_from7          )
);
up_sampling_7
#(
    .DATA_WIDTH     ( 8                  ),
    .STRING_LEN     ( 1                  ),
    .CHANNEL_NUM    ( 256                ),
    .DATA_O_WIDTH   ( DATA_WIDTH         )
)                                        
up_sampling_test                         
(                                        
    .clk            ( clk                ),
    .reset_n        ( reset_n            ),
    .data_i         ( data_from7         ),
	.valid_i        ( data_valid_from7   ),
    .sop_i          ( sop_from7          ),
    .eop_i          ( eop_from7          ),
    .sof_i          ( sof_from7          ),
    .eof_i          ( eof_from7          ),
    .data_o         ( data               ),
    .data_valid_o   ( data_valid         ),
    .sop_o          ( sop                ),
    .eop_o          ( eop                ),
    .sof_o          ( sof                ),
    .eof_o          ( eof                )
);
//                                                    
deconv_nn                                           
#(                                                  
    .DATA_WIDTH    ( 8 )                            
)                                                   
deconv_nn_inst                                      
(                                                   
	.clk                         ( clk             ),
    .reset_n                     ( reset_n         ),
    .data_valid_i                ( data_valid      ),
	.data_i                      ( data            ),
    .sop_i                       ( sop             ),
    .eop_i                       ( eop             ),
    .sof_i                       ( sof             ),
    .eof_i                       ( eof             ),
    .data_o                      ( data_o          ),
    .data_valid_o                ( data_valid_o    ),
	.sop_o                       ( sop_o           ),
    .eop_o                       ( eop_o           ),
    .sof_o                       ( sof_o           ),
    .eof_o                       ( eof_o           ),
    
    .ddr_data                    (avl_readdata),
    .ddr_data_valid              (avl_readdatavalid),
    .ddr_fifo_aempty             ( ddr_fifo_aempty  )
    
); 




concat_FSM concat_FSM_inst              
(
	.clk                    ( clk                       ),
    .reset_n                ( reset_n                   ),
    .req_wr                 ( ddr_fifo_afull            ),
    .req_rd                 ( ddr_fifo_aempty           ),
    .res_rd                 ( ddr_fifo_rd               ),

//avalon
	.avl_beginbursttransfer (   avl_beginbursttransfer  ),  // mm_interconnect_0:if0_avl_0_beginbursttransfer -> if0:avl_burstbegin_0
//	.avl_readdata           (                           ),  // if0:avl_rdata_0 -> mm_interconnect_0:if0_avl_0_readdata
	.avl_waitrequest        ( avl_waitrequest           ), // if0:avl_ready_0 -> mm_interconnect_0:if0_avl_0_waitrequest
	.avl_address            ( avl_address               ), // mm_interconnect_0:if0_avl_0_address -> if0:avl_addr_0
	.avl_read               ( avl_read                  ),   // mm_interconnect_0:if0_avl_0_read -> if0:avl_read_req_0
	//.avl_byteenable       (),   // mm_interconnect_0:if0_avl_0_byteenable -> if0:avl_be_0
//	.avl_readdatavalid      ( avl_readdatavalid         ),   // if0:avl_rdata_valid_0 -> mm_interconnect_0:if0_avl_0_readdatavalid
	.avl_write              ( avl_write                 ), // mm_interconnect_0:if0_avl_0_write -> if0:avl_write_req_0
	//.avl_writedata        (),   // mm_interconnect_0:if0_avl_0_writedata -> if0:avl_wdata_0
	.avl_burstcount         ( avl_burstcount            )// mm_interconnect_0:if0_avl_0_burstcount -> if0:avl_size_0    
    
);

////debug 

 assign avl_writedata = 64'hADCD_EF00_DEAD_CAFE;
// assign avl_read = 0;
	wire        afi_clk;                  //      afi_clk.clk
//	wire        afi_half_clk;             // afi_half_clk.clk
	wire        afi_reset_n;              //    afi_reset.reset_n
    wire        rst_controller_002_reset_out_reset;
    wire        pll0_pll_clk_clk;
    wire        local_init_done;
    wire        local_cal_success;
    wire        local_cal_fail;
    
	wire   [0:0] memory_mem_cas_n;              // e0:mem_cas_n -> m0:mem_cas_n
	wire         memory_mem_reset_n;            // e0:mem_reset_n -> m0:mem_reset_n
	wire   [2:0] memory_mem_ba;                 // e0:mem_ba -> m0:mem_ba
	wire   [0:0] memory_mem_we_n;               // e0:mem_we_n -> m0:mem_we_n
	wire   [0:0] memory_mem_ck;                 // e0:mem_ck -> m0:mem_ck
	wire   [3:0] memory_mem_dm;                 // e0:mem_dm -> m0:mem_dm
	wire   [3:0] memory_mem_dqs;                // [] -> [e0:mem_dqs, m0:mem_dqs]
	wire  [31:0] memory_mem_dq;                 // [] -> [e0:mem_dq, m0:mem_dq]
	wire   [0:0] memory_mem_cs_n;               // e0:mem_cs_n -> m0:mem_cs_n
	wire  [14:0] memory_mem_a;                  // e0:mem_a -> m0:mem_a
	wire   [0:0] memory_mem_ras_n;              // e0:mem_ras_n -> m0:mem_ras_n
	wire   [3:0] memory_mem_dqs_n;              // [] -> [e0:mem_dqs_n, m0:mem_dqs_n]
	wire   [0:0] memory_mem_odt;                // e0:mem_odt -> m0:mem_odt
	wire   [0:0] memory_mem_ck_n;               // e0:mem_ck_n -> m0:mem_ck_n
	wire   [0:0] memory_mem_cke;                // e0:mem_cke -> m0:mem_cke
 /*
	altera_avalon_clock_source #(
		.CLOCK_RATE (50000000),
		.CLOCK_UNIT (1)
	) pll_ref_clk (
		.clk (pll_ref_clk_clk_clk)  // clk.clk
	);
    
	altera_avalon_reset_source #(
		.ASSERT_HIGH_RESET    (0),
		.INITIAL_RESET_CYCLES (5)
	) global_reset (
		.reset (global_reset_reset_reset), // reset.reset_n
		.clk   (pll_ref_clk_clk_clk)       //   clk.clk
	); 
    
	altera_mem_if_single_clock_pll #(
		.DEVICE_FAMILY    ("Cyclone V"),
		.REF_CLK_FREQ_STR ("50.0 MHz"),
		.REF_CLK_PS       ("20000.0"),
		.PLL_CLK_FREQ_STR ("50.0 MHz"),
		.PLL_CLK_PHASE_PS (0),
		.PLL_CLK_MULT     (0),
		.PLL_CLK_DIV      (0),
		.USE_GENERIC_PLL  (1)
	) pll0 (
		.pll_ref_clk    (pll_ref_clk_clk_clk),          //    pll_ref_clk.clk
		.pll_clk        (pll0_pll_clk_clk),     //        pll_clk.clk
		.global_reset_n (global_reset_n),       // global_reset_n.reset_n
		.pll_locked     (),                     //     pll_locked.pll_locked
		.reset_out_n    (pll0_reset_out_reset)  //      reset_out.reset_n
	);    
 */   
DDR3_example_sim_e0_if0 if0 (
		.pll_ref_clk                ( clk                    ),                                    //        pll_ref_clk.clk
		.global_reset_n             ( reset_n            ),                                 //       global_reset.reset_n
		.soft_reset_n               ( reset_n              ),                                   //         soft_reset.reset_n
		.afi_clk                    ( afi_clk                   ),                                        //            afi_clk.clk
		.afi_half_clk               ( afi_half_clk              ),                                   //       afi_half_clk.clk
		.afi_reset_n                ( afi_reset_n               ),                                    //          afi_reset.reset_n
		.afi_reset_export_n         (                           ),                                               //   afi_reset_export.reset_n
		.mem_a                      ( memory_mem_a              ),                                          //             memory.mem_a
		.mem_ba                     ( memory_mem_ba             ),                                         //                   .mem_ba
		.mem_ck                     ( memory_mem_ck             ),                                         //                   .mem_ck
		.mem_ck_n                   ( memory_mem_ck_n           ),                                       //                   .mem_ck_n
		.mem_cke                    ( memory_mem_cke            ),                                        //                   .mem_cke
		.mem_cs_n                   ( memory_mem_cs_n           ),                                       //                   .mem_cs_n
		.mem_dm                     ( memory_mem_dm             ),                                         //                   .mem_dm
		.mem_ras_n                  ( memory_mem_ras_n          ),                                      //                   .mem_ras_n
		.mem_cas_n                  ( memory_mem_cas_n          ),                                      //                   .mem_cas_n
		.mem_we_n                   ( memory_mem_we_n           ),                                       //                   .mem_we_n
		.mem_reset_n                ( memory_mem_reset_n        ),                                    //                   .mem_reset_n
		.mem_dq                     ( memory_mem_dq             ),                                         //                   .mem_dq
		.mem_dqs                    ( memory_mem_dqs            ),                                        //                   .mem_dqs
		.mem_dqs_n                  ( memory_mem_dqs_n          ),                                      //                   .mem_dqs_n
		.mem_odt                    ( memory_mem_odt            ),                                        //                   .mem_odt
		.avl_ready_0                ( avl_waitrequest           ),              //              avl_0.waitrequest_n
		.avl_burstbegin_0           ( avl_beginbursttransfer    ),//                   .beginbursttransfer
		.avl_addr_0                 ( avl_address               ),                      //                   .address
		.avl_rdata_valid_0          ( avl_readdatavalid         ),          //                   .readdatavalid
		.avl_rdata_0                ( avl_readdata              ),                    //                   .readdata
		.avl_wdata_0                ( avl_writedata             ),                  //                   .writedata
		.avl_be_0                   ( /*avl_byteenable*/8'hFF            ),                //                   .byteenable
		.avl_read_req_0             ( avl_read                  ),                            //                   .read
		.avl_write_req_0            ( avl_write                 ),                          //                   .write
		.avl_size_0                 ( avl_burstcount            ),                //                   .burstcount
		.mp_cmd_clk_0_clk           ( clk                              ),                               //       mp_cmd_clk_0.clk
		.mp_cmd_reset_n_0_reset_n   ( reset_n                ),                //   mp_cmd_reset_n_0.reset_n
		.mp_rfifo_clk_0_clk         ( clk                               ),                               //     mp_rfifo_clk_0.clk
		.mp_rfifo_reset_n_0_reset_n ( reset_n            ),            // mp_rfifo_reset_n_0.reset_n
		.mp_wfifo_clk_0_clk         ( clk                               ),                               //     mp_wfifo_clk_0.clk
		.mp_wfifo_reset_n_0_reset_n ( reset_n            ),            // mp_wfifo_reset_n_0.reset_n
		.local_init_done            ( local_init_done                                ),                                //             status.local_init_done
		.local_cal_success          ( local_cal_success                              ),                              //                   .local_cal_success
		.local_cal_fail             ( local_cal_fail                                 ),                                 //                   .local_cal_fail
		.oct_rzqin                  ( oct_rzqin                                      ),                                      //                oct.rzqin
		.pll_mem_clk                (),                                               //        pll_sharing.pll_mem_clk
		.pll_write_clk              (),                                               //                   .pll_write_clk
		.pll_locked                 (),                                               //                   .pll_locked
		.pll_write_clk_pre_phy_clk  (),                                               //                   .pll_write_clk_pre_phy_clk
		.pll_addr_cmd_clk           (),                                               //                   .pll_addr_cmd_clk
		.pll_avl_clk                (),                                               //                   .pll_avl_clk
		.pll_config_clk             (),                                               //                   .pll_config_clk
		.pll_mem_phy_clk            (),                                               //                   .pll_mem_phy_clk
		.afi_phy_clk                (),                                               //                   .afi_phy_clk
		.pll_avl_phy_clk            ()                                                //                   .pll_avl_phy_clk
	);
    
    	alt_mem_if_ddr3_mem_model_top_ddr3_mem_if_dm_pins_en_mem_if_dqsn_en #(
		.MEM_IF_ADDR_WIDTH            (15),
		.MEM_IF_ROW_ADDR_WIDTH        (15),
		.MEM_IF_COL_ADDR_WIDTH        (10),
		.MEM_IF_CONTROL_WIDTH         (1),
		.MEM_IF_DQS_WIDTH             (4),
		.MEM_IF_CS_WIDTH              (1),
		.MEM_IF_BANKADDR_WIDTH        (3),
		.MEM_IF_DQ_WIDTH              (32),
		.MEM_IF_CK_WIDTH              (1),
		.MEM_IF_CLK_EN_WIDTH          (1),
		.MEM_TRCD                     (6),
		.MEM_TRTP                     (6),
		.MEM_DQS_TO_CLK_CAPTURE_DELAY (450),
		.MEM_CLK_TO_DQS_CAPTURE_DELAY (100000),
		.MEM_IF_ODT_WIDTH             (1),
		.MEM_IF_LRDIMM_RM             (0),
		.MEM_MIRROR_ADDRESSING_DEC    (0),
		.MEM_REGDIMM_ENABLED          (0),
		.MEM_LRDIMM_ENABLED           (0),
		.DEVICE_DEPTH                 (1),
		.MEM_NUMBER_OF_DIMMS          (1),
		.MEM_NUMBER_OF_RANKS_PER_DIMM (1),
		.MEM_GUARANTEED_WRITE_INIT    (0),
		.MEM_VERBOSE                  (1),
		.REFRESH_BURST_VALIDATION     (0),
		.AP_MODE_EN                   (2'b00),
		.MEM_INIT_EN                  (0),
		.MEM_INIT_FILE                (""),
		.DAT_DATA_WIDTH               (32)
	) m0 (
		.mem_a       ( memory_mem_a         ),       // memory.mem_a
		.mem_ba      ( memory_mem_ba        ),      //       .mem_ba
		.mem_ck      ( memory_mem_ck        ),      //       .mem_ck
		.mem_ck_n    ( memory_mem_ck_n      ),    //       .mem_ck_n
		.mem_cke     ( memory_mem_cke       ),     //       .mem_cke
		.mem_cs_n    ( memory_mem_cs_n      ),    //       .mem_cs_n
		.mem_dm      ( memory_mem_dm        ),      //       .mem_dm
		.mem_ras_n   ( memory_mem_ras_n     ),   //       .mem_ras_n
		.mem_cas_n   ( memory_mem_cas_n     ),   //       .mem_cas_n
		.mem_we_n    ( memory_mem_we_n      ),    //       .mem_we_n
		.mem_reset_n ( memory_mem_reset_n   ), //       .mem_reset_n
		.mem_dq      ( memory_mem_dq        ),      //       .mem_dq
		.mem_dqs     ( memory_mem_dqs       ),     //       .mem_dqs
		.mem_dqs_n   ( memory_mem_dqs_n     ),   //       .mem_dqs_n
		.mem_odt     ( memory_mem_odt       )      //       .mem_odt
	);

endmodule

