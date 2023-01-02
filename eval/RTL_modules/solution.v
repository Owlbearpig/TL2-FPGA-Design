`timescale 1ns / 1ps

module solution
	#(parameter pd = 12, parameter p = 22)(
	input wire [pd+p-1:0] d0_res, d1_res, d2_res,
	input wire [3+p-1:0] fx_res,
	input wire valid_i, clk, eval_done_i,
	input wire [7:0] p0_idx_i,
	output reg [pd+p-1:0] d0_sol, d1_sol, d2_sol,
	output reg [3+p-1:0] fx_best,
	output reg [7:0] p0_idx_best_o
	);
	
	initial begin
		d0_sol = {pd+p{1'b0}};
		d1_sol = {pd+p{1'b0}}; 
		d2_sol = {pd+p{1'b0}};
		p0_idx_best_o = 8'b0;
	end
	
	reg [3+p-1:0] fx_best = {3+p{1'b1}};
	always @(posedge clk) begin
		if ((fx_res < fx_best) & (valid_i)) begin
			fx_best <= fx_res;
			d0_sol <= d0_res;
			d1_sol <= d1_res;
			d2_sol <= d2_res;
			p0_idx_best_o <= p0_idx_i;
		end else begin
			fx_best <= fx_best;
			d0_sol <= d0_sol;
			d1_sol <= d1_sol;
			d2_sol <= d2_sol;
			p0_idx_best_o <= p0_idx_best_o;
		end
		if (eval_done_i) begin // reset
			fx_best <= {3+p{1'b1}};
			d0_sol <= {pd+p{1'b0}};
			d1_sol <= {pd+p{1'b0}}; 
			d2_sol <= {pd+p{1'b0}};
			p0_idx_best_o <= 8'b0;
		end
		
	end

	
	
endmodule
