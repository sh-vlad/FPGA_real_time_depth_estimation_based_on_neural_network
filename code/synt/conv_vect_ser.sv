//Author: ShVlad / e-mail: shvladspb@gmail.com
`timescale 1 ns / 1 ns
module conv_vect_ser
#(
    parameter NUMBER_SPLITTED_CHANNELS  = 1,
    parameter THIS_CHANNEL_NUMBER       = 1,
    parameter DATA_WIDTH                 = 8,
    parameter KERNEL_WIDTH              = 8,
    parameter CHANNEL_NUM               = 3,
    parameter MTRX_NUM                  = 8,
//    parameter HOLD_DATA                 = 8,
    parameter INI_FILE                  = "rom_init.txt",
    parameter STRING_LEN                = 224,
            
    parameter BIAS_NUM                  = 16,
    parameter BIAS_WIDTH                = 24,
    parameter BIAS_INI_FILE             = "rom_init.txt"
)
(
    input wire                                                  clk,
    input wire                                                  reset_n,
    input wire                                                  sop_i,
    input wire                                                  eop_i,
    input wire                                                  sof_i,
    input wire                                                  eof_i, 
    input wire                                                  valid_i,
    input logic  signed     [DATA_WIDTH-1:0]                    data_i,

    output logic signed[KERNEL_WIDTH+DATA_WIDTH+MTRX_NUM-1:0]   data_o,
    output logic                                                data_valid_o,
    output logic                                                sop_o,
    output logic                                                eop_o,
    output logic                                                sof_o,
    output logic                                                eof_o       
);
localparam RAM_STYLE = CHANNEL_NUM < 32 ? "logic" : "M10K";
localparam ADDR_WIDTH = $clog2(CHANNEL_NUM);
localparam MEM_DEPTH = (CHANNEL_NUM*MTRX_NUM);

reg  signed [KERNEL_WIDTH+DATA_WIDTH-1:0]           mult;
reg  signed [KERNEL_WIDTH+DATA_WIDTH+MTRX_NUM-1:0]  accum[CHANNEL_NUM];
reg [$clog2(CHANNEL_NUM*MTRX_NUM)-1:0]              rom_addr;    
reg [$clog2(MTRX_NUM)-1:0]                          mtrx_cnt;
wire  signed [KERNEL_WIDTH-1:0]                     kernel;
reg   signed[KERNEL_WIDTH-1:0]                      sh_kernel;
reg  signed[DATA_WIDTH-1:0]                         sh_data[1:0];
reg [$clog2(CHANNEL_NUM*MTRX_NUM)-1:0]                       sh_rom_addr[4:0];   
//
reg [$clog2(CHANNEL_NUM)-1:0]                       ram_addr;   
reg [$clog2(CHANNEL_NUM)-1:0]                       sh_ram_addr[3:0];  
//
//reg [$clog2(HOLD_DATA):0]                   hold_data_cnt;
reg [1:0]                                           hold_data_start;
reg [2:0]                                           fifo_wr;
wire                                                fifo_empty;
reg                                                 sh_fifo_empty;
wire                                                n_fifo_empty;
wire                                                fifo_rd;
reg     [$clog2(STRING_LEN*CHANNEL_NUM)-1:0]        out_cnt;
reg                                                 work;
reg [3:0]                                           fifo_acc_wr;
reg [2:0]                                           fifo_acc_rd;
reg [2:0]                                           sh_valid_i;
reg  signed[KERNEL_WIDTH+DATA_WIDTH+MTRX_NUM-1:0]   summ;
reg  signed[KERNEL_WIDTH+DATA_WIDTH-1:0]            fifo_out;
logic  signed[KERNEL_WIDTH+DATA_WIDTH-1:0]          fifo_in;

always @( posedge clk )
    sh_valid_i <= {sh_valid_i[1:0],valid_i};

always @( posedge clk )
    begin
        sh_data[0] <= data_i;
        sh_data[1] <= sh_data[0];
        //sh_rom_addr[2:0] <= {sh_rom_addr[1:0],rom_addr};
        sh_rom_addr[0] <= rom_addr;
        sh_rom_addr[1] <= sh_rom_addr[0];
        sh_rom_addr[2] <= sh_rom_addr[1];
        sh_rom_addr[3] <= sh_rom_addr[2];
        sh_rom_addr[4] <= sh_rom_addr[3];
    end

always @( posedge clk )
    fifo_wr <= {fifo_wr[1:0],(mtrx_cnt == MTRX_NUM-1)};
    
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        rom_addr <= '0;
    else
        if ( rom_addr == (CHANNEL_NUM*MTRX_NUM)-1 )
            rom_addr <= '0;
        else if ( valid_i )
            rom_addr <= rom_addr + 1'h1;
//            
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        ram_addr <= '0;
    else
        if ( ram_addr == (CHANNEL_NUM)-1 )
            ram_addr <= '0;
        else if ( sh_valid_i[0] )
            ram_addr <= ram_addr + 1'h1;            

always @( posedge clk )
    sh_ram_addr <= {sh_ram_addr[2:0],ram_addr};
            
//
wire [31:0] mod_test_0;
assign mod_test_0 = sh_rom_addr[1]%(CHANNEL_NUM);

//
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        mtrx_cnt <= '0;
    else
        if ( /*( rom_addr == CHANNEL_NUM-1 ) &&*/ (mtrx_cnt == MTRX_NUM-1) && sh_ram_addr[1]==CHANNEL_NUM-1 )
            mtrx_cnt <= '0;
        else if ( /*valid_i*/sh_valid_i[2] && (sh_ram_addr[1] == CHANNEL_NUM-1) )
            mtrx_cnt <= mtrx_cnt + 1'h1;

always @( posedge clk )
    sh_kernel <= kernel;
    
always @( posedge clk )
    mult <= sh_data[1] * sh_kernel;
//
reg mtrx_cnt_zero_it;
reg sh_mtrx_cnt_zero_it;
reg  signed[KERNEL_WIDTH+DATA_WIDTH+MTRX_NUM-1:0]  accum_it;  
reg  signed[KERNEL_WIDTH+DATA_WIDTH-1:0]           mult_it[1:0];

always @( posedge clk )
    begin
        mtrx_cnt_zero_it <= ( mtrx_cnt == 0 ) ? 1'h0 : 1'h1;
        sh_mtrx_cnt_zero_it <= mtrx_cnt_zero_it;
    end
//always @( posedge clk )
//    accum_it <= accum[sh_rom_addr[1]];
//    
always @( posedge clk )
    {mult_it[1],mult_it[0]} <= {mult_it[0], mult};
//    
//always @( posedge clk or negedge reset_n )
//    if ( !reset_n )
//        for ( int i = 0; i < CHANNEL_NUM; i++)
//            accum[i] <= '0;
//    else
//        if ( !mtrx_cnt_zero_it )
//            accum[sh_rom_addr[2]] <= mult_it[0];
//        else
//            accum[sh_rom_addr[2]] <= accum_it + mult_it[0];
            
// RAM test   
reg   signed[KERNEL_WIDTH+DATA_WIDTH-1:0]           ram_in; 
reg   signed[KERNEL_WIDTH+DATA_WIDTH-1:0]           test_ram_in; 
wire  signed [KERNEL_WIDTH+DATA_WIDTH-1:0]          ram_out; 
reg   signed[KERNEL_WIDTH+DATA_WIDTH-1:0]           sh_ram_out; 

always @( posedge clk )
    sh_ram_out <= ram_out;

always @( posedge clk )
    ram_in <= !mtrx_cnt_zero_it ? mult_it[0]:ram_out + mult_it[0];
    
always @( posedge clk )
    test_ram_in <= !mtrx_cnt_zero_it/*!sh_mtrx_cnt_zero_it*/ ? mult_it[0]:sh_ram_out + mult_it[0];
RAM
#(
    .DATA_WIDTH     ( KERNEL_WIDTH+DATA_WIDTH   ), 
    .ADDR_WIDTH     ( ADDR_WIDTH                ),
    .RAM_STYLE      ( RAM_STYLE                 )//"logic"
)
RAM_inst
(
    .data           ( test_ram_in            ),
    .read_addr      ( sh_ram_addr[0]/*sh_rom_addr[1]*/    ),
    .write_addr     ( sh_ram_addr[3]/*sh_rom_addr[4]*/    ),
    .we             ( 1'h1              ),
    .clk            ( clk               ),
    .q              ( ram_out           )
);           
            
            
////test fifo
//assign fifo_in = fifo_acc_rd[1] ? summ : mult_it[1];
////always @( posedge clk )
////    fifo_in <= fifo_acc_rd[2] ? summ : mult_it[1];
//    
//always @( posedge clk )
//    summ <= fifo_out + mult_it[0];
//
//always @( posedge clk or negedge reset_n )
//    if ( !reset_n )
//        fifo_acc_wr <= '0;
//    else
//        fifo_acc_wr <= {fifo_acc_wr[2:0],sh_valid_i & ( mtrx_cnt < MTRX_NUM-1 )};
//        
//always @( posedge clk or negedge reset_n )
//    if ( !reset_n )
//        fifo_acc_rd <= '0;
//    else
//        fifo_acc_rd <= {fifo_acc_rd[1:0],( mtrx_cnt > 0 )};        
//scfifo
//#(
//    .add_ram_output_register    ( "ON"                         ),
//    .intended_device_family     ( "Cyclone V"                  ),
//    .lpm_widthu                    ( 6                            ),
//    .lpm_numwords               ( 64                           ),
//    .lpm_width                  ( KERNEL_WIDTH+DATA_WIDTH      )
//)
//scfifo_inst
//(
//    .clock          ( clk                ),
//    .data           ( fifo_in            ),
//    .rdreq          ( /*fifo_acc_rd[0]*/( mtrx_cnt > 0 )|fifo_acc_rd[0]     ),
//    .wrreq          ( fifo_acc_wr[2]  ),
//    .empty          (  ),
//    .full           (  ),
//    .q              ( fifo_out       ),
//    .usedw          (  ),
//    .aclr           (  ),
//    .almost_empty   (  ),
//    .almost_full    (  ),
//    .eccstatus      (  ),
//    .sclr           (  )
//); 
//
//always @( posedge clk or negedge reset_n )
//    if ( !reset_n )
//        for ( int i = 0; i < CHANNEL_NUM; i++)
//            accum[i] <= '0;
//    else
//        if ( mtrx_cnt == 0 )
//            accum[sh_rom_addr[1]] <= mult;
//        else
//            accum[sh_rom_addr[1]] <= accum[sh_rom_addr[1]] + mult;

/*
always @( posedge clk )
    hold_data_start <= {hold_data_start[0],eop_i};    
*/    
/*
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        hold_data_cnt <= '0;
    else
        if ( !fifo_rd && hold_data_cnt == HOLD_DATA )
            hold_data_cnt <= 0;  
        else if ( fifo_rd || (hold_data_cnt == HOLD_DATA && !fifo_empty) )
            hold_data_cnt <= 1'h1;            
        else if ( hold_data_cnt != 0 )
            hold_data_cnt <= hold_data_cnt + 1'h1;     
*/       

        
ROM 
#(
   .TYPE                    ( "CVS_KERNEL"              ),
   .NUMBER_SPLITTED_CHANNELS(NUMBER_SPLITTED_CHANNELS   ),
   .THIS_CHANNEL_NUMBER     ( THIS_CHANNEL_NUMBER       ),
   .CHANNEL_NUM             ( CHANNEL_NUM               ),
   .DATA_WIDTH              ( KERNEL_WIDTH              ),
   .MEM_DEPTH               ( MEM_DEPTH                 ),
   .RAM_STYLE               ( "M10K"                    ),
   .INI_FILE                ( INI_FILE                  )
)                       
ROM_init                        
(                       
    .clk                    ( clk                       ), 
    .addr                   ( rom_addr                  ),
    .q                      ( kernel                    )
);
         
/*
always @( posedge clk )
    sh_fifo_empty <= fifo_empty;
    
assign n_fifo_empty = ~fifo_empty & sh_fifo_empty;
assign fifo_rd = n_fifo_empty || (!fifo_empty && hold_data_cnt==HOLD_DATA);    
scfifo
#(
    .add_ram_output_register    ( "ON"                                  ),
    .intended_device_family     ( "Cyclone V"                           ),
    .lpm_widthu                    ( 6                                     ),
    .lpm_numwords               ( 64                                    ),
    .lpm_width                  ( KERNEL_WIDTH+DATA_WIDTH+MTRX_NUM      )
)
scfifo_inst
(
    .clock          ( clk                       ),
    .data           ( accum[sh_rom_addr[2]]     ),
    .rdreq          ( fifo_rd   ),
    .wrreq          ( fifo_wr[2]                ),
    .empty          ( fifo_empty                ),
    .full           (),
    .q              ( data_o                    ),
    .usedw          (),
    .aclr           (),
    .almost_empty   (),
    .almost_full    (),
    .eccstatus      (),
    .sclr           ()
); 
    
always @( posedge clk or negedge reset_n ) 
    if ( !reset_n )
        data_valid_o <= 0;
    else
        data_valid_o <= fifo_rd;
        */

always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        work <= 1'h0;
    else
        if ( eof_i )
            work <= 1'h0;
        else if ( sof_o )
            work <= 1'h1;
 
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        out_cnt <= '0;
    else
        if ( ( out_cnt == /*CHANNEL_NUM**/STRING_LEN ) && ( !fifo_wr[0] && fifo_wr[1] ) )
            out_cnt <= '0;
        else if ( fifo_wr[0] && !fifo_wr[1] )
            out_cnt <= out_cnt + 1'h1;
/* 
always @( posedge clk )
    data_o <= accum[sh_rom_addr[2]];
    
always @( posedge clk or negedge reset_n ) 
    if ( !reset_n )
        data_valid_o <= 0;
    else
        data_valid_o <= fifo_wr[0];

always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        sop_o <= 1'h0;
    else
        if ( ( out_cnt == 0 ) && ( fifo_wr[0] && !fifo_wr[1] ) )
            sop_o <= 1'h1;
        else
            sop_o <= 1'h0;

always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        eop_o <= 1'h0;
    else
        if ( ( out_cnt == STRING_LEN ) && ( fifo_wr[0] && !(mtrx_cnt == MTRX_NUM-1 ) ) )
            eop_o <= 1'h1;
        else
            eop_o <= 1'h0;
*/

//
//reg [KERNEL_WIDTH+DATA_WIDTH+MTRX_NUM-1:0]  data_o_test;
//always @( posedge clk )
//    data_o_test <= ram_in;

reg [1:0]data_valid_it;
reg [1:0]sop_it;
reg [1:0]eop_it;

reg [$clog2(BIAS_NUM)-1:0]  bias_addr;

always_ff @( posedge clk or negedge reset_n )
    if ( !reset_n )
        bias_addr <= '0;
    else
        if ( bias_addr == BIAS_NUM-1)
            bias_addr <= 0;
        else if (/*data_valid_it[0]*/fifo_wr[0])
            bias_addr <= bias_addr + 1'h1;

wire signed [BIAS_WIDTH-1:0] bias;            
ROM 
#(
   .TYPE                    ( "CVS_BIAS"                ),
   .NUMBER_SPLITTED_CHANNELS(NUMBER_SPLITTED_CHANNELS   ),
   .THIS_CHANNEL_NUMBER     ( THIS_CHANNEL_NUMBER       ),
   .DATA_WIDTH              ( BIAS_WIDTH      ),
   .MEM_DEPTH               ( BIAS_NUM        ),
   .RAM_STYLE               ( "M10K"          ),
   .INI_FILE                ( BIAS_INI_FILE   )
)
ROM_bias_init
(
    .clk                    ( clk             ), 
    .addr                   ( bias_addr       ),
    .q                      ( bias                )
);

logic signed[KERNEL_WIDTH+DATA_WIDTH+MTRX_NUM-1:0]   data_pipe;
/*
always @( posedge clk )
    data_o <= test_ram_in + bias;
//    data_o <= accum[sh_rom_addr[3]];
*/  
always @( posedge clk )
    begin
        data_pipe <= test_ram_in + bias;
        data_o <= data_pipe;
    end
always @( posedge clk or negedge reset_n ) 
    if ( !reset_n )
        data_valid_it[0] <= 0;
    else
        data_valid_it[0] <= fifo_wr[0];

always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        sop_it[0] <= 1'h0;
    else
        if ( ( out_cnt == 0 ) && ( fifo_wr[0] && !fifo_wr[1] ) )
            sop_it[0] <= 1'h1;
        else
            sop_it[0] <= 1'h0;

always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        eop_it[0] <= 1'h0;
    else
        if ( ( out_cnt == STRING_LEN ) && ( fifo_wr[0] && !(mtrx_cnt == MTRX_NUM-1 ) ) )
            eop_it[0] <= 1'h1;
        else
            eop_it[0] <= 1'h0;

always @( posedge clk )
    begin
        data_valid_it[1]   <= data_valid_it[0];
        sop_it[1]          <= sop_it[0];
        eop_it[1]          <= eop_it[0];
    end   

always @( posedge clk )
    begin
        data_valid_o <= data_valid_it[1];
        sop_o        <= sop_it[1];
        eop_o        <= eop_it[1];
    end
      /*      
assign sof_o = sop_o & !work;
assign eof_o = eop_o & !work;
      */  
always @( posedge clk )
    begin
        sof_o <= sop_o & !work;
        eof_o <= eop_o & !work;
    end        
    
    /*
    initial
        @(posedge reset_n )
            $display("aaaaaaaaaaaaaaaaaaaaaaaaaaaa",INI_FILE);
    */
endmodule


