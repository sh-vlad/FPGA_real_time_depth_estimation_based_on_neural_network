//Author: ShVlad / e-mail: shvladspb@gmail.com
`timescale 1 ns / 1 ns
module ReLu
#(
    parameter DATA_WIDTH        = 8,
    parameter MAX_DATA          = 255,
    parameter DATA_O_WIDTH      = 8
)
(
    input wire                                  clk,
    input wire                                  reset_n,
    input wire signed       [DATA_WIDTH-1:0]    data_i,  
	input wire                                  valid_i,    
    input wire                                  sop_i,
    input wire                                  eop_i,
    input wire						            sof_i,
    input wire						            eof_i, 
    
    output logic            [DATA_O_WIDTH-1:0]  data_o,
    output logic                                data_valid_o,
    output logic                                sop_o,
    output logic                                eop_o,
    output logic					            sof_o,
    output logic					            eof_o     
);


always @( posedge clk )
    if ( data_i > MAX_DATA )
        data_o <= {(DATA_O_WIDTH){1'h1}};//MAX_DATA;
    else if ( data_i < 0 )
        data_o <= 0;
    else
        data_o <= data_i;
        
always @( posedge clk or negedge reset_n )
    if ( !reset_n )
        begin
            data_valid_o <= 0;
            sop_o        <= 0;
            eop_o        <= 0;
        end
    else
            begin
                data_valid_o <= valid_i;
                sop_o        <= sop_i;
                eop_o        <= eop_i;
                sof_o        <= sof_i;
                eof_o        <= eof_i;
            end
        
endmodule
