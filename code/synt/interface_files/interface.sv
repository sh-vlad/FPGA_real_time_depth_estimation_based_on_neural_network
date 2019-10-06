//////////////////////////////////////////////////////
//Name File     : interface_hps                //
//Author        : Andrey Papushin                   //
//Email         : andrey.papushin@gmail.com         //
//Standart      : IEEE 1800—2009(SystemVerilog-2009)//
//Start design  : 23.04.2018                        //
//Last revision : 23.04.2018                        //
//////////////////////////////////////////////////////
interface sdram_ifc #(parameter WIDTH_ADDR=1,  WIDTH_DATA=1, WIDTH_BE=1);
	logic [WIDTH_ADDR-1:0]  address           ;
	logic [7:0]             burstcount        ;
	logic                   waitrequest       ;
	logic [WIDTH_DATA-1:0]  readdata          ;
	logic                   readdatavalid     ;
	logic                   read              ;
	logic [WIDTH_DATA-1:0]  writedata         ;
	logic [WIDTH_BE  -1:0]  byteenable        ;
	logic                   write             ;
	modport sdram_bidirect_slave_port
	(
		input   address      ,       
		input   burstcount   ,    
		output  waitrequest  ,   
		output  readdata     ,      
		output  readdatavalid, 
		input   read         ,          
		input   writedata    ,     
		input   byteenable   ,    
		input   write
	);
	modport sdram_bidirect_master_port
	(
		output   address      ,       
		output   burstcount   ,    
		input    waitrequest  ,   
		input    readdata     ,      
		input    readdatavalid, 
		output   read         ,          
		output   writedata    ,     
		output   byteenable   ,    
		output   write
	);
	
	modport sdram_write_slave_port
	(
		input   address      ,       
		input   burstcount   ,    
		output  waitrequest  ,          
		input   writedata    ,     
		input   byteenable   ,    
		input   write
	);
	
	modport sdram_write_master_port
	(
		output   address      ,       
		output   burstcount   ,    
		input    waitrequest  ,   
		output   writedata    ,     
		output   byteenable   ,    
		output   write
	);
	
	modport sdram_read_slave_port
	(
		input   address      ,       
		input   burstcount   ,    
		output  waitrequest  ,          
		input   read         ,          
		output   readdata     ,   
		output   readdatavalid 
		
	);
	
	modport sdram_read_master_port
	(
		output   address      ,       
		output   burstcount   ,    
		input  waitrequest  ,          
		output   read         ,          
		input   readdata     ,   
		input   readdatavalid 
	);
endinterface
interface avl_stream_ifc #(parameter WIDTH_DATA=8);


	logic [WIDTH_DATA-1:0]  data ;
	logic                   valid;
	logic                   sop  ;
	logic                   eop  ; 
	logic                   sof  ;
	logic                   eof  ;
	
                           
	modport avl_stream_slave_port
	(
		input  data ,    
		input  valid, 
		input  sop  ,      
		input  eop  ,      
		input  sof  ,   
		input  eof           
	);
	
	modport avl_stream_master_port
	(
		output data ,    
		output valid, 
		output sop  ,      
		output eop  ,      
		output sof  ,   
		output eof           
	);   
	  
endinterface       
interface avl_ifc #(parameter WIDTH_ADDR=1,  WIDTH_DATA=1, WIDTH_BE=1);

	logic [WIDTH_ADDR-1:0]  address   ;
	logic [WIDTH_DATA-1:0]  readdata  ;
	logic [WIDTH_DATA-1:0]  writedata ;
	logic [WIDTH_BE  -1:0]  byteenable;
	logic                   chipselect;
	logic                   clken     ;
	logic                   write     ;
                           
	modport mem_slave_port
	(
		input  address   ,    
		input  chipselect, 
		input  clken     ,      
		input  write     ,      
		output readdata  ,   
		input  writedata ,  
		input  byteenable       
	);   
	
	modport mem_master_port
	(
		output  clken     ,
		output  address   ,    
		output  chipselect,     
		output  write     ,      
		input   readdata  ,   
		output  writedata ,  
		output  byteenable       
	);   
	modport avl_slave_port
	(
		input  address   ,    
		input  chipselect,      
		input  write     ,      
		output readdata ,   
		input  writedata ,  
		input  byteenable       
	);   
	modport avl_write_slave_port
	(
		input  address   ,    
		input  chipselect,      
		input  write     ,      
		input  writedata ,  
		input  byteenable       
	);   
	
	
	modport avl_master_port
	(
		output  address   ,    
		output  chipselect,     
		output  write     ,      
		input   readdata  ,   
		output  writedata ,  
		output  byteenable       
	);   
endinterface	

interface ddr3_ifc;
	
	logic [14:0]   a        ;
	logic [2:0]    ba       ;
	logic [0:0]    ck       ;
	logic [0:0]    ck_n     ;
	logic [0:0]    cke      ;
	logic [0:0]    cs_n     ;
	logic [3:0]    dm       ;
	logic [0:0]    ras_n    ;
	logic [0:0]    cas_n    ;
	logic [0:0]    we_n     ;
	logic          reset_n  ;
	logic [31:0]   dq       ;
	logic [3:0]    dqs      ;
	logic [3:0]    dqs_n    ;
	logic [0:0]    odt      ;
    logic           rzq      ;
                              
	modport ddr3_port
	(
		output a       , 
        output ba      , 
        output ck      , 
        output ck_n    , 
        output cke     , 
        output cs_n    , 
        output dm      , 
        output ras_n   , 
        output cas_n   , 
        output we_n    , 
        output reset_n , 
        inout  dq      , 
        inout  dqs     , 
        inout  dqs_n   , 
        output odt     , 
        input  rzq      
	);  
endinterface

interface dram_ifc;
    logic           clk  ;
    logic           cke  ;
    logic [12: 0]   addr ;
    logic [ 1: 0]   ba   ;
    logic [15: 0]   dq   ;
    logic           ldqm ;
    logic           udqm ;
    logic           cs_n ;
    logic           we_n ;
    logic           cas_n;
    logic           ras_n;




                              
	modport dram_port
	(
		output  clk  ,
		output  cke  ,
		output  addr ,
		output  ba   ,
		inout   dq   ,
		output  ldqm ,
		output  udqm ,
		output  cs_n ,
		output  we_n ,
		output  cas_n,
		output  ras_n	
	);  
endinterface




interface pcie_ifc;
	wire            smbclk   ;
	wire            smbdat   ;
	wire            refclk_p ;
	wire  [ 3: 0]   tx_p     ;
	wire  [ 3: 0]   rx_p     ;
	wire            perst_n  ;
	wire            wake_n   ;
	
	
                              
	modport pcie_port
	(
		inout   smbclk   ,
		inout   smbdat   ,
		input   refclk_p ,
		output  tx_p     ,
		input   rx_p     ,
		inout   perst_n  ,
		inout   wake_n   
	);  
endinterface
