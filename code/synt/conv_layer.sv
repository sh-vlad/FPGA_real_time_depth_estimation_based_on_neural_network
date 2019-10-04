//Author: Vlad Sharshin 
//e-mail: shvladspb@gmail.com
module conv_layer
#(
/*
    parameter DATA_WIDTH    = 8,
    parameter CHAN_NUM      = 3
    */
    parameter STRING2MATRIX_DATA_WIDTH          = 8,
//    parameter STRING2MATRIX_CHAN_NUM            = 3,
    parameter STRING2MATRIX_STRING_LEN          = 224,
    parameter STRING2MATRIX_MATRIX_SIZE         = 3,
    parameter STRING2MATRIX_CHANNEL_NUM         = 1,
    parameter STRING2MATRIX_HOLD_DATA           = 16,
//    
    //parameter MATRIX_PARALLEL2SERIAL_DATA_WIDTH = 8, 
    parameter MATRIX_PARALLEL2SERIAL_BUS_NUM    = 9,
    parameter MATRIX_PARALLEL2SERIAL_MTRX_NUM_I = 3,
    parameter MATRIX_PARALLEL2SERIAL_MTRX_NUM_O = 1,
//    parameter MATRIX_PARALLEL2SERIAL_DATA_HOLD  = 16,    
//
//    parameter CONV2_3X3_WRP_DATA_WIDTH          = 8, 
//    parameter CONV2_3X3_WRP_KERNEL_NUM          = 3,
    parameter CONV2_3X3_WRP_KERNEL_WIDTH        = 8,
    parameter CONV2_3X3_WRP_MEM_DEPTH           = 3,
    parameter CONV2_3X3_INI_FILE/*[CONV2_3X3_WRP_KERNEL_NUM]*/= "",//      = '{"rom_init_0.txt","rom_init_0.txt","rom_init_0.txt"},//'{""},
//
//    parameter CONV_VECT_SER_DATA_WIDTH          = 8,               
    parameter CONV_VECT_SER_KERNEL_WIDTH        = 8,               
    parameter CONV_VECT_SER_CHANNEL_NUM         = 16,              
    parameter CONV_VECT_SER_MTRX_NUM            = 3,               
    parameter CONV_VECT_SER_HOLD_DATA           = 8,               
    parameter CONV_VECT_SER_INI_FILE            = "rom_init.txt",
//
//    parameter MAX_POOL_DATA_WIDTH               = 8, 
    parameter MAX_POOL_CHANNEL_NUM              = 3,
    parameter MAX_POOL_HOLD_DATA                = 16,
//
//    parameter RELU_DATA_WIDTH                   = 8,
    parameter RELU_MAX_DATA                     = 254   
)
(
	input wire                                  clk, 
    input wire                                  reset_n,
	input wire [STRING2MATRIX_DATA_WIDTH-1:0]   data_i/*[STRING2MATRIX_CHAN_NUM]*/, 
    input wire                                  data_valid_i,    
    input wire						            sop_i,
    input wire						            eop_i,
    input wire						            sof_i,
    input wire						            eof_i,   

    output wire [STRING2MATRIX_DATA_WIDTH-1:0]  data_o,
    output wire                                 data_valid_o,
	output logic					            sop_o,
    output logic					            eop_o,
    output logic					            sof_o,
    output logic					            eof_o    
);

