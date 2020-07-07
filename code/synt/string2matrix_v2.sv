//Author: Vlad Sharshin 
//e-mail: shvladspb@gmail.com
module string2matrix_v2
#(
    parameter DATA_WIDTH    = 8,
    parameter STRING_LEN    = 640,
    parameter MATRIX_SIZE   = 3,
    parameter CHANNEL_NUM   = 3,
    parameter HOLD_DATA     = 16
)
(
	input wire                              clk, 
    input wire                              reset_n,
    input wire                              data_valid_i,
	input wire signed [DATA_WIDTH-1:0]      data_i,
	input wire						        sop_i,
    input wire						        eop_i,
    input wire						        sof_i,
    input wire						        eof_i,
    
    output logic                            data_valid_o,   
    output logic signed[DATA_WIDTH-1:0]     data_o[MATRIX_SIZE**2],
	output logic					        sop_o,
    output logic					        eop_o,
    output logic					        sof_o,
    output logic					        eof_o 
    
);
    localparam RAM_STYLE = CHANNEL_NUM < 32 ? "logic" : "M10K";
    localparam ADDR_WIDTH = $clog2(CHANNEL_NUM);
    localparam FIFO_DEPTH = 2**($clog2(STRING_LEN*CHANNEL_NUM*4));
    localparam LPM_WIDTHU = ($clog2(FIFO_DEPTH));
	localparam CNT_FIFO   = $clog2(MATRIX_SIZE)+1;
	localparam HOLD_DATA_CNT_WIDTHU = $clog2(HOLD_DATA+1);
    
    reg     [$clog2(CHANNEL_NUM)-1:0]               chan_cnt;
    reg     [$clog2(CHANNEL_NUM)-1:0]               sh_chan_cnt[2]; 
    wire    [ 2: 0]                                 fifo_empty;
    reg     [ 2: 0]                                 fifo_rd;
    reg     [ 2: 0]                                 fifo_wr;    
    reg     [HOLD_DATA_CNT_WIDTHU-1: 0]             hold_cnt;

    logic  signed   [DATA_WIDTH-1:0]                fifo_in[2:0];   //fifo input 
    logic  signed   [1:0][DATA_WIDTH-1:0]           fifo_in_pipe_0; //pipe regs on fifo input   
    logic  signed   [1:0][DATA_WIDTH-1:0]           fifo_in_pipe_1; //pipe regs on fifo input        
    wire   signed   [DATA_WIDTH-1:0]                fifo_out[2:0];  //fifo out
    logic  signed   [DATA_WIDTH-1:0]                sh_reg_in[2:0]; // connected to fifo output ->  
    logic  signed   [DATA_WIDTH-1:0]                sh_reg[MATRIX_SIZE**2-1:0];//shift regs to create output matrix 3x3    
    logic                                           fifo_ready; // there are enough data in fifo to be read 
    logic   [ 3: 0]                                 sh_rd_flag;
    logic                                           rd_flag; 
    wire    [LPM_WIDTHU-1:0]                        fifo_usedw[2:0];
    reg                                             sh_valid;
    
    reg                                             global_valid;
    reg     [5:0]                                   hold_cnt2wire;
    reg                                             eof;                                    
    reg[$clog2((CHANNEL_NUM*STRING_LEN+CHANNEL_NUM*2))-1:0]    out_cnt;
    reg                                             sop_imp;
    reg     [ 5: 0]                                 eop_imp; 
    wire    [ 2: 0]                                 fifo_full;    
    
	reg		[$clog2(CHANNEL_NUM):0]				    padding_cnt;
	reg		[$clog2(CHANNEL_NUM):0]					start;
	reg												padding_wr;
    reg                                             second_padding;
    logic   [$clog2(STRING_LEN)-1:0]                eop_cnt;
    logic                                           padding_flag;  
    
    enum reg [3:0] 
    {
        s_idle      = 4'd1,
        s_first_0   = 4'd2,
        s_first_1   = 4'd3,
        s_first_2   = 4'd4,
        s_work      = 4'd5,
        s_last_2    = 4'd6, 
        s_last_1    = 4'd7,
        s_last_0    = 4'd8
    }cs,ns, sh_cs[7:0];      


