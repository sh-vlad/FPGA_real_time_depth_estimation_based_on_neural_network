//Author: Vlad Sharshin 
//e-mail: shvladspb@gmail.com
module concat_FSM
(
	input wire                                  clk, 
    input wire                                  reset_n,
    
    input wire [5:0]                            req_wr,
    input wire [5:0]                            req_rd,

    output wire[5:0]                            res_rd,
    output wire[5:0]                            res_wr,
    
    input wire                                  conv_eof,
    input wire                                  deconv_eof,
//avalon
	output logic         avl_beginbursttransfer, // mm_interconnect_0:if0_avl_0_beginbursttransfer -> if0:avl_burstbegin_0
//	logic  [63:0] avl_readdata,           // if0:avl_rdata_0 -> mm_interconnect_0:if0_avl_0_readdata
	input logic         avl_waitrequest,        // if0:avl_ready_0 -> mm_interconnect_0:if0_avl_0_waitrequest
	output logic  [26:0] avl_address,            // mm_interconnect_0:if0_avl_0_addr_wress -> if0:avl_addr_wr_0
	logic         avl_read,               // mm_interconnect_0:if0_avl_0_read -> if0:avl_read_req_0
//	logic   [7:0] avl_byteenable,         // mm_interconnect_0:if0_avl_0_byteenable -> if0:avl_be_0
//	logic         avl_readdatavalid,      // if0:avl_rdata_valid_0 -> mm_interconnect_0:if0_avl_0_readdatavalid
	output logic         avl_write,              // mm_interconnect_0:if0_avl_0_write -> if0:avl_write_req_0
//	logic  [63:0] avl_writedata,          // mm_interconnect_0:if0_avl_0_writedata -> if0:avl_wdata_0
	output logic   [7:0] avl_burstcount       // mm_interconnect_0:if0_avl_0_burstcount -> if0:avl_size_0
    
);
// 
reg [4:0]   stop;
reg [7:0]   smpl_cnt;         
reg [2:0]   layer_cnt;   
reg         all_reg_wr;
reg         all_reg_rd;
reg         work_done;
reg [26:0]  addr_wr[5:0];
reg [26:0]  addr_rd[5:0];

always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        layer_cnt <= '0;
    else
        if ( layer_cnt == 5 )
            layer_cnt <= '0;
        else if ( work_done )
            layer_cnt <= layer_cnt + 1;

        
enum reg [3:0] 
{
    idle    = 4'd0,
    wr_wait = 4'd1,
    rd_wait = 4'd2,
    wr_0    = 4'd3,
    wr_1    = 4'd4,
    wr_2    = 4'd5,
    wr_3    = 4'd6,
    wr_4    = 4'd7,
    wr_5    = 4'd8,
    
    rd_0    = 4'd9,
    rd_1    = 4'd10,
    rd_2    = 4'd11,
    rd_3    = 4'd12,
    rd_4    = 4'd13,
    rd_5    = 4'd14
}cs,ns,sh_cs;

always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        cs <= idle;
    else
        cs <= ns;
        
