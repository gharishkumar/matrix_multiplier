module matrix_multiplication(
    input logic [31:0] A[1:0][1:0],  // 2x2 matrix A
    input logic [31:0] B[1:0][1:0],  // 2x2 matrix B
    output logic [31:0] C[1:0][1:0]  // Resultant 2x2 matrix C
);

    always_comb begin
        // Perform matrix multiplication
        C[0][0] = A[0][0] * B[0][0] + A[0][1] * B[1][0];
        C[0][1] = A[0][0] * B[0][1] + A[0][1] * B[1][1];
        C[1][0] = A[1][0] * B[0][0] + A[1][1] * B[1][0];
        C[1][1] = A[1][0] * B[0][1] + A[1][1] * B[1][1];
    end

endmodule
