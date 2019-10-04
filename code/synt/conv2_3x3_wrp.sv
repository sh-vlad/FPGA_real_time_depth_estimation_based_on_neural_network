//`include "conv2_3x3_wrp.vh"
module conv2_3x3_wrp
#(
    parameter DATA_WIDTH    = 8, 
//    parameter KERNEL_NUM    = 1,
    parameter KERNEL_WIDTH  = 8,
    parameter MEM_DEPTH     = 16,
    parameter DATA_HOLD     = 16,
    parameter INI_FILE/*[KERNEL_NUM] */     = "",
    parameter MULT_WIDTH = DATA_WIDTH + KERNEL_WIDTH,
    parameter DATAO_WIDTH = MULT_WIDTH + 8
)
(
	input wire                          clk, 
    input wire                          reset_n,
	input wire [(DATA_WIDTH-1):0]       data_i/*[1]*/[9],
    input wire                          data_valid_i,
	input wire						    sop_i,
    input wire						    eop_i,
    input wire						    sof_i,
    input wire						    eof_i,  
    output wire [DATAO_WIDTH-1:0]       data_o/*[KERNEL_NUM]*/,
    output wire                         data_valid_o,
	output logic					    sop_o,
    output logic					    eop_o,
    output logic					    sof_o,
    output logic					    eof_o     
);
    localparam RAM_STYLE = MEM_DEPTH < 512 ? "logic" : "M10K";
    localparam ROM_ADDR_WIDTH = $clog2(MEM_DEPTH);
    localparam ROM_DATA_WIDTH = KERNEL_WIDTH*9;

    
    wire    [KERNEL_WIDTH*9-1: 0]    rom_out/*[KERNEL_NUM]*/;
    reg     [ROM_ADDR_WIDTH-1: 0]    rom_addr;    
    logic   [KERNEL_WIDTH-1: 0]      kernel/*[KERNEL_NUM-1:0]*/[9];
    reg     [(DATA_WIDTH-1):0]       sh_data_i[9];
    reg     [31:0]                   hold_cnt;
    
    always @( posedge clk )
        if ( hold_cnt == DATA_HOLD-1 || !data_valid_i )
            hold_cnt <= 0;
 /*       else if ( !data_valid_i )
            hold_cnt <= 0;*/
        else if ( data_valid_i )
            hold_cnt <= hold_cnt + 1;
    
    
    always @( posedge clk )
        sh_data_i <= data_i/*[0]*/;
    
//
    always@( posedge clk or negedge reset_n )
        if ( !reset_n )            
            rom_addr <= '0;
        else
            if ( rom_addr == MEM_DEPTH-1 && hold_cnt == DATA_HOLD-1 )
                rom_addr <= '0;
            else if ( data_valid_i && hold_cnt == DATA_HOLD-1)
                rom_addr <= rom_addr + 1'h1;
//

    ROM
    #(
        .DATA_WIDTH    ( ROM_DATA_WIDTH ),
        .MEM_DEPTH     ( MEM_DEPTH      ),
        .RAM_STYLE     ( "logic"        ),
        .INI_FILE      ( INI_FILE/*"rom_init.txt"*/    ) //$sformatf("rom_init_%0d.txt", i) // 
    )
    ROM_gen_1
    (
        .clk            ( clk           ),
        .addr           ( rom_addr      ),
        .q              ( rom_out    )
    );        
    
    always_comb   
        begin
            for ( int j = 0; j < 9; j++ )
                kernel[j] = rom_out[((j+1)*8-1)-:8];
        end
    
    conv2_3x3
    #(
        .DATA_WIDTH     ( DATA_WIDTH    ),
        .KERNEL_WIDTH   ( KERNEL_WIDTH  )
    )
    conv2_3x3_gen_1
    (
    .clk        ( clk                    ),
    .data_i     ( sh_data_i              ),
    .kernel     ( kernel                 ),
    .data_o     ( data_o                 )
    );   


delay_rg
#(
    .W          ( 5     ),         
    .D          ( 5     )
)         
delay_rg     
(
    .clk        ( clk                                       ),        
	.data_in    ( { sop_i,eop_i,sof_i,eof_i,data_valid_i }  ), 
    .data_out   ( { sop_o,eop_o,sof_o,eof_o,data_valid_o }  )
);
endmodule

/*
genvar i;
generate 
    begin
        for ( i = 0; i < KERNEL_NUM; i++ )
            begin:conv_gen
                ROM
                #(
                    .DATA_WIDTH    ( ROM_DATA_WIDTH ),
                    .MEM_DEPTH     ( MEM_DEPTH      ),
                    .RAM_STYLE     ( "logic"        ),
                    .INI_FILE      ( INI_FILE[i]    ) //$sformatf("rom_init_%0d.txt", i) // "rom_init.txt"
                )
                ROM_gen_1
                (
                    .clk            ( clk           ),
                    .addr           ( rom_addr      ),
                    .q              ( rom_out[i]    )
                );        
                
                always_comb   
                    begin
                        for ( int j = 0; j < 9; j++ )
                            kernel[i][j] = rom_out[i][((j+1)*8-1)-:8];
                    end
                
                conv2_3x3
                #(
                    .DATA_WIDTH     ( DATA_WIDTH    ),
                    .KERNEL_WIDTH   ( KERNEL_WIDTH  )
                )
                conv2_3x3_gen_1
                (
                   .clk        ( clk                    ),
                   .data_i     ( sh_data_i              ),
                   .kernel     ( kernel[i]              ),
                   .data_o     ( data_o[i]              )
                );   
            end
    end
endgenerate

*/