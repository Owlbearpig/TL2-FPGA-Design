`timescale 1ns / 1ps


module fp_multiplication
	#(parameter p = 22)(
    input wire [3+p-1:0] f1, f2, // 3Qp
	//input clk,
    output wire [3+p-1:0] m // 3Qp
    );
    /* debugging
	integer file;
	reg [7:0] log_cntr = 8'b0;
	initial begin
		file = $fopen("display_output_mult.txt","w");
	end
	
	always @(posedge clk) begin
		$fwrite(file, "f1, %b\n", f1);
		$fwrite(file, "f2, %b\n", f2);
		$fwrite(file, "m, %b\n", m);
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
    wire [2*3+2*p-1:0] m_tmp; 
    
    assign m_tmp = f2 * f1; // (2*3)Q(2*p) unsigned mult
    assign m = m_tmp[3+2*p:p];
    
endmodule
