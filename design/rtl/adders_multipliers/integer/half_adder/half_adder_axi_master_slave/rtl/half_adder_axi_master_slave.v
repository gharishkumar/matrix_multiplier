module half_adder_axi_master_slave (
    input wire clk,
    input wire reset,

    // Slave Interface (Input from Master)
    input wire s_a_tvalid,      // Slave valid signal (from master)
    input wire s_a_tdata,       // Slave data signal (from master)
    output reg s_a_tready,      // Slave ready signal (to master)

    input wire s_b_tvalid,      // Slave valid signal (from master)
    input wire s_b_tdata,       // Slave data signal (from master)
    output reg s_b_tready,      // Slave ready signal (to master)

    // Master Interface (Output to Slave)
    output reg m_sum_tvalid,    // Master valid signal (to slave)
    output reg m_sum_tdata,     // Master data signal (to slave)
    input wire m_sum_tready,    // Master ready signal (from slave)

    output reg m_carry_tvalid,  // Master valid signal (to slave)
    output reg m_carry_tdata,   // Master data signal (to slave)
    input wire m_carry_tready   // Master ready signal (from slave)
);

    // State machine states
    parameter IDLE                    = 3'b000;
    parameter WAITING_FOR_B_VALID     = 3'b001;
    parameter WAITING_FOR_A_VALID     = 3'b010;
    parameter PROCESS                 = 3'b011;
    parameter WAITING_FOR_SUM_READY   = 3'b100;
    parameter WAITING_FOR_CARRY_READY = 3'b101;
    parameter DONE                    = 3'b110;
    

    reg [2:0] current_state;

    // Internal signals for half adder
    reg a_reg, b_reg;

    // State machine logic (single always block)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all signals and state
            current_state <= IDLE;

            s_a_tready <= 1'b0;
            s_b_tready <= 1'b0;
            m_sum_tvalid <= 1'b0;
            m_carry_tvalid <= 1'b0;

            a_reg <= 1'b0;
            b_reg <= 1'b0;
        end else begin
            case (current_state)
                IDLE: begin
                    // Wait for valid input data
                    case ({s_a_tvalid, s_b_tvalid})
                            2'b00 : begin
                                // No valid input data
                                current_state <= IDLE;
                                s_a_tready <= 1'b0;
                                s_b_tready <= 1'b0;
                            end
                            2'b01 : begin
                                // Only B is valid, wait for A
                                current_state <= WAITING_FOR_A_VALID;
                                b_reg <= s_b_tdata;
                                s_b_tready <= 1'b1;
                            end
                            2'b10 : begin
                                // Only A is valid, wait for B
                                current_state <= WAITING_FOR_B_VALID;
                                a_reg <= s_a_tdata;
                                s_a_tready <= 1'b1;
                            end
                            2'b11 : begin
                                // Both A and B are valid, process data
                                current_state <= PROCESS;
                                a_reg <= s_a_tdata;
                                b_reg <= s_b_tdata;
                                s_a_tready <= 1'b1;
                                s_b_tready <= 1'b1;
                            end
                        default: begin
                            current_state <= IDLE;
                        end
                    endcase
                end

                WAITING_FOR_A_VALID : begin
                    // Wait for A to be valid
                    if (s_a_tvalid == 1'b1) begin
                        current_state <= PROCESS;
                        a_reg <= s_a_tdata;
                        s_a_tready <= 1'b1;
                    end
                end

                WAITING_FOR_B_VALID : begin
                    // Wait for B to be valid
                    if (s_b_tvalid == 1'b1) begin
                        current_state <= PROCESS;
                        b_reg <= s_b_tdata;
                        s_b_tready <= 1'b1;
                    end
                end

                PROCESS: begin
                    // Perform half adder logic
                    s_a_tready <= 1'b0; // Stop accepting new input
                    s_b_tready <= 1'b0; // Stop accepting new input
                    // Output the result
                    m_sum_tdata <= a_reg ^ b_reg; // Sum = A XOR B
                    m_carry_tdata <= a_reg & b_reg; // Carry = A AND B
                    m_carry_tvalid <= 1'b1; // Assert output valid
                    m_sum_tvalid <= 1'b1; // Assert output valid
                    current_state <= DONE;
                end

                DONE: begin

                    // Wait for downstream slave to accept data
                    case ({m_sum_tready, m_carry_tready})
                        2'b00: begin
                            current_state <= DONE;
                        end
                        2'b01: begin
                            m_carry_tvalid <= 1'b0; // Deassert output valid
                            current_state <= WAITING_FOR_SUM_READY;
                        end
                        2'b10: begin
                            m_sum_tvalid <= 1'b0; // Deassert output valid
                            current_state <= WAITING_FOR_CARRY_READY;
                        end
                        2'b11: begin
                            m_carry_tvalid <= 1'b0; // Deassert output valid
                            m_sum_tvalid <= 1'b0; // Deassert output valid
                            current_state <= IDLE;
                        end
                        default: begin
                            current_state <= DONE;
                        end
                    endcase
                end

                WAITING_FOR_CARRY_READY : begin
                    // Wait for Carry to be ready
                    if (m_carry_tready == 1'b1) begin
                        m_carry_tvalid <= 1'b0; // Deassert output valid
                        current_state <= IDLE;
                    end
                end

                WAITING_FOR_SUM_READY : begin
                    // Wait for Sum to be ready
                    if (m_sum_tready == 1'b1) begin
                        m_sum_tvalid <= 1'b0; // Deassert output valid
                        current_state <= IDLE;
                    end
                end

                default: begin
                    // Handle unexpected states
                    current_state <= IDLE;
                end
            endcase
        end
    end

endmodule