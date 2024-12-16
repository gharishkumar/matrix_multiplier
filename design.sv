module matrix_multiplier_16bit (
    input  logic [15:0] matA_in [1:0][1:0], // 2x2 matrix A input
    input  logic [15:0] matB_in [1:0][1:0], // 2x2 matrix B input
    output logic [32:0] result_out [1:0][1:0]  // 2x2 matrix result output 33 bit as
                                               // FFFF x FFFF + FFFF X FFFF = 1 FFFC 0002
);

always_comb begin
    // Multiply matrices
    result_out[0][0] = matA_in[0][0] * matB_in[0][0] + matA_in[0][1] * matB_in[1][0];
    result_out[0][1] = matA_in[0][0] * matB_in[0][1] + matA_in[0][1] * matB_in[1][1];
    result_out[1][0] = matA_in[1][0] * matB_in[0][0] + matA_in[1][1] * matB_in[1][0];
    result_out[1][1] = matA_in[1][0] * matB_in[0][1] + matA_in[1][1] * matB_in[1][1];
end

endmodule
