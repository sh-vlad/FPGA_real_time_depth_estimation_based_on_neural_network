////////////////////////////////////////////////////////////////////////////
//Name File     : FPGA_rtime_depth_estimation_top                         //
//Author_1      : ShVlad            / e-mail: shvladspb@gmail.com         //             
//Author_2      : Andrey Papushin   / e-mail: andrey.papushin@gmail.com   //               
//Standart      : IEEE 1800-2009(SystemVerilog-2009)                      //
//Start design  : 01.08.2019                                              //
//Last revision : 05.10.2018                                              //
////////////////////////////////////////////////////////////////////////////
`include "main_param.vh"
module FPGA_rtime_depth_estimation_top
(

	///////// CLOCK /////////
    input                 CLOCK_50_B3B,
    input                 CLOCK_50_B4A, //Clock in DDR3's Bank
    input                 CLOCK_50_B5B,
    input                 CLOCK_50_B6A,
    input                 CLOCK_50_B7A,
    input                 CLOCK_50_B8A,
	///////// PCIE /////////
	pcie_ifc.pcie_port    pcie_pin    ,  
	///////// DDR3 /////////
	ddr3_ifc.ddr3_port    ddr3_pin    ,
	///////// FAN /////////
    output                fan_ctrl     	   
);
avl_stream_ifc  #( 8        )     data_i()            ; //stream of data between pcie and conv_nn
avl_stream_ifc  #( 8        )     data_o()            ; //stream of data between deconv_nn and pcie
avl_ifc         #( 20, 32, 4)     avl_ctrl_registers(); 
avl_ifc         #( 17, 32, 4)     avl_mem_result()    ;
wire                              clk_200             ;
wire                              clk_100             ;
wire [7:0]                        data                ;
wire                              data_valid          ;   
wire                              sop                 ;
wire                              eop                 ;
wire                              sof                 ;
wire                              eof                 ;
qsys_ifc qsys_ifc_inst
(
	.clock_50_b3b                (CLOCK_50_B3B       ),// <-
	.clk_dsp                     (clk_200            ),// <-
	.clk_ddr3                    (CLOCK_50_B4A       ),// <-
	.CLOCK_50_B5B                (CLOCK_50_B8A       ),// <-
	.clk_result                  (clk_200            ),// <-
	.clk_100                     (clk_100            ), //->
	.clk_200                     (clk_200            ), //->
	.global_reset_n              (reset_n            ), //->
	.avl_stream_rgb_data_in      (data_i             ), // ->
	.avl_ctrl_registers          (avl_ctrl_registers ), // ->  
	.avl_stream_rgb_data_result  (data_o             ), //<-  
	.pcie                        (pcie_pin.pcie_port ),
	.ddr3_mem                    (ddr3_pin.ddr3_port )
);                               
                                 
conv_nn                          
#(                               
    .DATA_WIDTH    ( 8 )         
)                                
conv_nn_inst                     
(                                
	.clk                         ( clk_200          ),
    .reset_n                     ( reset_n          ),
    .data_valid_i                ( data_i.valid     ),
	.data_i                      ( data_i.data      ),
    .sop_i                       ( data_i.sop       ),
    .eop_i                       ( data_i.eop       ),
    .sof_i                       ( data_i.sof       ),
    .eof_i                       ( data_i.eof       ),
    .data_o                      ( data             ),
    .data_valid_o                ( data_valid       ),
	.sop_o                       ( sop              ),
    .eop_o                       ( eop              ),
    .sof_o                       ( sof              ),
    .eof_o                       ( eof              )
);                                                  
                                                    
deconv_nn                                           
#(                                                  
    .DATA_WIDTH    ( 8 )                            
)                                                   
deconv_nn_inst                                      
(                                                   
	.clk                         ( clk_200          ),
    .reset_n                     ( reset_n          ),
    .data_valid_i                ( data             ),
	.data_i                      ( data_valid       ),
    .sop_i                       ( sop              ),
    .eop_i                       ( eop              ),
    .sof_i                       ( sof              ),
    .eof_i                       ( eof              ),
    .data_o                      ( data_o.data      ),
    .data_valid_o                ( data_o.valid     ),
	.sop_o                       ( data_o.sop       ),
    .eop_o                       ( data_o.eop       ),
    .sof_o                       ( data_o.sof       ),
    .eof_o                       ( data_o.eof       )
); 

assign 	fan_ctrl = 1'b1;


endmodule

