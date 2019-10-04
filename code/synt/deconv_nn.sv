//Author: Vlad Sharshin 
//e-mail: shvladspb@gmail.com
//`include "main_param.vh"
module deconv_nn
#(
    parameter DATA_WIDTH    = 8
)
(
	input wire                                  clk, 
    input wire                                  reset_n,
    input wire                                  data_valid_i,    
	input wire [DATA_WIDTH-1:0]                 data_i,    
    input wire						            sop_i,
    input wire						            eop_i,
    input wire						            sof_i,
    input wire						            eof_i,   

    output wire [DATA_WIDTH-1:0]                data_o,
    output wire                                 data_valid_o,
	output logic					            sop_o,
    output logic					            eop_o,
    output logic					            sof_o,
    output logic					            eof_o    
);
// 
wire [DATA_WIDTH-1:0]   data_o_l0      ;
wire                    data_valid_o_l0;   
wire					sop_o_l0       ;
wire					eop_o_l0       ;
wire					sof_o_l0       ;
wire					eof_o_l0       ;
// 
wire [DATA_WIDTH-1:0]   data_o_l1      ;
wire                    data_valid_o_l1;   
wire					sop_o_l1       ;
wire					eop_o_l1       ;
wire					sof_o_l1       ;
wire					eof_o_l1       ;
//
wire [DATA_WIDTH-1:0]   data_o_l2      ;
wire                    data_valid_o_l2;   
wire					sop_o_l2       ;
wire					eop_o_l2       ;
wire					sof_o_l2       ;
wire					eof_o_l2       ;
//
wire [DATA_WIDTH-1:0]   data_o_l3      ;
wire                    data_valid_o_l3;   
wire					sop_o_l3       ;
wire					eop_o_l3       ;
wire					sof_o_l3       ;
wire					eof_o_l3       ;
//
wire [DATA_WIDTH-1:0]   data_o_l4      ;
wire                    data_valid_o_l4;   
wire					sop_o_l4       ;
wire					eop_o_l4       ;
wire					sof_o_l4       ;
wire					eof_o_l4       ;
//
wire [DATA_WIDTH-1:0]   data_o_l5      ;
wire                    data_valid_o_l5;   
wire					sop_o_l5       ;
wire					eop_o_l5       ;
wire					sof_o_l5       ;
wire					eof_o_l5       ;

deconv_layer
#(

    .STRING2MATRIX_DATA_WIDTH         ( STRING2MATRIX_DATA_WIDTH[5]      ),      
    .STRING2MATRIX_STRING_LEN         ( STRING2MATRIX_STRING_LEN[5]      ),
    .STRING2MATRIX_MATRIX_SIZE        ( STRING2MATRIX_MATRIX_SIZE[5]     ),
    .STRING2MATRIX_CHANNEL_NUM        ( STRING2MATRIX_CHANNEL_NUM[5]     ),
    .STRING2MATRIX_HOLD_DATA          ( STRING2MATRIX_HOLD_DATA[5]       ),
    
    .CONV2_3X3_WRP_KERNEL_WIDTH       ( CONV2_3X3_WRP_KERNEL_WIDTH[5]    ),
    .CONV2_3X3_WRP_MEM_DEPTH          ( CONV2_3X3_WRP_MEM_DEPTH[5]       ),
    .CONV2_3X3_INI_FILE               ( CONV2_3X3_INI_FILE[5]            ), 
    
    .CONV_VECT_SER_KERNEL_WIDTH       ( CONV_VECT_SER_KERNEL_WIDTH[5]    ),
    .CONV_VECT_SER_CHANNEL_NUM        ( CONV_VECT_SER_CHANNEL_NUM[5]     ),
    .CONV_VECT_SER_MTRX_NUM           ( CONV_VECT_SER_MTRX_NUM[5]        ),
    .CONV_VECT_SER_INI_FILE           ( CONV_VECT_SER_INI_FILE[5]        ),
    
    .MAX_POOL_CHANNEL_NUM             ( MAX_POOL_CHANNEL_NUM[5]          ),
    .MAX_POOL_HOLD_DATA               ( MAX_POOL_HOLD_DATA[5]            ),
    
    .RELU_MAX_DATA                    ( RELU_MAX_DATA[5]                 )
)
layer_0
(
	.clk                              ( clk                     ),      
    .reset_n                          ( reset_n                 ),
	.data_i                           ( data_i                  ),    
    .data_valid_i                     ( data_valid_i            ),    
    .sop_i                            ( sop_i                   ),
    .eop_i                            ( eop_i                   ),
    .sof_i                            ( sof_i                   ),
    .eof_i                            ( eof_i                   ),
    .data_o                           ( data_o_l0               ),
    .data_valid_o                     ( data_valid_o_l0         ),
	.sop_o                            ( sop_o_l0                ),
    .eop_o                            ( eop_o_l0                ),
    .sof_o                            ( sof_o_l0                ),
    .eof_o                            ( eof_o_l0                )
);
//

