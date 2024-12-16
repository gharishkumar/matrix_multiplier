module matrix_multiplier_16bit (
    input  logic [15:0] matA_in [1:0][1:0], // 2x2 matrix A input
    input  logic [15:0] matB_in [1:0][1:0], // 2x2 matrix B input
    output logic [31:0] result_out [1:0][1:0]  // 2x2 matrix result output
);

always_comb begin
    // Multiply matrices
    result_out[0][0] = matA_in[0][0] * matB_in[0][0] + matA_in[0][1] * matB_in[1][0];
    result_out[0][1] = matA_in[0][0] * matB_in[0][1] + matA_in[0][1] * matB_in[1][1];
    result_out[1][0] = matA_in[1][0] * matB_in[0][0] + matA_in[1][1] * matB_in[1][0];
    result_out[1][1] = matA_in[1][0] * matB_in[0][1] + matA_in[1][1] * matB_in[1][1];
end

endmodule
