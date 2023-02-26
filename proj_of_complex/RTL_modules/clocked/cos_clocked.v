`timescale 1ns / 1ps

module cos_clocked
    #(parameter pd = 4, parameter p = 9)(
    input wire signed [pd+p-1:0] i_s, // pdQp, range: -pi, pi -> pd=3 bit for int, 1 for overflow
    input wire clk,
	output reg signed [3+p-1:0] o_c_r // 3Qp
    );
    
	wire signed [3+p-1:0] o_c; // 3Qp
    wire signed [pd+p-1:0] abs_p, x, m1_dw, y_dw, abs_y_dw, m2_dw, m3_dw, s, c; // pdQp
    wire signed [2*pd+2*p-1:0] y, m2, m1, m3;
	
	// constants
    wire signed [26-1:0] B, one, pi_half, pi, pi2, C, P;
	wire signed [pd+p-1:0] B_p, one_p, pi_half_p, pi_p, pi2_p, C_p, P_p;
	
	assign pi = 26'b0011_0010010000111111011010; // pi 4Q22
	assign pi2 = 26'b0110_0100100001111110110101; // 2pi 4Q22
	assign pi_half = 26'b0001_1001001000011111101101; // pi/2 4Q22
	
	assign pi_p = pi[26-1:(26-4)-p];
	assign pi2_p = pi2[26-1:(26-4)-p];
	assign pi_half_p = pi_half[26-1:(26-4)-p];
		
    assign B = 26'b0001_0100010111110011000001; // 4/pi 4Q22
	assign C = 26'b1111_1001100000111111010001; // -4/pi**2 4Q22
	assign P = 26'b0000_0011100110011001100110; // 0.225 4Q22
	assign one = 26'b0001_0000000000000000000000; // 1 4Q22
	assign B_p = B[26-1:(26-4)-p];
	assign C_p = C[26-1:(26-4)-p];
	assign P_p = P[26-1:(26-4)-p];
	assign one_p = one[26-1:(26-4)-p];

	/* debugging
	integer file;
	reg [7:0] log_cntr = 8'b0;
	initial begin
		file = $fopen("display_output_cos.txt","w");
	end
	
	always @(posedge clk) begin
		$fwrite(file, "i_s, %b\n", i_s);
		$fwrite(file, "c, %b\n", c);
		$fwrite(file, "x, %b\n", x);
		$fwrite(file, "m1, %b\n", m1);
		$fwrite(file, "y, %b\n", y);
		$fwrite(file, "y_dw, %b\n", y_dw);
		$fwrite(file, "m2, %b\n", m2);
		$fwrite(file, "m3, %b\n", m3);
		$fwrite(file, "o_c, %b\n", o_c);
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
    assign c = i_s + pi_half_p; // pdQp
	assign x = (c > pi_p) ? c - pi2_p : c;
	
    assign abs_p = (x[pd+p-1] == 1'b1) ? -x : x; // pdQp
	
	assign m1 = C_p * abs_p; // (2*pd)Q(2*p)
	assign m1_dw = m1[pd+2*p:p]; // pdQpd
	
    assign y = x * (m1_dw + B_p); // pdQ(2*p)
    assign y_dw = y[pd+2*p:p]; // pdQp
	
    assign abs_y_dw = (y_dw[pd+p-1] == 1'b1) ? -y_dw : y_dw; // pdQp
	
	assign m2 = y_dw * (abs_y_dw - one_p); // (2*pd)Q(2*p)
	assign m2_dw = m2[pd+2*p:p]; // pdQp
	
    assign m3 = P_p * m2_dw; // (2*pd)Q(2*p)
	assign m3_dw = m3[pd+2*p:p]; // pdQp
	
	assign o_c = m3_dw + y_dw; // 3Qp
	
	always @(posedge clk) begin
		o_c_r <= o_c;
	end
	
	

endmodule
