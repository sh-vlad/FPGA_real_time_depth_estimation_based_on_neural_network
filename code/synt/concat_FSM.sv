//Author: Vlad Sharshin 
//e-mail: shvladspb@gmail.com
module concat_FSM
(
	input wire                                  clk, 
    input wire                                  reset_n,
    
    input wire [4:0]                            req_wr,
    input wire [4:0]                            req_rd,

    output wire[4:0]                            res_rd    
);
// 
reg [4:0]   stop;
reg [7:0]   smpl_cnt;         
reg [2:0]   layer_cnt;   
reg         all_reg_wr;
reg         all_reg_rd;
reg        work_done;
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
    
    rd_0    = 4'd8,
    rd_1    = 4'd9,
    rd_2    = 4'd10,
    rd_3    = 4'd11,
    rd_4    = 4'd12
}cs,ns;

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
                                                        5'b????1: ns = wr_0;
                                                        5'b???1?: ns = wr_1;
                                                        5'b??1??: ns = wr_2;
                                                        5'b?1???: ns = wr_3;
                                                        5'b1????: ns = wr_4;
                                                        default:ns = rd_wait; 
                                                    endcase
                                                end
                                                        
                                        3'd1:   begin
                                                    casez ( req_wr )
                                                        5'b???1?: ns = wr_1;
                                                        5'b??1??: ns = wr_2;
                                                        5'b?1???: ns = wr_3;
                                                        5'b1????: ns = wr_4;                                                    
                                                        5'b????1: ns = wr_0;
                                                        default:ns = rd_wait; 
                                                    endcase
                                                end
                                        3'd2:   begin
                                                    casez ( req_wr )
                                                        5'b??1??: ns = wr_2;
                                                        5'b?1???: ns = wr_3;
                                                        5'b1????: ns = wr_4;                                                    
                                                        5'b????1: ns = wr_0;
                                                        5'b???1?: ns = wr_1;                                                        
                                                        default:ns = rd_wait; 
                                                    endcase
                                                end
                                        3'd3:   begin
                                                    casez ( req_wr )
                                                        5'b?1???: ns = wr_3;
                                                        5'b1????: ns = wr_4;                                                    
                                                        5'b????1: ns = wr_0;
                                                        5'b???1?: ns = wr_1; 
                                                        5'b??1??: ns = wr_2;                                                        
                                                        default:ns = rd_wait; 
                                                    endcase
                                                end
                                        3'd4:   begin
                                                    casez ( req_wr )
                                                        5'b1????: ns = wr_4;                                                    
                                                        5'b????1: ns = wr_0;
                                                        5'b???1?: ns = wr_1; 
                                                        5'b??1??: ns = wr_2;  
                                                        5'b?1???: ns = wr_3;                                                        
                                                        default:ns = rd_wait; 
                                                    endcase
                                                end
                                        default:        ns = rd_wait;    
                                    endcase
                            else                        ns = rd_wait;
                        end
            rd_wait:    begin
                            if ( req_rd ) 
                                case ( layer_cnt )
                                    3'd0:           ns = rd_0;
                                    3'd1:           ns = rd_1;
                                    3'd2:           ns = rd_2;
                                    3'd3:           ns = rd_3;
                                    3'd4:           ns = rd_4;
                                    default:        ns = wr_wait;    
                                endcase
                            else                    ns = wr_wait;
                        end    
            wr_0:       if ( work_done )            ns = rd_wait;
            wr_1:       if ( work_done )            ns = rd_wait;
            wr_2:       if ( work_done )            ns = rd_wait;
            wr_3:       if ( work_done )            ns = rd_wait;
            wr_4:       if ( work_done )            ns = rd_wait;
            
            rd_0:       if ( work_done )            ns = wr_wait;
            rd_1:       if ( work_done )            ns = wr_wait;
            rd_2:       if ( work_done )            ns = wr_wait;
            rd_3:       if ( work_done )            ns = wr_wait;
            rd_4:       if ( work_done )            ns = wr_wait;            
            default:                                ns = idle;
        endcase
    end
    
always @( posedge clk )
    all_reg_wr <= |req_wr;
    
always @( posedge clk )
    all_reg_rd <= |req_rd;   

    
    
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        smpl_cnt <= '0;
    else        
        if ( ( cs == wr_0 || cs == rd_0 ) && smpl_cnt == 16*112/8 )
            smpl_cnt <= 0;
        else if ( ( cs == wr_1 || cs == rd_1 ) && smpl_cnt == 16*56/8 )
            smpl_cnt <= 0;   
        else if ( ( cs == wr_2 || cs == rd_2 ) && smpl_cnt == 32*28/8 )
            smpl_cnt <= 0;        
        else if ( ( cs == wr_3 || cs == rd_3 ) && smpl_cnt == 64*14/8 )
            smpl_cnt <= 0;  
        else if ( ( cs == wr_4 || cs == rd_4 ) && smpl_cnt == 128*7/8 )
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
        else 
            work_done <= 1'h0;

assign res_rd[0] = ( cs == wr_0 ) && ( smpl_cnt != 0 ) ? 1'h1 : 1'h0;
assign res_rd[1] = ( cs == wr_1 ) && ( smpl_cnt != 0 ) ? 1'h1 : 1'h0;
assign res_rd[2] = ( cs == wr_2 ) && ( smpl_cnt != 0 ) ? 1'h1 : 1'h0;
assign res_rd[3] = ( cs == wr_3 ) && ( smpl_cnt != 0 ) ? 1'h1 : 1'h0;
assign res_rd[4] = ( cs == wr_3 ) && ( smpl_cnt != 0 ) ? 1'h1 : 1'h0;            
endmodule

