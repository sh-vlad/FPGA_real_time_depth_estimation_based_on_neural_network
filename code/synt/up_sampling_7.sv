//Author: ShVlad / e-mail: shvladspb@gmail.com
`timescale 1 ns / 1 ns
module up_sampling_7
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

localparam ADDR_WIDTH =  $clog2(CHANNEL_NUM);

reg [$clog2(CHANNEL_NUM)-1:0]       chan_cnt;
reg [$clog2(CHANNEL_NUM):0]         rd_addr;
reg [5:0]                           smpl_cnt;
wire[DATA_WIDTH-1:0]                ram_out;

always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        chan_cnt <= '0;
    else
        if ( (chan_cnt==CHANNEL_NUM-1) )
            chan_cnt <= '0;
        else if ( valid_i )
            chan_cnt <= chan_cnt + 1'h1;

            
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        rd_addr <= '0;
    else
        if ( (rd_addr==CHANNEL_NUM-1) && (smpl_cnt==48) )
            rd_addr <= '0;
        else if (chan_cnt==CHANNEL_NUM-1)
            rd_addr <= 1;    
        else if ( (rd_addr==CHANNEL_NUM-1) )
            rd_addr <= 1;
        else if ( rd_addr != 0 )
            rd_addr <= rd_addr + 1;
            
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        smpl_cnt <= '0;
    else
        if ( (smpl_cnt==48) && (rd_addr==CHANNEL_NUM-1) )
            smpl_cnt <= '0;
        else if ( (rd_addr==CHANNEL_NUM-1) )
            smpl_cnt <= smpl_cnt + 1'h1;
            
///////////////////////////////////
RAM
#(
    .DATA_WIDTH     ( DATA_WIDTH        ), 
    .ADDR_WIDTH     ( ADDR_WIDTH        ),
    .RAM_STYLE      ( "M10K"         )//"logic"
)
RAM_inst
(
	.data           ( data_i            ),
	.read_addr      ( rd_addr           ),
    .write_addr     ( chan_cnt          ),
	.we             ( valid_i           ),
    .clk            ( clk               ),
	.q              ( ram_out           )
);  
//
    reg valid_tmp;
    reg sop_tmp;
    reg eop_tmp;
    reg data_tmp;
    reg sof_tmp;
    reg eof_tmp;
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        sop_tmp <= 1'h0;
    else
        if ( rd_addr == 1 )
            sop_tmp <= 1'h1;
        else
            sop_tmp <= 1'h0;
            
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        eop_tmp <= 1'h0;
    else
        if ( rd_addr == 255 )
            eop_tmp <= 1'h1;
        else
            eop_tmp <= 1'h0;

always @( posedge clk or negedge reset_n )
    data_tmp <= ram_out;

always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        sof_tmp <= 1'h0;
    else
        if ( ( rd_addr == 1 ) && ( smpl_cnt == 0 ) )
            sof_tmp <= 1'h1;
        else
            sof_tmp <= 1'h0;
            
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        eof_tmp <= 1'h0;
    else
        if ( ( rd_addr == CHANNEL_NUM-1 ) && ( smpl_cnt == 48 ) )
            eof_tmp <= 1'h1;
        else
            eof_tmp <= 1'h0;
            
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        eof_tmp <= 1'h0;
    else
        if ( ( rd_addr != 0 ) )
            valid_tmp <= 1'h1;
        else
            valid_tmp <= 1'h0;   
            
            
//     
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        data_valid_o <= 1'h0;
    else
        if ( valid_i )
            data_valid_o <= 1'h1;
    /*    else if ( rd_addr != 0 )
            data_valid_o <= 1'h1;*/
        else
            data_valid_o <= 1'h0;
            
always @( posedge clk )
    data_o <= data_i;
    
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        sop_o <= 1'h0;
    else
        sop_o <= sop_i;

always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        sof_o <= 1'h0;
    else
        sof_o <= sof_i;        
        
endmodule
