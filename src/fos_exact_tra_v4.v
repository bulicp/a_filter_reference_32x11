


module fos_exact_tra_v4(
    input [31:0] x_in,
    input [10:0] a1,
    input clk,
    input reset,
    output [31:0] y_out);
    /*
    Transposed I form
     x_in ---------------->(+)------------------- >y_out
            |               ^              |
            |               |              |
            |             (z^-1)           |
            |               ^              |
            |               |              |
            ----->(X)----->(+)<-----(X)<----
                   ^                 ^
                   |                 |
                  b1                a1
    */

    /*
    b1x = b1*x  (b1 multiplier)
    a1y = a1*y  (a1 multiplier)
    sum0_next = a1y + b1y (lower adder)
    sum0 = D(sum0_next) (output of D flipflop)
    sum1 = y = x + sum0  (upper adder)
    */
    wire [31:0] b1x;
    wire [31:0] a1y;
    wire signed [31:0] sum0_next;
    wire signed [31:0] sum1;
    reg signed [31:0] sum0;

    //assign a1y = a1 * sum1;
    rad4_reference3 mult(sum1,a1,a1y);

    assign y_out = sum0 + x_in;
    assign sum1 = y_out;
    assign sum0_next = a1y;
    

    always @ (posedge clk)
    if (reset) begin
        sum0 <= 32'b0;
    end else begin
        sum0 <= sum0_next;
    end
    


endmodule


module fos_exact_v4(
    input [31:0] x_in,
    input [10:0] a1,
    input clk,
    input reset,
    output [31:0] y_out);
    /*
    Direct I form
     x_in ---------------->(+)------------------- >y_out
            |               ^              |
            |               |              |
         (z^-1)              |            (z^-1) 
            |               |              |
            |               |              |
            ----->(X)----->(+)<-----(X)<----
                   ^                 ^
                   |                 |
                  b1                a1
    */

    wire signed [31:0] Data_feedforward;
    wire signed [31:0] Data_feedback;
    wire signed [31:0] sum0;
    reg signed  [31:0] Samples_in1; 
    reg signed  [31:0] Samples_in2; 
    reg signed  [31:0] Samples_out; 

    //assign Data_feedforward = Samples_in2; 
    //assign Data_feedback = a1*Samples_out; 
    //b1 = 0;
    assign y_out = Samples_in1 - Data_feedback; 
    
    rad4_reference3 mult(Samples_out,a1,Data_feedback);
                  
 
   always @ (posedge clk) 
   if(reset == 1) begin
         Samples_in1 <= 0; 
         Samples_in2 <= 0; 
         Samples_out <= 0; 
      end 
   else begin 
      Samples_in1 <= x_in; 
      Samples_in2 <= Samples_in1; 
      Samples_out <= y_out; 
   end 
 
    

endmodule