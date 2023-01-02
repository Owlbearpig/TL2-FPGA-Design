`timescale 1ns / 1ps

module machine
	#(parameter pd = 12, parameter p = 22)(
	input wire [3+p-1:0] OF_fx_i, // 3Qp
	input wire [4:0] state,
	input wire clk, valid_i,
	input wire [pd+p-1:0] p0_d0_0, p0_d1_0, p0_d2_0,
	input wire [pd+p-1:0] p1_d0_0, p1_d1_0, p1_d2_0,
	input wire [pd+p-1:0] p2_d0_0, p2_d1_0, p2_d2_0,
	input wire [pd+p-1:0] p3_d0_0, p3_d1_0, p3_d2_0,
	output wire [pd+p-1:0] d0_upd_o, d1_upd_o, d2_upd_o, // goes to OF + points (global wire) pdQp
	output reg [pd+p-1:0] p0_d0, p0_d1, p0_d2,
	output reg [p+3-1:0] r_fx_o, e_fx_o, c_fx_o, p0_fx_o, p2_fx_o, p3_fx_o // 3Qp
	);
	reg [p+3-1:0] p1_fx_o; // not actually output (makes notation less confusing)
	
	wire [pd+p-1:0] d0_upd, d1_upd, d2_upd; // updated point
	wire [pd+p-1:0] ce_d0_upd, ce_d1_upd, ce_d2_upd;
	
	// points
	reg [pd+p-1:0] r_d0, r_d1, r_d2;
	reg [pd+p-1:0] c_d0, c_d1, c_d2;
	reg [pd+p-1:0] ce_d0, ce_d1, ce_d2;
	reg [pd+p-1:0] e_d0, e_d1, e_d2;
	reg [pd+p-1:0] p1_d0, p1_d1, p1_d2;
	reg [pd+p-1:0] p2_d0, p2_d1, p2_d2;
	reg [pd+p-1:0] p3_d0, p3_d1, p3_d2;	
	
	wire [pd+p-1:0] p1_d0_shrunk, p1_d1_shrunk, p1_d2_shrunk;
	wire [pd+p-1:0] p2_d0_shrunk, p2_d1_shrunk, p2_d2_shrunk;
	wire [pd+p-1:0] p3_d0_shrunk, p3_d1_shrunk, p3_d2_shrunk;	
	
	assign gnd = {34{1'b0}};
	
	initial begin
		p0_fx_o = gnd;
		p1_fx_o = gnd;
		p2_fx_o = gnd;
		p3_fx_o = gnd;
		
		// values of initial centroid is set at state 10101 
		ce_d0 = gnd; // 0.0 
		ce_d1 = gnd; // 0.0
		ce_d2 = gnd; // 0.0
	end
	/*
	integer f;
	reg [15:0] cntr = 16'b0;
	initial begin
		f = $fopen("state_debug_v1_0.txt","w");
	end
	
	always @(posedge clk) begin
		cntr = cntr + 1;
		if (cntr == 16'b11111111_11111111)
			$fclose(f);
	end
	
	always @(state) begin
		$fwrite(f, "state: %b \n", state);
		$fwrite(f, "clk cntr: %b \n\n", cntr);
	end
	
	integer f;
	reg [15:0] cntr = 16'b0;
	initial begin
		f = $fopen("display_output_machine_v2_0.txt","w");
	end
	
	always @(posedge clk) begin
		$fwrite(f, "state: %b\n", state);
		$fwrite(f, "OF_fx_i: %b \n", OF_fx_i);
		$fwrite(f, "p_r, x: [%b, %b, %b], fx %b \n", r_d0, r_d1, r_d2, r_fx_o);
		$fwrite(f, "p_e, x: [%b, %b, %b], fx %b \n", e_d0, e_d1, e_d2, e_fx_o);
		$fwrite(f, "p_c, x: [%b, %b, %b], fx %b \n", c_d0, c_d1, c_d2, c_fx_o);
		$fwrite(f, "p_ce, x: [%b, %b, %b], fx None \n", ce_d0, ce_d1, ce_d2);
		$fwrite(f, "p0, x: [%b, %b, %b], fx %b \n", p0_d0, p0_d1, p0_d2, p0_fx_o);
		$fwrite(f, "p1, x: [%b, %b, %b], fx %b \n", p1_d0, p1_d1, p1_d2, p1_fx_o);
		$fwrite(f, "p2, x: [%b, %b, %b], fx %b \n", p2_d0, p2_d1, p2_d2, p2_fx_o);
		$fwrite(f, "p3, x: [%b, %b, %b], fx %b \n", p3_d0, p3_d1, p3_d2, p3_fx_o);
		
		case(state)
			5'b10000 : $fwrite(f, "state: %b, after valid, assign initial guess, cost(p0). Next 10001 \n", state);
			5'b10001 : $fwrite(f, "state: %b, cost(p1). Next 10010 \n", state);
			5'b10010 : $fwrite(f, "state: %b, cost(p2). Next 10011 \n", state);
			5'b10011 : $fwrite(f, "state: %b, cost(p3). Next 10100 \n", state);
			5'b10100 : $fwrite(f, "state: %b, sort simplex. Next 10101 \n", state);
			5'b10101 : $fwrite(f, "state: %b, set initial centroid. Next 00000 \n", state);
			5'b00000 : $fwrite(f, "state: %b, upd(r) + cost(r) + assign. Next r_fx < p0_fx ? 00010 : 00011 \n", state);
			5'b00010 : $fwrite(f, "state: %b, upd(e) + cost(e) + assign. Next e_fx < r_fx ? 00100 : 00101 \n", state);
			5'b00011 : $fwrite(f, "state: %b, Next r_fx < p2_fx ? 00110 : 00111 \n", state);
			5'b00100 : $fwrite(f, "state: %b, expand copy(e, p3). Next 01101 \n", state);
			5'b00101 : $fwrite(f, "state: %b, reflect 1 copy(r, p3). Next 01101 \n", state);
			5'b00110 : $fwrite(f, "state: %b, reflect 2 copy(r, p3). Next 01101 \n", state);
			5'b00111 : $fwrite(f, "state: %b, Next r_fx < p3_fx ? 01000 : 01001 \n", state);
			5'b01000 : $fwrite(f, "state: %b, upd_1(c) + cost(c) + assign. Next c_fx <= r_fx ? 01010 : 01110 \n", state);
			5'b01001 : $fwrite(f, "state: %b, upd_2(c) + cost(c) + assign. Next c_fx <= p3_fx ? 01100 : 01110 \n", state);
			5'b01010 : $fwrite(f, "state: %b, contract outside copy(c, p3). Next 01101 \n", state);
			5'b01100 : $fwrite(f, "state: %b, contract inside copy(c, p3). Next 01101 \n", state);
			5'b01110 : $fwrite(f, "state: %b, break out completely, valid = 1, shrink. Next 10000 \n", state);
			5'b01101 : $fwrite(f, "state: %b, sort simplex + transform done. Next 01111 \n", state);
		endcase
		
		$fwrite(f, "clk cycle %b \n\n", cntr);
		cntr = cntr + 1;
	end
	
	always @(cntr) begin
		//$display("cntr: %b", cntr);
		if (cntr == 16'b11111111_11111111)
			$fclose(f);
			//cntr <= 8'b0;
	end
	*/
	
	always @(*) begin
		case(state)
			5'b00000 : begin
				r_d0 <= d0_upd;
				r_d1 <= d1_upd;
				r_d2 <= d2_upd;
			end
			5'b00010 : begin
				e_d0 <= d0_upd;
				e_d1 <= d1_upd;
				e_d2 <= d2_upd;
			end
			5'b01000 : begin
				c_d0 <= d0_upd;
				c_d1 <= d1_upd;
				c_d2 <= d2_upd;
			end
			5'b01001 : begin
				c_d0 <= d0_upd;
				c_d1 <= d1_upd;
				c_d2 <= d2_upd;
			end
		endcase
	end
	
	reg c0, c1, c2, c3, c4, c5, c0_min, c1_min, c2_min, c3_min, c0_max, c1_max, c2_max, c3_max;
	
	always @(posedge clk) begin
		case(state)
			// set new initial simplex and clear values
			// other points don't need to be reset(reset on valid_i) since update() only depends on centroid and simplex
			5'b11111 : begin
				p0_d0 = p0_d0_0[34-1:(34-12)-p];
				p0_d1 = p0_d1_0[34-1:(34-12)-p];
				p0_d2 = p0_d2_0[34-1:(34-12)-p];
				p0_fx_o = gnd;

				p1_d0 = p1_d0_0[34-1:(34-12)-p];
				p1_d1 = p1_d1_0[34-1:(34-12)-p];
				p1_d2 = p1_d2_0[34-1:(34-12)-p];
				p1_fx_o = gnd;

				p2_d0 = p2_d0_0[34-1:(34-12)-p];
				p2_d1 = p2_d1_0[34-1:(34-12)-p];
				p2_d2 = p2_d2_0[34-1:(34-12)-p];
				p2_fx_o = gnd;

				p3_d0 = p3_d0_0[34-1:(34-12)-p];
				p3_d1 = p3_d1_0[34-1:(34-12)-p];
				p3_d2 = p3_d2_0[34-1:(34-12)-p];
				p3_fx_o = gnd;
				
				// centroid updated at state 10101
				ce_d0 = gnd;
				ce_d1 = gnd;
				ce_d2 = gnd;
			end
			5'b10101 : begin // update centroid after simplex sort
				ce_d0 <= ce_d0_upd;
				ce_d1 <= ce_d1_upd;
				ce_d2 <= ce_d2_upd;
			end
			5'b00100 : begin // copy operations
				p3_d0 = e_d0;
				p3_d1 = e_d1;
				p3_d2 = e_d2;
				p3_fx_o = e_fx_o;
			end
			5'b00101 : begin
				p3_d0 = r_d0;
				p3_d1 = r_d1;
				p3_d2 = r_d2;
				p3_fx_o = r_fx_o;
			end
			5'b00110 : begin
				p3_d0 = r_d0;
				p3_d1 = r_d1;
				p3_d2 = r_d2;
				p3_fx_o = r_fx_o;
			end
			5'b01100 : begin
				p3_d0 = c_d0;
				p3_d1 = c_d1;
				p3_d2 = c_d2;
				p3_fx_o = c_fx_o;
			end
			5'b01010 : begin
				p3_d0 = c_d0;
				p3_d1 = c_d1;
				p3_d2 = c_d2;
				p3_fx_o = c_fx_o;
			end // set shrunk points
			5'b01110 : begin
				p1_d0 = p1_d0_shrunk;
				p1_d1 = p1_d1_shrunk;
				p1_d2 = p1_d2_shrunk;
				
				p2_d0 = p2_d0_shrunk;
				p2_d1 = p2_d1_shrunk;
				p2_d2 = p2_d2_shrunk;
				
				p3_d0 = p3_d0_shrunk;
				p3_d1 = p3_d1_shrunk;
				p3_d2 = p3_d2_shrunk;
			end
			5'b01001 : c_fx_o = OF_fx_i; 
			5'b10000 : p0_fx_o = OF_fx_i;
			5'b10001 : p1_fx_o = OF_fx_i;
			5'b10010 : p2_fx_o = OF_fx_i;
			5'b10011 : p3_fx_o = OF_fx_i;
			5'b00000 : r_fx_o = OF_fx_i;
			5'b00010 : e_fx_o = OF_fx_i;
			5'b01000 : c_fx_o = OF_fx_i;
			5'b10110 : p1_fx_o = OF_fx_i;
			5'b10111 : p2_fx_o = OF_fx_i;
			5'b11000 : p3_fx_o = OF_fx_i;
		endcase
		
		c0 <= p0_fx_o < p1_fx_o;
		c1 <= p0_fx_o < p2_fx_o;
		c2 <= p0_fx_o < p3_fx_o;
		c3 <= p1_fx_o < p2_fx_o;
		c4 <= p1_fx_o < p3_fx_o;
		c5 <= p2_fx_o < p3_fx_o;
		c0_min = (p0_fx_o < p1_fx_o) & (p0_fx_o < p2_fx_o) & (p0_fx_o < p3_fx_o);
		c1_min = (p1_fx_o < p2_fx_o) & (p1_fx_o < p3_fx_o) & ~(p0_fx_o < p1_fx_o);
		c2_min = ~(p0_fx_o < p2_fx_o) & ~(p1_fx_o < p2_fx_o) & (p2_fx_o < p3_fx_o);
		c3_min = ~(p0_fx_o < p3_fx_o) & ~(p1_fx_o < p3_fx_o) & ~(p2_fx_o < p3_fx_o);
		c0_max = ~(p0_fx_o < p1_fx_o) & ~(p0_fx_o < p2_fx_o) & ~(p0_fx_o < p3_fx_o);
		c1_max = ~(p1_fx_o < p2_fx_o) & ~(p1_fx_o < p3_fx_o) & (p0_fx_o < p1_fx_o);
		c2_max = (p0_fx_o < p2_fx_o) & (p1_fx_o < p2_fx_o) & ~(p2_fx_o < p3_fx_o);
		c3_max = (p2_fx_o < p3_fx_o) & (p1_fx_o < p3_fx_o) & (p0_fx_o < p3_fx_o);
		
		// Sorts simplex. Refer to python script (sort_test.py)
		if (state == 5'b10100) begin // or swap state... TODO simplify if else with tt expr
			// set first spot, smallest value
			if (c0_min) begin // TODO add coords too.. done
				p0_fx_o <= p0_fx_o;
				p0_d0 <= p0_d0;
				p0_d1 <= p0_d1;
				p0_d2 <= p0_d2;
			end else if (c1_min) begin
				p0_fx_o <= p1_fx_o;
				p0_d0 <= p1_d0;
				p0_d1 <= p1_d1;
				p0_d2 <= p1_d2;
			end else if (c2_min) begin
				p0_fx_o <= p2_fx_o;
				p0_d0 <= p2_d0;
				p0_d1 <= p2_d1;
				p0_d2 <= p2_d2;
			end else begin // (c3_min):
				p0_fx_o <= p3_fx_o;
				p0_d0 <= p3_d0;
				p0_d1 <= p3_d1;
				p0_d2 <= p3_d2;
			end
				
			// set last spot, largest value
			if (c0_max) begin
				p3_fx_o <= p0_fx_o;
				p3_d0 <= p0_d0;
				p3_d1 <= p0_d1;
				p3_d2 <= p0_d2;
			end else if (c1_max) begin
				p3_fx_o <= p1_fx_o;
				p3_d0 <= p1_d0;
				p3_d1 <= p1_d1;
				p3_d2 <= p1_d2;
			end else if (c2_max) begin
				p3_fx_o <= p2_fx_o;
				p3_d0 <= p2_d0;
				p3_d1 <= p2_d1;
				p3_d2 <= p2_d2;
			end else begin // (c3_max)
				p3_fx_o <= p3_fx_o;
				p3_d0 <= p3_d0;
				p3_d1 <= p3_d1;
				p3_d2 <= p3_d2;
			end
			
			// set p1_fx_o, p2_fx_o; middle spots
			// case where p0_fx_o and p1_fx_o are already placed
			if ((c0_min | c0_max) & (c1_min | c1_max)) begin  
				if ((c5)) begin
					p1_fx_o <= p2_fx_o;
					p1_d0 <= p2_d0;
					p1_d1 <= p2_d1;
					p1_d2 <= p2_d2;
					p2_fx_o <= p3_fx_o;
					p2_d0 <= p3_d0;
					p2_d1 <= p3_d1;
					p2_d2 <= p3_d2;
				end else begin
					p1_fx_o <= p3_fx_o;
					p1_d0 <= p3_d0;
					p1_d1 <= p3_d1;
					p1_d2 <= p3_d2;
					p2_fx_o <= p2_fx_o;
					p2_d0 <= p2_d0;
					p2_d1 <= p2_d1;
					p2_d2 <= p2_d2;
				end
			// case where p0_fx_o and p2_fx_o are already placed
			end else if ((c0_min | c0_max) & (c2_min | c2_max)) begin  
				if (c4) begin
					p1_fx_o <= p1_fx_o;
					p1_d0 <= p1_d0;
					p1_d1 <= p1_d1;
					p1_d2 <= p1_d2;
					p2_fx_o <= p3_fx_o;
					p2_d0 <= p3_d0;
					p2_d1 <= p3_d1;
					p2_d2 <= p3_d2;
				end else begin
					p1_fx_o <= p3_fx_o;
					p1_d0 <= p3_d0;
					p1_d1 <= p3_d1;
					p1_d2 <= p3_d2;
					p2_fx_o <= p1_fx_o;
					p2_d0 <= p1_d0;
					p2_d1 <= p1_d1;
					p2_d2 <= p1_d2;
				end
			// case where p1_fx_o and p2_fx_o are already placed
			end else if ((c0_min | c0_max) & (c3_min | c3_max)) begin  
				if (c3) begin
					p1_fx_o <= p1_fx_o;
					p1_d0 <= p1_d0;
					p1_d1 <= p1_d1;
					p1_d2 <= p1_d2;
					p2_fx_o <= p2_fx_o;
					p2_d0 <= p2_d0;
					p2_d1 <= p2_d1;
					p2_d2 <= p2_d2;
				end else begin
					p1_fx_o <= p2_fx_o;
					p1_d0 <= p2_d0;
					p1_d1 <= p2_d1;
					p1_d2 <= p2_d2;
					p2_fx_o <= p1_fx_o;
					p2_d0 <= p1_d0;
					p2_d1 <= p1_d1;
					p2_d2 <= p1_d2;
				end 
			// case where p1_fx_o and p2_fx_o are already placed;
			end else if ((c1_min | c1_max) & (c2_min | c2_max)) begin  
				if (c2) begin
					p1_fx_o <= p0_fx_o;
					p1_d0 <= p0_d0;
					p1_d1 <= p0_d1;
					p1_d2 <= p0_d2;
					p2_fx_o <= p3_fx_o;
					p2_d0 <= p3_d0;
					p2_d1 <= p3_d1;
					p2_d2 <= p3_d2;
				end else begin
					p1_fx_o <= p3_fx_o;
					p1_d0 <= p3_d0;
					p1_d1 <= p3_d1;
					p1_d2 <= p3_d2;
					p2_fx_o <= p0_fx_o;
					p2_d0 <= p0_d0;
					p2_d1 <= p0_d1;
					p2_d2 <= p0_d2;
				end
			// case where p1_fx_o and p3_fx_o are already placed
			end else if ((c1_min | c1_max) & (c3_min | c3_max)) begin  
				if (c1) begin
					p1_fx_o <= p0_fx_o;
					p1_d0 <= p0_d0;
					p1_d1 <= p0_d1;
					p1_d2 <= p0_d2;
					p2_fx_o <= p2_fx_o;
					p2_d0 <= p2_d0;
					p2_d1 <= p2_d1;
					p2_d2 <= p2_d2;
				end else begin
					p1_fx_o <= p2_fx_o;
					p1_d0 <= p2_d0;
					p1_d1 <= p2_d1;
					p1_d2 <= p2_d2;
					p2_fx_o <= p0_fx_o;
					p2_d0 <= p0_d0;
					p2_d1 <= p0_d1;
					p2_d2 <= p0_d2;
				end
			// (c2_min or c2_max) and (c3_min or c3_max):  # case where  p2_fx_o and p3_fx_o are already placed
			end else begin
				if (c0) begin
					p1_fx_o <= p0_fx_o;
					p1_d0 <= p0_d0;
					p1_d1 <= p0_d1;
					p1_d2 <= p0_d2;
					p2_fx_o <= p1_fx_o;
					p2_d0 <= p1_d0;
					p2_d1 <= p1_d1;
					p2_d2 <= p1_d2;
				end else begin
					p1_fx_o <= p1_fx_o;
					p1_d0 <= p1_d0;
					p1_d1 <= p1_d1;
					p1_d2 <= p1_d2;
					p2_fx_o <= p0_fx_o;
					p2_d0 <= p0_d0;
					p2_d1 <= p0_d1;
					p2_d2 <= p0_d2;
				end
			end
		end else begin
			p0_d0 = p0_d0;
			p0_d1 = p0_d1;
			p0_d2 = p0_d2;
			p0_fx_o = p0_fx_o;

			p1_d0 = p1_d0;
			p1_d1 = p1_d1;
			p1_d2 = p1_d2;
			p1_fx_o = p1_fx_o;

			p2_d0 = p2_d0;
			p2_d1 = p2_d1;
			p2_d2 = p2_d2;
			p2_fx_o = p2_fx_o;
			
			p3_d0 = p3_d0;
			p3_d1 = p3_d1;
			p3_d2 = p3_d2;
			p3_fx_o = p3_fx_o;
			
			ce_d0 = ce_d0;
			ce_d1 = ce_d1;
			ce_d2 = ce_d2;
		end
	end

    // upd_pnt: (1+lambda)*ce - lambda*p3
	// TODO fix states done v1
	assign d0_upd = (state == 5'b00000) ? (ce_d0 + ce_d0) - p3_d0 : // updated r , (1+1)*ce - 1*p3 (lambda=1)
					(state == 5'b00010) ? (ce_d0 + ce_d0 + ce_d0) - (p3_d0 + p3_d0) : // updated e (1+2)*ce - 2*p3 (lambda=2)
					(state == 5'b01000) ? ce_d0 + (ce_d0 >> 1) - (p3_d0 >> 1) : // updated c 1 (1+0.5)*ce - 0.5*p3 (lambda=0.5)
					(state == 5'b01001) ? (ce_d0 >> 1) + (p3_d0 >> 1) : // updated c 2 (1-0.5)*ce + 0.5*p3 (lambda=-0.5)
					(state == 5'b10000) ? p0_d0 :
					(state == 5'b10001) ? p1_d0 :
					(state == 5'b10010) ? p2_d0 :
					(state == 5'b10011) ? p3_d0 :
					(state == 5'b10110) ? p1_d0 :
					(state == 5'b10111) ? p2_d0 :
					(state == 5'b11000) ? p3_d0 :
					{pd+p{1'b0}};
	assign d1_upd = (state == 5'b00000) ? (ce_d1 + ce_d1) - p3_d1 : // updated r
					(state == 5'b00010) ? (ce_d1 + ce_d1 + ce_d1) - (p3_d1 + p3_d1) : // updated e
					(state == 5'b01000) ? ce_d1 + (ce_d1 >> 1) - (p3_d1 >> 1) : // updated c 1
					(state == 5'b01001) ? (ce_d1 >> 1) + (p3_d1 >> 1) : // updated c 2
					(state == 5'b10000) ? p0_d1 :
					(state == 5'b10001) ? p1_d1 :
					(state == 5'b10010) ? p2_d1 :
					(state == 5'b10011) ? p3_d1 :
					(state == 5'b10110) ? p1_d1 :
					(state == 5'b10111) ? p2_d1 :
					(state == 5'b11000) ? p3_d1 :
					{pd+p{1'b0}};
	assign d2_upd = (state == 5'b00000) ? (ce_d2 + ce_d2) - p3_d2 : // updated r
					(state == 5'b00010) ? (ce_d2 + ce_d2 + ce_d2) - (p3_d2 + p3_d2) : // updated e
					(state == 5'b01000) ? ce_d2 + (ce_d2 >> 1) - (p3_d2 >> 1) : // updated c 1
					(state == 5'b01001) ? (ce_d2 >> 1) + (p3_d2 >> 1) : // updated c 2
					(state == 5'b10000) ? p0_d2 :
					(state == 5'b10001) ? p1_d2 :
					(state == 5'b10010) ? p2_d2 :
					(state == 5'b10011) ? p3_d2 :
					(state == 5'b10110) ? p1_d2 :
					(state == 5'b10111) ? p2_d2 :
					(state == 5'b11000) ? p3_d2 :
					{pd+p{1'b0}};
	
    assign d0_upd_o = d0_upd; // TODO fix/check lengths this needs two steps. Done v1
    assign d1_upd_o = d1_upd;
    assign d2_upd_o = d2_upd;
	
	// centroid update
	wire [22-1:0] recip_3;
	assign recip_3 = 22'b0101010101010101010101; // 1/3 0Q22
	
	wire [p-1:0] recip_3_p;
	assign recip_3_p = recip_3[22-1:22-p];
	
	wire [pd+p+2-1:0] d0_sum, d1_sum, d2_sum; // sum of d0 + d1 + d2  (pd+2)Qp, 2 additions
	
	wire [pd+p+2+p-1:0] m0_tmp, m1_tmp, m2_tmp; // d0_sum * recip_3_p
		
	assign d0_sum = (p0_d0 + p1_d0 + p2_d0);
	assign d1_sum = (p0_d1 + p1_d1 + p2_d1);
	assign d2_sum = (p0_d2 + p1_d2 + p2_d2);
	
	assign m0_tmp = d0_sum * recip_3_p; // pd+2Q(2*p)
	assign m1_tmp = d1_sum * recip_3_p;
	assign m2_tmp = d2_sum * recip_3_p;
	
	assign ce_d0_upd = m0_tmp[pd+p+p:p]; // TODO might be wrong v1 should be 12Q17 out. Seems OK. Done
	assign ce_d1_upd = m1_tmp[pd+p+p:p];
	assign ce_d2_upd = m2_tmp[pd+p+p:p];
	
	// shrunk simplex
	assign p1_d0_shrunk = p0_d0 + (p1_d0 >> 1) - (p0_d0 >> 1);
	assign p1_d1_shrunk = p0_d1 + (p1_d1 >> 1) - (p0_d1 >> 1);
	assign p1_d2_shrunk = p0_d2 + (p1_d2 >> 1) - (p0_d2 >> 1);
	
	assign p2_d0_shrunk = p0_d0 + (p2_d0 >> 1) - (p0_d0 >> 1);
	assign p2_d1_shrunk = p0_d1 + (p2_d1 >> 1) - (p0_d1 >> 1);
	assign p2_d2_shrunk = p0_d2 + (p2_d2 >> 1) - (p0_d2 >> 1);
	
	assign p3_d0_shrunk = p0_d0 + (p3_d0 >> 1) - (p0_d0 >> 1);
	assign p3_d1_shrunk = p0_d1 + (p3_d1 >> 1) - (p0_d1 >> 1);
	assign p3_d2_shrunk = p0_d2 + (p3_d2 >> 1) - (p0_d2 >> 1);
	
	
endmodule
