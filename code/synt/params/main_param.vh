//
//parameter STRING2MATRIX_CHAN_NUM           [1:0] = 1;
//                                         [1:0]
parameter  integer STRING2MATRIX_DATA_WIDTH  [6]        = '{8  ,     8,      8,      8,      8,      8} ;
//parameter  logic[31:0]STRING2MATRIX_DATA_WIDTH[0:4]         = '{32'd8  ,     32'd8,      32'd8,      32'd8,      32'd8} ;
parameter  integer STRING2MATRIX_STRING_LEN  [6]        = '{224,     112,    56,     28,     14,     7};//{224,     112    };
parameter  integer STRING2MATRIX_MATRIX_SIZE [6]        = '{3  ,     3,      3,      3,      3,      3};
parameter  integer STRING2MATRIX_CHANNEL_NUM [6]        = '{3  ,     16,     16,     32,     64,     128};
parameter  integer STRING2MATRIX_HOLD_DATA   [6]        = '{16 ,     16,     32,     64,     128,    256};
//                                         [1:0]
//parameter CONV2_3X3_WRP_KERNEL_NUM         [1:0] = 1             ;
parameter  integer CONV2_3X3_WRP_KERNEL_WIDTH[6]        = '{8,       8,      8,      8,      8,      8};
parameter  integer CONV2_3X3_WRP_MEM_DEPTH[6]           = '{3,       16,     16,     32,     64,     128};
parameter string CONV2_3X3_INI_FILE [6]        = '{"conv20.txt","rom_init_0.txt","rom_init_0.txt","rom_init_0.txt","rom_init_0.txt","rom_init_0.txt"};          
                                           
parameter  integer CONV_VECT_SER_KERNEL_WIDTH[6]        = '{8 ,      8,      8,      8,      8,      8};
parameter  integer CONV_VECT_SER_CHANNEL_NUM[6]         = '{16,      16,     32,     64,     128,    256};
parameter  integer CONV_VECT_SER_MTRX_NUM[6]            = '{3 ,      16,     16,     32,     64,     128};
//parameter CONV_VECT_SER_HOLD_DATA          [1:0] = 8              ;
parameter string CONV_VECT_SER_INI_FILE[6]     = '{"conv_vect0.txt","rom_init.txt","rom_init.txt","rom_init.txt","rom_init.txt","rom_init.txt"} ;
                                       
parameter  integer MAX_POOL_CHANNEL_NUM[6]              = '{16 ,     16,     32,     64,     128,    256};
parameter  integer MAX_POOL_HOLD_DATA[6]                = '{16 ,     32,     32,     64,     128,    256};
parameter  integer RELU_MAX_DATA[6]                     = '{127,     127,    127,    127,    127,    127}/*2541*/           ;

//
//parameter MATRIX_PARALLEL2SERIAL_DATA_WIDTH = STRING2MATRIX_DATA_WIDTH;
//parameter CONV2_3X3_WRP_DATA_WIDTH = MATRIX_PARALLEL2SERIAL_DATA_WIDTH;
//parameter CONV_VECT_SER_DATA_WIDTH = CONV2_3X3_WRP_DATA_WIDTH+CONV2_3X3_WRP_KERNEL_WIDTH+4;
//
/////parameter MAX_POOL_DATA_WIDTH = CONV_VECT_SER_DATA_WIDTH + CONV_VECT_SER_MTRX_NUM + CONV_VECT_SER_KERNEL_WIDTH;
/////parameter RELU_DATA_WIDTH = MAX_POOL_DATA_WIDTH;
/////parameter MATRIX_PARALLEL2SERIAL_DATA_HOLD = CONV_VECT_SER_CHANNEL_NUM;
//parameter RELU_DATA_WIDTH = $clog2(RELU_MAX_DATA);;
//parameter MAX_POOL_DATA_WIDTH = RELU_DATA_WIDTH;


//
/*
localparam CONV2_3X3_WRP_DATA_WIDTH = STRING2MATRIX_DATA_WIDTH*CONV2_3X3_WRP_KERNEL_WIDTH+8;
localparam CONV_VECT_SER_DATA_WIDTH = CONV2_3X3_WRP_DATA_WIDTH*CONV_VECT_SER_KERNEL_WIDTH+CONV_VECT_SER_MTRX_NUM;
localparam RELU_DATA_WIDTH =  $clog2(RELU_MAX_DATA);
localparam MAX_POOL_DATA_WIDTH = RELU_DATA_WIDTH;
*/

