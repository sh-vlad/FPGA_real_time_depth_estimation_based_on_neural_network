//Author: ShVlad / e-mail: shvladspb@gmail.com
`timescale 1 ns / 1 ns
module max_pool
#(
    parameter DATA_WIDTH 		= 8,
    parameter CHANNEL_NUM       = 3,
    parameter HOLD_DATA         = 8,
    parameter STRING_LEN        = 4
)
(
    input wire                          clk,
    input wire                          reset_n,
    input wire                          sop_i,
    input wire                          eop_i,
    input wire						    sof_i,
    input wire						    eof_i,      
	input wire                          valid_i,
    input logic     [DATA_WIDTH-1:0]    data_i,

    output logic    [DATA_WIDTH-1:0]    data_o,
    output logic                        data_valid_o,
    output logic                        sop_o,
    output logic                        eop_o,
    output logic					    sof_o,
    output logic					    eof_o      
);
localparam RAM_STYLE = CHANNEL_NUM < 32 ? "logic" : "M10K";
localparam ADDR_WIDTH = $clog2(CHANNEL_NUM);
localparam FIFO_DEPTH = CHANNEL_NUM*STRING_LEN;
localparam LPM_WIDTHU = $clog2(FIFO_DEPTH);

localparam FIFOE_DEPTH = (CHANNEL_NUM*STRING_LEN)/4;
localparam LPME_WIDTHU = $clog2(FIFOE_DEPTH);

reg [DATA_WIDTH-1:0]                    sh_data_i;
reg [$clog2(CHANNEL_NUM):0]             chan_cnt;
reg [$clog2(CHANNEL_NUM):0]             sh_chan_cnt[4];
reg                                     row_mark;    
reg                                     line_mark; 
reg                                     sh_row_mark;    
reg                                     sh_line_mark; 
//reg [DATA_WIDTH-1:0]                    max[CHANNEL_NUM];
reg                                     fifo_wr;
reg                                     fifo_rd;
reg [DATA_WIDTH-1:0]                    fifo_out;
reg [$clog2(HOLD_DATA):0]               hold_data_cnt;

reg                                     fifoe_wr;
wire                                    fifoe_empty;
reg                                     sh_fifoe_empty;
wire                                    n_fifoe_empty;
wire                                    fifoe_rd;

reg [31:0]                              smpl_cnt;
reg [3:0]                               sh_valid;
wire                                    n_valid;
reg                                     valid_o_imp;
reg                                     work;
reg [$clog2(STRING_LEN):0]              cnt_out;

always @( posedge clk )
    sh_valid <= {sh_valid[2:0],valid_i};
    
assign n_valid = !valid_i & sh_valid[0];

always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        smpl_cnt <= '0;
    else
        if ( smpl_cnt == STRING_LEN/*-1*/ )
            smpl_cnt <= '0;
        else if ( n_valid )
            smpl_cnt <= smpl_cnt + 1;

always @( posedge clk )
    sh_data_i <= data_i;

always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        chan_cnt <= '0;    
    else
        if ( chan_cnt == CHANNEL_NUM-1 )
            chan_cnt <= '0;
        else if ( valid_i )
            chan_cnt <= chan_cnt + 1'h1;

always @( posedge clk )
    {sh_chan_cnt[3],sh_chan_cnt[2],sh_chan_cnt[1],sh_chan_cnt[0]} <= {sh_chan_cnt[2],sh_chan_cnt[1],sh_chan_cnt[0],chan_cnt};
            
always @( posedge clk or negedge reset_n )   
    if ( !reset_n )
        row_mark <= 0;
    else
        if ( chan_cnt == CHANNEL_NUM-1 )
            row_mark <= ~row_mark;
            
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        line_mark <= 0;
    else
        if ( /*eop_i*/smpl_cnt == STRING_LEN/*-1*/ )
            line_mark <= ~line_mark;

always @( posedge clk )
    begin
        sh_row_mark     <= row_mark ;    
        sh_line_mark    <= line_mark;
    end
//
reg [1:0]               row_line_mark_it;
reg                     max_sh_data_it;
reg                     fifo_sh_data_it;
reg [1:0]               fifo_rd_it;
reg [1:0]               fifo_wr_it;
reg [DATA_WIDTH-1:0]    sh_data_i_it;
reg [DATA_WIDTH-1:0]    fifo_out_it;
reg [DATA_WIDTH-1:0]    max_it; 
reg [DATA_WIDTH-1:0]    ram_out; 
reg [1:0]data_valid_it;
reg [1:0]sop_it;
reg [1:0]eop_it; 

always @( posedge clk )
    if ( !sh_row_mark && !sh_line_mark && sh_valid[0] )
        row_line_mark_it <= 3'd1;
    else if ( !sh_row_mark && sh_line_mark && sh_valid[0] )
        row_line_mark_it <= 3'd2;
    else if ( sh_row_mark && sh_valid[0] )
        row_line_mark_it <= 3'd3;

always @( posedge clk )
    fifo_sh_data_it <= (fifo_out>sh_data_i) ? 1'h1 : 1'h0 ;          
        
//always @( posedge clk )
//    max_sh_data_it <= (max[sh_chan_cnt[0]]>sh_data_i) ? 1'h1 : 1'h0 ;  

always @( posedge clk )
    sh_data_i_it <= sh_data_i;
    
always @( posedge clk )
    fifo_out_it <= fifo_out;   


    
//always @( posedge clk )    
//        case ( row_line_mark_it ) 
//            1:          max_it  <= sh_data_i_it;
//            2:          max_it  <= fifo_sh_data_it ? fifo_out_it : sh_data_i_it; 
//            3:          max_it  <= max_sh_data_it ? max[sh_chan_cnt[1]] : sh_data_i_it;
//            default:    max_it <= '0;
//        endcase

//always @( posedge clk )  
//    if ( sh_valid[2] )
//        max[sh_chan_cnt[2]] <= max_it;
    
always @( posedge clk )
    begin
        fifo_rd_it <= {fifo_rd_it[0],fifo_rd};
        fifo_wr_it <= {fifo_wr_it[0],fifo_wr};
    end
 
//RAM test
reg max_sh_data_it_ram;
reg fifo_sh_data_it_ram;
reg [2:0][DATA_WIDTH-1:0]    max_it_ram; 
reg [2:0][DATA_WIDTH-1:0]    sh_ram_out;
//reg                     max_sh_data_it_ram;

always @( posedge clk )
    max_sh_data_it_ram <= (ram_out>sh_data_i) ? 1'h1 : 1'h0 ;  
  
always @( posedge clk )
    sh_ram_out[2:0] <= {sh_ram_out[1:0],ram_out};

    
always @( posedge clk )  
    begin
        case ( row_line_mark_it ) 
            1:          max_it_ram[0]  <= sh_data_i_it;
            2:          max_it_ram[0]  <= fifo_sh_data_it ? fifo_out_it : sh_data_i_it; 
            3:          max_it_ram[0]  <= max_sh_data_it_ram ? sh_ram_out[0] : sh_data_i_it;
            default:    max_it_ram[0] <= '0;
        endcase   
        max_it_ram[1] <= max_it_ram[0];
        max_it_ram[2] <= max_it_ram[1];       
    end

  
    
RAM
#(
    .DATA_WIDTH     ( DATA_WIDTH        ), 
    .ADDR_WIDTH     ( ADDR_WIDTH        ),
    .RAM_STYLE      ( RAM_STYLE         )//"logic"
)
RAM_inst
(
	.data           ( /*max_it*/max_it_ram[0]            ),
	.read_addr      ( /*sh_chan_cnt[0] */ chan_cnt  ),
    .write_addr     ( sh_chan_cnt[2]    ),
	.we             ( sh_valid[2]       ),
    .clk            ( clk               ),
	.q              ( ram_out           )
);        

/*       
always @( posedge clk )
    if ( !sh_row_mark && !sh_line_mark && sh_valid[0] )
        max[sh_chan_cnt[0]]  <= sh_data_i;
    else if ( !sh_row_mark && sh_line_mark && sh_valid[0] )
        max[sh_chan_cnt[0]]  <= (fifo_out>sh_data_i) ? fifo_out : sh_data_i;        
    else if ( sh_row_mark && sh_valid[0]  )
        max[sh_chan_cnt[0]]  <= (max[sh_chan_cnt[0]]>sh_data_i) ? max[sh_chan_cnt[0]] : sh_data_i;
*/
        
always @( posedge clk )
    fifo_wr <= ~sh_line_mark & sh_row_mark & sh_valid[0];

assign fifo_rd = line_mark & !row_mark & valid_i;
    
scfifo
#(
    .add_ram_output_register    ( "ON"          ),
    .intended_device_family     ( "Cyclone V"   ),
	.lpm_widthu					( LPM_WIDTHU  	),
    .lpm_numwords               ( FIFO_DEPTH    ),
    .lpm_width                  ( DATA_WIDTH    )
)
scfifo_inst
(
    .clock          ( clk                       ),
    .data           ( max_it_ram[1]/*max[sh_chan_cnt[3]]*/          ),
    .rdreq          ( fifo_rd/*fifo_rd_it[1] */                  ),
    .wrreq          ( fifo_wr_it[1]/*fifo_rd_it[1]*/                   ),
    .empty          (                           ),
    .full           (),
    .q              ( fifo_out                  ),
    .usedw          (),
    .aclr           (),
    .almost_empty   (),
    .almost_full    (),
    .eccstatus      (),
    .sclr           ()
); 
///////////

//always @( posedge clk )
//    fifoe_wr <= sh_line_mark & sh_row_mark & sh_valid[0];
//
//always @( posedge clk or negedge reset_n )
//    if ( !reset_n )
//        hold_data_cnt <= '0;
//    else
//        if ( !fifoe_rd && hold_data_cnt == HOLD_DATA )
//            hold_data_cnt <= 0;  
//        else if ( fifoe_rd || (hold_data_cnt == HOLD_DATA && !fifoe_empty) )
//            hold_data_cnt <= 1'h1;            
//        else if ( hold_data_cnt != 0 )
//            hold_data_cnt <= hold_data_cnt + 1'h1;    
//
//always @( posedge clk )
//    sh_fifoe_empty <= fifoe_empty;
//    
//assign n_fifoe_empty = ~fifoe_empty & sh_fifoe_empty;
//assign fifoe_rd = n_fifoe_empty || (!fifoe_empty && hold_data_cnt==HOLD_DATA);    
//scfifo
//#(
//    .add_ram_output_register    ( "ON"                ),
//    .intended_device_family     ( "Cyclone V"         ),
//	.lpm_widthu					( LPME_WIDTHU         ),
//    .lpm_numwords               ( FIFOE_DEPTH         ),
//    .lpm_width                  ( DATA_WIDTH          )
//)
//scfifo_evenly
//(
//    .clock          ( clk                       ),
//    .data           ( max[sh_chan_cnt[1]]        ),
//    .rdreq          ( fifoe_rd   ),
//    .wrreq          ( fifoe_wr                ),
//    .empty          ( fifoe_empty                ),
//    .full           (),
//    .q              ( data_o                    ),
//    .usedw          (),
//    .aclr           (),
//    .almost_empty   (),
//    .almost_full    (),
//    .eccstatus      (),
//    .sclr           ()
//); 
//    
//always @( posedge clk or negedge reset_n ) 
//    if ( !reset_n )
//        data_valid_o <= 0;
//    else
//        data_valid_o <= fifoe_rd;


///////////////new

always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        cnt_out <= '0;
    else
        if ( cnt_out == STRING_LEN/2 && ( !valid_o_imp && data_valid_it[0]/*data_valid_o*/ ) )
            cnt_out <= '0;
        else if ( valid_o_imp && !data_valid_it[0]/*data_valid_o*/ )
            cnt_out <= cnt_out + 1'h1;
            

always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        work <= 1'h0;
    else
        if ( eof_i )
            work <= 1'h0;
        else if ( sof_o )
            work <= 1'h1;

always @( posedge clk ) 
    valid_o_imp <= sh_line_mark & sh_row_mark & sh_valid[0];   
    
/*     
always @( posedge clk or negedge reset_n )
    data_valid_o <= valid_o_imp;
   
always @( posedge clk )
    data_o <= max[sh_chan_cnt[1]];

always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        sop_o <= 1'h0;
    else
        sop_o <= valid_o_imp & ( cnt_out == 0 );

always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        eop_o <= 1'h0;
    else
        eop_o <= ( cnt_out == STRING_LEN/2 && ( !(sh_line_mark & sh_row_mark & sh_valid[0]) && valid_o_imp ) );
*/


reg [DATA_WIDTH-1:0] data_o_test;
/*
always @( posedge clk )
    if ( data_valid_o )
        if ( data_o_test != data_o )
            begin
                $display("data_o_test - %h, data_o - %h, time - %t",data_o_test,data_o,$time);
                #10;
                $stop;
            end
*/
/*
always @( posedge clk )
   data_o_test <= max_it_ram[1];
*/
always @( posedge clk or negedge reset_n )
    data_valid_it[0] <= valid_o_imp;

always @( posedge clk )
    data_o <= max_it_ram[1];
    //data_o <= max[sh_chan_cnt[3]];

always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        sop_it[0] <= 1'h0;
    else
        sop_it[0] <= valid_o_imp & ( cnt_out == 0 );

always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        eop_it[0] <= 1'h0;
    else
        eop_it[0] <= ( cnt_out == STRING_LEN/2 && ( !(sh_line_mark & sh_row_mark & sh_valid[0]) && valid_o_imp ) );

always @( posedge clk )
    begin
        data_valid_it[1]   <= data_valid_it[0];
        sop_it[1]          <= sop_it[0];
        eop_it[1]          <= eop_it[0];
       
        data_valid_o  <= data_valid_it[1];
        sop_o         <= sop_it[1];
        eop_o         <= eop_it[1];
    end

assign sof_o = sop_o & !work;
assign eof_o = eop_o & !work;
/*
int test;
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        test <= 0;
    else
        if (data_valid_o)
            test <= test + 1;
*/
endmodule

//    output logic                      sop_o,
//    output logic                      eop_o,
//    output logic					    sof_o,
//    output logic					    eof_o  