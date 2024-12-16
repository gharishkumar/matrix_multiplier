import cocotb
from cocotb.triggers import Timer
from cocotb.regression import TestFactory
import numpy as np

@cocotb.test()
async def test_matrix_multiplier_16bit(dut):
    # Number of tests to run
    num_tests = 10

    for _ in range(num_tests):
        # Generate random input matrices using numpy
        A = np.random.randint(0, 255, size=(2, 2))
        B = np.random.randint(0, 255, size=(2, 2))

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
                    f"Test failed with A={A}, B={B}. Expected {int(C_expected[i][j])}, got {int(dut.result_out[i][j].value)}"
        
        # Print the results of the current test
        print(f"Test passed with A={A}, B={B}, result={C_expected}")

# Create a TestFactory and register the test
factory = TestFactory(test_matrix_multiplier_16bit)
factory.generate_tests()
