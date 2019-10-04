//Author: Vlad Sharshin 
//e-mail: shvladspb@gmail.com
`include "main_param.vh"
module FPGA_rtime_depth_estimation_top
(
	input wire                                  clk, 
    input wire                                  reset_n,
	input wire [8-1:0]                          data_i, 
    input wire                                  data_valid_i,    
    input wire                                  sop_i,
    input wire                                  eop_i,
    input wire                                  sof_i,
    input wire                                  eof_i,   

    output wire [8-1:0]                         data_o,
    output wire                                 data_valid_o,
	output logic                                sop_o,
    output logic                                eop_o,
    output logic                                sof_o,
    output logic                                eof_o    
);
wire [7:0]              data;
wire                    data_valid;   
wire                    sop;
wire                    eop;
wire                    sof;
wire                    eof;
conv_nn
#(
    .DATA_WIDTH    ( 8 )
)
conv_nn_inst
(
	.clk                    (  clk          ),
    .reset_n                ( reset_n       ),
    .data_valid_i           ( data_valid_i  ),
	.data_i                 ( data_i        ),
    .sop_i                  ( sop_i         ),
    .eop_i                  ( eop_i         ),
    .sof_i                  ( sof_i         ),
    .eof_i                  ( eof_i         ),
    .data_o                 ( data          ),
    .data_valid_o           ( data_valid    ),
	.sop_o                  ( sop           ),
    .eop_o                  ( eop           ),
    .sof_o                  ( sof           ),
    .eof_o                  ( eof           )
);

deconv_nn
#(
    .DATA_WIDTH    ( 8 )
)
deconv_nn_inst
(
	.clk            ( clk          ),
    .reset_n        ( reset_n      ),
    .data_valid_i   ( data         ),
	.data_i         ( data_valid   ),
    .sop_i          ( sop          ),
    .eop_i          ( eop          ),
    .sof_i          ( sof          ),
    .eof_i          ( eof          ),
    .data_o         ( data_o       ),
    .data_valid_o   ( data_valid_o ),
	.sop_o          ( sop_o        ),
    .eop_o          ( eop_o        ),
    .sof_o          ( sof_o        ),
    .eof_o          ( eof_o        )
);


endmodule