//parameter [1:0] MAX_POOL_STRING_LEN;

parameter integer MAX_POOL_STRING_LEN[6]      = '{ STRING2MATRIX_STRING_LEN[0], STRING2MATRIX_STRING_LEN[1], STRING2MATRIX_STRING_LEN[2],
                                                  STRING2MATRIX_STRING_LEN[3],STRING2MATRIX_STRING_LEN[4], STRING2MATRIX_STRING_LEN[5]};
parameter integer CONV2_3X3_WRP_DATA_WIDTH[6] = '{ STRING2MATRIX_DATA_WIDTH[0], STRING2MATRIX_DATA_WIDTH[1], STRING2MATRIX_DATA_WIDTH[2],
                                                  STRING2MATRIX_DATA_WIDTH[3],STRING2MATRIX_DATA_WIDTH[4],STRING2MATRIX_DATA_WIDTH[5]};
parameter integer CONV_VECT_SER_DATA_WIDTH[6] = '{ STRING2MATRIX_DATA_WIDTH[0]+CONV2_3X3_WRP_KERNEL_WIDTH[0]+8,
                                             STRING2MATRIX_DATA_WIDTH[1]+CONV2_3X3_WRP_KERNEL_WIDTH[1]+8,
                                             STRING2MATRIX_DATA_WIDTH[2]+CONV2_3X3_WRP_KERNEL_WIDTH[2]+8,
                                             STRING2MATRIX_DATA_WIDTH[3]+CONV2_3X3_WRP_KERNEL_WIDTH[3]+8,
                                             STRING2MATRIX_DATA_WIDTH[4]+CONV2_3X3_WRP_KERNEL_WIDTH[4]+8,
                                             STRING2MATRIX_DATA_WIDTH[5]+CONV2_3X3_WRP_KERNEL_WIDTH[5]+8};
parameter integer RELU_DATA_WIDTH[6]          =  '{ CONV2_3X3_WRP_DATA_WIDTH[0]+CONV_VECT_SER_KERNEL_WIDTH[0]+CONV_VECT_SER_MTRX_NUM[0],
                                             CONV2_3X3_WRP_DATA_WIDTH[1]+CONV_VECT_SER_KERNEL_WIDTH[1]+CONV_VECT_SER_MTRX_NUM[1],
                                             CONV2_3X3_WRP_DATA_WIDTH[2]+CONV_VECT_SER_KERNEL_WIDTH[2]+CONV_VECT_SER_MTRX_NUM[2],
                                             CONV2_3X3_WRP_DATA_WIDTH[3]+CONV_VECT_SER_KERNEL_WIDTH[3]+CONV_VECT_SER_MTRX_NUM[3],
                                             CONV2_3X3_WRP_DATA_WIDTH[4]+CONV_VECT_SER_KERNEL_WIDTH[4]+CONV_VECT_SER_MTRX_NUM[4],
                                             CONV2_3X3_WRP_DATA_WIDTH[5]+CONV_VECT_SER_KERNEL_WIDTH[5]+CONV_VECT_SER_MTRX_NUM[5]};
parameter integer MAX_POOL_DATA_WIDTH[6]      = '{ $clog2(RELU_DATA_WIDTH[0]), $clog2(RELU_DATA_WIDTH[1]),$clog2(RELU_DATA_WIDTH[2]),
                                                  $clog2(RELU_DATA_WIDTH[3]),$clog2(RELU_DATA_WIDTH[4]),$clog2(RELU_DATA_WIDTH[5])};
///////////////////


//
//parameter MAX_POOL_STRING_LEN[1]       = STRING2MATRIX_STRING_LEN[1];
//parameter CONV2_3X3_WRP_DATA_WIDTH[1] = STRING2MATRIX_DATA_WIDTH[1];
//parameter CONV_VECT_SER_DATA_WIDTH[1] = STRING2MATRIX_DATA_WIDTH[1]+CONV2_3X3_WRP_KERNEL_WIDTH[1]+8;
//parameter RELU_DATA_WIDTH[1]          =  CONV2_3X3_WRP_DATA_WIDTH[1]+CONV_VECT_SER_KERNEL_WIDTH[1]+CONV_VECT_SER_MTRX_NUM[1];
//parameter MAX_POOL_DATA_WIDTH[1]      = $clog2(RELU_DATA_WIDTH[1];