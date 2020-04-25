//Author: Vlad Sharshin 
//e-mail: shvladspb@gmail.com
module concat_channels
#(
    parameter DATA_WIDTH        = 8,
    parameter NUMBER_CHANNELS   = 2
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

    output logic signed [DATA_WIDTH-1:0]        data_o,
    output logic                                data_valid_o,
	output logic					            sop_o,
    output logic					            eop_o,
    output logic					            sof_o,
    output logic					            eof_o/*,

    input wire [5:0]                            ddr_fifo_rd,
    output reg [5:0]                            ddr_fifo_afull       */
);

logic [4:0]                         cnt;
logic [DATA_WIDTH-1:0]              sh_data_l;
logic                               sh_data_valid;
logic [DATA_WIDTH-1:0]              fifo_out;      
logic                               fifo_out_valid;

logic signed [DATA_WIDTH-1:0]       data;
logic                               data_valid;
logic					            sop;
logic					            eop;
logic					            sof;
logic					            eof;

always_ff @( posedge clk )
    sh_data_l     <= data_li;

always_ff @( posedge clk or negedge reset_n )  
    if ( !reset_n )
        sh_data_valid <= 1'h0;
    else
        sh_data_valid <= data_valid_i;
    

always_ff @( posedge clk or negedge reset_n )
    if ( !reset_n )
        cnt <= '0;
    else 
        if ( cnt != 0 )
            cnt <= cnt + 1'h1;
        else if ( data_valid_i && !sh_data_valid )
            cnt <= 1;
            
    
scfifo
#(
    .add_ram_output_register    ( "ON"          ),
    .intended_device_family     ( "Cyclone V"   ),
	.lpm_widthu					( 4	),
    .lpm_numwords               ( 16    ),
    .lpm_width                  ( DATA_WIDTH    )
)
scfifo_inst
(
    .clock          ( clk                       ),
    .data           ( data_ri                   ),
    .rdreq          ( ( cnt > 15 )              ),
    .wrreq          ( data_valid_i              ),
	.empty          (                           ),
	.full           (                           ),
    .q              ( fifo_out                  ),
	.usedw          (                           ),
	.aclr           (                           ),
	.almost_empty   (                           ),
	.almost_full    (                           ),
	.eccstatus      (                           ),
	.sclr           ( !reset_n                  )
); 

//assign data_valid_o = sh_data_valid;    
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        fifo_out_valid <= 1'h0;
    else
        fifo_out_valid <=  (cnt > 15);

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
assign data = fifo_out_valid ? fifo_out : sh_data_l;

max_pool 
#(
    .DATA_WIDTH 	  ( /*MAX_POOL_DATA_WIDTH */8        ),
    .CHANNEL_NUM      ( /*MAX_POOL_CHANNEL_NUM*/32        ),
    .HOLD_DATA        ( /*MAX_POOL_HOLD_DATA  */32        ),
    .STRING_LEN       ( /*MAX_POOL_STRING_LEN */224        )
)
max_pool_inst
(
    .clk              ( clk                         ),  
    .reset_n          ( reset_n                     ),
    .data_i           ( data                        ),    
    .valid_i          ( data_valid                  ),   
    .sop_i            ( sop                         ),
    .eop_i            ( eop                         ),
    .sof_i            ( sof                         ),  
    .eof_i            ( eof                         ),
    .data_o           ( data_o                      ),
    .data_valid_o     ( data_valid_o                ),
    .sop_o            ( sop_o                       ),
    .eop_o            ( eop_o                       ),
    .sof_o            ( sof_o                       ),  
    .eof_o            ( eof_o                       )
);

endmodule