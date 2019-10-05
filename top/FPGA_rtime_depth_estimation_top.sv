////////////////////////////////////////////////////////////////////////////
//Name File     : FPGA_rtime_depth_estimation_top                         //
//Author_1      : ShVlad            / e-mail: shvladspb@gmail.com         //             
//Author_2      : Andrey Papushin   / e-mail: andrey.papushin@gmail.com   //               
//Standart      : IEEE 1800-2009(SystemVerilog-2009)                      //
//Start design  : 01.08.2019                                              //
//Last revision : 16.09.2018                                              //
////////////////////////////////////////////////////////////////////////////

module FPGA_rtime_depth_estimation_top
(

	///////// CLOCK /////////
    input              CLOCK_50_B3B,
    input              CLOCK_50_B4A, //Clock in DDR3's Bank
    input              CLOCK_50_B5B,
    input              CLOCK_50_B6A,
    input              CLOCK_50_B7A,
    input              CLOCK_50_B8A,
	
	///////// PCIE /////////
	pcie_ifc.pcie_port    pcie_pin,  
	///////// DDR3 /////////
	ddr3_ifc.ddr3_port     ddr3_pin,
	///////// DRAM /////////
	//dram_ifc.dram_port     dram_pin,
	///////// FAN /////////
    output             fan_ctrl     	   
	
);
avl_ifc  #( 20, 32, 4)     avl_rgb_data_in(); 
avl_ifc  #( 20, 32, 4)     avl_ctrl_registers(); 
avl_ifc  #( 17, 32, 4)     avl_mem_result();
qsys_ifc qsys_ifc_inst
(
	.clock_50_b3b       (CLOCK_50_B3B),
	.clk_dsp            (),
	.clk_ddr3            (CLOCK_50_B4A),
	.clk_result         (clk_user_out), // <-
	.global_reset_n     (reset_n           ), //->
	.clk_user_out       (clk_user_out      ), // ->
	.avl_rgb_data_in    (avl_rgb_data_in   ),   // ->
	.avl_ctrl_registers (avl_ctrl_registers),   
	.avl_mem_result     (avl_mem_result    ),   
	.pcie               (pcie_pin.pcie_port          ),
	.ddr3_mem           (ddr3_pin.ddr3_port          )
); 
/*
qsys_ifc qsys_ifc_inst
(
	.clock_50_b3b       (CLOCK_50_B4A),
	.clk_dsp            (),
	.clk_result         (),
	.global_reset_n     (reset_n           ), //->
	.clk_user_out       (clk_user_out      ), // ->
	.avl_rgb_data_in    (avl_rgb_data_in   ),   // ->
	.avl_ctrl_registers (avl_ctrl_registers),   
	.avl_mem_result     (avl_mem_result    ),   
	.pcie               (pcie_pin          ),
	.ddr3_mem           (ddr3_pin          )
);
*/


assign 	fan_ctrl = 1'b1;


endmodule