always_comb
    begin
        ns = cs;
        case( cs )
            idle:                                   ns = wr_wait;
            wr_wait:    begin
                            if ( all_reg_wr ) 
                                    case ( layer_cnt )
                                        3'd0:   begin
                                                    casez ( req_wr )
                                                        6'b?????1: ns = wr_0;
                                                        6'b????1?: ns = wr_1;
                                                        6'b???1??: ns = wr_2;
                                                        6'b??1???: ns = wr_3;
                                                        6'b?1????: ns = wr_4;
                                                        6'b1?????: ns = wr_5;
                                                        default:ns = rd_wait; 
                                                    endcase
                                                end
                                                        
                                        3'd1:   begin
                                                    casez ( req_wr )
                                                        6'b????1?: ns = wr_1;
                                                        6'b???1??: ns = wr_2;
                                                        6'b??1???: ns = wr_3;
                                                        6'b?1????: ns = wr_4; 
                                                        6'b1?????: ns = wr_5;      
                                                        6'b?????1: ns = wr_0;
                                                        default:ns = rd_wait; 
                                                    endcase
                                                end
                                        3'd2:   begin
                                                    casez ( req_wr )
                                                        6'b???1??: ns = wr_2;
                                                        6'b??1???: ns = wr_3;
                                                        6'b?1????: ns = wr_4; 
                                                        6'b1?????: ns = wr_5;       
                                                        6'b?????1: ns = wr_0;
                                                        6'b????1?: ns = wr_1;                                                        
                                                        default:ns = rd_wait; 
                                                    endcase
                                                end
                                        3'd3:   begin
                                                    casez ( req_wr )
                                                        6'b??1???: ns = wr_3;
                                                        6'b?1????: ns = wr_4;
                                                        6'b1?????: ns = wr_5;                                                       
                                                        6'b?????1: ns = wr_0;
                                                        6'b????1?: ns = wr_1; 
                                                        6'b???1??: ns = wr_2;                                                        
                                                        default:ns = rd_wait; 
                                                    endcase
                                                end
                                        3'd4:   begin
                                                    casez ( req_wr )
                                                        6'b?1????: ns = wr_4; 
                                                        6'b1?????: ns = wr_5;                                                       
                                                        6'b?????1: ns = wr_0;
                                                        6'b????1?: ns = wr_1; 
                                                        6'b???1??: ns = wr_2;  
                                                        6'b??1???: ns = wr_3;                                                        
                                                        default:ns = rd_wait; 
                                                    endcase
                                                end
                                        3'd5:   begin
                                                    casez ( req_wr )
                                                        6'b1?????: ns = wr_5;                                                       
                                                        6'b?????1: ns = wr_0;
                                                        6'b????1?: ns = wr_1; 
                                                        6'b???1??: ns = wr_2;  
                                                        6'b??1???: ns = wr_3; 
                                                        6'b?1????: ns = wr_4;                                                         
                                                        default:ns = rd_wait; 
                                                    endcase
                                                end 
                                        default:        ns = rd_wait;    
                                    endcase
                            else                        ns = rd_wait;
                        end
            rd_wait:    begin
                            if ( all_reg_rd ) 
                                    case ( layer_cnt )
                                        3'd0:   begin
                                                    casez ( req_rd )
                                                        6'b?????1: ns = rd_0;
                                                        6'b????1?: ns = rd_1;
                                                        6'b???1??: ns = rd_2;
                                                        6'b??1???: ns = rd_3;
                                                        6'b?1????: ns = rd_4;
                                                        6'b1?????: ns = rd_5;
                                                        default:ns = rd_wait; 
                                                    endcase
                                                end
                                                        
                                        3'd1:   begin
                                                    casez ( req_rd )
                                                        6'b????1?: ns = rd_1;
                                                        6'b???1??: ns = rd_2;
                                                        6'b??1???: ns = rd_3;
                                                        6'b?1????: ns = rd_4; 
                                                        6'b1?????: ns = rd_5;
                                                        6'b?????1: ns = rd_0;
                                                        default:ns = rd_wait; 
                                                    endcase
                                                end
                                        3'd2:   begin
                                                    casez ( req_rd )
                                                        6'b???1??: ns = rd_2;
                                                        6'b??1???: ns = rd_3;
                                                        6'b?1????: ns = rd_4;  
                                                        6'b1?????: ns = rd_5;
                                                        6'b?????1: ns = rd_0;
                                                        6'b????1?: ns = rd_1;                                                        
                                                        default:ns = rd_wait; 
                                                    endcase
                                                end
                                        3'd3:   begin
                                                    casez ( req_rd )
                                                        6'b??1???: ns = rd_3;
                                                        6'b?1????: ns = rd_4; 
                                                        6'b1?????: ns = rd_5;
                                                        6'b?????1: ns = rd_0;
                                                        6'b????1?: ns = rd_1; 
                                                        6'b???1??: ns = rd_2;                                                        
                                                        default:ns = rd_wait; 
                                                    endcase
                                                end
                                        3'd4:   begin
                                                    casez ( req_rd )
                                                        6'b?1????: ns = rd_4; 
                                                        6'b1?????: ns = rd_5;
                                                        6'b?????1: ns = rd_0;
                                                        6'b????1?: ns = rd_1; 
                                                        6'b???1??: ns = rd_2;  
                                                        6'b??1???: ns = rd_3;                                                        
                                                        default:ns = wr_wait; 
                                                    endcase
                                                end
                                        3'd5:   begin
                                                    casez ( req_rd )
                                                        6'b1?????: ns = rd_5;                                              
                                                        6'b?????1: ns = rd_0;
                                                        6'b????1?: ns = rd_1; 
                                                        6'b???1??: ns = rd_2;  
                                                        6'b??1???: ns = rd_3;   
                                                        6'b?1????: ns = rd_4;                                                         
                                                        default:ns = wr_wait; 
                                                    endcase
                                                end                                               
                                        default:        ns = wr_wait;    
                                    endcase
                            else                        ns = wr_wait;
                        end   
            wr_0:       if ( work_done )            ns = rd_wait;
            wr_1:       if ( work_done )            ns = rd_wait;
            wr_2:       if ( work_done )            ns = rd_wait;
            wr_3:       if ( work_done )            ns = rd_wait;
            wr_4:       if ( work_done )            ns = rd_wait;
            wr_5:       if ( work_done )            ns = rd_wait;
            
            rd_0:       if ( work_done )            ns = wr_wait;
            rd_1:       if ( work_done )            ns = wr_wait;
            rd_2:       if ( work_done )            ns = wr_wait;
            rd_3:       if ( work_done )            ns = wr_wait;
            rd_4:       if ( work_done )            ns = wr_wait;    
            rd_5:       if ( work_done )            ns = wr_wait;               
            default:                                ns = idle;
        endcase
    end