deconv_layer
#(

    .STRING2MATRIX_DATA_WIDTH         ( STRING2MATRIX_DATA_WIDTH[4]     ),            
    .STRING2MATRIX_STRING_LEN         ( STRING2MATRIX_STRING_LEN[4]     ),
    .STRING2MATRIX_MATRIX_SIZE        ( STRING2MATRIX_MATRIX_SIZE[4]    ),
    .STRING2MATRIX_CHANNEL_NUM        ( STRING2MATRIX_CHANNEL_NUM[4]    ),
    .STRING2MATRIX_HOLD_DATA          ( STRING2MATRIX_HOLD_DATA[4]      ),    

    .CONV2_3X3_WRP_KERNEL_WIDTH       ( CONV2_3X3_WRP_KERNEL_WIDTH[4]   ),
    .CONV2_3X3_WRP_MEM_DEPTH          ( CONV2_3X3_WRP_MEM_DEPTH[4]      ),
    .CONV2_3X3_INI_FILE               ( CONV2_3X3_INI_FILE[4]           ), 
    
    .CONV_VECT_SER_KERNEL_WIDTH       ( CONV_VECT_SER_KERNEL_WIDTH[4]   ),
    .CONV_VECT_SER_CHANNEL_NUM        ( CONV_VECT_SER_CHANNEL_NUM[4]    ),
    .CONV_VECT_SER_MTRX_NUM           ( CONV_VECT_SER_MTRX_NUM[4]       ),
    .CONV_VECT_SER_INI_FILE           ( CONV_VECT_SER_INI_FILE[4]       ),
    
    .MAX_POOL_CHANNEL_NUM             ( MAX_POOL_CHANNEL_NUM[4]         ),
    .MAX_POOL_HOLD_DATA               ( MAX_POOL_HOLD_DATA[4]           ),
    
    .RELU_MAX_DATA                    ( RELU_MAX_DATA[4]                )
)
layer_1
(
	.clk                              ( clk                     ),      
    .reset_n                          ( reset_n                 ),
	.data_i                           ( data_o_l0          ),     
    .data_valid_i                     ( data_valid_o_l0    ),   
    .sop_i                            ( sop_o_l0           ),
    .eop_i                            ( eop_o_l0           ),
    .sof_i                            ( sof_o_l0           ),
    .eof_i                            ( eof_o_l0           ),
    .data_o                           ( data_o_l1          ),
    .data_valid_o                     ( data_valid_o_l1    ),
	.sop_o                            ( sop_o_l1           ),
    .eop_o                            ( eop_o_l1           ),
    .sof_o                            ( sof_o_l1           ),
    .eof_o                            ( eof_o_l1           )
);
//
deconv_layer
#(

    .STRING2MATRIX_DATA_WIDTH         ( STRING2MATRIX_DATA_WIDTH[3]     ),            
    .STRING2MATRIX_STRING_LEN         ( STRING2MATRIX_STRING_LEN[3]     ),
    .STRING2MATRIX_MATRIX_SIZE        ( STRING2MATRIX_MATRIX_SIZE[3]    ),
    .STRING2MATRIX_CHANNEL_NUM        ( STRING2MATRIX_CHANNEL_NUM[3]    ),
    .STRING2MATRIX_HOLD_DATA          ( STRING2MATRIX_HOLD_DATA[3]      ),    

    .CONV2_3X3_WRP_KERNEL_WIDTH       ( CONV2_3X3_WRP_KERNEL_WIDTH[3]   ),
    .CONV2_3X3_WRP_MEM_DEPTH          ( CONV2_3X3_WRP_MEM_DEPTH[3]      ),
    .CONV2_3X3_INI_FILE               ( CONV2_3X3_INI_FILE[3]           ), 
    
    .CONV_VECT_SER_KERNEL_WIDTH       ( CONV_VECT_SER_KERNEL_WIDTH[3]   ),
    .CONV_VECT_SER_CHANNEL_NUM        ( CONV_VECT_SER_CHANNEL_NUM[3]    ),
    .CONV_VECT_SER_MTRX_NUM           ( CONV_VECT_SER_MTRX_NUM[3]       ),
    .CONV_VECT_SER_INI_FILE           ( CONV_VECT_SER_INI_FILE[3]       ),
    
    .MAX_POOL_CHANNEL_NUM             ( MAX_POOL_CHANNEL_NUM[3]         ),
    .MAX_POOL_HOLD_DATA               ( MAX_POOL_HOLD_DATA[3]           ),
    
    .RELU_MAX_DATA                    ( RELU_MAX_DATA[3]                )
)
layer_2
(
	.clk                              ( clk                     ),      
    .reset_n                          ( reset_n                 ),
	.data_i                           ( data_o_l1          ),     
    .data_valid_i                     ( data_valid_o_l1    ),   
    .sop_i                            ( sop_o_l1           ),
    .eop_i                            ( eop_o_l1           ),
    .sof_i                            ( sof_o_l1           ),
    .eof_i                            ( eof_o_l1           ),
    .data_o                           ( data_o_l2          ),
    .data_valid_o                     ( data_valid_o_l2    ),
	.sop_o                            ( sop_o_l2           ),
    .eop_o                            ( eop_o_l2           ),
    .sof_o                            ( sof_o_l2           ),
    .eof_o                            ( eof_o_l2           )
);
//
deconv_layer
#(

    .STRING2MATRIX_DATA_WIDTH         ( STRING2MATRIX_DATA_WIDTH[2]     ),            
    .STRING2MATRIX_STRING_LEN         ( STRING2MATRIX_STRING_LEN[2]     ),
    .STRING2MATRIX_MATRIX_SIZE        ( STRING2MATRIX_MATRIX_SIZE[2]    ),
    .STRING2MATRIX_CHANNEL_NUM        ( STRING2MATRIX_CHANNEL_NUM[2]    ),
    .STRING2MATRIX_HOLD_DATA          ( STRING2MATRIX_HOLD_DATA[2]      ),    

    .CONV2_3X3_WRP_KERNEL_WIDTH       ( CONV2_3X3_WRP_KERNEL_WIDTH[2]   ),
    .CONV2_3X3_WRP_MEM_DEPTH          ( CONV2_3X3_WRP_MEM_DEPTH[2]      ),
    .CONV2_3X3_INI_FILE               ( CONV2_3X3_INI_FILE[2]           ), 
    
    .CONV_VECT_SER_KERNEL_WIDTH       ( CONV_VECT_SER_KERNEL_WIDTH[2]   ),
    .CONV_VECT_SER_CHANNEL_NUM        ( CONV_VECT_SER_CHANNEL_NUM[2]    ),
    .CONV_VECT_SER_MTRX_NUM           ( CONV_VECT_SER_MTRX_NUM[2]       ),
    .CONV_VECT_SER_INI_FILE           ( CONV_VECT_SER_INI_FILE[2]       ),
    
    .MAX_POOL_CHANNEL_NUM             ( MAX_POOL_CHANNEL_NUM[2]         ),
    .MAX_POOL_HOLD_DATA               ( MAX_POOL_HOLD_DATA[2]           ),
    
    .RELU_MAX_DATA                    ( RELU_MAX_DATA[2]                )
)
layer_3
(
	.clk                              ( clk                     ),      
    .reset_n                          ( reset_n                 ),
	.data_i                           ( data_o_l2          ),     
    .data_valid_i                     ( data_valid_o_l2    ),   
    .sop_i                            ( sop_o_l2           ),
    .eop_i                            ( eop_o_l2           ),
    .sof_i                            ( sof_o_l2           ),
    .eof_i                            ( eof_o_l2           ),
    .data_o                           ( data_o_l3          ),
    .data_valid_o                     ( data_valid_o_l3    ),
	.sop_o                            ( sop_o_l3           ),
    .eop_o                            ( eop_o_l3           ),
    .sof_o                            ( sof_o_l3           ),
    .eof_o                            ( eof_o_l3           )
);
//
deconv_layer
#(

    .STRING2MATRIX_DATA_WIDTH         ( STRING2MATRIX_DATA_WIDTH[1]     ),            
    .STRING2MATRIX_STRING_LEN         ( STRING2MATRIX_STRING_LEN[1]     ),
    .STRING2MATRIX_MATRIX_SIZE        ( STRING2MATRIX_MATRIX_SIZE[1]    ),
    .STRING2MATRIX_CHANNEL_NUM        ( STRING2MATRIX_CHANNEL_NUM[1]    ),
    .STRING2MATRIX_HOLD_DATA          ( STRING2MATRIX_HOLD_DATA[1]      ),    

    .CONV2_3X3_WRP_KERNEL_WIDTH       ( CONV2_3X3_WRP_KERNEL_WIDTH[1]   ),
    .CONV2_3X3_WRP_MEM_DEPTH          ( CONV2_3X3_WRP_MEM_DEPTH[1]      ),
    .CONV2_3X3_INI_FILE               ( CONV2_3X3_INI_FILE[1]           ), 
    
    .CONV_VECT_SER_KERNEL_WIDTH       ( CONV_VECT_SER_KERNEL_WIDTH[1]   ),
    .CONV_VECT_SER_CHANNEL_NUM        ( CONV_VECT_SER_CHANNEL_NUM[1]    ),
    .CONV_VECT_SER_MTRX_NUM           ( CONV_VECT_SER_MTRX_NUM[1]       ),
    .CONV_VECT_SER_INI_FILE           ( CONV_VECT_SER_INI_FILE[1]       ),
    
    .MAX_POOL_CHANNEL_NUM             ( MAX_POOL_CHANNEL_NUM[1]         ),
    .MAX_POOL_HOLD_DATA               ( MAX_POOL_HOLD_DATA[1]           ),
    
    .RELU_MAX_DATA                    ( RELU_MAX_DATA[1]                )
)
layer_4
(
	.clk                              ( clk                     ),      
    .reset_n                          ( reset_n                 ),
	.data_i                           ( data_o_l3          ),     
    .data_valid_i                     ( data_valid_o_l3    ),   
    .sop_i                            ( sop_o_l3           ),
    .eop_i                            ( eop_o_l3           ),
    .sof_i                            ( sof_o_l3           ),
    .eof_i                            ( eof_o_l3           ),
    .data_o                           ( data_o_l4          ),
    .data_valid_o                     ( data_valid_o_l4    ),
	.sop_o                            ( sop_o_l4           ),
    .eop_o                            ( eop_o_l4           ),
    .sof_o                            ( sof_o_l4           ),
    .eof_o                            ( eof_o_l4           )
);
//

