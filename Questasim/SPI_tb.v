module SPI_tb ();

    reg  MOSI, clk, rst, ss_n; 
    wire MISO;

    SPI_wrapper DUT (
        .MOSI(MOSI), 
        .clk(clk), 
        .rst_n(rst), 
        .SS_n(ss_n), 
        .MISO(MISO)
        );

    integer i;

    always #5
        clk = ~clk;

    reg  MISO_Exp;

    initial begin
    clk      = 0;
    rst      = 0;
    ss_n     = 1;
    MOSI     = 0;
    MISO_Exp = 0; 

    $readmemh ("mem.dat", DUT.my_mem.mem);

    repeat(4)@(negedge clk);

    rst = 1; 
    @(negedge clk);

    // Write address
    ss_n = 0; 
    @(negedge clk);
    
    MOSI = 0; @(negedge clk);

    MOSI = 0; @(negedge clk);
    MOSI = 0; @(negedge clk);

    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    ss_n = 1; @(negedge clk);

    ss_n = 1;  @(negedge clk);

    // Write data
    ss_n = 0; 
    @(negedge clk);

    MOSI = 0; @(negedge clk);

    MOSI = 0; @(negedge clk);
    MOSI = 1; @(negedge clk);

    MOSI = 1; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 0; @(negedge clk); 

    ss_n = 1; @(negedge clk);

    // Read address
    ss_n = 0; 
    @(negedge clk);

    MOSI = 1; @(negedge clk);

    MOSI = 1; @(negedge clk);
    MOSI = 0; @(negedge clk);

    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk); 
    ss_n = 1; @(negedge clk); 

    ss_n = 1; @(negedge clk);

    // Read data
    ss_n = 0; 
    @(negedge clk);

    MOSI = 1; @(negedge clk);

    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);

    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);

    for (i=0 ; i<12 ; i=i+1)
        @(negedge clk);

    ss_n = 1;

    repeat(4)@(negedge clk);
    $stop;
    end
endmodule