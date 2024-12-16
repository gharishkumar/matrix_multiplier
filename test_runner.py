import cocotb_test.simulator
import os

def test_MatrixMultiplier2x2():
    # Define the path to the Verilog source file and the test module
    verilog_sources = [os.path.join(os.getcwd(), "design.sv")]

    # Run the test
    cocotb_test.simulator.run(
        verilog_sources=verilog_sources,
        toplevel="matrix_multiplier_16bit",
        module="test_matrix_multiplier_16bit",
        simulator="questa"
    )

if __name__ == "__main__":
    test_MatrixMultiplier2x2()
