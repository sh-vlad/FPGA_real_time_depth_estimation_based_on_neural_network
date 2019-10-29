//Author: ShVlad / e-mail: shvladspb@gmail.com
`timescale 1 ns / 1 ns
module up_sampling
#(
    parameter DATA_WIDTH        = 8,
    parameter STRING_LEN        = 224,
    parameter CHANNEL_NUM       = 3,
    parameter DATA_O_WIDTH      = DATA_WIDTH
)
(
    input wire                                  clk,
    input wire                                  reset_n,
    input wire signed       [DATA_WIDTH-1:0]    data_i,    
	input wire                                  valid_i,
    input wire                                  sop_i,
    input wire                                  eop_i,
    input wire                                  sof_i,
    input wire                                  eof_i,
    output logic            [DATA_O_WIDTH-1:0]  data_o,
    output logic                                data_valid_o,
    output logic                                sop_o,
    output logic                                eop_o,
    output logic                                sof_o,
    output logic                                eof_o
);

localparam FIFO_DEPTH_LONG = CHANNEL_NUM*STRING_LEN*2;
localparam LPM_WIDTHU_LONG = $clog2(FIFO_DEPTH_LONG);
localparam FIFO_DEPTH_SHORT = CHANNEL_NUM;
localparam LPM_WIDTHU_SHORT = $clog2(FIFO_DEPTH_SHORT);
localparam FIFO_DEPTH_INPUT  = CHANNEL_NUM*STRING_LEN*2;
localparam LPM_WIDTHU_INPUT  = $clog2(FIFO_DEPTH_INPUT);

localparam RAM_STYLE_SHORT = FIFO_DEPTH_SHORT < 32 ? "logic" : "M10K";


reg  [$clog2(CHANNEL_NUM):0]             chan_cnt;
reg  [$clog2(FIFO_DEPTH_LONG):0]         chan_str_cnt;    
logic                                    fifo_short_rd;
logic[ 1: 0]                             sh_fifo_short_rd;
reg  [$clog2(CHANNEL_NUM):0]             fifo_short_rd_cnt;
wire [DATA_WIDTH-1:0]                    fifo_short_out;

logic[DATA_WIDTH-1:0]                    fifo_long_in;
logic                                    fifo_long_rd;
reg                                      sh_fifo_long_rd;
wire                                     fifo_long_empty;
reg                                      sh_fifo_long_empty;
wire                                     fifo_long_almost_empty;
wire [DATA_O_WIDTH-1:0]                  fifo_long_out;
wire [LPM_WIDTHU_LONG-1:0]               fifo_long_usedw;

logic[DATA_WIDTH-1:0]                    fifo_input_out;
logic                                    fifo_input_wr;
wire [LPM_WIDTHU_INPUT-1:0]              fifo_input_usedw;
wire                                     fifo_input_empty;
logic                                    fifo_input_valid;
reg [$clog2(STRING_LEN*2)-1:0]            line_cnt;
///////////////////////////////////
      
scfifo
#(
    .add_ram_output_register    ( "ON"              ),
    .intended_device_family     ( "Cyclone V"       ),
	.lpm_widthu					( LPM_WIDTHU_INPUT	),
    .lpm_numwords               ( FIFO_DEPTH_INPUT    ),
    .lpm_width                  ( DATA_WIDTH        )
)
scfifo_input
(
    .clock          ( clk                                                   ),
    .data           ( data_i                                                ),
    .rdreq          ( !fifo_input_empty && !fifo_short_rd && !fifo_long_rd  ),
    .wrreq          ( valid_i                                               ),
	.empty          ( fifo_input_empty                                      ),
	.full           (),                     
    .q              ( fifo_input_out                                        ),
	.usedw          ( fifo_input_usedw                                      ),
	.aclr           (),
	.almost_empty   (),
	.almost_full    (),
	.eccstatus      (),
	.sclr           ()
);    
 
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        fifo_input_valid <= 1'h0;
    else
        fifo_input_valid <= !fifo_input_empty && !fifo_short_rd && !fifo_long_rd;
/**/
    
//////////////////////////////////


//
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        chan_cnt <= '0;
    else
        if ( chan_cnt == CHANNEL_NUM-1 )
            chan_cnt <= '0;
        else if ( fifo_input_valid )
            chan_cnt <= chan_cnt + 1'h1;
 //           
always @( posedge clk )
    if ( !reset_n )
        fifo_short_rd_cnt <= '0;
    else
        if ( fifo_short_rd_cnt == CHANNEL_NUM )
            fifo_short_rd_cnt <= '0;
        else if ( chan_cnt == CHANNEL_NUM-2 )
           fifo_short_rd_cnt <= 1;
        else if ( fifo_short_rd_cnt != 0 )
            fifo_short_rd_cnt <= fifo_short_rd_cnt + 1'h1;
//
assign fifo_short_rd = fifo_short_rd_cnt != 0;            
always @( posedge clk )
    sh_fifo_short_rd <= { sh_fifo_short_rd[0] ,fifo_short_rd };
// 
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        chan_str_cnt <= '0;
    else
        if ( chan_str_cnt == FIFO_DEPTH_LONG/2 && !fifo_short_rd )
            chan_str_cnt <= '0;
        else if ( fifo_input_valid )
            chan_str_cnt <= chan_str_cnt + 1'h1;
 
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        fifo_long_rd <= 0;
    else
        if ( !fifo_long_rd && chan_str_cnt == FIFO_DEPTH_LONG/2 && !fifo_short_rd )
            fifo_long_rd <= 1'h1;
        else if ( fifo_long_rd && fifo_long_empty )
            fifo_long_rd <= 1'h0;

always @( posedge clk )
    sh_fifo_long_rd <= fifo_long_rd;
            
scfifo
#(
    .add_ram_output_register    ( "ON"              ),
    .intended_device_family     ( "Cyclone V"       ),
	.lpm_widthu					( LPM_WIDTHU_SHORT	),
    .lpm_numwords               ( FIFO_DEPTH_SHORT   ),
    .lpm_width                  ( DATA_WIDTH    )
)
scfifo_short_inst
(
    .clock          ( clk               ),
    .data           ( fifo_input_out            ),
    .rdreq          ( fifo_short_rd     ),
    .wrreq          ( fifo_input_valid           ),
	.empty          (),
	.full           (),
    .q              ( fifo_short_out    ),
	.usedw          (),
	.aclr           (),
	.almost_empty   (),
	.almost_full    (),
	.eccstatus      (),
	.sclr           ()
); 

always_comb
    begin
        if ( fifo_input_valid )
            fifo_long_in = fifo_input_out;
        else if ( sh_fifo_short_rd[0] )
            fifo_long_in = fifo_short_out;
        else 
            fifo_long_in = '0;
    end
 
scfifo
#(
    .add_ram_output_register    ( "ON"              ),
    .intended_device_family     ( "Cyclone V"       ),
	.lpm_widthu					( LPM_WIDTHU_LONG	),
    .lpm_numwords               ( FIFO_DEPTH_LONG   ),
    .lpm_width                  ( DATA_WIDTH        )
)
scfifo_long_inst
(
    .clock          ( clk                               ),
    .data           ( fifo_long_in                      ),
    .rdreq          ( fifo_long_rd && !fifo_long_empty                     ),
    .wrreq          ( fifo_input_valid || sh_fifo_short_rd[0]    ),
	.empty          ( fifo_long_empty                   ),
	.full           (),
    .q              ( fifo_long_out                     ),
	.usedw          (),
	.aclr           (),
	.almost_empty   ( fifo_long_almost_empty            ),
	.almost_full    (),
	.eccstatus      (),
	.sclr           ()
); 
always @( posedge clk )
    sh_fifo_long_empty <= fifo_long_empty;
always @( posedge clk )
    if ( sh_fifo_short_rd[0] )
        data_o <=  fifo_short_out;
    else if ( fifo_input_valid )
        data_o <=  fifo_input_out; 
    else if ( sh_fifo_long_rd )
        data_o <= fifo_long_out;    

always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        data_valid_o <= 1'h0;
    else
        data_valid_o <= (sh_fifo_short_rd[0] | fifo_input_valid | (sh_fifo_long_rd && !sh_fifo_long_empty) )  ; 
 
reg [$clog2(CHANNEL_NUM*STRING_LEN*2):0] cnt_sampls;
reg [$clog2(CHANNEL_NUM*2):0]            chnl_cnt;

always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        chnl_cnt <= '0;
    else
        if ( !( sh_fifo_short_rd[0] | fifo_input_valid | sh_fifo_long_rd ) && data_valid_o && chnl_cnt == CHANNEL_NUM*2 )
            chnl_cnt <= '0;
        else if ( chnl_cnt == CHANNEL_NUM*2 && cnt_sampls == STRING_LEN*2-1 )
            chnl_cnt <= '0;
        else if ( chnl_cnt == CHANNEL_NUM*2 )
            chnl_cnt <= 1;
        else if ( sh_fifo_short_rd[0] | fifo_input_valid | sh_fifo_long_rd )
            chnl_cnt <= chnl_cnt + 1'h1;

always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        cnt_sampls <= '0;
    else
        if ( chnl_cnt == CHANNEL_NUM*2 && cnt_sampls == STRING_LEN*2-1 )
            cnt_sampls <= '0;
        else if ( chnl_cnt == CHANNEL_NUM*2 )
            cnt_sampls <= cnt_sampls + 1'h1;

always @( posedge clk or posedge reset_n )
    if ( !reset_n )
        line_cnt <= '0;
    else
        if ( eop_o && line_cnt == STRING_LEN*2-1 )
            line_cnt <= '0;    
        else if ( eop_o )
            line_cnt <= line_cnt + 1;
            
assign sop_o = ( chnl_cnt == 1 ) & ( ( cnt_sampls == 0 ) || ( cnt_sampls == STRING_LEN ) );
assign eop_o =  chnl_cnt == CHANNEL_NUM*2 && ( (cnt_sampls == STRING_LEN*2-1) || (cnt_sampls == STRING_LEN-1) );

assign sof_o = sop_o & line_cnt == 0/*( chnl_cnt == 1 ) & ( cnt_sampls == 0 )*/;
assign eof_o = eop_o & line_cnt == STRING_LEN*2-1/*( chnl_cnt == CHANNEL_NUM*2 ) & ( cnt_sampls == STRING_LEN*2-1 )*/;     
       
endmodule
