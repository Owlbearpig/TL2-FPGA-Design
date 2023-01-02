`timescale 1ns / 1ps


module controller
	#(parameter pd = 12, parameter p=22)(
    input wire [pd+p-1:0] i_d0, i_d1, i_d2, // pdQp
	input wire valid,
    input wire clk,
    output wire [pd+p-1:0] o_d0, o_d1, o_d2, // pdQp
    output reg [2:0] cntr = 3'b000,
	output reg busy
    );

    assign o_d0 = (cntr > 3'b000) ? i_d0 : {pd+p{1'b0}};
    assign o_d1 = (cntr > 3'b000) ? i_d1 : {pd+p{1'b0}};
    assign o_d2 = (cntr > 3'b000) ? i_d2 : {pd+p{1'b0}};
    
	//assign busy = ((i_d0 != {pd+p{1'b0}}) & (~valid)) ? 1'b1 : 1'b0;
	
    initial busy = 1'b1;
	always @(i_d0, valid) begin
		if ((i_d0 != {pd+p{1'b0}}) & (~valid)) begin
			busy = 1'b1;
		end else begin
			busy = 1'b0;
		end
	end
	/*
	always @(posedge clk) begin
        $display("o_d0, %b", o_d0);
	end
	always @* $display("cntr: %b", cntr);
	*/
	// count to six reset counter and lock until valid signal
	reg lock = 1'b0;
	always @(posedge clk) begin
		if ((~lock) & (busy) & (cntr != 3'b110)) begin
			cntr <= cntr + 1;
		end else if (cntr == 3'b110) begin
            cntr <= 3'b000;
            lock <= 1'b1;
		end else begin
		    cntr <= cntr;
		end
		if (valid) begin
            lock <= 1'b0;
		end 
	end
	
endmodule