// due to necessary to fill firsts matrix index 0, there is padding below
    always_ff @( posedge clk or negedge reset_n )
        if ( !reset_n )
            padding_flag <= 0;
        else
            padding_flag <= ( (sh_cs[4]==s_idle) && (sh_cs[5]==s_last_0) ) ? 1 : 0;  
            
	always@ (posedge clk or negedge reset_n )
		if ( !reset_n )
			start <= '0;
		else
            if ( eop_i || (second_padding && padding_cnt == CHANNEL_NUM)|| padding_flag)
                start <= '0;
			else if ( start < CHANNEL_NUM+2 )
				start <= start + 1'h1;
			
		
	always @( posedge clk or negedge reset_n )
		if ( !reset_n )
			padding_cnt <= '0;
		else
            if ( padding_cnt == CHANNEL_NUM )
                padding_cnt <= '0;
            else if ( start == CHANNEL_NUM+1 )
                padding_cnt <= 1;
            else if ( padding_cnt != 0 )
                padding_cnt <= padding_cnt + 1;

    always @( posedge clk or negedge reset_n )
		if ( !reset_n )
            padding_wr <= 1'h0;
        else
            if ( padding_cnt != 0 )
                padding_wr <= 1'h1;
            else    
                padding_wr <= 1'h0;

    always @( posedge clk or negedge reset_n )
        if (! reset_n )
            second_padding  <= 1'h0;
        else
            if ( eop_i )
                second_padding <= 1'h1;
            else if ( second_padding && padding_cnt == CHANNEL_NUM )
                second_padding  <= 1'h0;	
              

//
    always @( posedge clk )
        hold_cnt2wire <= {hold_cnt2wire[4:0],(hold_cnt!=0)};
//
    always @( posedge clk )
        sh_rd_flag <= {sh_rd_flag[2:0],rd_flag};

    always @( posedge clk )
        sh_valid <= data_valid_i;
//
	always @( posedge clk )
		begin
            fifo_in_pipe_0 <= {fifo_in_pipe_0[0],data_i};
	//		{fifo_in_pipe_0[1],fifo_in_pipe_0[0]} <= {fifo_in_pipe_0[0],data_i};    
    /*        if ( padding_wr )
                fifo_in_pipe_0[0] <= '0;
            else 
                fifo_in_pipe_0[0] <= data_i;
                fifo_in_pipe_0[1] <= fifo_in_pipe_0[0];*/ 
		end    
       
    always_comb    
		begin
            fifo_in_pipe_1[0] = fifo_out[0];
            fifo_in_pipe_1[1] = fifo_out[1];
        end        

	assign fifo_in[2] = fifo_in_pipe_1[1];
	assign fifo_in[1] = fifo_in_pipe_1[0];
	assign fifo_in[0] = padding_wr ? '0 : fifo_in_pipe_0[1];
    
    

    always @( posedge clk or negedge reset_n )
        if ( !reset_n )
            chan_cnt <= '0;
        else
            if ( (sh_rd_flag[0] && chan_cnt == CHANNEL_NUM - 1) || sh_cs[7] == s_idle  )
                chan_cnt <= '0;            
            else if ( sh_rd_flag[0] )
                chan_cnt <= chan_cnt + 1'h1;
                
    always @( posedge clk )
        {sh_chan_cnt[1],sh_chan_cnt[0]} <= { sh_chan_cnt[0] ,chan_cnt };                
//        
    always @( posedge clk )
        if ( eof_i )
            eof <= 1'h1;
        else if ( ( sh_rd_flag[0] && chan_cnt == CHANNEL_NUM - 1 ) )
            eof <= 1'h0;
//
    always @( posedge clk )
        sop_imp <= ( hold_cnt == 4 ) ? 1'h1 : 1'h0;
        
    always @( posedge clk )
        begin
            eop_imp <= { eop_imp[4:0], ( hold_cnt == HOLD_DATA ) };
        end