/*
localparam CONV2_3X3_WRP_DATA_WIDTH = STRING2MATRIX_DATA_WIDTH*CONV2_3X3_WRP_KERNEL_WIDTH+8;
localparam CONV_VECT_SER_DATA_WIDTH = CONV2_3X3_WRP_DATA_WIDTH*CONV_VECT_SER_KERNEL_WIDTH+CONV_VECT_SER_MTRX_NUM;
localparam RELU_DATA_WIDTH =  $clog2(RELU_MAX_DATA);
localparam MAX_POOL_DATA_WIDTH = RELU_DATA_WIDTH;
*/
/*
localparam CONV2_3X3_WRP_DATA_WIDTH = STRING2MATRIX_DATA_WIDTH+CONV2_3X3_WRP_KERNEL_WIDTH+8;
localparam CONV_VECT_SER_DATA_WIDTH = CONV2_3X3_WRP_DATA_WIDTH+CONV_VECT_SER_KERNEL_WIDTH+CONV_VECT_SER_MTRX_NUM;
localparam RELU_DATA_WIDTH =  $clog2(RELU_DATA_WIDTH);;
localparam MAX_POOL_DATA_WIDTH = RELU_DATA_WIDTH;
*/
localparam CONV2_3X3_WRP_DATA_WIDTH = STRING2MATRIX_DATA_WIDTH;
localparam CONV_VECT_SER_DATA_WIDTH = STRING2MATRIX_DATA_WIDTH+CONV2_3X3_WRP_KERNEL_WIDTH+8;
localparam RELU_DATA_WIDTH =  CONV2_3X3_WRP_DATA_WIDTH+CONV_VECT_SER_KERNEL_WIDTH+CONV_VECT_SER_MTRX_NUM;
localparam MAX_POOL_DATA_WIDTH = $clog2(RELU_DATA_WIDTH);


localparam MATRIX_PARALLEL2SERIAL_DATA_HOLD = CONV_VECT_SER_CHANNEL_NUM;

localparam MAX_POOL_STRING_LEN = STRING2MATRIX_STRING_LEN;
localparam CONV2_3X3_WRP_DATA_HOLD = STRING2MATRIX_HOLD_DATA;
//wire [STRING2MATRIX_DATA_WIDTH-1:0] data_mtrx[STRING2MATRIX_CHAN_NUM][9];
//wire [STRING2MATRIX_CHAN_NUM-1: 0]  data_mtrx_valid;
//wire                                data_mtrx_serilal_valid;
//wire [CONV2_3X3_WRP_DATA_WIDTH-1:0] data_mtrx_serial/*[MATRIX_PARALLEL2SERIAL_MTRX_NUM_O]*/[9];
//
////
//wire [CONV_VECT_SER_DATA_WIDTH-1:0] data_conv2_wrp[CONV2_3X3_WRP_KERNEL_NUM];
//wire                                data_conv2_wrp_valid;
//wire            					sop_conv2_wrp;
//wire            					eop_conv2_wrp;
//wire            					sof_conv2_wrp;
//wire            					eof_conv2_wrp;
////
//wire [MAX_POOL_DATA_WIDTH-1:0]      data_conv_vect_ser;
//wire                                data_conv_vect_ser_valid;
//wire            					sop_conv_vect_ser;
//wire            					eop_conv_vect_ser;
//wire            					sof_conv_vect_ser;
//wire            					eof_conv_vect_ser;
////
//wire [MAX_POOL_DATA_WIDTH-1:0]      data_max_pool;
//wire                                data_max_pool_valid;
//wire            					sop_max_pool;
//wire            					eop_max_pool;
//wire            					sof_max_pool;
//wire            					eof_max_pool;
////
//wire [MAX_POOL_DATA_WIDTH-1:0]      data_ReLu;
//wire                                data_ReLu_valid;

