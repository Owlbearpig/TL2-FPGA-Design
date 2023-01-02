`timescale 1ns / 1ps

module lut_fp_division
	#(parameter p = 22)(
    input wire [3+p-1:0] x, // input 3Qp
    input clk,
	output wire [3+p-1:0] o_recip_x // dividend * (1/x), 3Qp
	);
	
    // we can probably reduce size via interpolation
    reg [15:0] bram [0:65536]; // 2Q14 in bram
	reg [15:0] x0;
    wire [15:0] addr; // 16Q0
	reg [15:0] lut; // 2Q14
	reg [3+p-1:0] x_prev_cycle;
	wire [25-1:0] c1, c2;
	
	/* debugging
	integer file;
	reg [7:0] log_cntr = 8'b0;
	initial begin
		file = $fopen("display_output_lut_fp_division.txt","w");
	end
	
	always @(posedge clk) begin
		$fwrite(file, "lut, %b\n", lut);
		$fwrite(file, "x_prev_cycle, %b\n", x_prev_cycle);
		$fwrite(file, "o_recip_x, %b\n", o_recip_x);
		$fwrite(file, "clk cycle %b done \n\n", log_cntr);
		log_cntr <= log_cntr + 1;
	end
	
	always @(log_cntr) begin
		$display("log_cntr: %b", log_cntr); 
		if (log_cntr == 8'b01011010)
			$fclose(file);
			//log_cntr <= 8'b0;
	end
	*/
	
    initial begin
		x0 = 16'b00_10000000000000;
        $readmemb("recip_lut_extended.mem", bram);
    end
	
	// addr = (x - x0) * (2**16 / (x1 - x0)), x1 = 2.5
	if (p >= 16) begin
	   assign addr = x[1+p:p-14] - x0; 
	end else begin
	   assign addr = {{x[1+p:1]}, {15-p{1'b0}}} - x0;
	end
	
    always @(posedge clk) begin
        lut <= bram[addr << 1]; // *2**15 same as << 1
		x_prev_cycle <= x;
    end
	
	// precision extension, all numbers unsigned
	/*
		1. 1+a = lut * x // lut
		2. t := 1/(1+a) = 1 - a + a^2 - a^3 + a^4 - a^5 + a^6 + O(a^7)
		2.1 simplify: 1/(1+a) ~ (3/2 - lut*x)**2 + 3/4 // m = (3/2 - lut*x) = c1 - r*x
		3. 1/x = lut * t
	*/
	wire [3+p-1:0] r;
	wire [3+p-1:0] c1_p, c2_p;

    wire [2*3+2*p-1:0] rx, m_sqr, recip_x; 
    wire [3+p-1:0] m, t;
	
	if (p >= 16) begin
        assign r = {{lut}, {p-14{1'b0}}}; // 3Qp
    end else begin // lut is 2Q14
        if (p == 15) begin
            assign r = {{1'b0}, {lut}, {1'b0}};
        end else if (p == 14) begin
            assign r = {{1'b0}, {lut}};
        end else begin
            assign r = lut[2+14-1:14-p];
        end
    end
    
    assign c1 = 25'b001_1000000000000000000000; // 3/2 3Q22
    assign c2 = 25'b000_1100000000000000000000; // 3/4 3Q22
    
    assign c1_p = c1[25-1:(25-3)-p];
    assign c2_p = c2[25-1:(25-3)-p];
    
    assign rx = r * x_prev_cycle; // needs x from previous clk cycle otherwise r and x don't match current cycle ...
    //assign m = c1[25-1:(25-3)-p] - rx[3+2*p:p];
    assign m = c1_p - rx[3+2*p:p];
    assign m_sqr = m * m;
    //assign t = m_sqr[3+2*p:p] + c2[25-1:(25-3)-p];
    assign t = m_sqr[3+2*p:p] + c2_p;
    assign recip_x = r * t;
    assign o_recip_x = recip_x[3+2*p:p];
	
endmodule
