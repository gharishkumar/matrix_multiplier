`timescale 1ns / 1ps

module bfloat_16_mul(
        input_a,
        input_b,
        start,
        input_a_stb,
        input_b_stb,
        clk,
        rst,
        output_z,
        output_z_stb);

  input     clk;
  input     rst;

  input     start;

  input     [15:0] input_a;
  input     input_a_stb;

  input     [15:0] input_b;
  input     input_b_stb;

  output    [15:0] output_z;
  output    output_z_stb;

  reg       s_output_z_stb;
  reg       [15:0] s_output_z;

  reg       [3:0] state;
  parameter idle                 = 4'd0,
            get_input_a          = 4'd1,
            get_input_b          = 4'd2,
            unpack_input         = 4'd3,
            handle_special_cases = 4'd4,
            normalise_input_a    = 4'd5,
            normalise_input_b    = 4'd6,
            multiply_step_0      = 4'd7,
            multiply_step_1      = 4'd8,
            normalise_step_1     = 4'd9,
            normalise_step_2     = 4'd10,
            round_off_output     = 4'd11,
            pack_output          = 4'd12,
            put_z_output         = 4'd13;

  reg       [15:0] a, b, z;
  reg       [7:0] a_m, b_m, z_m;
  reg       [9:0] a_e, b_e, z_e;
  reg       a_s, b_s, z_s;
  reg       guard, round_bit, sticky;
  reg       [15:0] product;
  wire      [31:0] vedic_mul_product;
  
  reg done;
  reg vedic_mul_start;
  wire valid_out;
  
  wire [15:0] a_m_padded;
  wire [15:0] b_m_padded;
  assign a_m_padded = {8'b0,a_m};
  assign b_m_padded = {8'b0,b_m};
  
  vedic16x16 inst_vedic16x16 
  (
    .clk(clk), 
    .reset(rst), 
    .a(a_m_padded), 
    .b(b_m_padded), 
    .start(vedic_mul_start), 
    .result(vedic_mul_product), 
    .done(valid_out)
  );

  always @(posedge clk)
  begin
    if (rst) begin
      state <= idle;
      s_output_z_stb <= 0;
      product <= 0;
    end else begin
    case(state)

      idle : 
      begin
        if (start) begin
          state <= get_input_a;
        end else begin
          state <= idle;
        end
      end

      get_input_a:
      begin
        done  <= 1'b0;
        if (input_a_stb ) begin
          a <= input_a;
          state <= get_input_b;
        end
      end

      get_input_b:
      begin
        if (input_b_stb) begin
          b <= input_b;
          state <= unpack_input;
        end
      end

      unpack_input:
      begin
        a_m <= {1'b0, a[6:0]};
        b_m <= {1'b0, b[6:0]};
        a_e <= a[14:7] - 127;
        b_e <= b[14:7] - 127;
        a_s <= a[15];
        b_s <= b[15];
        state <= handle_special_cases;
      end

      handle_special_cases:
      begin
        if ((a_e == 128 && a_m[6:0] != 0) || (b_e == 128 && b_m[6:0] != 0)) begin
          z[15] <= 1;
          z[14:7] <= 8'hFF;
          z[6] <= 1;
          z[5:0] <= 0;
          state <= put_z_output;
        end else if (a_e == 128) begin
          z[15] <= a_s ^ b_s;
          z[14:7] <= 8'hFF;
          z[6:0] <= 0;
          if (($signed(b_e) == -127) && (b_m[6:0] == 0)) begin
            z[15] <= 1;
            z[14:7] <= 8'hFF;
            z[6] <= 1;
            z[5:0] <= 0;
          end
          state <= put_z_output;
        end else if (b_e == 128) begin
          z[15] <= a_s ^ b_s;
          z[14:7] <= 8'hFF;
          z[6:0] <= 0;
          if (($signed(a_e) == -127) && (a_m[6:0] == 0)) begin
            z[15] <= 1;
            z[14:7] <= 8'hFF;
            z[6] <= 1;
            z[5:0] <= 0;
          end
          state <= put_z_output;
        end else if ((($signed(a_e) == -127) && (a_m[6:0] == 0)) && (($signed(b_e) == -127) && (b_m[6:0] == 0))) begin
          z <= 16'h0;
          state <= put_z_output;
        end else if (($signed(a_e) == -127) && (a_m[6:0] == 0)) begin
          z[15] <= a_s ^ b_s;
          z[14:7] <= 0;
          z[6:0] <= 0;
          state <= put_z_output;
        end else if (($signed(b_e) == -127) && (b_m[6:0] == 0)) begin
          z[15] <= a_s ^ b_s;
          z[14:7] <= 0;
          z[6:0] <= 0;
          state <= put_z_output;
        end else begin
          if ($signed(a_e) == -127) begin
            a_e <= -126;
          end else begin
            a_m[7] <= 1;
          end
          if ($signed(b_e) == -127) begin
            b_e <= -126;
          end else begin
            b_m[7] <= 1;
          end
          state <= normalise_input_a;
        end
      end

      normalise_input_a:
      begin
        if (a_m[7]) begin
          state <= normalise_input_b;
        end else begin
          a_m <= a_m << 1;
          a_e <= a_e - 1;
        end
      end

      normalise_input_b:
      begin
        if (b_m[7]) begin
          state <= multiply_step_0;
        end else begin
          b_m <= b_m << 1;
          b_e <= b_e - 1;
        end
      end

      multiply_step_0:
      begin
        z_s <= a_s ^ b_s;
        z_e <= a_e + b_e + 1;
        vedic_mul_start <= 1'b1;
        if (valid_out) begin
          product <= vedic_mul_product[15:0];
          state <= multiply_step_1;
          vedic_mul_start <= 1'b0;
        end
      end

      multiply_step_1:
      begin
        z_m <= product[15:8];
        guard <= product[7];
        round_bit <= product[6];
        sticky <= (product[5:0] != 0);
        state <= normalise_step_1;
      end

      normalise_step_1:
      begin
        if (z_m[7] == 0) begin
          z_e <= z_e - 1;
          z_m <= z_m << 1;
          z_m[0] <= guard;
          guard <= round_bit;
          round_bit <= 0;
        end else begin
          state <= normalise_step_2;
        end
      end

      normalise_step_2:
      begin
        if ($signed(z_e) < -126) begin
          z_e <= z_e + 1;
          z_m <= z_m >> 1;
          guard <= z_m[0];
          round_bit <= guard;
          sticky <= sticky | round_bit;
        end else begin
          state <= round_off_output;
        end
      end

      round_off_output:
      begin
        if (guard && (round_bit | sticky | z_m[0])) begin
          z_m <= z_m + 1;
          if (z_m == 8'hFF) begin
            z_e <= z_e + 1;
          end
        end
        state <= pack_output;
      end

      pack_output:
      begin
        z[6:0] <= z_m[6:0];
        z[14:7] <= z_e[7:0] + 127;
        z[15] <= z_s;
        if ($signed(z_e) == -126 && z_m[7] == 0) begin
          z[14:7] <= 0;
        end
        if ($signed(z_e) > 127) begin
          z[6:0] <= 0;
          z[14:7] <= 8'hFF;
          z[15] <= z_s;
        end
        state <= put_z_output;
      end

      put_z_output:
      begin
        s_output_z <= z;
        state <= idle;
        done  <= 1'b1;
      end

    endcase
    end
  end
  
  assign output_z_stb = done;
  assign output_z = s_output_z;

endmodule