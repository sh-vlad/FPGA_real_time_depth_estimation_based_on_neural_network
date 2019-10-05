//Author: Vlad Sharshin 
//e-mail: shvladspb@gmail.com
module parallel2serial
#(
    parameter DATA_WIDTH    = 8, 
    parameter BUS_NUM_I     = 8,
    parameter BUS_NUM_O     = 1
)
(
	input wire                      clk, 
    input wire                      reset_n,
    input wire                      data_valid_i,
	input wire [DATA_WIDTH-1:0]     data_i[BUS_NUM_I],
    
    output wire                     data_valid_o,   
    output wire [DATA_WIDTH-1:0]    data_o[BUS_NUM_O]
    
);

    reg [$clog2(BUS_NUM_I)-1:0] cnt;
    
    always @( posedge clk or negedge reset_n )
        if ( !reset_n )
            cnt <= {(BUS_NUM_I){1'h0}};
        else
            if ( !data_valid_i )
                cnt <= {(BUS_NUM_I){1'h0}};
            else if ( cnt == BUS_NUM_I/BUS_NUM_O )
                cnt <= cnt;
            else
                cnt <= cnt + 1;
                
    always @( posedge clk )
        if ( data_valid_i )
            for ( int i = 0; i < BUS_NUM_O; i++ )
                data_o[i] <= data_i[cnt+(BUS_NUM_I/BUS_NUM_O)*i];
            //    case (cnt)
            //        cnt:      data_o[i] <= data_i[cnt+(BUS_NUM_I/BUS_NUM_O)*i];
            //        default data_o[i] <= '0;
            //    endcase
                
    always @( posedge clk or negedge reset_n )
        if ( !reset_n )
            data_valid_o <= 0;
        else
            if ( data_valid_i && ( cnt != BUS_NUM_I/BUS_NUM_O ) )
                data_valid_o <= 1;
            else
                data_valid_o <= 0;
endmodule