// main FSM    
    always @( posedge clk or negedge reset_n )
        if ( !reset_n )
            cs <= s_idle;
        else
            cs <= ns;
            
    always_comb
        begin
            ns = cs;
            case ( cs )
                s_idle:         if ( sop_i )        ns = s_first_0;
                s_first_0:      if ( sop_i )        ns = s_first_1;
                s_first_1:      if ( sop_i )        ns = s_first_2;
                s_first_2:      if ( sop_i )        ns = s_work;
                s_work:         if ( ( sh_rd_flag[0] && chan_cnt == CHANNEL_NUM - 1 )&&eof )                 ns = s_last_2;
                s_last_2:       if ( fifo_empty[0]  )        ns = s_last_1;
                s_last_1:       if ( fifo_empty[1]  )        ns = s_last_0;
                s_last_0:       if ( fifo_empty[2]  )        ns = s_idle;
                default:                                     ns = s_idle;
            endcase
        end

// FSM stage shifting to improve timing    
    always @( posedge clk )
        begin
            sh_cs[0] <= cs;
            for ( int i = 0; i < 6; i++)
                sh_cs[i+1] <= sh_cs[i];
        end
        //sh_cs[7:0] <= { sh_cs[6:0],cs};
        
// inserting data hold time for next module    
    always @( posedge clk or negedge reset_n )
        if ( !reset_n )
            hold_cnt <= '0;
        else
            if ( ( hold_cnt == HOLD_DATA ) && !fifo_ready )
                hold_cnt <= '0;
            else if ( hold_cnt == HOLD_DATA )
                hold_cnt <= 1;                
            else if ( hold_cnt != 0 )
                hold_cnt <= hold_cnt + 1'h1;
            else if ( fifo_ready )    
                hold_cnt <= 1;  
//
always_comb
    case ( cs )
        s_last_2:fifo_ready = fifo_usedw[0] > 0;
        s_last_1:fifo_ready = fifo_usedw[1] > 0;
        s_last_0:fifo_ready = fifo_usedw[2] > 0;
        default: fifo_ready = fifo_usedw[0] > STRING_LEN*CHANNEL_NUM+CHANNEL_NUM*3;
    endcase
