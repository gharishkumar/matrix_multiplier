// DATA_TYPE SELECTION
// 000 - fpu 754
// 001 - bfloat 8
// 001 - bfloat 16
// 011 - int 8
// 100 - int 16
// 101 - int 32

// similar pe structure for bfloat data types

module pe_fpu_bfloat_16 #(parameter DATA_TYPE = 3'b001 )
( 
    input             clk,
    input             rst,
    input             load_in,
    input [15:0]      row_in, 
    input [15:0]      col_in, 
    output reg [15:0] col_out, 
    output reg [15:0] row_out, 
    output reg [15:0] pe_result,
    output reg        done_pe
);
    
    // assign done_pe = (state == DONE) ? 1'b1 : 1'b0;
    

    //placeholder for multiplier module and signals FPU

    reg [15:0] a_in_mul_reg;
    reg [15:0] b_in_mul_reg;

    wire [15:0] input_a_mul;
    wire [15:0] input_b_mul;

    wire [15:0] output_fpu_mul;

    wire input_a_stb_mul;
    wire input_b_stb_mul;

    reg input_a_stb_mul_reg;
    reg input_b_stb_mul_reg;

    assign input_a_stb_mul = input_a_stb_mul_reg;
    assign input_b_stb_mul = input_b_stb_mul_reg;

    assign input_a_mul = a_in_mul_reg;
    assign input_b_mul = b_in_mul_reg;

    reg start_mul_reg;
    assign start_mul = start_mul_reg;


        bfloat_16_mul inst_bfloat_16_mul (
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

    //placeholder for adder module ans signal

    wire input_a_stb_add;
    wire input_b_stb_add;

    reg input_a_stb_add_reg;
    reg input_b_stb_add_reg;

    assign input_a_stb_add = input_a_stb_add_reg;
    assign input_b_stb_add = input_b_stb_add_reg;

    reg [15:0]  result_mul_reg;
    reg [15:0]  pe_result_reg;

    wire [15:0] input_a_add;
    wire [15:0] input_b_add;

    assign input_a_add = result_mul_reg;
    assign input_b_add = pe_result;

    wire [15:0] output_add;

    bfloat_16_adder inst_bfloat_16_adder (
            .input_a      (input_a_add),
            .input_b      (input_b_add),
            .input_a_stb  (input_a_stb_add),
            .input_b_stb  (input_b_stb_add),
            .clk          (clk),
            .rst          (rst),
            .output_z     (output_add),
            .output_z_stb (output_done_add)
        );

 

    parameter IDLE     = 2'b00,
              STORE    = 2'b01,
              MUL_START = 2'b10,
              DONE     = 2'b11;

    reg [1:0] state;



    always @(posedge rst or posedge clk) begin 
        if(rst) begin 
            pe_result <= 0; 
            row_out  <= 0; 
            col_out  <= 0; 
            a_in_mul_reg <= 0;
            b_in_mul_reg <= 0;
            input_a_stb_mul_reg <= 0;
            input_b_stb_mul_reg <= 0;
            input_a_stb_add_reg <= 0;
            input_b_stb_add_reg <= 0;
            state     <= IDLE;
            pe_result_reg <= 0;
            result_mul_reg <= 0;
            start_mul_reg <= 0;
            // done_pe        <= 0;
        end else begin 
            case (state)
                IDLE :  begin
                        if(load_in) begin
                            // done_pe <= 1'b0;
                            a_in_mul_reg <= row_in;                    
                            b_in_mul_reg <= col_in;
                            state        <= STORE;                                
                        end
                end
                STORE : begin
                            input_a_stb_mul_reg <= 1'b1;
                            input_b_stb_mul_reg <= 1'b1;
                            start_mul_reg <= 1'b1;
                            state <= MUL_START;
                end
                MUL_START : begin
                            if(output_mul_done) begin
                                start_mul_reg <= 1'b0;
                                input_a_stb_mul_reg <= 1'b0;
                                input_b_stb_mul_reg <= 1'b0;
                                // done_pe      <= 1'b0;
                                result_mul_reg <= output_fpu_mul;
                                // pe_result_reg  <= pe_result;
                                input_a_stb_add_reg <= 1'b1;
                                input_b_stb_add_reg <= 1'b1;
                                state          <= DONE;
                            end
                end
                DONE : begin
                           if (output_done_add) begin
                               input_a_stb_add_reg <= 1'b0;
                               input_b_stb_add_reg <= 1'b0;
                               pe_result <= output_add;
                               col_out  <= b_in_mul_reg;                    
                               row_out  <= a_in_mul_reg;
                               // done_pe      <= 1'b1;
                               state     <= IDLE;
                           end  
                end
                default : state <= IDLE;
            endcase
        end 
    end 

    always @(posedge clk) begin 
        if(rst) begin
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