deconv_layer
#(

    .STRING2MATRIX_DATA_WIDTH         ( STRING2MATRIX_DATA_WIDTH[0]     ),            
    .STRING2MATRIX_STRING_LEN         ( STRING2MATRIX_STRING_LEN[0]     ),
    .STRING2MATRIX_MATRIX_SIZE        ( STRING2MATRIX_MATRIX_SIZE[0]    ),
    .STRING2MATRIX_CHANNEL_NUM        ( STRING2MATRIX_CHANNEL_NUM[0]    ),
    .STRING2MATRIX_HOLD_DATA          ( STRING2MATRIX_HOLD_DATA[0]      ),    

    .CONV2_3X3_WRP_KERNEL_WIDTH       ( CONV2_3X3_WRP_KERNEL_WIDTH[0]   ),
    .CONV2_3X3_WRP_MEM_DEPTH          ( CONV2_3X3_WRP_MEM_DEPTH[0]      ),
    .CONV2_3X3_INI_FILE               ( CONV2_3X3_INI_FILE[0]           ), 
    
    .CONV_VECT_SER_KERNEL_WIDTH       ( CONV_VECT_SER_KERNEL_WIDTH[0]   ),
    .CONV_VECT_SER_CHANNEL_NUM        ( CONV_VECT_SER_CHANNEL_NUM[0]    ),
    .CONV_VECT_SER_MTRX_NUM           ( CONV_VECT_SER_MTRX_NUM[0]       ),
    .CONV_VECT_SER_INI_FILE           ( CONV_VECT_SER_INI_FILE[0]       ),
    
    .MAX_POOL_CHANNEL_NUM             ( MAX_POOL_CHANNEL_NUM[0]         ),
    .MAX_POOL_HOLD_DATA               ( MAX_POOL_HOLD_DATA[0]           ),
    
    .RELU_MAX_DATA                    ( RELU_MAX_DATA[0]                )
)
layer_5
(
	.clk                              ( clk                     ),      
    .reset_n                          ( reset_n                 ),
	.data_i                           ( data_o_l4          ),     
    .data_valid_i                     ( data_valid_o_l4    ),   
    .sop_i                            ( sop_o_l4           ),
    .eop_i                            ( eop_o_l4           ),
    .sof_i                            ( sof_o_l4           ),
    .eof_i                            ( eof_o_l4           ),
    .data_o                           ( data_o_l5          ),
    .data_valid_o                     ( data_valid_o_l5    ),
	.sop_o                            ( sop_o_l5           ),
    .eop_o                            ( eop_o_l5           ),
    .sof_o                            ( sof_o_l5           ),
    .eof_o                            ( eof_o_l5           )
);

