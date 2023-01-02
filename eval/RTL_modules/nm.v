`timescale 1ns / 1ps

module nm
	#(parameter pd = 12, parameter p = 22)(
	input wire [pd+p-1:0] p0_d0_i, p0_d1_i, p0_d2_i,
	input wire [3+p-1:0] OF_fx_i, // 3Qp
	input wire [3+p-1:0] p0_fx, p2_fx, p3_fx, r_fx, e_fx, c_fx, // from machine, current fx vals.
	input wire busy, clk, enhance_i, eval_done_i,
    output reg [4:0] state,
	output wire [pd+p-1:0] d0_res, d1_res, d2_res,
	output wire [3+p-1:0] fx_res,
	//output wire valid_o,
	output reg valid_o,
	output reg [7:0] iter_cnt
	);
	
	wire valid;
	reg [4:0] nextstate; 
	initial state = 5'b11111; // initial state
	initial iter_cnt = 8'b0;
	
	localparam max_iters_std = 8'b00001111;
	localparam max_iters_enh = 8'b00110010;
	
	//wire [7:0] max_iters;
	//assign max_iters = (enhance_i) ? 8'b00110010 : 8'b00001111; // do 15 iterations if not enhance else 50
	reg [7:0] max_iters = max_iters_std;
	always @(enhance_i, eval_done_i) begin
		if (enhance_i) begin
			max_iters = max_iters_enh;
		end else if(eval_done_i) begin
			max_iters = max_iters_std;
		end else begin
			max_iters = max_iters;
		end
	end
	/*
	always @(*) begin
		$display("iter_cnt, %d", iter_cnt);
		$display("max_iters, %d", max_iters);
		$display("enhance_i, %d", enhance_i);
	end
	*/
	//reg [7:0] max_iters = 8'b00001111; //reg [7:0] max_iters = 8'b00110010;
	
	always @(posedge clk) begin
		if ((iter_cnt == max_iters)) begin
			valid_o <= 1'b1;
		end else begin
			valid_o <= 1'b0;
		end
	end
	// output is valid if we reach max_iters iterations
	assign valid = (iter_cnt == max_iters) ? 1'b1 : 1'b0;
	
	/*
	integer f;
	reg [15:0] cntr = 16'b0;
	initial begin
		f = $fopen("display_output_nm_v2_0.txt","w");
	end
	
	always @(OF_fx_i) begin
		$display("OF_fx_i: %b, p0_fx: %b, cntr: %d", OF_fx_i, p0_fx, cntr);
	end
	
	always @(posedge clk) begin
		$fwrite(f, "state: %b\n", state);
		$fwrite(f, "iter_cnt: %b\n", iter_cnt);
		$fwrite(f, "clk cycle %b \n\n", cntr);
		cntr = cntr + 1;
	end
	
	always @(cntr) begin
		$display("cntr: %b", cntr);
		if (cntr == 16'b11111111_11111111)
			$fclose(f);
	end
	*/
	// TODO compare p0_fx of current with last iteration. 
	
	
	always @(posedge clk) begin
		if (state == 5'b10100) begin // TODO fix this done v1. cnt when we finish an iteration
			iter_cnt = iter_cnt + 1;
		end else begin
			iter_cnt = iter_cnt;
		end
		
		// always block to update state (set nextstate/step)
		if (valid_o) begin
			state <= 5'b11111;
			iter_cnt <= 8'b0;
		end else begin
			state <= nextstate;
		end
	end
	
	
	/*
	always @(state, valid) begin
		if (state == 5'b00000) begin // TODO fix this done v1. cnt when we finish an iteration
			iter_cnt <= iter_cnt + 1;
		end else begin
			iter_cnt <= iter_cnt;
		end
		
		if (valid) begin
			iter_cnt <= 8'b0;
		end
	end
	*/
	/*
	always @(posedge clk) begin // always block to update state
		if (valid) begin
			state <= 5'b11111; // reset (on valid)
		end else begin
			state <= nextstate;
		end
	end
	*/
	
	//always @(busy) begin
	//	$display("BUSY: OF_fx_i: %b, cntr: %d \n", OF_fx_i, cntr);
	//end
	
	// Note: if there are problems with timings of when conditional expressions are evaluated add last changing signal to sensitivity list.
	always @(state or valid_o or busy or OF_fx_i or eval_done_i or valid) begin // always-block to decide nextstate
		if (~busy & ~valid_o & ~eval_done_i & ~valid) begin
			case(state) 
				// initial simplex + initial centroid
				5'b11111 : nextstate <= 5'b10000; // initial simplex
				5'b10000 : nextstate <= 5'b10001; // simplex p0.fx 
				5'b10001 : nextstate <= 5'b10010; // simplex p1.fx
				5'b10010 : nextstate <= 5'b10011; // simplex p2.fx
				5'b10011 : nextstate <= 5'b10100; // simplex p3.fx
				5'b10100 : nextstate <= 5'b10101; // sort simplex
				5'b10101 : nextstate <= 5'b00000; // update centroid (centroid has no fx)
				5'b00000 : begin // 5'b00000 start of transformations, update r
					if (OF_fx_i < p0_fx) begin
						nextstate <= 5'b00010; // state 2 update e
					end else begin
						nextstate <= 5'b00011; // state 3 r_fx => p0_fx
					end
				end
				5'b00010 : begin
					if (OF_fx_i < r_fx) begin
						nextstate <= 5'b00100; // state 4 expand
					end else begin
						nextstate <= 5'b00101; // state 5 reflect 1
					end
				end
				5'b00100 : nextstate <= 5'b10100; // state 13 Bottom of iteration(transform done) (Swap, centroid upd) TODO Done v1
				5'b00101 : nextstate <= 5'b10100; // state 13 transform done
				5'b00011 : begin
					if (r_fx < p2_fx) begin
						nextstate <= 5'b00110; // state 6 reflect 2
					end else begin
						nextstate <= 5'b00111; // state 7 r_fx => p2_fx
					end
				end
				5'b00110 : nextstate <= 5'b10100; // state 13 transform done
				5'b00111 : begin
					if (r_fx < p3_fx) begin
						//$display("r_fx: %b, p3_fx: %b", r_fx, p3_fx);
						nextstate <= 5'b01000; // state 8 update c (update c1)
					end else begin
						nextstate <= 5'b01001; // state 9 r_fx => p3_fx update c (update c2)
					end
				end
				5'b01000 : begin
					if (OF_fx_i <= r_fx) begin
						nextstate <= 5'b01010; // state 10 contract outside
					end else begin
						nextstate <= 5'b01110; // state 14 shrink TODO
					end
				end
				5'b01010 : nextstate <= 5'b10100; // state 13 transform done
				5'b01001 : begin
					if (OF_fx_i <= p3_fx) begin
						nextstate <= 5'b01100; // state 12 contract inside
					end else begin
						nextstate <= 5'b01110; // state 14 shrink TODO
					end
				end
				5'b01100 : nextstate <= 5'b10100; // state 13 transform done
				
				// shrink routine
				5'b01110 : nextstate <= 5'b10110; // assign shrunken values 
				5'b10110 : nextstate <= 5'b10111; // simplex p1.fx for shrunk values
				5'b10111 : nextstate <= 5'b11000; // simplex p2.fx for shrunk values
				5'b11000 : nextstate <= 5'b10100; // simplex p3.fx for shrunk values
				
				default : nextstate <= 5'b00000; // if nothing else restart transformations
				
			endcase
		end else begin
			nextstate <= state; // if still busy stay in same state.
		end
    end
	
	assign fx_res = valid_o ? p0_fx : {3+p{1'b0}};
	assign d0_res = valid_o ? p0_d0_i : {pd+p{1'b0}};
	assign d1_res = valid_o ? p0_d1_i : {pd+p{1'b0}};
	assign d2_res = valid_o ? p0_d2_i : {pd+p{1'b0}};
	
	//assign valid_o = valid;
	
endmodule
