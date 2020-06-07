//Author: Vlad Sharshin 
//e-mail: shvladspb@gmail.com
module concat_channels
#(
    parameter DATA_WIDTH                    = 8,
    parameter NUMBER_CONCAT_CHANNELS        = 2,
    parameter CHANNEL_NUM                   = 8
)
(
    input wire                                  clk, 
    input wire                                  reset_n,
    input wire                                  data_valid_i,      
//    input wire signed [DATA_WIDTH-1:0]          data_li,   
//    input wire signed [DATA_WIDTH-1:0]          data_ri,  
    input wire signed [DATA_WIDTH-1:0]          data_i[0:NUMBER_CONCAT_CHANNELS-1],   
    input wire                                    sop_i,
    input wire                                    eop_i,
    input wire                                    sof_i,
    input wire                                    eof_i,   

    output logic signed [DATA_WIDTH-1:0]        data_o,
    output logic                                data_valid_o,
    output logic                                sop_o,
    output logic                                eop_o,
    output logic                                sof_o,
    output logic                                eof_o/*,

    input wire [5:0]                            ddr_fifo_rd,
    output reg [5:0]                            ddr_fifo_afull       */
);

logic [$clog2(CHANNEL_NUM)-1:0]             cnt_number;
logic [$clog2(CHANNEL_NUM)-1:0]             sh_cnt_number[1:0];
logic [$clog2(NUMBER_CONCAT_CHANNELS)-1:0]  cnt_concat_number;
logic [$clog2(NUMBER_CONCAT_CHANNELS)-1:0]  sh_cnt_concat_number[1:0];
logic [DATA_WIDTH-1:0]                      sh_data_l;
logic                                       sh_data_valid;
logic [DATA_WIDTH-1:0]                      fifo_out[NUMBER_CONCAT_CHANNELS-1];      
logic                                       fifo_out_valid;
logic                                       eop_flag;
        
logic signed [DATA_WIDTH-1:0]               data;
logic                                       data_valid;
logic                                        sop;
logic                                        eop;
logic                                        sof;
logic                                        eof;

always_ff @( posedge clk )
    sh_data_l     <= data_i[0];

always_ff @( posedge clk or negedge reset_n )  
    if ( !reset_n )
        sh_data_valid <= 1'h0;
    else
        sh_data_valid <= data_valid_i;
    

always_ff @( posedge clk or negedge reset_n )
    if ( !reset_n )
        cnt_number <= '0;
    else
        if ( (cnt_number == CHANNEL_NUM-1) && (cnt_concat_number == NUMBER_CONCAT_CHANNELS-1) )
            cnt_number <= '0;   
        else if ( (data_valid_i && !sh_data_valid) )
            cnt_number <= 1;            
        else if ( cnt_number != 0 )
            cnt_number <= cnt_number + 1'h1;
        else if ( |cnt_concat_number )
            cnt_number <= 1;  

always_ff @( posedge clk or negedge reset_n )
    if ( !reset_n )
        for ( int i=0; i<2; i++ )
            sh_cnt_number[i] <= '0;
    else
        sh_cnt_number <= '{sh_cnt_number[0],cnt_number};
            

always_ff @( posedge clk or negedge reset_n )
    if ( !reset_n )
        cnt_concat_number <= '0;
    else
        if ( (cnt_concat_number == NUMBER_CONCAT_CHANNELS-1) && (cnt_number == CHANNEL_NUM-1) )
            cnt_concat_number <= '0;
        else if ( cnt_number == CHANNEL_NUM-1 )
            cnt_concat_number <= cnt_concat_number + 1'h1;
        
always_ff @( posedge clk or negedge reset_n )
    if ( !reset_n )
        for ( int i=0; i<2; i++ )
            sh_cnt_concat_number[i] <= '0;
    else
        sh_cnt_concat_number <= '{sh_cnt_concat_number[0],cnt_concat_number};