assign rd_flag = (hold_cnt == 2);
    always @( posedge clk )
        case ( cs )
            s_idle:     begin
                            fifo_wr     <= '0;
                            fifo_rd     <= '0;
                        end
            s_first_0:  begin
                            fifo_wr     <= {1'h0,1'h0,sh_valid};
                            fifo_rd     <= '0;
                        end
            s_first_1:  begin 
                            fifo_wr     <= {1'h0,fifo_rd[0],sh_valid};
                            fifo_rd     <= {1'h0,1'h0,rd_flag};        
                        end
            s_first_2:  begin 
                            fifo_wr     <= {fifo_rd[1],fifo_rd[0],sh_valid};                            
                            fifo_rd     <= {1'h0,rd_flag,rd_flag};                            
                        end
            s_work:     begin
                            fifo_wr     <= {fifo_rd[1],fifo_rd[0],sh_valid};                            
                            fifo_rd     <= {rd_flag,rd_flag,rd_flag}; 
                        end 
            s_last_2:   begin
                            fifo_wr     <= {fifo_rd[1],fifo_rd[0],1'h0};                            
                            fifo_rd     <= {rd_flag,rd_flag,rd_flag}; 
                        end
            s_last_1:   begin
                            fifo_wr     <= {fifo_rd[1],1'h0,1'h0};                            
                            fifo_rd     <= {rd_flag,rd_flag,1'h0}; 
                        end   
            s_last_0:   begin
                            fifo_wr     <= {1'h0,1'h0,1'h0};                            
                            fifo_rd     <= {rd_flag,1'h0,1'h0}; 
                        end                         
            default:    begin
                            fifo_wr     <= '0;
                            fifo_rd     <= '0;
                        end
        endcase

wire [ 2: 0] fifo_wr_;   

assign fifo_wr_[0] = fifo_wr[0]|padding_wr;
assign fifo_wr_[1] = fifo_wr[1];
assign fifo_wr_[2] = fifo_wr[2];

    genvar j;        
    generate
        begin
            for ( j = 0; j < MATRIX_SIZE; j++ )
                begin: FIFO_CHAIN
                    scfifo
                    #(
                        .add_ram_output_register    ( "ON"          ),
                        .intended_device_family     ( "Cyclone V"   ),
						.lpm_widthu					( LPM_WIDTHU	),
                        .lpm_numwords               ( FIFO_DEPTH    ),
                        .lpm_width                  ( DATA_WIDTH    )
                    )
                    scfifo_inst
                    (
                        .clock          ( clk                       ),
                        .data           ( fifo_in[j]                ),
                        .rdreq          ( fifo_rd[j]                ),
                        .wrreq          ( fifo_wr_[j]               ),
                		.empty          ( fifo_empty[j]             ),
                		.full           ( fifo_full[j]              ),
                        .q              ( fifo_out[j]               ),
                		.usedw          ( fifo_usedw[j]             ),
                		.aclr           (                           ),
                		.almost_empty   (                           ),
                		.almost_full    (                           ),
                		.eccstatus      (                           ),
                		.sclr           ( !reset_n                  )
                    ); 
                end
        end      
    endgenerate
//
    always_comb
        case ( cs )
            s_idle:     sh_reg_in = '{'0,'0,'0};
            s_first_0:  sh_reg_in = '{'0,'0,'0};
            s_first_1:  sh_reg_in = '{'0,'0,fifo_out[0]};
            s_first_2:  sh_reg_in = '{'0,fifo_out[1],fifo_out[0]};
            s_last_1:   sh_reg_in = '{fifo_out[2],fifo_out[1],'0};
            s_last_0:   sh_reg_in = '{fifo_out[2],'0,'0};

            default:    sh_reg_in = '{fifo_out[2],fifo_out[1],fifo_out[0]};
        endcase
//
    
    always @( posedge clk or negedge reset_n )
        if ( !reset_n )
            global_valid <= 1'h0;
        else
            //if ( ( sh_cs[6] == s_first_2 ) || ( sh_cs[6] == s_work ) || ( sh_cs[6] == s_last_2 ) || ( sh_cs[6] == s_last_1 ) )
            if ( ( sh_cs[6] == s_first_2 ) || ( sh_cs[6] == s_work ) || ( sh_cs[6] == s_last_2 ) || ( sh_cs[6] == s_last_1 ) )
                global_valid <= 1'h1;
            else if ( hold_cnt == 5 )
                global_valid <= 1'h0;
    

//  RAM test
  
wire  signed   [DATA_WIDTH-1:0]  mem_out[MATRIX_SIZE**2-1:0];   

always @ ( posedge clk )
    if ( sh_rd_flag[1] )
        begin
            sh_reg[2:0] <= sh_reg_in;
            sh_reg[5:3] <= mem_out[2:0];
            sh_reg[8:6] <= mem_out[5:3];
        end
         
genvar gen; 
generate 
    for ( gen = 0; gen < 9; gen++)
        begin: gen_ram
            RAM
            #(
                .DATA_WIDTH     ( DATA_WIDTH   ), 
                .ADDR_WIDTH     ( ADDR_WIDTH   ),
                .RAM_STYLE      ( RAM_STYLE    )//"logic"
            )
            RAM_inst
            (
                .data           ( sh_reg[gen]  ),
                .read_addr      ( chan_cnt          ),
                .write_addr     ( sh_chan_cnt[1]    ),
                .we             ( sh_rd_flag[2]     ),
                .clk            ( clk               ),
                .q              ( mem_out[gen]      )
            ); 
        end
endgenerate    
//
        
