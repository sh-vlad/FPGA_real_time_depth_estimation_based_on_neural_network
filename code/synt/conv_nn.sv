//Author: Vlad Sharshin 
//e-mail: shvladspb@gmail.com
//`include "main_param.vh"
`include "params/main_param.vh"
module conv_nn
#(
    parameter DATA_WIDTH    = 8
)
(
	input wire                                  clk, 
    input wire                                  reset_n,
    input wire                                  data_valid_i,      
	input wire signed [DATA_WIDTH-1:0]          data_li,   
	input wire signed [DATA_WIDTH-1:0]          data_ri,       
    input wire						            sop_i,
    input wire						            eop_i,
    input wire						            sof_i,
    input wire						            eof_i,   

    output wire signed [DATA_WIDTH-1:0]         data_o,
    output wire                                 data_valid_o,
	output logic					            sop_o,
    output logic					            eop_o,
    output logic					            sof_o,
    output logic					            eof_o,

    input wire [5:0]                            ddr_fifo_rd,
    output reg [5:0]                            ddr_fifo_afull       
);
// 
wire signed [DATA_WIDTH-1:0]    data_o_ll0      ;
wire                            data_valid_o_ll0;   
wire					        sop_o_ll0       ;
wire					        eop_o_ll0       ;
wire					        sof_o_ll0       ;
wire					        eof_o_ll0       ;
// 
wire signed[DATA_WIDTH-1:0]     data_o_ll1      ;
wire                            data_valid_o_ll1;   
wire					        sop_o_ll1       ;
wire					        eop_o_ll1       ;
wire					        sof_o_ll1       ;
wire					        eof_o_ll1       ;
// 
wire signed [DATA_WIDTH-1:0]    data_o_lr0      ;
wire                            data_valid_o_l0r;   
wire					        sop_o_lr0       ;
wire					        eop_o_lr0       ;
wire					        sof_o_lr0       ;
wire					        eof_o_lr0       ;
// 
wire signed[DATA_WIDTH-1:0]     data_o_lr1      ;
wire                            data_valid_o_lr1;   
wire					        sop_o_lr1       ;
wire					        eop_o_lr1       ;
wire					        sof_o_lr1       ;
wire					        eof_o_lr1       ;
//
wire signed[DATA_WIDTH-1:0]     data_o_l1      ;
wire                            data_valid_o_l1;   
wire					        sop_o_l1       ;
wire					        eop_o_l1       ;
wire					        sof_o_l1       ;
wire					        eof_o_l1       ;
//
wire signed[DATA_WIDTH-1:0]     data_o_l2      ;
wire                            data_valid_o_l2;   
wire					        sop_o_l2       ;
wire					        eop_o_l2       ;
wire					        sof_o_l2       ;
wire					        eof_o_l2       ;
//
wire signed[DATA_WIDTH-1:0]     data_o_l3      ;
wire                            data_valid_o_l3;   
wire					        sop_o_l3       ;
wire					        eop_o_l3       ;
wire					        sof_o_l3       ;
wire					        eof_o_l3       ;
//
wire signed[DATA_WIDTH-1:0]     data_o_l4      ;
wire                            data_valid_o_l4;   
wire					        sop_o_l4       ;
wire					        eop_o_l4       ;
wire					        sof_o_l4       ;
wire					        eof_o_l4       ;
//
wire signed[DATA_WIDTH-1:0]     data_o_l5      ;
wire                            data_valid_o_l5;   
wire					        sop_o_l5       ;
wire					        eop_o_l5       ;
wire					        sof_o_l5       ;
wire					        eof_o_l5       ;
//
wire signed[DATA_WIDTH-1:0]     data_o_l6      ;
wire                            data_valid_o_l6;   
wire					        sop_o_l6       ;
wire					        eop_o_l6       ;
wire					        sof_o_l6       ;
wire	                        eof_o_l6       ;
//
wire signed[DATA_WIDTH-1:0]     data_o_l7      ;
wire                            data_valid_o_l7;   
wire					        sop_o_l7       ;
wire					        eop_o_l7       ;
wire					        sof_o_l7       ;
wire	                        eof_o_l7       ;
//
conv_layer
#(
    .MAX_POOL_OFF                     ( 1                                ),
    .STRING2MATRIX_DATA_WIDTH         ( STRING2MATRIX_DATA_WIDTH[0]      ),      
    .STRING2MATRIX_STRING_LEN         ( STRING2MATRIX_STRING_LEN[0]      ),
    .STRING2MATRIX_MATRIX_SIZE        ( STRING2MATRIX_MATRIX_SIZE[0]     ),
    .STRING2MATRIX_CHANNEL_NUM        ( STRING2MATRIX_CHANNEL_NUM[0]     ),
    .STRING2MATRIX_HOLD_DATA          ( STRING2MATRIX_HOLD_DATA[0]       ),
    
    .CONV2_3X3_WRP_KERNEL_WIDTH       ( CONV2_3X3_WRP_KERNEL_WIDTH[0]    ),
    .CONV2_3X3_WRP_MEM_DEPTH          ( CONV2_3X3_WRP_MEM_DEPTH[0]       ),
    .CONV2_3X3_INI_FILE               ( CONV2_3X3_INI_FILE[0]            ), 
    
    .CONV_VECT_SER_KERNEL_WIDTH       ( CONV_VECT_SER_KERNEL_WIDTH[0]    ),
    .CONV_VECT_SER_CHANNEL_NUM        ( CONV_VECT_SER_CHANNEL_NUM[0]     ),
    .CONV_VECT_SER_MTRX_NUM           ( CONV_VECT_SER_MTRX_NUM[0]        ),
    .CONV_VECT_SER_INI_FILE           ( CONV_VECT_SER_INI_FILE[0]        ),
    .CONV_VECT_BIAS_INI_FILE          ( CONV_VECT_BIAS_INI_FILE[0]      ),
    .MAX_POOL_CHANNEL_NUM             ( MAX_POOL_CHANNEL_NUM[0]          ),
    .MAX_POOL_HOLD_DATA               ( MAX_POOL_HOLD_DATA[0]            ),
    
    .RELU_MAX_DATA                    ( RELU_MAX_DATA[0]                 )
)
conv_layer_l0
(
	.clk                              ( clk                     ),      
    .reset_n                          ( reset_n                 ),
	.data_i                           ( data_li                  ),    
    .data_valid_i                     ( data_valid_i            ),    
    .sop_i                            ( sop_i                   ),
    .eop_i                            ( eop_i                   ),
    .sof_i                            ( sof_i                   ),
    .eof_i                            ( eof_i                   ),
    .data_o                           ( data_o_ll0               ),
    .data_valid_o                     ( data_valid_o_ll0         ),
	.sop_o                            ( sop_o_ll0                ),
    .eop_o                            ( eop_o_ll0                ),
    .sof_o                            ( sof_o_ll0                ),
    .eof_o                            ( eof_o_ll0                ),
    .ddr_fifo_rd                      ( ddr_fifo_rd[0]          ), 
    .ddr_fifo_afull                   ( ddr_fifo_afull[0]       )
);
//

conv_layer
#(
    .MAX_POOL_OFF                     ( 1                               ),
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
    .CONV_VECT_BIAS_INI_FILE          ( CONV_VECT_BIAS_INI_FILE[1]      ),
    .MAX_POOL_CHANNEL_NUM             ( MAX_POOL_CHANNEL_NUM[1]         ),
    .MAX_POOL_HOLD_DATA               ( MAX_POOL_HOLD_DATA[1]           ),
    
    .RELU_MAX_DATA                    ( RELU_MAX_DATA[1]                )
)
conv_layer_l1
(
	.clk                              ( clk                     ),      
    .reset_n                          ( reset_n                 ),
	.data_i                           ( data_o_ll0               ),     
    .data_valid_i                     ( data_valid_o_ll0         ),   
    .sop_i                            ( sop_o_ll0                ),
    .eop_i                            ( eop_o_ll0                ),
    .sof_i                            ( sof_o_ll0                ),
    .eof_i                            ( eof_o_ll0                ),
    .data_o                           ( data_o_ll1               ),
    .data_valid_o                     ( data_valid_o_ll1         ),
	.sop_o                            ( sop_o_ll1                ),
    .eop_o                            ( eop_o_ll1                ),
    .sof_o                            ( sof_o_ll1                ),
    .eof_o                            ( eof_o_ll1                ),
    .ddr_fifo_rd                      ( ddr_fifo_rd[1]          ), 
    .ddr_fifo_afull                   ( ddr_fifo_afull[1]       )
);
//////////////////////////////
conv_layer
#(
    .MAX_POOL_OFF                     ( 1                               ),
    .STRING2MATRIX_DATA_WIDTH         ( STRING2MATRIX_DATA_WIDTH[0]      ),      
    .STRING2MATRIX_STRING_LEN         ( STRING2MATRIX_STRING_LEN[0]      ),
    .STRING2MATRIX_MATRIX_SIZE        ( STRING2MATRIX_MATRIX_SIZE[0]     ),
    .STRING2MATRIX_CHANNEL_NUM        ( STRING2MATRIX_CHANNEL_NUM[0]     ),
    .STRING2MATRIX_HOLD_DATA          ( STRING2MATRIX_HOLD_DATA[0]       ),
    
    .CONV2_3X3_WRP_KERNEL_WIDTH       ( CONV2_3X3_WRP_KERNEL_WIDTH[0]    ),
    .CONV2_3X3_WRP_MEM_DEPTH          ( CONV2_3X3_WRP_MEM_DEPTH[0]       ),
    .CONV2_3X3_INI_FILE               ( CONV2_3X3_INI_FILE[2]            ), 
    
    .CONV_VECT_SER_KERNEL_WIDTH       ( CONV_VECT_SER_KERNEL_WIDTH[0]    ),
    .CONV_VECT_SER_CHANNEL_NUM        ( CONV_VECT_SER_CHANNEL_NUM[0]     ),
    .CONV_VECT_SER_MTRX_NUM           ( CONV_VECT_SER_MTRX_NUM[0]        ),
    .CONV_VECT_SER_INI_FILE           ( CONV_VECT_SER_INI_FILE[2]        ),
    .CONV_VECT_BIAS_INI_FILE          ( CONV_VECT_BIAS_INI_FILE[2]      ),
    .MAX_POOL_CHANNEL_NUM             ( MAX_POOL_CHANNEL_NUM[0]          ),
    .MAX_POOL_HOLD_DATA               ( MAX_POOL_HOLD_DATA[0]            ),
    
    .RELU_MAX_DATA                    ( RELU_MAX_DATA[0]                 )
)
conv_layer_r0
(
	.clk                              ( clk                     ),      
    .reset_n                          ( reset_n                 ),
	.data_i                           ( data_ri                  ),    
    .data_valid_i                     ( data_valid_i            ),    
    .sop_i                            ( sop_i                   ),
    .eop_i                            ( eop_i                   ),
    .sof_i                            ( sof_i                   ),
    .eof_i                            ( eof_i                   ),
    .data_o                           ( data_o_lr0               ),
    .data_valid_o                     ( data_valid_o_lr0         ),
	.sop_o                            ( sop_o_lr0                ),
    .eop_o                            ( eop_o_lr0                ),
    .sof_o                            ( sof_o_lr0                ),
    .eof_o                            ( eof_o_lr0                ),
    .ddr_fifo_rd                      ( /*ddr_fifo_rd[0]*/          ), 
    .ddr_fifo_afull                   ( /*ddr_fifo_afull[0]*/       )
);
//
conv_layer
#(
    .MAX_POOL_OFF                     ( 1                               ),
    .STRING2MATRIX_DATA_WIDTH         ( STRING2MATRIX_DATA_WIDTH[1]     ),            
    .STRING2MATRIX_STRING_LEN         ( STRING2MATRIX_STRING_LEN[1]     ),
    .STRING2MATRIX_MATRIX_SIZE        ( STRING2MATRIX_MATRIX_SIZE[1]    ),
    .STRING2MATRIX_CHANNEL_NUM        ( STRING2MATRIX_CHANNEL_NUM[1]    ),
    .STRING2MATRIX_HOLD_DATA          ( STRING2MATRIX_HOLD_DATA[1]      ),    

    .CONV2_3X3_WRP_KERNEL_WIDTH       ( CONV2_3X3_WRP_KERNEL_WIDTH[1]   ),
    .CONV2_3X3_WRP_MEM_DEPTH          ( CONV2_3X3_WRP_MEM_DEPTH[1]      ),
    .CONV2_3X3_INI_FILE               ( CONV2_3X3_INI_FILE[3]           ), 
    
    .CONV_VECT_SER_KERNEL_WIDTH       ( CONV_VECT_SER_KERNEL_WIDTH[1]   ),
    .CONV_VECT_SER_CHANNEL_NUM        ( CONV_VECT_SER_CHANNEL_NUM[1]    ),
    .CONV_VECT_SER_MTRX_NUM           ( CONV_VECT_SER_MTRX_NUM[1]       ),
    .CONV_VECT_SER_INI_FILE           ( CONV_VECT_SER_INI_FILE[3]       ),
    .CONV_VECT_BIAS_INI_FILE          ( CONV_VECT_BIAS_INI_FILE[3]      ),
    .MAX_POOL_CHANNEL_NUM             ( MAX_POOL_CHANNEL_NUM[1]         ),
    .MAX_POOL_HOLD_DATA               ( MAX_POOL_HOLD_DATA[1]           ),
    
    .RELU_MAX_DATA                    ( RELU_MAX_DATA[1]                )
)
conv_layer_r1
(
	.clk                              ( clk                     ),      
    .reset_n                          ( reset_n                 ),
	.data_i                           ( data_o_lr0               ),     
    .data_valid_i                     ( data_valid_o_lr0         ),   
    .sop_i                            ( sop_o_lr0                ),
    .eop_i                            ( eop_o_lr0                ),
    .sof_i                            ( sof_o_lr0                ),
    .eof_i                            ( eof_o_lr0                ),
    .data_o                           ( data_o_lr1               ),
    .data_valid_o                     ( data_valid_o_lr1         ),
	.sop_o                            ( sop_o_lr1                ),
    .eop_o                            ( eop_o_lr1                ),
    .sof_o                            ( sof_o_lr1                ),
    .eof_o                            ( eof_o_lr1                ),
    .ddr_fifo_rd                      ( /*ddr_fifo_rd[1]*/          ), 
    .ddr_fifo_afull                   ( /*ddr_fifo_afull[1]  */     )
);
//
concat_channels 
#(
   .DATA_WIDTH      ( DATA_WIDTH )
)
concat_channels_lr
(
	.clk                              ( clk                 ),
    .reset_n                          ( reset_n             ),
    .data_valid_i                     ( data_valid_o_lr1    ),
	.data_li                          ( data_o_ll1          ),
	.data_ri                          ( data_o_lr1          ),
    .sop_i                            ( sop_o_lr1           ),
    .eop_i                            ( eop_o_lr1           ),
    .sof_i                            ( sof_o_lr1           ),
    .eof_i                            ( eof_o_lr1           ),
    .data_o                           ( data_o_l1           ),
    .data_valid_o                     ( data_valid_o_l1     ),
	.sop_o                            ( sop_o_l1            ),
    .eop_o                            ( eop_o_l1            ),
    .sof_o                            ( sof_o_l1            ),
    .eof_o                            ( eof_o_l1            )
);
//
conv_layer
#(

    .STRING2MATRIX_DATA_WIDTH         ( STRING2MATRIX_DATA_WIDTH[2]     ),            
    .STRING2MATRIX_STRING_LEN         ( STRING2MATRIX_STRING_LEN[2]     ),
    .STRING2MATRIX_MATRIX_SIZE        ( STRING2MATRIX_MATRIX_SIZE[2]    ),
    .STRING2MATRIX_CHANNEL_NUM        ( STRING2MATRIX_CHANNEL_NUM[2]    ),
    .STRING2MATRIX_HOLD_DATA          ( STRING2MATRIX_HOLD_DATA[2]      ),    

    .CONV2_3X3_WRP_KERNEL_WIDTH       ( CONV2_3X3_WRP_KERNEL_WIDTH[2]   ),
    .CONV2_3X3_WRP_MEM_DEPTH          ( CONV2_3X3_WRP_MEM_DEPTH[2]      ),
    .CONV2_3X3_INI_FILE               ( CONV2_3X3_INI_FILE[4]           ), 
    
    .CONV_VECT_SER_KERNEL_WIDTH       ( CONV_VECT_SER_KERNEL_WIDTH[2]   ),
    .CONV_VECT_SER_CHANNEL_NUM        ( CONV_VECT_SER_CHANNEL_NUM[2]    ),
    .CONV_VECT_SER_MTRX_NUM           ( CONV_VECT_SER_MTRX_NUM[2]       ),
    .CONV_VECT_SER_INI_FILE           ( CONV_VECT_SER_INI_FILE[4]       ),
    .CONV_VECT_BIAS_INI_FILE          ( CONV_VECT_BIAS_INI_FILE[4]      ),    
    .MAX_POOL_CHANNEL_NUM             ( MAX_POOL_CHANNEL_NUM[2]         ),
    .MAX_POOL_HOLD_DATA               ( MAX_POOL_HOLD_DATA[2]           ),
    
    .RELU_MAX_DATA                    ( RELU_MAX_DATA[2]                )
)
conv_layer_2
(
	.clk                              ( clk                     ),      
    .reset_n                          ( reset_n                 ),
	.data_i                           ( data_o_l1               ),     
    .data_valid_i                     ( data_valid_o_l1         ),   
    .sop_i                            ( sop_o_l1                ),
    .eop_i                            ( eop_o_l1                ),
    .sof_i                            ( sof_o_l1                ),
    .eof_i                            ( eof_o_l1                ),
    .data_o                           ( data_o_l2               ),
    .data_valid_o                     ( data_valid_o_l2         ),
	.sop_o                            ( sop_o_l2                ),
    .eop_o                            ( eop_o_l2                ),
    .sof_o                            ( sof_o_l2                ),
    .eof_o                            ( eof_o_l2                ),
    .ddr_fifo_rd                      ( ddr_fifo_rd[2]          ), 
    .ddr_fifo_afull                   ( ddr_fifo_afull[2]       )
);
//
conv_layer
#(

    .STRING2MATRIX_DATA_WIDTH         ( STRING2MATRIX_DATA_WIDTH[3]     ),            
    .STRING2MATRIX_STRING_LEN         ( STRING2MATRIX_STRING_LEN[3]     ),
    .STRING2MATRIX_MATRIX_SIZE        ( STRING2MATRIX_MATRIX_SIZE[3]    ),
    .STRING2MATRIX_CHANNEL_NUM        ( STRING2MATRIX_CHANNEL_NUM[3]    ),
    .STRING2MATRIX_HOLD_DATA          ( STRING2MATRIX_HOLD_DATA[3]      ),    

    .CONV2_3X3_WRP_KERNEL_WIDTH       ( CONV2_3X3_WRP_KERNEL_WIDTH[3]   ),
    .CONV2_3X3_WRP_MEM_DEPTH          ( CONV2_3X3_WRP_MEM_DEPTH[3]      ),
    .CONV2_3X3_INI_FILE               ( CONV2_3X3_INI_FILE[5]           ), 
    
    .CONV_VECT_SER_KERNEL_WIDTH       ( CONV_VECT_SER_KERNEL_WIDTH[3]   ),
    .CONV_VECT_SER_CHANNEL_NUM        ( CONV_VECT_SER_CHANNEL_NUM[3]    ),
    .CONV_VECT_SER_MTRX_NUM           ( CONV_VECT_SER_MTRX_NUM[3]       ),
    .CONV_VECT_SER_INI_FILE           ( CONV_VECT_SER_INI_FILE[5]       ),
    .CONV_VECT_BIAS_INI_FILE          ( CONV_VECT_BIAS_INI_FILE[5]      ),    
    .CONV_VECT_BIAS_NUM               ( 32                              ),    
    .MAX_POOL_CHANNEL_NUM             ( MAX_POOL_CHANNEL_NUM[3]         ),
    .MAX_POOL_HOLD_DATA               ( MAX_POOL_HOLD_DATA[3]           ),
    
    .RELU_MAX_DATA                    ( RELU_MAX_DATA[3]                )
)
conv_layer_3
(
	.clk                              ( clk                     ),      
    .reset_n                          ( reset_n                 ),
	.data_i                           ( data_o_l2               ),     
    .data_valid_i                     ( data_valid_o_l2         ),   
    .sop_i                            ( sop_o_l2                ),
    .eop_i                            ( eop_o_l2                ),
    .sof_i                            ( sof_o_l2                ),
    .eof_i                            ( eof_o_l2                ),
    .data_o                           ( data_o_l3               ),
    .data_valid_o                     ( data_valid_o_l3         ),
	.sop_o                            ( sop_o_l3                ),
    .eop_o                            ( eop_o_l3                ),
    .sof_o                            ( sof_o_l3                ),
    .eof_o                            ( eof_o_l3                ),
    .ddr_fifo_rd                      ( ddr_fifo_rd[3]          ), 
    .ddr_fifo_afull                   ( ddr_fifo_afull[3]       )
);
//
conv_layer
#(

    .STRING2MATRIX_DATA_WIDTH         ( STRING2MATRIX_DATA_WIDTH[4]     ),            
    .STRING2MATRIX_STRING_LEN         ( STRING2MATRIX_STRING_LEN[4]     ),
    .STRING2MATRIX_MATRIX_SIZE        ( STRING2MATRIX_MATRIX_SIZE[4]    ),
    .STRING2MATRIX_CHANNEL_NUM        ( STRING2MATRIX_CHANNEL_NUM[4]    ),
    .STRING2MATRIX_HOLD_DATA          ( STRING2MATRIX_HOLD_DATA[4]      ),    

    .CONV2_3X3_WRP_KERNEL_WIDTH       ( CONV2_3X3_WRP_KERNEL_WIDTH[4]   ),
    .CONV2_3X3_WRP_MEM_DEPTH          ( CONV2_3X3_WRP_MEM_DEPTH[4]      ),
    .CONV2_3X3_INI_FILE               ( CONV2_3X3_INI_FILE[6]           ), 
    
    .CONV_VECT_SER_KERNEL_WIDTH       ( CONV_VECT_SER_KERNEL_WIDTH[4]   ),
    .CONV_VECT_SER_CHANNEL_NUM        ( CONV_VECT_SER_CHANNEL_NUM[4]    ),
    .CONV_VECT_SER_MTRX_NUM           ( CONV_VECT_SER_MTRX_NUM[4]       ),
    .CONV_VECT_SER_INI_FILE           ( CONV_VECT_SER_INI_FILE[6]       ),
    .CONV_VECT_BIAS_INI_FILE          ( CONV_VECT_BIAS_INI_FILE[6]      ),    
    .CONV_VECT_BIAS_NUM               ( 64                              ), 
    .MAX_POOL_CHANNEL_NUM             ( MAX_POOL_CHANNEL_NUM[4]         ),
    .MAX_POOL_HOLD_DATA               ( MAX_POOL_HOLD_DATA[4]           ),
    
    .RELU_MAX_DATA                    ( RELU_MAX_DATA[4]                )
)
conv_layer_4
(
	.clk                              ( clk                     ),      
    .reset_n                          ( reset_n                 ),
	.data_i                           ( data_o_l3               ),     
    .data_valid_i                     ( data_valid_o_l3         ),   
    .sop_i                            ( sop_o_l3                ),
    .eop_i                            ( eop_o_l3                ),
    .sof_i                            ( sof_o_l3                ),
    .eof_i                            ( eof_o_l3                ),
    .data_o                           ( data_o_l4               ),
    .data_valid_o                     ( data_valid_o_l4         ),
	.sop_o                            ( sop_o_l4                ),
    .eop_o                            ( eop_o_l4                ),
    .sof_o                            ( sof_o_l4                ),
    .eof_o                            ( eof_o_l4                ),
    .ddr_fifo_rd                      ( ddr_fifo_rd[4]          ), 
    .ddr_fifo_afull                   ( ddr_fifo_afull[4]       )    
);

//
conv_layer
#(
    .MAX_POOL_OFF                     ( 0                               ),
    .STRING2MATRIX_DATA_WIDTH         ( STRING2MATRIX_DATA_WIDTH[5]     ),            
    .STRING2MATRIX_STRING_LEN         ( STRING2MATRIX_STRING_LEN[5]     ),
    .STRING2MATRIX_MATRIX_SIZE        ( STRING2MATRIX_MATRIX_SIZE[5]    ),
    .STRING2MATRIX_CHANNEL_NUM        ( STRING2MATRIX_CHANNEL_NUM[5]    ),
    .STRING2MATRIX_HOLD_DATA          ( STRING2MATRIX_HOLD_DATA[5]      ),    

    .CONV2_3X3_WRP_KERNEL_WIDTH       ( CONV2_3X3_WRP_KERNEL_WIDTH[5]   ),
    .CONV2_3X3_WRP_MEM_DEPTH          ( CONV2_3X3_WRP_MEM_DEPTH[5]      ),
    .CONV2_3X3_INI_FILE               ( CONV2_3X3_INI_FILE[7]           ), 
    
    .CONV_VECT_SER_KERNEL_WIDTH       ( CONV_VECT_SER_KERNEL_WIDTH[5]   ),
    .CONV_VECT_SER_CHANNEL_NUM        ( CONV_VECT_SER_CHANNEL_NUM[5]    ),
    .CONV_VECT_SER_MTRX_NUM           ( CONV_VECT_SER_MTRX_NUM[5]       ),
    .CONV_VECT_SER_INI_FILE           ( CONV_VECT_SER_INI_FILE[7]       ),
    .CONV_VECT_BIAS_INI_FILE          ( CONV_VECT_BIAS_INI_FILE[7]      ),    
    .CONV_VECT_BIAS_NUM               ( 128                             ), 
    .MAX_POOL_CHANNEL_NUM             ( MAX_POOL_CHANNEL_NUM[5]         ),
    .MAX_POOL_HOLD_DATA               ( MAX_POOL_HOLD_DATA[5]           ),
    
    .RELU_MAX_DATA                    ( RELU_MAX_DATA[5]                )
)
conv_layer_5
(
	.clk                              ( clk                     ),      
    .reset_n                          ( reset_n                 ),
	.data_i                           ( data_o_l4               ),     
    .data_valid_i                     ( data_valid_o_l4         ),   
    .sop_i                            ( sop_o_l4                ),
    .eop_i                            ( eop_o_l4                ),
    .sof_i                            ( sof_o_l4                ),
    .eof_i                            ( eof_o_l4                ),
    .data_o                           ( data_o_l5               ),
    .data_valid_o                     ( data_valid_o_l5         ),
	.sop_o                            ( sop_o_l5                ),
    .eop_o                            ( eop_o_l5                ),
    .sof_o                            ( sof_o_l5                ),
    .eof_o                            ( eof_o_l5                ),
    .ddr_fifo_rd                      ( ddr_fifo_rd[5]          ), 
    .ddr_fifo_afull                   ( ddr_fifo_afull[5]       )
);
//
conv_layer
#(
    .MAX_POOL_OFF                     ( 1                               ),
    .STRING2MATRIX_DATA_WIDTH         ( STRING2MATRIX_DATA_WIDTH[6]     ),            
    .STRING2MATRIX_STRING_LEN         ( STRING2MATRIX_STRING_LEN[6]     ),
    .STRING2MATRIX_MATRIX_SIZE        ( STRING2MATRIX_MATRIX_SIZE[6]    ),
    .STRING2MATRIX_CHANNEL_NUM        ( STRING2MATRIX_CHANNEL_NUM[6]    ),
    .STRING2MATRIX_HOLD_DATA          ( STRING2MATRIX_HOLD_DATA[6]      ),    

    .CONV2_3X3_WRP_KERNEL_WIDTH       ( CONV2_3X3_WRP_KERNEL_WIDTH[6]   ),
    .CONV2_3X3_WRP_MEM_DEPTH          ( CONV2_3X3_WRP_MEM_DEPTH[6]      ),
    .CONV2_3X3_INI_FILE               ( CONV2_3X3_INI_FILE[8]           ), 
    
    .CONV_VECT_SER_KERNEL_WIDTH       ( CONV_VECT_SER_KERNEL_WIDTH[6]   ),
    .CONV_VECT_SER_CHANNEL_NUM        ( CONV_VECT_SER_CHANNEL_NUM[6]    ),
    .CONV_VECT_SER_MTRX_NUM           ( CONV_VECT_SER_MTRX_NUM[6]       ),
    .CONV_VECT_SER_INI_FILE           ( CONV_VECT_SER_INI_FILE[8]       ),
    .CONV_VECT_BIAS_INI_FILE          ( CONV_VECT_BIAS_INI_FILE[8]      ),    
    .CONV_VECT_BIAS_NUM               ( 256                             ), 
    .MAX_POOL_CHANNEL_NUM             ( MAX_POOL_CHANNEL_NUM[6]         ),
    .MAX_POOL_HOLD_DATA               ( MAX_POOL_HOLD_DATA[6]           ),
    
    .RELU_MAX_DATA                    ( RELU_MAX_DATA[6]                )
)
conv_layer_6
(
	.clk                              ( clk                     ),      
    .reset_n                          ( reset_n                 ),
	.data_i                           ( data_o_l5               ),     
    .data_valid_i                     ( data_valid_o_l5         ),   
    .sop_i                            ( sop_o_l5                ),
    .eop_i                            ( eop_o_l5                ),
    .sof_i                            ( sof_o_l5                ),
    .eof_i                            ( eof_o_l5                ),
    .data_o                           ( data_o_l6               ),
    .data_valid_o                     ( data_valid_o_l6         ),
	.sop_o                            ( sop_o_l6                ),
    .eop_o                            ( eop_o_l6                ),
    .sof_o                            ( sof_o_l6                ),
    .eof_o                            ( eof_o_l6                ),
    .ddr_fifo_rd                      (                         ), 
    .ddr_fifo_afull                   (                         )
);

max_pool_7
#(
    .DATA_WIDTH 	   ( 8                          ),
    .CHANNEL_NUM       ( MAX_POOL_CHANNEL_NUM[6]    ),
    .HOLD_DATA         ( MAX_POOL_HOLD_DATA[6]      ),
    .STRING_LEN        ( STRING2MATRIX_STRING_LEN[6])
)
max_pool_7_inst
(
    .clk                 (clk),
    .reset_n             (reset_n),
    .sop_i               (sop_o_l6),
    .eop_i               (eop_o_l6),
    .sof_i               (sof_o_l6),
    .eof_i               (eof_o_l6),
	.valid_i             (data_valid_o_l6),
    .data_i              (data_o_l6),
    .data_o              (data_o      ),
    .data_valid_o        (data_valid_o),
    .sop_o               (sop_o       ),
    .eop_o               (eop_o       ),
    .sof_o               (sof_o       ),
    .eof_o               (eof_o       )
);
/*
assign data_o       = data_o_l7      ;
assign data_valid_o = data_valid_o_l7;
assign sop_o        = sop_o_l7       ;
assign eop_o        = eop_o_l7       ;
assign sof_o        = sof_o_l7       ;
assign eof_o        = eof_o_l7       ;
*/
`ifndef SYNT
int l5_file_d,l5_file_v,l5_file_sop,l5_file_eop,l5_file_sof,l5_file_eof;
 