genvar i_gen;        
generate   
    for (/*genvar*/ i_gen=1; i_gen < NUMBER_CONCAT_CHANNELS; i_gen++)
        begin: fifo_gen
            scfifo
            #(
                .add_ram_output_register    ( "ON"              ),
                .intended_device_family     ( "Cyclone V"       ),
                .lpm_widthu                    ( $clog2(CHANNEL_NUM)),
                .lpm_numwords               ( CHANNEL_NUM       ),
                .lpm_width                  ( DATA_WIDTH        )
            )
            scfifo_inst
            (
                .clock          ( clk                       ),
                .data           ( data_i[i_gen]                 ),
                .rdreq          ( /*( cnt_number > 15 )*/cnt_concat_number==i_gen              ),
                .wrreq          ( data_valid_i                  ),
                .empty          (                               ),
                .full           (                               ),
                .q              ( fifo_out[i_gen-1]                   ),
                .usedw          (                               ),
                .aclr           (                               ),
                .almost_empty   (                               ),
                .almost_full    (                               ),
                .eccstatus      (                               ),
                .sclr           ( !reset_n                      )
            ); 
        end        
//    assign data = fifo_out_valid ? fifo_out : sh_data_l;
endgenerate

//assign data_valid_o = sh_data_valid;    
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        fifo_out_valid <= 1'h0;
    else
        fifo_out_valid <=  (cnt_concat_number > 0);
/*
delay_rg
#(
    .W          ( 2     ),         
    .D          ( 17     )
)         
delay_rg_eopf     
(
    .clk        ( clk               ),        
    .data_in    ( { eof_i, eop_i }  ), 
    .data_out   ( { eof, eop }  )
);
*/
always_ff @( posedge clk or negedge reset_n )
    if ( !reset_n )
        eop <= '0;
    else
        if ( (cnt_concat_number == NUMBER_CONCAT_CHANNELS-1) && (cnt_number == CHANNEL_NUM-1) )
            eop <= 1;
        else 
            eop <= '0;

assign eof = eop_flag ? eop : 1'h0;

always_ff @( posedge clk or negedge reset_n )
    if ( !reset_n )
        eop_flag <= 1'h0;
    else
        if ( eof_i )
            eop_flag <= 1'h1;
        else if ( eof_o )
            eop_flag <= 1'h0;
            


delay_rg
#(
    .W          ( 2     ),         
    .D          ( 1     )
)         
delay_rg_sopf     
(
    .clk        ( clk              ),        
    .data_in    ( { sof_i, sop_i } ), 
    .data_out   ( { sof, sop }  )
);        
assign data_valid = fifo_out_valid | sh_data_valid;       
//assign data = fifo_out_valid ? fifo_out : sh_data_l;
always_comb
    begin
        for ( int i=0; i<NUMBER_CONCAT_CHANNELS-1; i++)
            if ( sh_cnt_concat_number[0] == 0 )
                data = sh_data_l;                
            else if ( sh_cnt_concat_number[0] == i+1)
                data = fifo_out[i];
    end
    
always_comb
    begin
        data_o        =  data;  
        data_valid_o  =  data_valid;
        sop_o         =  sop;
        eop_o         =  eop;
        sof_o         =  sof;
        eof_o         =  eof;
    end
    
//max_pool 
//#(
//    .DATA_WIDTH       ( /*MAX_POOL_DATA_WIDTH */8        ),
//    .CHANNEL_NUM      ( /*MAX_POOL_CHANNEL_NUM*/32        ),
//    .HOLD_DATA        ( /*MAX_POOL_HOLD_DATA  */32        ),
//    .STRING_LEN       ( /*MAX_POOL_STRING_LEN */224        )
//)
//max_pool_inst
//(
//    .clk              ( clk                         ),  
//    .reset_n          ( reset_n                     ),
//    .data_i           ( data                        ),    
//    .valid_i          ( data_valid                  ),   
//    .sop_i            ( sop                         ),
//    .eop_i            ( eop                         ),
//    .sof_i            ( sof                         ),  
//    .eof_i            ( eof                         ),
//    .data_o           ( data_o                      ),
//    .data_valid_o     ( data_valid_o                ),
//    .sop_o            ( sop_o                       ),
//    .eop_o            ( eop_o                       ),
//    .sof_o            ( sof_o                       ),  
//    .eof_o            ( eof_o                       )
//);

endmodule