//connectors wires
wire [STRING2MATRIX_DATA_WIDTH-1:0] data_string2matrix/*[STRING2MATRIX_CHAN_NUM]*/[9];
wire /*[STRING2MATRIX_CHAN_NUM-1: 0]*/  data_string2matrix_valid;
wire            					sop_string2matrix;
wire            					eop_string2matrix;
wire            					sof_string2matrix;
wire            					eof_string2matrix;
//
wire [CONV_VECT_SER_DATA_WIDTH-1:0] data_conv2_wrp/*[CONV2_3X3_WRP_KERNEL_NUM]*/;
wire                                data_conv2_wrp_valid;
wire            					sop_conv2_wrp;
wire            					eop_conv2_wrp;
wire            					sof_conv2_wrp;
wire            					eof_conv2_wrp;
//
wire [RELU_DATA_WIDTH-1:0] data_conv_vect_ser;
wire                                data_conv_vect_ser_valid;
wire            					sop_conv_vect_ser;
wire            					eop_conv_vect_ser;
wire            					sof_conv_vect_ser;
wire            					eof_conv_vect_ser;
//
wire [MAX_POOL_DATA_WIDTH-1:0]      data_ReLu;
wire                                data_ReLu_valid;
wire            					sop_ReLu;
wire            					eop_ReLu;
wire            					sof_ReLu;
wire            					eof_ReLu;
//
wire [MAX_POOL_DATA_WIDTH-1:0]      data_max_pool;
wire                                data_max_pool_valid;
wire            					sop_max_pool;
wire            					eop_max_pool;
wire            					sof_max_pool;
wire            					eof_max_pool;
//
// convert string to matrix
string2matrix_v2
#(
    .DATA_WIDTH    ( STRING2MATRIX_DATA_WIDTH   ),
    .STRING_LEN    ( STRING2MATRIX_STRING_LEN   ),
    .MATRIX_SIZE   ( STRING2MATRIX_MATRIX_SIZE  ),
    .CHANNEL_NUM   ( STRING2MATRIX_CHANNEL_NUM  ),
    .HOLD_DATA     ( STRING2MATRIX_HOLD_DATA    )
)       
string2matrix_v2_inst      
(       
    .clk            ( clk                       ),
    .reset_n        ( reset_n                   ),
    .data_valid_i   ( data_valid_i              ),
    .data_i         ( data_i/*[0  ]*/           ),
    .sop_i          ( sop_i                     ),
    .eop_i          ( eop_i                     ),
    .sof_i          ( sof_i                     ),
    .eof_i          ( eof_i                     ),
    .data_o         ( data_string2matrix/*[0]*/     ),    
    .data_valid_o   ( data_string2matrix_valid  ),
	.sop_o          ( sop_string2matrix         ),
    .eop_o          ( eop_string2matrix         ),
    .sof_o          ( sof_string2matrix         ),
    .eof_o          ( eof_string2matrix         )
);
//
conv2_3x3_wrp
#(
    .DATA_WIDTH     ( CONV2_3X3_WRP_DATA_WIDTH  ), 
//    .KERNEL_NUM     ( CONV2_3X3_WRP_KERNEL_NUM  ),
    .KERNEL_WIDTH   ( CONV2_3X3_WRP_KERNEL_WIDTH),
    .MEM_DEPTH      ( CONV2_3X3_WRP_MEM_DEPTH   ),
    .DATA_HOLD      ( CONV2_3X3_WRP_DATA_HOLD   ),
    .INI_FILE       ( CONV2_3X3_INI_FILE        )
)
conv2_3x3_wrp_inst
(
	.clk            ( clk                       ),
    .reset_n        ( reset_n                   ),
	.data_i         ( data_string2matrix        ),
    .data_valid_i   ( data_string2matrix_valid  ),
	.sop_i          ( sop_string2matrix         ),
    .eop_i          ( eop_string2matrix         ),
    .sof_i          ( sof_string2matrix         ),
    .eof_i          ( eof_string2matrix         ),
    .data_o         ( data_conv2_wrp            ),
    .data_valid_o   ( data_conv2_wrp_valid      ),
	.sop_o          ( sop_conv2_wrp             ),
    .eop_o          ( eop_conv2_wrp             ),
    .sof_o          ( sof_conv2_wrp             ),
    .eof_o          ( eof_conv2_wrp             )
);
//
conv_vect_ser
#(
    .DATA_WIDTH 	  ( CONV_VECT_SER_DATA_WIDTH  ),
    .KERNEL_WIDTH     ( CONV_VECT_SER_KERNEL_WIDTH),
    .CHANNEL_NUM      ( CONV_VECT_SER_CHANNEL_NUM ),
    .MTRX_NUM         ( CONV_VECT_SER_MTRX_NUM    ),