assign data_o       = data_o_l5      ;
assign data_valid_o = data_valid_o_l5;
assign sop_o        = sop_o_l5       ;
assign eop_o        = eop_o_l5       ;
assign sof_o        = sof_o_l5       ;
assign eof_o        = eof_o_l5       ;
/*
assign data_o       = data_o_l1      ;
assign data_valid_o = data_valid_o_l1;
assign sop_o        = sop_o_l1       ;
assign eop_o        = eop_o_l1       ;
assign sof_o        = sof_o_l1       ;
assign eof_o        = eof_o_l1       ;
*/
/*
up_sampling
#(
    .DATA_WIDTH        ( 8              ),
    .STRING_LEN        ( 7              ),
    .CHANNEL_NUM       ( 256            ),
    .DATA_O_WIDTH      ( DATA_WIDTH     )
)
up_sampling_test
(
    .clk                ( clk            ),
    .reset_n            ( reset_n        ),
    .data_i             ( data_o_l5      ),
	.valid_i            ( data_valid_o_l5),
    .sop_i              ( sop_o_l5       ),
    .eop_i              ( eop_o_l5       ),
    .sof_i              ( sof_o_l5       ),
    .eof_i              ( eof_o_l5       ),
    .data_o             ( ),
    .data_valid_o       ( ),
    .sop_o              ( ),
    .eop_o              ( ),
    .sof_o              ( ),
    .eof_o              ( )
);
*/
endmodule

