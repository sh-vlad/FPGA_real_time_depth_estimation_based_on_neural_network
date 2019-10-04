// Quartus Prime Verilog Template
// Single Port ROM
// modified: Vlad Sharshin 
// shvladspb@gmail.com

module ROM
#(
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
		$readmemh(/*"C:/proj/tbs/tb_layer/rom_init_0.txt"*/INI_FILE, rom);
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
