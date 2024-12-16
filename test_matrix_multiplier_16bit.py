import cocotb
from cocotb.triggers import Timer
from cocotb.regression import TestFactory
import numpy as np

import numpy as np

def print_matrix_hex(matrix):
    """Print a NumPy array or list of lists in hexadecimal format."""
    if isinstance(matrix, list):
        matrix = np.array(matrix)  # Convert to NumPy array if needed
    print("[")
    for row in matrix:
        print("["+" ".join(f"{val:04X}" for val in row) + "]")  # Format as 4-digit hex
    print("]")

@cocotb.test()
async def test_matrix_multiplier_16bit(dut):
    # Number of tests to run
    num_tests = 2

    for _ in range(num_tests):
        # Generate random input matrices using numpy
        A = np.random.randint(0, 65536, size=(2, 2), dtype=np.uint64)
        B = np.random.randint(0, 65536, size=(2, 2), dtype=np.uint64)

        # Assign inputs to the DUT
        for i in range(2):
            for j in range(2):
                dut.matA_in[i][j].value = int(A[i][j])
                dut.matB_in[i][j].value = int(B[i][j])

        # Wait for some time to allow for multiplication to occur
        await Timer(10, units='ns')

        # Compute the expected result using numpy
        C_expected = np.dot(A, B)

        # Check the result
        for i in range(2):
            for j in range(2):
                assert dut.result_out[i][j].value == int(C_expected[i][j]), \
                    f"Test failed with A={A}, B={B}. Expected result [{i}] [{j}] {int(C_expected[i][j])}, got {int(dut.result_out[i][j].value)}"
        
        # Print the results of the current test
        print(f"Test passed with ")
            # Print matrices in hex
        print("Matrix A:")
        print_matrix_hex(A)

        print("Matrix B:")
        print_matrix_hex(B)

        print("Expected Result:")
        print_matrix_hex(C_expected)



# Create a TestFactory and register the test
factory = TestFactory(test_matrix_multiplier_16bit)
factory.generate_tests()
