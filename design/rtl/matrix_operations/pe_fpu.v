`timescale 1ns/1ps

module pe_fpu 
( 
    input wire        clk,       // Clock signal
    input wire        rst,       // Reset signal
    input wire        load_in,   // Load input signal
    input wire [31:0] row_in,    // 32-bit input row
    input wire [31:0] col_in,    // 32-bit input column
    output reg [31:0] col_out,   // 32-bit output column
    output reg [31:0] row_out,   // 32-bit output row
    output reg [31:0] pe_result, // Processing element result
    output reg        done_pe    // Done signal for processing element
);

    // Registers to hold inputs for multiplication
    reg [31:0] a_in_mul_reg;
    reg [31:0] b_in_mul_reg;

    // Wires to connect to the multiplier inputs
    wire [31:0] input_a_mul;
    wire [31:0] input_b_mul;

    // Wire to hold the output of the multiplier
    wire [31:0] output_fpu_mul;

    // Wires to signal when inputs are stable for multiplier
    wire input_a_stb_mul;
    wire input_b_stb_mul;

    // Registers to hold stable input signals for multiplier
    reg input_a_stb_mul_reg;
    reg input_b_stb_mul_reg;

    // Assign stable signals from registers
    assign input_a_stb_mul = input_a_stb_mul_reg;
    assign input_b_stb_mul = input_b_stb_mul_reg;

    // Assign input values from registers
    assign input_a_mul = a_in_mul_reg;
    assign input_b_mul = b_in_mul_reg;

    // Register to hold start signal for multiplier
    reg start_mul_reg;
    assign start_mul = start_mul_reg;

    // Instantiate the floating-point multiplier
    fpu_multiplier inst_fpu_multiplier (
        .input_a      (input_a_mul),
        .input_b      (input_b_mul),
        .input_a_stb  (input_a_stb_mul),
        .input_b_stb  (input_b_stb_mul),
        .clk          (clk),
        .rst          (rst),
        .start        (start_mul),
        .output_z     (output_fpu_mul),
        .output_z_stb (output_mul_done)
    );

    // Wires to signal when inputs are stable for adder
    wire input_a_stb_add;
    wire input_b_stb_add;

    // Registers to hold stable input signals for adder
    reg input_a_stb_add_reg;
    reg input_b_stb_add_reg;

    // Assign stable signals from registers
    assign input_a_stb_add = input_a_stb_add_reg;
    assign input_b_stb_add = input_b_stb_add_reg;

    // Registers to hold intermediate results
    reg [31:0] result_mul_reg;
    reg [31:0] pe_result_reg;

    // Wires to connect to the adder inputs
    wire [31:0] input_a_add;
    wire [31:0] input_b_add;

    // Assign adder inputs
    assign input_a_add = result_mul_reg;
    assign input_b_add = pe_result;

    // Wire to hold the output of the adder
    wire [31:0] output_add;

    // Instantiate the floating-point adder
    fpu_adder inst_fpu_adder (
        .input_a      (input_a_add),
        .input_b      (input_b_add),
        .input_a_stb  (input_a_stb_add),
        .input_b_stb  (input_b_stb_add),
        .clk          (clk),
        .rst          (rst),
        .output_z     (output_add),
        .output_z_stb (output_done_add)
    );

    // State machine states
    parameter IDLE      = 2'b00,
              STORE     = 2'b01,
              MUL_START = 2'b10,
              DONE      = 2'b11;

    // Register to hold the current state
    reg [1:0] state;

    // Sequential block for state transitions and output logic
    always @(posedge rst or posedge clk) begin 
        if (rst) begin 
            // Reset all signals
            pe_result           <= 0; 
            row_out             <= 0; 
            col_out             <= 0; 
            a_in_mul_reg        <= 0;
            b_in_mul_reg        <= 0;
            input_a_stb_mul_reg <= 0;
            input_b_stb_mul_reg <= 0;
            input_a_stb_add_reg <= 0;
            input_b_stb_add_reg <= 0;
            state               <= IDLE;
            pe_result_reg       <= 0;
            result_mul_reg      <= 0;
            start_mul_reg       <= 0;
        end else begin 
            case (state)
                IDLE : begin
                    if (load_in) begin
                        // Load inputs and transition to STORE state
                        a_in_mul_reg <= row_in;                    
                        b_in_mul_reg <= col_in;
                        state        <= STORE;                                
                    end
                end
                STORE : begin
                    // Set stable signals and start multiplication
                    input_a_stb_mul_reg <= 1'b1;
                    input_b_stb_mul_reg <= 1'b1;
                    start_mul_reg       <= 1'b1;
                    state               <= MUL_START;
                end
                MUL_START : begin
                    if (output_mul_done) begin
                        // Multiplication done, prepare for addition
                        start_mul_reg       <= 1'b0;
                        input_a_stb_mul_reg <= 1'b0;
                        input_b_stb_mul_reg <= 1'b0;
                        result_mul_reg      <= output_fpu_mul;
                        input_a_stb_add_reg <= 1'b1;
                        input_b_stb_add_reg <= 1'b1;
                        state               <= DONE;
                    end
                end
                DONE : begin
                    if (output_done_add) begin
                        // Addition done, update outputs and reset to IDLE state
                        input_a_stb_add_reg <= 1'b0;
                        input_b_stb_add_reg <= 1'b0;
                        pe_result           <= output_add;
                        col_out             <= b_in_mul_reg;                    
                        row_out             <= a_in_mul_reg;
                        state               <= IDLE;
                    end  
                end
                default : state <= IDLE;
            endcase
        end 
    end 

    // Sequential block to set done signal
    always @(posedge clk) begin 
        if (rst) begin
            done_pe <= 0;
        end else begin
            if (output_done_add && (state == DONE)) begin
                done_pe <= 1'b1;
            end else begin
                done_pe <= 1'b0;
            end
        end
    end

endmodule
