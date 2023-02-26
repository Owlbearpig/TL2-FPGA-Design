`timescale 1ns / 1ps


module input_module_clocked
	#(parameter pd = 4, parameter p = 9)(
    input wire signed [pd+p-1:0] d0, d1, d2, // pdQp
    input wire [2:0] cntr,
    input wire clk,
	output wire signed [4+p-1:0] p0, p1, p2, p3 // 8Qp
    );
    
    reg signed [pd+2*p-1:0] m0_r, m1_r, m2_r, m3_r; // pdQ(2*p)
    wire signed [p-1:0] f, g;
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

	assign f = (cntr == 3'b001) ? 9'b000110110: // 0.10563059
				(cntr == 3'b010) ? 9'b001000010: // 0.13078073
				(cntr == 3'b011) ? 9'b001010011: // 0.16347591
				(cntr == 3'b100) ? 9'b001100111: // 0.20120112
				(cntr == 3'b101) ? 9'b001101101: // 0.21377619
				(cntr == 3'b110) ? 9'b001111010: // 0.23892633
				{p{1'b0}};
				
	assign g = (cntr == 3'b001) ? 9'b001100100: // 0.1971771
				(cntr == 3'b010) ? 9'b001111100: // 0.24412403
				(cntr == 3'b011) ? 9'b010011100: // 0.30515504
				(cntr == 3'b100) ? 9'b011000000: // 0.37557543
				(cntr == 3'b101) ? 9'b011001100: // 0.39904889
				(cntr == 3'b110) ? 9'b011100100: // 0.44599582
				{p{1'b0}};

	
	assign g_p = g[p-1:p-p];
	assign f_p = f[p-1:p-p];
	
	always @(posedge clk) begin
		m0_r <= f_p * (d2 + d0) + g_p * d1;
		m1_r <= g_p * d1;
		m2_r <= f_p * (d2 - d0);
		m3_r <= - f_p * (d2 + d0) + g_p * d1;
	end
	
	assign p0 = m0_r[pd+2*p-1:p]; // out should be pdQp
	assign p1 = m1_r[pd+2*p-1:p];
	assign p2 = m2_r[pd+2*p-1:p];
	assign p3 = m3_r[pd+2*p-1:p];
    
endmodule
