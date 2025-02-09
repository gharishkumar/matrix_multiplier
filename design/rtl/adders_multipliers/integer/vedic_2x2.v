
module vedic2x2(
    input wire       clk,
    input wire       reset,
    input wire [1:0] a, b,
    input wire       start,
    output reg [3:0] result,
    output reg       done
);
    wire w0, w1, w2, w3, w4, w5;  
    wire w2_buf_1; 
    wire w5_buf_1; 
    wire do_s2;
    wire [3:0] result_w;

    assign w0 = a[0] & b[1];
    assign w1 = a[1] & b[0];
    assign w2 = a[1] & b[1];
    assign w5 = a[0] & b[0];

    PIPO   #(1)B2(clk, reset, w5,     start, w5_buf_1, done_s1_1);
    adder  #(1)H0(clk, reset, w0, w1, start, {w3, w4}, done_s1_2);
    PIPO   #(1)B1(clk, reset, w2,     start, w2_buf_1, done_s1_3);
      
    assign do_s2 = done_s1_1 & done_s1_2 & done_s1_3;

    PIPO  #(1)B3(clk, reset, w5_buf_1,     do_s2, result_w[0],   done_s2_1);
    PIPO  #(1)B0(clk, reset, w4,           do_s2, result_w[1],   done_s2_2);
    adder #(1)H1(clk, reset, w2_buf_1, w3, do_s2, result_w[3:2], done_s2_3);

    always @(posedge clk) begin
        if (reset) begin
            done <= 1'b0;
        end else begin
          result <= result_w;
          done <= done_s2_1 & done_s2_2 & done_s2_3;
        end
    end
  
endmodule