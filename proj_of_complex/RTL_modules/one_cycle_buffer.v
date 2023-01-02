`timescale 1ns / 1ps


module one_cycle_buffer
	#(parameter p = 22)(
    input wire [3+p-1:0] i_data_1, // 3Qp
	input wire [3+p-1:0] i_data_2, // 3Qp
    input clk,
    output reg [3+p-1:0] o_data_1,
	output reg [3+p-1:0] o_data_2
    );
    
    always @ (posedge clk) begin
        o_data_1 <= i_data_1;
		o_data_2 <= i_data_2;
    end
    
endmodule