always @( posedge clk )
    sh_cs <= cs;
    
always @( posedge clk )
    all_reg_wr <= |req_wr;
    
always @( posedge clk )
    all_reg_rd <= |req_rd;   

    
    
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        smpl_cnt <= '0;
    else     
        if ( !avl_waitrequest )
            smpl_cnt <= smpl_cnt;
        else if ( ( cs == wr_0 || cs == rd_0 ) && smpl_cnt == 16*112/8 )
            smpl_cnt <= 0;
        else if ( ( cs == wr_1 || cs == rd_1 ) && smpl_cnt == 16*56/8 )
            smpl_cnt <= 0;   
        else if ( ( cs == wr_2 || cs == rd_2 ) && smpl_cnt == 32*28/8 )
            smpl_cnt <= 0;        
        else if ( ( cs == wr_3 || cs == rd_3 ) && smpl_cnt == 64*14/8 )
            smpl_cnt <= 0;  
        else if ( ( cs == wr_4 || cs == rd_4 ) && smpl_cnt == 128*7/8 )
            smpl_cnt <= 0;      
        else if ( ( cs == wr_5 || cs == rd_5 ) && smpl_cnt == 256*1/8 )
            smpl_cnt <= 0;              
        else if ( smpl_cnt != 0 )
            smpl_cnt <= smpl_cnt + 1'h1;
        else if ( cs != wr_wait && cs != rd_wait && cs != idle )
            smpl_cnt <= 1;

always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        work_done <= 0;
    else        
        if ( ( cs == wr_0 || cs == rd_0 ) && smpl_cnt == 16*112/8-1 )
            work_done <= 1;
        else if ( ( cs == wr_1 || cs == rd_1 ) && smpl_cnt == 16*56/8-1 )
            work_done <= 1;   
        else if ( ( cs == wr_2 || cs == rd_2 ) && smpl_cnt == 32*28/8-1 )
            work_done <= 1;        
        else if ( ( cs == wr_3 || cs == rd_3 ) && smpl_cnt == 64*14/8-1 )
            work_done <= 1;  
        else if ( ( cs == wr_4 || cs == rd_4 ) && smpl_cnt == 128*7/8-1 )
            work_done <= 1;   
        else if ( ( cs == wr_5 || cs == rd_5 ) && smpl_cnt == 256*1/8-1 )
            work_done <= 1;                 
        else 
            work_done <= 1'h0;

assign res_rd[0] = ( cs == wr_0 ) && ( smpl_cnt != 0 ) && avl_waitrequest ? 1'h1 : 1'h0;
assign res_rd[1] = ( cs == wr_1 ) && ( smpl_cnt != 0 ) && avl_waitrequest ? 1'h1 : 1'h0;
assign res_rd[2] = ( cs == wr_2 ) && ( smpl_cnt != 0 ) && avl_waitrequest ? 1'h1 : 1'h0;
assign res_rd[3] = ( cs == wr_3 ) && ( smpl_cnt != 0 ) && avl_waitrequest ? 1'h1 : 1'h0;
assign res_rd[4] = ( cs == wr_4 ) && ( smpl_cnt != 0 ) && avl_waitrequest ? 1'h1 : 1'h0; 
assign res_rd[5] = ( cs == wr_5 ) && ( smpl_cnt != 0 ) && avl_waitrequest ? 1'h1 : 1'h0; 

assign res_wr[0] = ( cs == rd_0 ) && ( smpl_cnt != 0 ) && avl_waitrequest ? 1'h1 : 1'h0;
assign res_wr[1] = ( cs == rd_1 ) && ( smpl_cnt != 0 ) && avl_waitrequest ? 1'h1 : 1'h0;
assign res_wr[2] = ( cs == rd_2 ) && ( smpl_cnt != 0 ) && avl_waitrequest ? 1'h1 : 1'h0;
assign res_wr[3] = ( cs == rd_3 ) && ( smpl_cnt != 0 ) && avl_waitrequest ? 1'h1 : 1'h0;
assign res_wr[4] = ( cs == rd_4 ) && ( smpl_cnt != 0 ) && avl_waitrequest ? 1'h1 : 1'h0; 
assign res_wr[5] = ( cs == rd_5 ) && ( smpl_cnt != 0 ) && avl_waitrequest ? 1'h1 : 1'h0; 