initial 
    begin
        l5_file_d =   $fopen("output_data/l5_output_d.txt","w");
        l5_file_v =   $fopen("output_data/l5_output_v.txt","w");
        l5_file_sop = $fopen("output_data/l5_output_sop.txt","w");
        l5_file_eop = $fopen("output_data/l5_output_eop.txt","w");        
        l5_file_sof = $fopen("output_data/l5_output_sof.txt","w");
        l5_file_eof = $fopen("output_data/l5_output_eof.txt","w");              
        
    end
/*
initial begin
    forever begin
        @( posedge data_valid_o_ll0 );
        repeat (116480*2) @( posedge clk )
            begin
                $fdisplay(l5_file_v,"%h",data_valid_o_ll0);        
                if (data_valid_o_ll0)
                    $fdisplay(l5_file_d,"%h",data_o_ll0);
                else
                    $fdisplay(l5_file_d,"%h",1'h0);
            end        
    end
end
*/

initial begin
    forever begin
        @( posedge data_valid_o_l5 );
        repeat (116480*2) @( posedge clk )
            begin
                $fdisplay(l5_file_v,"%h",data_valid_o_l5);  
                
                $fdisplay(l5_file_sop,"%h",sop_o_l5);  
                $fdisplay(l5_file_eop,"%h",eop_o_l5);  
                $fdisplay(l5_file_sof,"%h",sof_o_l5);  
                $fdisplay(l5_file_eof,"%h",eof_o_l5);  
                if (data_valid_o_l5)
                    $fdisplay(l5_file_d,"%h",data_o_l5);
                else
                    $fdisplay(l5_file_d,"%h",1'h0);
            end        
    end
end

/*
always_ff @( posedge data_valid_o_l5 )
    repeat (116480*2) @( posedge clk )
        begin
            $fdisplay(l5_file_d,"%h",data_o_l5);
            $fdisplay(l5_file_v,"%h",data_valid_o_l5);
        end
*/        
`endif   
endmodule

       
 