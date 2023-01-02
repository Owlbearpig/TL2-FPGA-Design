`timescale 1ns / 1ps

module controller_eval
	#(parameter pd = 12, parameter p = 22)(
	input wire [6*3+6*p-1:0] cur_data_real_i, cur_data_imag_i,
	input wire eval_done_i,
	output reg [6*3+6*p-1:0] cur_data_real_o, cur_data_imag_o,
	output wire eval_busy_o
	);
	
	reg eval_busy = 1'b0;
	reg ready = 1'b1;
	always @(cur_data_real_i, cur_data_imag_i, eval_done_i) begin
		if ((cur_data_real_i != {6*(3+p){1'b0}}) & (cur_data_imag_i != {6*(3+p){1'b0}})) begin
			cur_data_real_o = cur_data_real_i;
			cur_data_imag_o = cur_data_imag_i;
			eval_busy = 1'b1;
			ready = 1'b0;
		end else if (eval_done_i) begin
			eval_busy = 1'b0;
			ready = 1'b1;
		end
	end
	
	assign eval_busy_o = eval_busy;
	
endmodule