reg valid_by_cnt;

    always @( posedge clk or negedge reset_n )
        if ( !reset_n )
            valid_by_cnt <= 1'h0;
        else
            if ( eop_imp[3] && out_cnt == 0 )
                valid_by_cnt <= 1'h0;         
            else if ( out_cnt > (CHANNEL_NUM*2) )
                valid_by_cnt <= 1'h1;
        
    always @( posedge clk or negedge reset_n )
        if ( !reset_n )
            out_cnt <= '0;
        else
            if ( sof_i )
                out_cnt <= '0;
            else if ( ( out_cnt == (CHANNEL_NUM*STRING_LEN+CHANNEL_NUM*2)-1 ) && hold_cnt == 4 )
                out_cnt <= '0;
            else if ( hold_cnt == 4/*hold_cnt2wire[2]*/ /*& global_valid*/ )
                out_cnt <= out_cnt + 1'h1;
        
        
    always @( posedge clk )
        if ( sh_rd_flag[2] )
            begin  
                //    data_o <= sh_reg[sh_chan_cnt[1]];
                //data_o <= sh_reg;
                data_o[0] <= sh_reg[8];
                data_o[1] <= sh_reg[5];
                data_o[2] <= sh_reg[2];
                data_o[3] <= sh_reg[7];
                data_o[4] <= sh_reg[4];
                data_o[5] <= sh_reg[1];
                data_o[6] <= sh_reg[6];
                data_o[7] <= sh_reg[3];
                data_o[8] <= sh_reg[0];
            end 
        
    assign data_valid_o = hold_cnt2wire[4] & global_valid & valid_by_cnt;   
    
    always @( posedge clk or negedge reset_n )
        if ( !reset_n )
            sop_o <= 1'h0;
        else
            if ( ( sh_cs[6] >= s_first_2 && sh_cs[6] < s_last_0 ) && sop_imp )
                sop_o <= out_cnt == CHANNEL_NUM*2+1 ;
            else    
                sop_o <= 1'h0;
  
    always @( posedge clk or negedge reset_n )
        if ( !reset_n )
            sof_o <= 1'h0;
        else
            if ( sh_cs[6] == s_first_2 && sop_imp )
                sof_o <= out_cnt == CHANNEL_NUM*2+1;
            else
                sof_o <= 1'h0;
    
    always_ff @( posedge clk or negedge reset_n )
        if ( !reset_n )
            eop_cnt <= '0;
        else
            if ( eop_imp[3] && (out_cnt == 0) && ( eop_cnt == STRING_LEN+1 ) )
                eop_cnt <= '0;
            else if ( eop_imp[3] && (out_cnt == 0) )
                eop_cnt <= eop_cnt + 1;                                                                            
 //
                
// 
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        eof_o <= 1'h0;
    else
        //if ( sh_cs[6] == s_last_0 && eop_imp[2] )
        if ( (eop_cnt == STRING_LEN)&&(out_cnt == 0) && eop_imp[2] )
            eof_o <= 1;
        else
            eof_o <= 1'h0;
            
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        eop_o <= 1'h0;
    else
        if ( (eop_cnt > 0 )&&(eop_cnt <= STRING_LEN)&&(out_cnt == 0) && eop_imp[2] )
            eop_o <= 1;
        else    
            eop_o <= 1'h0;
//
`ifdef SYNT
`else
int cnt_wr=0;
int cnt_rd=0;
    always @(posedge clk)   
        begin
            assert ( !fifo_full[0] ) else begin $error("%m FIFO 0 FULL!!!, STRING_LEN - %d",STRING_LEN); $stop; end; 
            assert ( !fifo_full[1] ) else begin $error("%m FIFO 1 FULL!!!, STRING_LEN - %d",STRING_LEN); $stop; end; 
            assert ( !fifo_full[2] ) else begin $error("%m FIFO 2 FULL!!!, STRING_LEN - %d",STRING_LEN); $stop; end; 
        end
    
always @(posedge fifo_wr_ )
    cnt_wr = cnt_wr + 1;  
    
always @(posedge fifo_rd )
    cnt_rd = cnt_rd + 1;      
    
`endif            

endmodule

