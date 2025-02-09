`timescale 1ns / 1ps

module fpu_multiplier(
  input  wire        clk,
  input  wire        rst,
  input  wire [31:0] input_a,
  input  wire [31:0] input_b,
  input  wire        start,
  input  wire        input_a_stb,
  input  wire        input_b_stb,
  output wire [31:0] output_z,
  output wire        output_z_stb
);

  reg        s_output_z_stb;
  reg [31:0] s_output_z;
  reg [3:0]  state;

  parameter IDLE                 = 4'd0,
            GET_INPUT_A          = 4'd1,
            GET_INPUT_B          = 4'd2,
            UNPACK_INPUT         = 4'd3,
            HANDLE_SPECIAL_CASES = 4'd4,
            NORMALISE_INPUT_A    = 4'd5,
            NORMALISE_INPUT_B    = 4'd6,
            MULTIPLY_STEP_0      = 4'd7,
            MULTIPLY_STEP_1      = 4'd8,
            NORMALISE_STEP_1     = 4'd9,
            NORMALISE_STEP_2     = 4'd10,
            ROUND_OFF_OUTPUT     = 4'd11,
            PACK_OUTPUT          = 4'd12,
            PUT_Z_OUTPUT         = 4'd13;

  reg       [31:0] a, b, z;
  reg       [23:0] a_m, b_m, z_m;
  reg       [9:0] a_e, b_e, z_e;
  reg       a_s, b_s, z_s;
  reg       guard, round_bit, sticky;
  reg       [47:0] product;
  wire      [63:0] vedic_mul_product;
  

  reg  done;
  reg  vedic_mul_start;
  wire valid_out;
  
  wire [31:0] a_m_padded;
  wire [31:0] b_m_padded;

  assign a_m_padded = {8'b0,a_m};
  assign b_m_padded = {8'b0,b_m};

    vedic32x32 inst_vedic32x32 
    (
      .clk   (clk), 
      .reset (rst), 
      .a     (a_m_padded), 
      .b     (b_m_padded), 
      .start (vedic_mul_start), 
      .result(vedic_mul_product), 
      .done  (valid_out)
    );



  always @(posedge clk) begin
      if (rst) begin
        state          <= IDLE;
        s_output_z_stb <= 0;
        product        <= 0;
      end else begin
        case(state)
          IDLE : begin
                 if (start) begin
                   state <= GET_INPUT_A;
                 end else begin
                   state <= IDLE;
                 end
          end

          GET_INPUT_A: begin
                       done    <= 1'b0;
                       if (input_a_stb ) begin
                         a     <= input_a;
                         state <= GET_INPUT_B;
                       end
          end

          GET_INPUT_B: begin
                       if (input_b_stb) begin
                         b     <= input_b;
                         state <= UNPACK_INPUT;
                       end
          end

          UNPACK_INPUT: begin
                        a_m   <= a[22 : 0];
                        b_m   <= b[22 : 0];
                        a_e   <= a[30 : 23] - 127;
                        b_e   <= b[30 : 23] - 127;
                        a_s   <= a[31];
                        b_s   <= b[31];
                        state <= HANDLE_SPECIAL_CASES;
          end

          HANDLE_SPECIAL_CASES: begin
                                //if a is NaN or b is NaN return NaN 
                                if ((a_e == 128 && a_m != 0) || (b_e == 128 && b_m != 0)) begin
                                  z[31]    <= 1;
                                  z[30:23] <= 255;
                                  z[22]    <= 1;
                                  z[21:0]  <= 0;
                                  state    <= PUT_Z_OUTPUT;
                                end else if (a_e == 128) begin  //if a is inf return inf
                                  z[31]    <= a_s ^ b_s;
                                  z[30:23] <= 255;
                                  z[22:0]  <= 0;
                                  if (($signed(b_e) == -127) && (b_m == 0)) begin  //if b is zero return NaN
                                    z[31]    <= 1;
                                    z[30:23] <= 255;
                                    z[22]    <= 1;
                                    z[21:0]  <= 0;
                                  end
                                  state      <= PUT_Z_OUTPUT;
                              end else if (b_e == 128) begin   //if b is inf return inf
                                z[31]    <= a_s ^ b_s;
                                z[30:23] <= 255;
                                z[22:0]  <= 0;
                                //if a is zero return NaN
                                if (($signed(a_e) == -127) && (a_m == 0)) begin
                                  z[31]    <= 1;
                                  z[30:23] <= 255;
                                  z[22]    <= 1;
                                  z[21:0]  <= 0;
                                end
                                state <= PUT_Z_OUTPUT;
                              //if a is zero return zero
                              end else if ((($signed(a_e) == -127) && (a_m == 0)) && (($signed(b_e) == -127) && (b_m == 0))) begin
                                z[31:0] <= 0;
                                state   <= PUT_Z_OUTPUT;
                              end else if (($signed(a_e) == -127) && (a_m == 0)) begin
                                z[31]    <= a_s ^ b_s;
                                z[30:23] <= 0;
                                z[22:0]  <= 0;
                                state    <= PUT_Z_OUTPUT;
                              //if b is zero return zero
                              end else if (($signed(b_e) == -127) && (b_m == 0)) begin
                                z[31]    <= a_s ^ b_s;
                                z[30:23] <= 0;
                                z[22:0]  <= 0;
                                state    <= PUT_Z_OUTPUT;
                              end else begin
                                //Denormalised Number
                                if ($signed(a_e) == -127) begin
                                  a_e     <= -126;
                                end else begin
                                  a_m[23] <= 1;
                                end
                                //Denormalised Number
                                if ($signed(b_e) == -127) begin
                                  b_e     <= -126;
                                end else begin
                                  b_m[23] <= 1;
                                end
                                state <= NORMALISE_INPUT_A;
                              end
          end
          NORMALISE_INPUT_A: begin
                             if (a_m[23]) begin
                               state <= NORMALISE_INPUT_B;
                             end else begin
                               a_m <= a_m << 1;
                               a_e <= a_e - 1;
                             end
          end

          NORMALISE_INPUT_B: begin
                             if (b_m[23]) begin
                               state <= MULTIPLY_STEP_0;
                             end else begin
                               b_m <= b_m << 1;
                               b_e <= b_e - 1;
                             end
          end

          MULTIPLY_STEP_0: begin
                           z_s               <= a_s ^ b_s;
                           z_e               <= a_e + b_e + 1;
                           vedic_mul_start   <= 1'b1;
                           if (valid_out) begin
                             product         <= vedic_mul_product[47:0];
                             state           <= MULTIPLY_STEP_1;
                             vedic_mul_start <= 1'b0;
                           end
          end

          MULTIPLY_STEP_1: begin
                           z_m       <= product[47:24];
                           guard     <= product[23];
                           round_bit <= product[22];
                           sticky    <= (product[21:0] != 0);
                           state     <= NORMALISE_STEP_1;
          end

          NORMALISE_STEP_1: begin
                            if (z_m[23] == 0) begin
                              z_e       <= z_e - 1;
                              z_m       <= z_m << 1;
                              z_m[0]    <= guard;
                              guard     <= round_bit;
                              round_bit <= 0;
                            end else begin
                              state <= NORMALISE_STEP_2;
                            end
          end

          NORMALISE_STEP_2: begin
                            if ($signed(z_e) < -126) begin
                              z_e       <= z_e + 1;
                              z_m       <= z_m >> 1;
                              guard     <= z_m[0];
                              round_bit <= guard;
                              sticky    <= sticky | round_bit;
                            end else begin
                              state <= ROUND_OFF_OUTPUT;
                            end
          end

          ROUND_OFF_OUTPUT: begin
                            if (guard && (round_bit | sticky | z_m[0])) begin
                             z_m <= z_m + 1;
                             if (z_m == 24'hffffff) begin
                               z_e <=z_e + 1;
                             end
                            if (z_m == 24'hffffff) begin
                              z_e <= z_e + 1;
                              end
                            end
                            state <= PACK_OUTPUT;
          end

          PACK_OUTPUT: begin
                       z[22 : 0]  <= z_m[22:0];
                       z[30 : 23] <= z_e[7:0] + 127;
                       z[31]      <= z_s;
                       if ($signed(z_e) == -126 && z_m[23] == 0) begin
                         z[30 : 23] <= 0;
                       end
                       //if overflow occurs, return inf
                       if ($signed(z_e) > 127) begin
                         z[22 : 0]  <= 0;
                         z[30 : 23] <= 255;
                         z[31]      <= z_s;
                       end
                       state <= PUT_Z_OUTPUT;
          end

          PUT_Z_OUTPUT: begin
                        s_output_z <= z;
                        state <= IDLE;
                        done  <= 1'b1;
          end
          default: state <= IDLE;
        endcase
        end
  end
  
  assign output_z_stb = done;
  assign output_z = s_output_z;

endmodule

