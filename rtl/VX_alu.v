
`include "VX_define.v"

module VX_alu(
	input wire[31:0]  in_1,
	input wire[31:0]  in_2,
	input wire        in_rs2_src,
	input wire[31:0]  in_itype_immed,
	input wire[19:0]  in_upper_immed,
	input wire[4:0]   in_alu_op,
	input wire[31:0]  in_csr_data, // done
	input wire[31:0]  in_curr_PC,
	output wire[31:0]  out_alu_result
	);


		wire which_in2;

		wire[31:0] ALU_in1;
		wire[31:0] ALU_in2;
		wire[31:0] upper_immed;


		assign which_in2  = in_rs2_src == `RS2_IMMED;

		assign ALU_in1 = in_1;

		assign ALU_in2 = which_in2 ? in_itype_immed : in_2;


		assign upper_immed = {in_upper_immed, {12{1'b0}}};



		// always @(*) begin
		// 	$display("EXECUTE CURR_PC: %h",in_curr_PC);
		// end

		/* verilator lint_off UNUSED */
		wire[63:0] mult_unsigned_result  = ALU_in1 * ALU_in2;
		wire[63:0] mult_signed_result    = $signed(ALU_in1) * $signed(ALU_in2);

		wire[63:0] alu_in1_signed = {{32{ALU_in1[31]}}, ALU_in1};

		wire[63:0] mult_signed_un_result = alu_in1_signed * ALU_in2;
		/* verilator lint_on UNUSED */
		
		reg[31:0] use_out_alu_result;

		always @(*) begin
			case(in_alu_op)
				`ADD:        use_out_alu_result = $signed(ALU_in1) + $signed(ALU_in2);
				`SUB:        use_out_alu_result = $signed(ALU_in1) - $signed(ALU_in2);
				`SLLA:       use_out_alu_result = ALU_in1 << ALU_in2[4:0];
				`SLT:        use_out_alu_result = ($signed(ALU_in1) < $signed(ALU_in2)) ? 32'h1 : 32'h0;
				`SLTU:       use_out_alu_result = ALU_in1 < ALU_in2 ? 32'h1 : 32'h0;
				`XOR:        use_out_alu_result = ALU_in1 ^ ALU_in2;
				`SRL:        use_out_alu_result = ALU_in1 >> ALU_in2[4:0];						
				`SRA:        use_out_alu_result = $signed(ALU_in1)  >>> ALU_in2[4:0];
				`OR:         use_out_alu_result = ALU_in1 | ALU_in2;	
				`AND:        use_out_alu_result = ALU_in2 & ALU_in1;	
				`SUBU:       use_out_alu_result = (ALU_in1 >= ALU_in2) ? 32'h0 : 32'hffffffff;
				`LUI_ALU:    use_out_alu_result = upper_immed;
				`AUIPC_ALU:  use_out_alu_result = $signed(in_curr_PC) + $signed(upper_immed);
				`CSR_ALU_RW: use_out_alu_result = in_csr_data;
				`CSR_ALU_RS: use_out_alu_result = in_csr_data;
				`CSR_ALU_RC: use_out_alu_result = in_csr_data;
				`MUL:        begin use_out_alu_result = mult_signed_result[31:0]; end
				`MULH:       use_out_alu_result = mult_signed_result[63:32];
				`MULHSU:     use_out_alu_result = mult_signed_un_result[63:32];
				`MULHU:      use_out_alu_result = mult_unsigned_result[63:32];
				`DIV:        use_out_alu_result = (ALU_in2 == 0) ? 32'hffffffff : $signed($signed(ALU_in1) / $signed(ALU_in2));
				`DIVU:       use_out_alu_result = (ALU_in2 == 0) ? 32'hffffffff : ALU_in1 / ALU_in2;
				`REM:        use_out_alu_result = (ALU_in2 == 0) ? ALU_in1 : $signed($signed(ALU_in1) % $signed(ALU_in2));
				`REMU:       use_out_alu_result = (ALU_in2 == 0) ? ALU_in1 : ALU_in1 % ALU_in2;
				default: use_out_alu_result = 32'h0;
			endcase // in_alu_op
		end
	assign out_alu_result = use_out_alu_result;

endmodule // VX_alu