//    .HOLD_DATA        ( CONV_VECT_SER_HOLD_DATA   ),
    .INI_FILE         ( CONV_VECT_SER_INI_FILE    ),
    .STRING_LEN       ( STRING2MATRIX_STRING_LEN  )
)
conv_vect_ser_inst
(
    .clk              ( clk                     ),  
    .reset_n          ( reset_n                 ),
    .data_i           ( data_conv2_wrp      /*[0]*/ ),    
	.valid_i          ( data_conv2_wrp_valid    ),    
    .sop_i            ( sop_conv2_wrp           ),
    .eop_i            ( eop_conv2_wrp           ),
    .sof_i            ( sof_conv2_wrp           ),  
    .eof_i            ( eof_conv2_wrp           ),

    .data_o           ( data_conv_vect_ser      ),
    .data_valid_o     ( data_conv_vect_ser_valid),
    .sop_o            ( sop_conv_vect_ser       ),
    .eop_o            ( eop_conv_vect_ser       ),
    .sof_o            ( sof_conv_vect_ser       ),  
    .eof_o            ( eof_conv_vect_ser       )
);
//
ReLu
#(
    .DATA_WIDTH       ( RELU_DATA_WIDTH             ),
    .MAX_DATA         ( RELU_MAX_DATA               ),
    .DATA_O_WIDTH     ( STRING2MATRIX_DATA_WIDTH    )
)
ReLu_inst
(
    .clk               ( clk                        ),
    .reset_n           ( reset_n                    ),
    .data_i            ( data_conv_vect_ser         ), 
	.valid_i           ( data_conv_vect_ser_valid   ),    
    .sop_i             ( sop_conv_vect_ser          ),
    .eop_i             ( eop_conv_vect_ser          ),
    .sof_i             ( sof_conv_vect_ser          ),
    .eof_i             ( eof_conv_vect_ser          ),
    .data_o            ( data_ReLu                  ),
    .data_valid_o      ( data_ReLu_valid            ),
    .sop_o             ( sop_ReLu                   ),
    .eop_o             ( eop_ReLu                   ),
    .sof_o             ( sof_ReLu                   ),
    .eof_o             ( eof_ReLu                   )
);
//
max_pool 
#(
    .DATA_WIDTH 	  ( MAX_POOL_DATA_WIDTH         ),
    .CHANNEL_NUM      ( MAX_POOL_CHANNEL_NUM        ),
    .HOLD_DATA        ( MAX_POOL_HOLD_DATA          ),
    .STRING_LEN       ( MAX_POOL_STRING_LEN         )
)
max_pool_inst
(
    .clk              ( clk                         ),  
    .reset_n          ( reset_n                     ),
    .data_i           ( data_ReLu                   ),    
 	.valid_i          ( data_ReLu_valid             ),   
    .sop_i            ( sop_ReLu                    ),
    .eop_i            ( eop_ReLu                    ),
    .sof_i            ( sof_ReLu                    ),  
    .eof_i            ( eof_ReLu                    ),

    .data_o           ( data_max_pool               ),
    .data_valid_o     ( data_max_pool_valid         ),
    .sop_o            ( sop_max_pool                ),
    .eop_o            ( eop_max_pool                ),
    .sof_o            ( sof_max_pool                ),  
    .eof_o            ( eof_max_pool                )
);

/*

*/
assign data_o       = data_max_pool      ;
assign data_valid_o = data_max_pool_valid;
assign sop_o        = sop_max_pool       ;
assign eop_o        = eop_max_pool       ;
assign sof_o        = sof_max_pool       ;
assign eof_o        = eof_max_pool       ;
endmodule

