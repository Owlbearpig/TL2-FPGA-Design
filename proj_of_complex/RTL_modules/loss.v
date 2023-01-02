`timescale 1ns / 1ps

module loss
	#(parameter p = 22)(
    input clk,
	input wire signed [3+p-1:0] r_enum_real, r_enum_imag, r_denum, // 3Qp
    input wire signed [6*3+6*p-1:0] cur_data_real, // 6 x 3Qp
	input wire signed [6*3+6*p-1:0] cur_data_imag, // 6 x 3Qp
    input wire busy,
    output wire valid,
    output wire [3+p-1:0] o_total_loss // 3Qp
	//output wire [4+p-1:0] o_total_loss // 3Qp
    );
    
    wire signed [3+p-1:0] r0_real, r0_imag;
	wire signed [2*(3+p)-1:0] cd_real_norm, cd_imag_norm; // current data "normalized"
	wire signed [3+p-1:0] cd_real_norm_pw, cd_imag_norm_pw;
    reg [3:0] cntr = 4'b0000;
	reg [2*3+2*p-1:0] s;
    wire [2*(3+p)-1:0] diff_sqr_real, diff_sqr_imag; // (2*dp)Q(2*p)
	reg [2*(3+p)-1:0] r_total_loss = {6+2*p{1'b0}}; // (2*dp)Q(2*p)
	//reg [2*(4+p)-1:0] r_total_loss = {8+2*p{1'b0}}; // (2*dp)Q(2*p)
	
	/*
	always @(posedge clk) begin
		$display("r_enum_real: %b", r_enum_real);
		$display("r_enum_imag: %b", r_enum_imag);
		$display("r_denum: %b", r_denum);
	end
	*/
	
	// experimental data array
	assign r0_real = (cntr == 4'b0001) ? cur_data_real[(3+p)*5+:3+p] :
					(cntr == 4'b0010) ? cur_data_real[(3+p)*4+:3+p] :
					(cntr == 4'b0011) ? cur_data_real[(3+p)*3+:3+p] :
					(cntr == 4'b0100) ? cur_data_real[(3+p)*2+:3+p] :
					(cntr == 4'b0101) ? cur_data_real[(3+p)*1+:3+p] :
					(cntr == 4'b0110) ? cur_data_real[(3+p)*0+:3+p] :
					{p{1'b0}};
	
	assign r0_imag = (cntr == 4'b0001) ? cur_data_imag[(3+p)*5+:3+p] :
					(cntr == 4'b0010) ? cur_data_imag[(3+p)*4+:3+p] :
					(cntr == 4'b0011) ? cur_data_imag[(3+p)*3+:3+p] :
					(cntr == 4'b0100) ? cur_data_imag[(3+p)*2+:3+p] :
					(cntr == 4'b0101) ? cur_data_imag[(3+p)*1+:3+p] :
					(cntr == 4'b0110) ? cur_data_imag[(3+p)*0+:3+p] :
					{p{1'b0}};
	
	assign cd_real_norm = r0_real * r_denum;
	assign cd_imag_norm = r0_imag * r_denum;
	
	assign cd_real_norm_pw = cd_real_norm[3+2*p:p];
	assign cd_imag_norm_pw = cd_imag_norm[3+2*p:p];
	
	assign diff_sqr_real = (r_enum_real-cd_real_norm_pw)*(r_enum_real-cd_real_norm_pw);
	assign diff_sqr_imag = (r_enum_imag-cd_imag_norm_pw)*(r_enum_imag-cd_imag_norm_pw);
	
	/* //debugging begin
	integer f;
	reg [7:0] log_cntr = 8'b0;
	initial begin
		f = $fopen("display_output_loss_after.txt","w");
	end
	
	always @(posedge clk) begin
		$fwrite(f, "cur_data_real, %b\n", cur_data_real);
		$fwrite(f, "cur_data_imag, %b\n", cur_data_imag);
		$fwrite(f, "r0_real, %b\n", r0_real);
		$fwrite(f, "r0_imag, %b\n", r0_imag);
		$fwrite(f, "r_denum, %b\n", r_denum);
		$fwrite(f, "cd_real_norm_pw, %b\n", cd_real_norm_pw);
		$fwrite(f, "cd_imag_norm_pw, %b\n", cd_imag_norm_pw);
		$fwrite(f, "r_enum_real, %b\n", r_enum_real);
		$fwrite(f, "r_enum_imag, %b\n", r_enum_imag);
		$fwrite(f, "diff_sqr_real, %b\n", diff_sqr_real);
		$fwrite(f, "diff_sqr_imag, %b\n", diff_sqr_imag);
		$fwrite(f, "r_total_loss, %b\n", r_total_loss);
		$fwrite(f, "cntr, %b\n", cntr);
		$fwrite(f, "o_total_loss, %b\n", o_total_loss);
		$fwrite(f, "clk cycle %b done \n\n", log_cntr);
		log_cntr <= log_cntr + 1;
	end
	
	always @(posedge clk) begin
		$fwrite(f, "busy, %b\n", busy);
		$fwrite(f, "temp_loss, %b\n", temp_loss);
		$fwrite(f, "loss_buffer, %b\n", loss_buffer);
		$fwrite(f, "latched, %b\n", latched);
		$fwrite(f, "r_total_loss, %b\n", r_total_loss);
		$fwrite(f, "cntr, %b\n", cntr);
		$fwrite(f, "o_total_loss, %b\n", o_total_loss);
		$fwrite(f, "clk cycle %b done \n\n", log_cntr);
		log_cntr <= log_cntr + 1;
	end
	
	
	always @(log_cntr) begin
		if (log_cntr == 8'b01011010)
			$fclose(f);
			//log_cntr <= 8'b0;
	end
	
	reg [7:0] clk_cntr = 8'b0;
	always @(posedge clk) begin
		clk_cntr <= clk_cntr + 1;
	end
	
	always @(o_total_loss) begin
		$display("o_total_loss: %b, clk_cntr: %d", o_total_loss, clk_cntr);
	end
	*/ //debugging end
	
    always @(posedge clk) begin
        if (busy) begin
            cntr = cntr + 1;
            if (cntr >= 4'b0001) begin
                r_total_loss <= r_total_loss + (diff_sqr_real >> 1) + (diff_sqr_imag >> 1);
            end else begin
				r_total_loss <= r_total_loss;
			end
        end else begin
            cntr = 4'b0;
			r_total_loss <= {6+2*p{1'b0}}; // reset
			//r_total_loss <= {8+2*p{1'b0}}; // reset
        end      
    end
	
	assign valid = (cntr == 4'b0110) ? 1'b1 : 1'b0;
	
	wire [2*(3+p)-1:0] temp_loss;
	//wire [2*(4+p)-1:0] temp_loss;
	reg [3+p-1:0] loss_buffer = {3+p{1'b0}};
	//reg [4+p-1:0] loss_buffer = {4+p{1'b0}};
	
	// should hold the output for another cycle
	reg latched = 1'b0;
	always @(posedge clk) begin
		if (valid) begin
			loss_buffer = temp_loss[3+2*p:p];
			//loss_buffer = temp_loss[4+2*p:p];
			latched <= 1'b1;
		end else
			latched <= 1'b0;
	end
	
	
	assign temp_loss = r_total_loss + (diff_sqr_real >> 1) + (diff_sqr_imag >> 1);
	assign o_total_loss = temp_loss[3+2*p:p];
    /*
	assign o_total_loss = (valid) ? temp_loss[3+2*p:p] : 
	//assign o_total_loss = (valid) ? temp_loss[4+2*p:p] : 
						  (latched) ? loss_buffer :
						  loss_buffer;//{3+p{1'b0}};
	*/
	
endmodule
