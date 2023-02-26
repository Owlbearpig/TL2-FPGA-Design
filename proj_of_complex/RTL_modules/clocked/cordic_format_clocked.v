`timescale 1ns / 1ps


module cordic_format_clocked
	#(parameter pd = 4, parameter p = 9)(
    input wire signed [pd+p-1:0] x, // pdQp
    input wire clk,
	output wire signed [pd+p-1:0] s_out // 4Qp
    );
	
	reg signed [pd+p-1:0] x_r_0, x_r_1;
	reg signed [pd+p-1:0] s, ss; // 4Qp
    reg signed [2*pd+2*p-1:0] r, m; // (2*pd)Q(2*p)
	reg signed [pd+p-1:0] n, m_p; // pdQp
	wire signed [pd+p-1:0] r_int; // pdQp
	// constants, pi, 2*pi, 1/(2*pi)
    wire signed [30-1:0] pi, pi2, pi2_inv;
	wire signed [pd+p-1:0] pi_p, pi2_p, pi2_inv_p;
	
	assign pi = 30'b00000011_0010010000111111011010; // pi 8Q22
	assign pi2 = 30'b00000110_0100100001111110110101; // 2pi 8Q22
	assign pi2_inv = 30'b00000000_0010100010111110011000; // 1/(2pi) 8Q22
	
	assign pi_p = pi[30-1:(30-pd)-p];
	assign pi2_p = pi2[30-1:(30-pd)-p];
	assign pi2_inv_p = pi2_inv[30-1:(30-pd)-p];
	
	/*
	integer file;
	reg [7:0] log_cntr = 8'b0;
	initial begin
		file = $fopen("display_output_cordic_format.txt","w");
	end
	
	always @(posedge clk) begin
		$fwrite(file, "x, %b\n", x);
		$fwrite(file, "r, %b\n", r);
		$fwrite(file, "r_int, %b\n", r_int);
		$fwrite(file, "m, %b\n", m);
		$fwrite(file, "m_p, %b\n", m_p);
		$fwrite(file, "n, %b\n", n);
		$fwrite(file, "s, %b\n", s);
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
	assign r_int = {{r[2*p+:pd]}, {p{1'b0}}}; // pdQp
	
	wire signed [3+pd+p-1:0] x_long;
	assign x_long = {{3{1'b0}}, x};
	
	wire signed [3+pd+p-1:0] x_long_shifted;
	assign x_long_shifted = x_long << 3;
	
	wire signed [3+pd+p-1:0] x_long_shifted_int;
	assign x_long_shifted_int = {x_long_shifted[pd+p:p], {p{1'b0}}};
	
	wire signed [pd+p-1:0] x_mod;
	assign x_mod = x_long_shifted_int;
	
	
	
	always @(posedge clk) begin
		m <= pi2_p * x_mod; // (2*pd)Q(2*p)
	end
	
	assign m_p = m[pd+p:p];
	assign s_out = m_p;
	
	/*
	if m_p < 0
		m_p = m_p + pi2;
	
	if m_p > pi
		m_p = m_p - pi2
	
	assign s_out = (m_p > pi_p) ?  :
				   (m_p[pd+p] == 1'b1) ? ()
				   ;
	*/
endmodule
