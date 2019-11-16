//Author: ShVlad / e-mail: shvladspb@gmail.com
`timescale 1 ns / 1 ns
module conv2_3x3
#(
    parameter DATA_WIDTH = 8,
    parameter KERNEL_WIDTH = 8,
    parameter MULT_WIDTH = DATA_WIDTH + KERNEL_WIDTH,
    parameter DATAO_WIDTH = MULT_WIDTH + 8
)
(
    input wire                                  clk,
    input logic  signed     [DATA_WIDTH-1:0]    data_i[9],
//    input logic     [KERNEL_WIDTH*9-1:0]  kernel_,	
    input logic   signed    [KERNEL_WIDTH-1:0]  kernel[9],
    output logic  signed    [DATAO_WIDTH-1:0]   data_o
);

    
    
	reg signed[MULT_WIDTH-1:0]    mult[9];
    reg signed[MULT_WIDTH:0]      add_st0[5];
    reg signed[MULT_WIDTH+1:0]    add_st1[3];
    reg signed[MULT_WIDTH+4:0]    add_st2[2];    
    reg signed[MULT_WIDTH+8:0]    add_st3;  
    
//    wire[KERNEL_WIDTH-1:0]  kernel[9];    
//   always_comb   
//    begin
//        for ( int i = 0; i < 9; i++ )
//            kernel[i] = kernel_[((i+1)*8-1)-:8];
//    end

//mult    
    always_comb /*always @( posedge clk )*/
        for (int i = 0; i < 9; i++ )
            mult[i] = data_i[i] * kernel[i];
//pipeline st0    
    always @( posedge clk )
        begin
            add_st0[0] <= mult[0] + mult[1];
            add_st0[1] <= mult[2] + mult[3];
            add_st0[2] <= mult[4] + mult[5];
            add_st0[3] <= mult[6] + mult[7];
            add_st0[4] <= mult[8];
        end
//pipeline st1      
    always @( posedge clk )
        begin
            add_st1[0] <= add_st0[0] + add_st0[1];
            add_st1[1] <= add_st0[2] + add_st0[3];
            add_st1[2] <= add_st0[4];
        end
//pipeline st2         
    always @( posedge clk )
        begin
            add_st2[0] <= add_st1[0] + add_st1[1];
            add_st2[1] <= add_st1[2];
        end
//pipeline st3        
    always @( posedge clk )
        add_st3 <=  add_st2[0] + add_st2[1];
/*    
    always @( posedge clk )
        data_o <=  add_st3 / 9;    
        */
    assign data_o = add_st3;
endmodule