always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        avl_beginbursttransfer <= 1'h0;
    else
        if ( smpl_cnt == 1 || smpl_cnt == 129 )
            avl_beginbursttransfer <= 1'h1;
        else
            avl_beginbursttransfer <= 1'h0;
            
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        avl_burstcount <= '0;
    else 
        if ( smpl_cnt == 1 )
            begin
                if ( cs == wr_0 || cs == rd_0 )
                    avl_burstcount <= 128;   
                else if ( cs > wr_0 )
                    avl_burstcount <= 112;
            end
        else if ( smpl_cnt == 129 )
            avl_burstcount <= 96;    
        else if ( smpl_cnt > 1 && avl_waitrequest && cs < rd_0 )
            avl_burstcount <= avl_burstcount - 1;
            
//   
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        begin
            addr_wr[0] <= '0;
            addr_wr[1] <= 25088;
            addr_wr[2] <= 31360;
            addr_wr[3] <= 34496;
            addr_wr[4] <= 36064;
            addr_wr[5] <= 36750;
        end    
    else
        if ( avl_burstcount == 1 )
            case ( sh_cs )
                wr_0:       addr_wr[0] <= avl_address+1'd1;
                wr_1:       addr_wr[1] <= avl_address+1'd1;
                wr_2:       addr_wr[2] <= avl_address+1'd1;
                wr_3:       addr_wr[3] <= avl_address+1'd1;
                wr_4:       addr_wr[4] <= avl_address+1'd1;
                wr_5:       addr_wr[5] <= avl_address+1'd1;
                default:    for ( int i = 0; i < 6; i ++ )
                                addr_wr[i] <= addr_wr[i]; 
            endcase 
            
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        begin
            addr_rd[0] <= '0;
            addr_rd[1] <= 25088;
            addr_rd[2] <= 31360;
            addr_rd[3] <= 34496;
            addr_rd[4] <= 36064;
            addr_rd[5] <= 36750;  
        end  
    else
        if ( avl_burstcount == 1 )
            case ( sh_cs )
                rd_0:       addr_rd[0] <= avl_address+1'd1;
                rd_1:       addr_rd[1] <= avl_address+1'd1;
                rd_2:       addr_rd[2] <= avl_address+1'd1;
                rd_3:       addr_rd[3] <= avl_address+1'd1;
                rd_4:       addr_rd[4] <= avl_address+1'd1;
                rd_5:       addr_rd[5] <= avl_address+1'd1;
                default:    for ( int i = 0; i < 6; i ++ )
                                addr_rd[i] <= addr_rd[i]; 
            endcase             
         
always @( posedge clk or negedge reset_n )
    if ( !reset_n )    
        avl_address <= '0;
    else
        if ( smpl_cnt == 1 )
            case ( cs )
                wr_0:       avl_address <= addr_wr[0];
                wr_1:       avl_address <= addr_wr[1];
                wr_2:       avl_address <= addr_wr[2];
                wr_3:       avl_address <= addr_wr[3];
                wr_4:       avl_address <= addr_wr[4];
                wr_5:       avl_address <= addr_wr[5];
                
                rd_0:       avl_address <= addr_rd[0];
                rd_1:       avl_address <= addr_rd[1];
                rd_2:       avl_address <= addr_rd[2];
                rd_3:       avl_address <= addr_rd[3];
                rd_4:       avl_address <= addr_rd[4];
                rd_5:       avl_address <= addr_rd[5];
                
                default:    avl_address <= avl_address;
            endcase        
        else if ( smpl_cnt >= 1 && avl_waitrequest /*&& cs < rd_0*/ )
            avl_address <= avl_address + 1'h1;
            
//
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        avl_write <= 1'h0;
    else
        if ( smpl_cnt >= 1  && cs >= wr_0 && cs < rd_0 )
            avl_write <= 1'h1;
        else
            avl_write <= 1'h0;


always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        avl_read <= 1'h0;
    else
        if ( (smpl_cnt == 1 || smpl_cnt == 129 )/*&& avl_waitrequest*/ && cs >= rd_0 )
            avl_read <= 1'h1;
        else
            avl_read <= 1'h0;        
            
endmodule

