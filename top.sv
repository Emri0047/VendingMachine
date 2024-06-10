`default_nettype none
// Empty top module

typedef enum logic [2:0] {
INIT =0, money=1, purchased=2, rejection=3, refund = 4
} state_t;

module top (
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);

logic [4:0] encoderOut;
logic [1:0] cost, foodType;
ecn20to5 encoder (.in(pb[19:0]), .out(encoderOut), .strobe(red));
vending testVend(.button(encoderOut[3:0]), .cost(cost), .foodtype(foodType));
assign right[1:0] = cost;
assign left [1:0] = foodType;

endmodule

module balance (
    input logic [1:0] cost, foodtype,
    input logic rst, clk, nickel, dime,
    output logic enoughMoney,
    output logic [4:0] balanceCheck
    );
    logic [4:0] currBalance, nextBalance;
    logic currEnoughMoney, nextEnoughMoney;

    assign enoughMoney = currEnoughMoney;
    assign balanceCheck = currBalance;


    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            currBalance <= 0;
            //is this defaulting to 0 going to be an issue??
            currEnoughMoney <= 0;
        end
        else begin
            currBalance <= nextBalance;
            currEnoughMoney <= nextEnoughMoney;
        end
    end

    always_comb begin
        //will this work, is them multiplication an issue??
        if (currBalance > (cost + 2'b01) * 0.25) begin
            nextEnoughMoney = 1;
            nextBalance = currBalance - ((cost + 2'b01) * 0.25);
        end
        //should enough money stay the same or change it??
        else if (nickel || dime) begin
        nextEnoughMoney = enoughMoney;
        nextBalance = currBalance + {4'b0000, nickel} + (2'b10 * dime);
        end

        //are these corret states? Have enoughMoney go to 0?
        else begin
            nextEnoughMoney = 0;
            nextBalance = currBalance;
        end
    end
endmodule


module vending (
    input logic [3:0] button,
    output logic [1:0] cost, foodtype
    );


    always_comb begin

    //figure out type of food
        if (button == 4'hF || button == 4'hE || button == 4'hD || button == 4'hC) begin
        foodtype = 'b10;
        end
        else if (button == 4'hB || button == 4'hA || button == 4'b1001 || button == 4'b1000) begin
        foodtype = 'b01;
        end
        else begin
            foodtype = 'b00;
        end

    //figure out cost of food
    if (button == 4'hF || button == 4'hB || button == 4'b0111) begin
        cost= 'b11;
    end
    else if (button == 4'hE || button == 4'hA || button == 4'b0110) begin
        cost= 'b10;
    end
    else if (button == 4'hD || button == 4'b1001 || button == 4'b0101)begin
        cost= 'b01;
    end
    else begin
        cost= 'b00;
    end
    end
endmodule

module ecn20to5 (
input logic [19:0] in,
output logic [4:0] out,
output logic strobe
);
logic [5:0] i;
assign strobe = |in;
always_comb begin
  out = 0;
  for (i = 0; i < 20; i++)
    if(in[i[4:0]])
      out = i[4:0];
end
endmodule