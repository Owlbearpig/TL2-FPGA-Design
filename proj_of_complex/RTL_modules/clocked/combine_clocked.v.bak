`timescale 1ns / 1ps


module combine_clocked
	#(parameter p = 22)(
    input wire signed [3+p-1:0] i_s_0, i_c_0, i_s_1, i_c_1, i_s_2, i_c_2, i_s_3, i_c_3, //  3Qp
    //input wire clk,
	output wire signed [3+p-1:0] o_r_enum_real, o_r_enum_imag, o_r_denum //  3Qp
	);
    
    wire signed [25-1:0] c0, c1, c2, c3, c4, c5, c6, c7;
	wire signed [3+p-1:0] c0_p, c1_p, c2_p, c3_p, c4_p, c5_p, c6_p, c7_p;
	wire signed [2*3+2*p-1:0] m_12_r, m_22_r, m_12_i, m_22_i, r_enum_real, r_enum_imag, r_denum; // 6Q(2*p)
	wire signed [3+p-1:0] m_12_r_pw, m_22_r_pw, m_12_i_pw, m_22_i_pw;
	
	assign c0 = 25'b111_0110101111101110000100; // -0.5783987651272869 3Q22
	assign c1 = 25'b000_0110010100001110111010; // 0.39475871488622216 3Q22
	assign c2 = 25'b000_1010000000010011001100; // 0.625292920983037 3Q22
	assign c3 = 25'b000_0000100100100110101110; // 0.03574721937867608 3Q22
	assign c4 = 25'b000_0001011100101110100101; // 0.09055460470069467 3Q22
	assign c5 = 25'b111_0000100111111001001101; // -0.9610413892553445 3Q22
	assign c6 = 25'b001_0000100111111001001100; // 1.0389586107446553 3Q22
	assign c7 = 25'b000_0011110011010010010011; // 0.2375838915640707 3Q22
	
	assign c0_p = c0[25-1:(25-3)-p];
	assign c1_p = c1[25-1:(25-3)-p];
	assign c2_p = c2[25-1:(25-3)-p];
	assign c3_p = c3[25-1:(25-3)-p];
	assign c4_p = c4[25-1:(25-3)-p];
	assign c5_p = c5[25-1:(25-3)-p];
	assign c6_p = c6[25-1:(25-3)-p];
	assign c7_p = c7[25-1:(25-3)-p];
    
	
	/* debugging
    integer file;
	reg [7:0] log_cntr = 8'b0;
	initial begin
		file = $fopen("display_output_combine.txt","w");
	end
	
	always @(posedge clk) begin
		$fwrite(file, "i_s_0: %b, i_c_0: %b, i_s_1: %b, i_c_1: %b, i_s_2: %b, i_c_2: %b, i_s_3: %b, i_c_3: %b\n", i_s_0, i_c_0, i_s_1, i_c_1, i_s_2, i_c_2, i_s_3, i_c_3);
		$fwrite(file, "m_12_i, %b\n", m_12_i);
		$fwrite(file, "m_22_i, %b\n", m_22_i);
		$fwrite(file, "m_12_r, %b\n", m_12_r);
		$fwrite(file, "m_22_r, %b\n", m_22_r);
		$fwrite(file, "m_12_i_pw, %b\n", m_12_i_pw);
		$fwrite(file, "m_12_r_pw, %b\n", m_12_r_pw);
		$fwrite(file, "o_r_denum, %b\n", o_r_denum);
		$fwrite(file, "m_r_enum_real, %b\n", m_r_enum_real);
		$fwrite(file, "m_r_enum_imag, %b\n", m_r_enum_imag);
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
	
	wire signed [2*3+2*p-1:0] d0, d1, d2, d3; // 6Q(2p)
	wire signed [3+p-1:0] d0_pw, d1_pw, d2_pw, d3_pw; // 6Q(2p)
	assign d0 = i_s_1 * i_c_2;
	assign d1 = i_s_1 * i_s_2;
	assign d2 = c4_p * i_c_3;
	assign d3 = c4_p * i_s_3;
	
	assign d0_pw = d0[3+2*p:p];
	assign d1_pw = d1[3+2*p:p];
	assign d2_pw = d2[3+2*p:p];
	assign d3_pw = d3[3+2*p:p];
	
	assign m_12_r = c0_p * d1_pw;
	assign m_12_i = c1_p * i_s_0 + c2_p * d0_pw + c3_p * i_s_3;
	
	assign m_22_r = c5_p * (d2_pw - i_c_0);
	assign m_22_i = c6_p * (d3_pw + i_s_0) + c7_p * d0_pw;
	
	assign m_12_r_pw = m_12_r[3+2*p:p];
	assign m_22_r_pw = m_22_r[3+2*p:p];
	assign m_12_i_pw = m_12_i[3+2*p:p];
	assign m_22_i_pw = m_22_i[3+2*p:p];
	
	assign r_enum_real = m_12_r_pw * m_22_r_pw + m_12_i_pw * m_22_i_pw;
	assign r_enum_imag = m_22_r_pw * m_12_i_pw - m_22_i_pw * m_12_r_pw;
	
	assign r_denum = m_22_r_pw * m_22_r_pw + m_22_i_pw * m_22_i_pw;
	
	assign o_r_enum_real = r_enum_real[3+2*p:p];
	assign o_r_enum_imag = r_enum_imag[3+2*p:p];
	
	assign o_r_denum = r_denum[3+2*p:p];
	
endmodule
