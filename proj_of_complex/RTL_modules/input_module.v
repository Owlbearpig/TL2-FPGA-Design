`timescale 1ns / 1ps


module input_module
	#(parameter pd = 12, parameter p = 22)(
    input wire signed [pd+p-1:0] d0, d1, d2, // pdQp d in um
    input wire [2:0] cntr,
    //input wire clk,
	output wire signed [8+p-1:0] p0, p1, p2, p3 // 8Qp
    );
    
    wire signed [pd+2*p-1:0] m0, m1, m2, m3; // pdQ(2*p)
    wire signed [22-1:0] f, g;
	wire signed [p-1:0] f_p, g_p;
	
    /*
	integer file;
	reg [7:0] log_cntr = 8'b0;
	initial begin
		file = $fopen("display_output_input_module.txt","w");
	end
	
	always @(posedge clk) begin
		$fwrite(file, "m0, %b\n", m0);
		$fwrite(file, "m1, %b\n", m1);
		$fwrite(file, "m2, %b\n", m2);
		$fwrite(file, "m3, %b\n", m3);
		$fwrite(file, "p0, %b\n", p0);
		$fwrite(file, "p1, %b\n", p1);
		$fwrite(file, "p2, %b\n", p2);
		$fwrite(file, "p3, %b\n", p3);
		$fwrite(file, "clk cycle %b done \n\n", log_cntr);
		log_cntr <= log_cntr + 1;
	end
	
	always @(log_cntr) begin
		$display("log_cntr: %b", log_cntr);
		if (log_cntr == 8'b00001100)
			$fclose(file);
			//log_cntr <= 8'b0;
	end
	*/
	
	assign g = (cntr == 3'b001) ? 22'b0000011001001111010001 : // 0.024647137458149997 0Q22
				(cntr == 3'b010) ? 22'b0000011111001111110111 : // 0.03051550351962 0Q22
				(cntr == 3'b011) ? 22'b0000100111000011110101 : // 0.03814437939952 0Q22
				(cntr == 3'b100) ? 22'b0000110000000100101101 : // 0.04694692849172 0Q22
				(cntr == 3'b101) ? 22'b0000110011000101000000 : // 0.04988111152245 0Q22
				(cntr == 3'b110) ? 22'b0000111001000101100110 : // 0.055749477583909995 0Q22
				{p{1'b0}};
				
	assign f = (cntr == 3'b001) ? 22'b0000001101100001010100 : // 0.0132038236383 0Q22
				(cntr == 3'b010) ? 22'b0000010000101111010110 : // 0.016347591171219998 0Q22
				(cntr == 3'b011) ? 22'b0000010100111011001100 : // 0.02043448896403 0Q22
				(cntr == 3'b100) ? 22'b0000011001110000001111 : // 0.02515014026342 0Q22
				(cntr == 3'b101) ? 22'b0000011011010111010000 : // 0.02672202402988 0Q22
				(cntr == 3'b110) ? 22'b0000011110100101010010 : // 0.02986579156281 0Q22
				{p{1'b0}};

	
	assign g_p = g[22-1:22-p];
	assign f_p = f[22-1:22-p];
	
	assign m0 = f_p * (d2 + d0) + g_p * d1;
	assign m1 = g_p * d1;
	assign m2 = f_p * (d2 - d0);
	assign m3 = - f_p * (d2 + d0) + g_p * d1;

	assign p0 = m0[8+2*p:p]; // out should be 8Qp
	assign p1 = m1[8+2*p:p];
	assign p2 = m2[8+2*p:p];
	assign p3 = m3[8+2*p:p];
    
endmodule
