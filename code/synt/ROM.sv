// Quartus Prime Verilog Template
// Single Port ROM
// modified: Vlad Sharshin 
// shvladspb@gmail.com

module ROM
#(
    parameter TYPE                     = "",
    parameter NUMBER_SPLITTED_CHANNELS = 1,
    parameter THIS_CHANNEL_NUMBER      = 0,
    parameter CHANNEL_NUM              = 3,
    parameter DATA_WIDTH    = 8, 
    parameter MEM_DEPTH     = 8,
    parameter RAM_STYLE     = "M10K",//"logic"
    parameter INI_FILE      = "rom_init.txt",
    parameter ADDR_WIDTH = $clog2(MEM_DEPTH)  
)

(
	input wire                      clk, 
	input wire [(ADDR_WIDTH-1):0]   addr,
	output logic [(DATA_WIDTH-1):0] q
);

    reg [(DATA_WIDTH-1):0]   out; 
(* romstyle = RAM_STYLE *)	
    reg [DATA_WIDTH-1:0] rom[MEM_DEPTH-1:0];

	initial
	begin
        if ( TYPE == "CVS_KERNEL" )
            begin
                reg [31:0] a,b,c;
                reg [DATA_WIDTH-1:0] tmp_rom[MEM_DEPTH*NUMBER_SPLITTED_CHANNELS-1:0];
                int cnt;
                cnt = 0;
                $readmemh(INI_FILE, tmp_rom);
                
                a = (THIS_CHANNEL_NUMBER)*MEM_DEPTH;
                c = MEM_DEPTH;        
                b = ((THIS_CHANNEL_NUMBER)*MEM_DEPTH+MEM_DEPTH);         
                
                for ( int i=THIS_CHANNEL_NUMBER*CHANNEL_NUM; i<MEM_DEPTH*NUMBER_SPLITTED_CHANNELS;i=i+CHANNEL_NUM*NUMBER_SPLITTED_CHANNELS )
                    for ( int j=0; j<CHANNEL_NUM; j++ )
                        begin
                        //    $display("%m i+j=%0d cnt=%0d i=%0d, j=%0d, MEM_DEPTH=%0d, THIS_CHANNEL_NUMBER*CHANNEL_NUM=%0d",i+j,cnt,i,j,MEM_DEPTH,THIS_CHANNEL_NUMBER*CHANNEL_NUM);
                            rom[cnt] = tmp_rom[i+j];
                            cnt++;
                        end
            end
        else if ( TYPE == "CVS_BIAS" )
            begin
                reg [DATA_WIDTH-1:0] tmp_rom[MEM_DEPTH*NUMBER_SPLITTED_CHANNELS-1:0];
                $readmemh(INI_FILE, tmp_rom);
                for ( int i=THIS_CHANNEL_NUMBER*MEM_DEPTH; i<THIS_CHANNEL_NUMBER*MEM_DEPTH+MEM_DEPTH; i++)
                    rom[i-THIS_CHANNEL_NUMBER*MEM_DEPTH] = tmp_rom[i];
            end
        else
            $readmemh(INI_FILE, rom);
//        //for (integer i=(THIS_CHANNEL_NUMBER)*MEM_DEPTH/NUMBER_SPLITTED_CHANNELS; i<((THIS_CHANNEL_NUMBER-1)*MEM_DEPTH/NUMBER_SPLITTED_CHANNELS+MEM_DEPTH/NUMBER_SPLITTED_CHANNELS); i++)
//        for (integer i=a; i<b; i++)
//            begin
//                rom[i-a] = tmp_rom[i];
//            end
    
    //    for (integer i=0; i<7; i++)
    //        begin
    //             $display(i);
    //        end
    
    //    //$readmemh(/*"C:/proj/tbs/tb_layer/rom_init_0.txt"*/INI_FILE, rom);
    //    for ( int i=0; i<44;i++)
    //        rom[i] = i;
    //    rom[0] = 4;
    
        
	end

	always @ (posedge clk)
	begin
		out <= rom[addr];
	end
    /*
    always @ (posedge clk)
        q <= out;
        */
    assign q = out;     
endmodule
