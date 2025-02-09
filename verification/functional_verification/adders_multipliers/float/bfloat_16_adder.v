module bfloat_16_adder(
        input_a,
        input_b,
        input_a_stb,
        input_b_stb,
        clk,
        rst,
        output_z,
        output_z_stb);

  input     clk;
  input     rst;

  input     [15:0] input_a;
  input     input_a_stb;
  wire    input_a_ack;

  input     [15:0] input_b;
  input     input_b_stb;
  wire    input_b_ack;

  output    [15:0] output_z;
  output    output_z_stb;
  

  reg       s_output_z_stb;
  reg       [15:0] s_output_z;
  reg       s_input_a_ack;
  reg       s_input_b_ack;

  reg       [3:0] state;
  
  parameter get_a_input          = 4'd0,
            get_b_input          = 4'd1,
            unpack_input         = 4'd2,
            handle_special_cases = 4'd3,
            align_number         = 4'd4,
            add_step_1           = 4'd5,
            add_step_2           = 4'd6,
            normalise_step_1     = 4'd7,
            normalise_step_2     = 4'd8,
            round_off            = 4'd9,
            pack_output          = 4'd10,
            put_z_output         = 4'd11;

  reg       [15:0] a, b, z;
  reg       [10:0] a_m, b_m;
  reg       [7:0] z_m;
  reg       [9:0] a_e, b_e, z_e;
  reg       a_s, b_s, z_s;
  reg       guard, round_bit, sticky;
  reg       [11:0] sum;

  always @(posedge clk)
  begin

    case(state)

      get_a_input:
      begin
        s_input_a_ack <= 1;
        if (s_input_a_ack && input_a_stb) begin
          a <= input_a;
          s_input_a_ack <= 0;
          state <= get_b_input;
        end
      end

      get_b_input:
      begin
        s_input_b_ack <= 1;
        if (s_input_b_ack && input_b_stb) begin
          b <= input_b;
          s_input_b_ack <= 0;
          state <= unpack_input;
        end
      end

      unpack_input:
      begin
        a_m <= {1'b0 , a[6 : 0], 3'd0};
        b_m <= {1'b0 , b[6 : 0], 3'd0};
        a_e <= a[14 : 7] - 127;
        b_e <= b[14 : 7] - 127;
        a_s <= a[15];
        b_s <= b[15];
        state <= handle_special_cases;
      end

      handle_special_cases:
      begin
        //if a is NaN or b is NaN return NaN 
        if ((a_e == 128 && a_m != 0) || (b_e == 128 && b_m != 0)) begin
          z[15] <= 1;
          z[14:7] <= 255;
          z[6] <= 1;
          z[5:0] <= 0;
          state <= put_z_output;
        //if a is inf return inf
        end else if (a_e == 128) begin
          z[15] <= a_s;
          z[14:7] <= 255;
          z[6:0] <= 0;
          //if a is inf and signs don't match return nan
          if ((b_e == 128) && (a_s != b_s)) begin
              z[15] <= b_s;
              z[14:7] <= 255;
              z[6] <= 1;
              z[5:0] <= 0;
          end
          state <= put_z_output;
        //if b is inf return inf
        end else if (b_e == 128) begin
          z[15] <= b_s;
          z[14:7] <= 255;
          z[6:0] <= 0;
          state <= put_z_output;
        //if a is zero return b
        end else if ((($signed(a_e) == -127) && (a_m == 0)) && (($signed(b_e) == -127) && (b_m == 0))) begin
          z[15] <= a_s & b_s;
          z[14:7] <= 0;
          z[6:0] <= 0;
          state <= put_z_output;
        //if a is zero return b
        end else if (($signed(a_e) == -127) && (a_m == 0)) begin
          z[15] <= b_s;
          z[14:7] <= b_e[7:0] + 127;
          z[6:0] <= b_m[10:3];
          state <= put_z_output;
        //if b is zero return a
        end else if (($signed(b_e) == -127) && (b_m == 0)) begin
          z[15] <= a_s;
          z[14:7] <= a_e[7:0] + 127;
          z[6:0] <= a_m[10:3];
          state <= put_z_output;
        end else begin
          //Denormalised Number
          if ($signed(a_e) == -127) begin
            a_e <= -126;
          end else begin
            a_m[10] <= 1;
          end
          //Denormalised Number
          if ($signed(b_e) == -127) begin
            b_e <= -126;
          end else begin
            b_m[10] <= 1;
          end
          state <= align_number;
        end
      end

      align_number:
      begin
        if ($signed(a_e) > $signed(b_e)) begin
          b_e <= b_e + 1;
          b_m <= b_m >> 1;
          b_m[0] <= b_m[0] | b_m[1];
        end else if ($signed(a_e) < $signed(b_e)) begin
          a_e <= a_e + 1;
          a_m <= a_m >> 1;
          a_m[0] <= a_m[0] | a_m[1];
        end else begin
          state <= add_step_1;
        end
      end

      add_step_1:
      begin
        z_e <= a_e;
        if (a_s == b_s) begin
          sum <= a_m + b_m;
          z_s <= a_s;
        end else begin
          if (a_m >= b_m) begin
            sum <= a_m - b_m;
            z_s <= a_s;
          end else begin
            sum <= b_m - a_m;
            z_s <= b_s;
          end
        end
        state <= add_step_2;
      end

      add_step_2:
      begin
        if (sum[11]) begin
          z_m <= sum[11:4];
          guard <= sum[3];
          round_bit <= sum[2];
          sticky <= sum[1] | sum[0];
          z_e <= z_e + 1;
        end else begin
          z_m <= sum[10:3];
          guard <= sum[2];
          round_bit <= sum[1];
          sticky <= sum[0];
        end
        state <= normalise_step_1;
      end

      normalise_step_1:
      begin
        if (z_m[7] == 0 && $signed(z_e) > -126) begin
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
          state <= round_off;
        end
      end

      round_off:
      begin     
        if (guard && (round_bit | sticky | z_m[0])) begin
          z_m <= z_m + 1;
          if (z_m == 8'hff) begin
            z_e <=z_e + 1;
          end
        end
        state <= pack_output;
        // if (guard) begin
        //   if ((round_bit | sticky) | (z_m[0] &(round_bit | sticky))) begin
        //     z_m <= z_m + 1;
        //     if (z_m == 8'hff) begin
        //       z_e <=z_e + 1;
        //     end
        //   end
        // end 
        // state <= pack_output;
      end

      pack_output:
      begin
        z[6 : 0] <= z_m[6:0];
        z[14 : 7] <= z_e[7:0] + 127;
        z[15] <= z_s;
        if ($signed(z_e) == -126 && z_m[7] == 0) begin
          z[14 : 7] <= 0;
        end
        if ($signed(z_e) == -126 && z_m[7:0] == 8'h0) begin
          z[15] <= 1'b0; // FIX SIGN BUG: -a + a = +0.
        end
        //if overflow occurs, return inf
        if ($signed(z_e) > 127) begin
          z[6 : 0] <= 0;
          z[14 : 7] <= 255;
          z[15] <= z_s;
        end
        state <= put_z_output;
      end

      put_z_output:
      begin
        s_output_z_stb <= 1;
        s_output_z <= z;
        if (s_output_z_stb) begin
          s_output_z_stb <= 0;
          state <= get_a_input;
        end
      end

    endcase

    if (rst == 1) begin
      state <= get_a_input;
      s_input_a_ack <= 0;
      s_input_b_ack <= 0;
      s_output_z_stb <= 0;
    end

  end
  assign input_a_ack = s_input_a_ack;
  assign input_b_ack = s_input_b_ack;
  assign output_z_stb = s_output_z_stb;
  assign output_z = s_output_z;

endmodule
