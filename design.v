module alu #(parameter N = 8)(
    input CLK, RST, MODE, CE,
    input [1:0] INP_VALID,
    input [3:0] CMD,
    input [N-1:0] OPA, OPB,
    input CIN,
    //output ports
    output reg [2*N-1:0] RES,
    output reg OFLOW, COUT, G, L, E, ERR
);
    reg [3:0] CMD_w;
    reg [1:0] count;
     reg  [1:0]INP_VALID_w;
    reg [N-1:0]OPA_w,OPB_w;
    reg CIN_w;
    reg [N-1:0] temp_a, temp_b;
    reg signed [N-1:0] signed_a, signed_b;
    wire [N:0] sum_ext;
    assign sum_ext = $signed(OPA_w) + $signed(OPB_w);
 
    always @(posedge CLK) begin
      if (MODE && (CMD == 4'd9 || CMD == 4'd10)) begin
          if(count <2) 
            count <= count + 1;
          else
            count <= 1;
      end
      else
           count <=0;
    end
 
    always @(posedge CLK or posedge RST) begin
        if (RST) begin //RST logic
            RES   <= 0;
            OFLOW <= 0;
            COUT  <= 0;
            G <= 0; 
            L <= 0; 
            E <= 0;
            ERR <= 0;
        end
        else if (CE) begin 
          	INP_VALID_w <= INP_VALID ;
            OPA_w <= OPA;
            OPB_w <= OPB;
			CMD_w <= CMD;
            OFLOW <= 0;
            COUT  <= 0;
            CIN_w <= CIN;
            G <= 0; 
            L <= 0; 
            E <= 0;
            ERR <= 0;
 
            if (MODE) begin 
              case (CMD_w)
 
                    4'd0: begin
                        if (INP_VALID_w == 2'b11)
                            {COUT, RES[N-1:0]} <= OPA_w + OPB_w;
                        else begin ERR <= 1; RES <= 0; end
                    end
 
                    4'd1: begin
                        if (INP_VALID_w == 2'b11)
                            RES[N-1:0] <= OPA_w - OPB_w;
                        else begin ERR <= 1; RES <= 0; end
                    end
 
                    4'd2: begin
                        if (INP_VALID_w == 2'b11)
                        {COUT, RES[N-1:0]} <= OPA_w + OPB_w + CIN_w;
                        else begin ERR <= 1; RES <= 0; end
                    end
 
                    4'd3: begin
                        if (INP_VALID_w == 2'b11)
                          RES[N-1:0] <= OPA_w - OPB_w - CIN_w;
                        else begin ERR <= 1; RES <= 0; end
                    end
 
                    4'd4: begin
                        if (INP_VALID_w[0])
                            RES[N-1:0] <= OPA_w + 1;
                        else begin ERR <= 1; RES <= 0; end
                    end
 
                    4'd5: begin
                        if (INP_VALID_w[0])
                            RES[N-1:0] <= OPA_w - 1;
                        else begin ERR <= 1; RES <= 0; end
                    end
 
                    4'd6: begin
                        if (INP_VALID_w[1])
                            RES[N-1:0] <= OPB_w + 1;
                        else begin ERR <= 1; RES <= 0; end
                    end
 
                    4'd7: begin
                        if (INP_VALID_w[1])
                            RES[N-1:0] <= OPB_w - 1;
                        else begin ERR <= 1; RES <= 0; end
                    end
 
                    4'd8: begin
                        if (INP_VALID_w == 2'b11) begin
                            G <= (OPA_w > OPB_w);
                            E <= (OPA_w == OPB_w);
                            L <= (OPA_w < OPB_w);
                        end 
                        else begin ERR <= 1; RES <= 0; end
                    end
 
                    4'd9: begin
                        if (INP_VALID_w == 2'b11) begin
                          if (count == 2'd1) begin
                                temp_a <= OPA_w + 1;
                                temp_b <= OPB_w + 1;
                                RES <= 'bx;
                          end
                          else if (count == 2'd2) begin
                                RES <= temp_a * temp_b;
                          end
                          else
                                RES <= RES;
                        end
                        else begin ERR <= 1; RES <= 0; end
                    end
 
                    4'd10: begin
                        if (INP_VALID_w == 2'b11) begin
                          if (count == 2'd1) begin
                                temp_a <= OPA_w << 1;
                                RES <= 'bx;
                          end
                          else if (count == 2'd2) begin
                                RES <= temp_a * OPB_w;
                          end
                          else
                                RES <= RES;
                        end
                        else begin ERR <= 1; RES <= 0; end
                    end
 
                    4'd11: begin
                      signed_a = $signed(OPA_w);
                      signed_b = $signed(OPB_w);
                        if (INP_VALID_w == 2'b11) begin
                            RES <= signed_a + signed_b;
                            OFLOW <= (signed_a[N-1] == signed_b[N-1]) &&
                                     (sum_ext[N] != signed_a[N-1]);
                            G <= signed_a > signed_b;
                            E <= signed_a == signed_b;
                            L <= signed_a < signed_b;
                        end 
                        else begin ERR <= 1; RES <= 0; end
                    end
 
                    4'd12: begin
                        signed_a = OPA_w;
                        signed_b = OPB_w;
                        if (INP_VALID_w == 2'b11) begin
                            RES <= signed_a - signed_b;
                            OFLOW <= (signed_a[N-1] != signed_b[N-1]) &&
                                     (sum_ext[N] != signed_a[N-1]);
                            G <= signed_a > signed_b;
                            E <= signed_a == signed_b;
                            L <= signed_a < signed_b;
                        end 
                        else begin ERR <= 1; RES <= 0; end
                    end
 
                    default: begin ERR <= 1; RES <= 0; end
 
                endcase
            end
 
            else begin 
              case (CMD_w)
 
                     4'd0: begin //AND
                         if (INP_VALID_w==2'b11) 
                            RES <= OPA_w & OPB_w; 
                         else begin ERR<=1; RES <= 0; end
                        end
 
                    4'd1: begin//NAND
                          if (INP_VALID_w==2'b11) 
                            RES <= ~(OPA_w & OPB_w); 
                          else begin ERR<=1; RES <= 0; end
                        end
 
                    4'd2: begin//OR
                            if (INP_VALID_w==2'b11) 
                                RES <= OPA_w | OPB_w; 
                            else begin ERR<=1; RES <= 0; end
                    end
 
                    4'd3: begin//NOR
                            if (INP_VALID_w==2'b11) 
                                RES <= ~(OPA_w | OPB_w); 
                            else begin ERR<=1; RES <= 0; end
                    end
 
                    4'd4: begin//XOR
                            if (INP_VALID_w==2'b11) 
                                   RES <= OPA_w ^ OPB_w; 
                            else begin ERR<=1; RES <= 0; end
                    end
 
                    4'd5: begin//XNOR
                            if (INP_VALID_w==2'b11) 
                                    RES <= ~(OPA_w ^ OPB_w); 
                            else begin ERR<=1; RES <= 0; end
                    end
 
                    4'd6: begin//NOT A
                        if (INP_VALID_w[0]) 
                            RES <= ~OPA_w; 
                        else begin ERR<=1; RES <= 0; end
                    end
 
                    4'd7: begin//NOT B
                        if (INP_VALID_w[1]) 
                                RES <= ~OPB_w; 
                        else begin ERR<=1; RES <= 0; end
                    end
 
                    4'd8: begin//SHFTR1_A
                        if (INP_VALID_w[0]) 
                                RES <= OPA_w >> 1; 
                        else begin ERR<=1; RES <= 0; end
                    end
 
                    4'd9: begin//SHFTL1_A
                        if (INP_VALID_w[0]) 
                                RES <= OPA_w << 1; 
                        else begin ERR<=1; RES <= 0; end
                    end
 
                    4'd10: begin//SHFTR1_B
                         if (INP_VALID_w[1]) 
                            RES <= OPB_w >> 1; 
                         else begin ERR<=1; RES <= 0; end
                    end
 
                    4'd11: begin//SHFTL1_B
                        if (INP_VALID_w[1]) 
                            RES <= OPB_w << 1; 
                        else begin ERR<=1; RES <= 0; end
                    end
 
                    4'd12: begin//ROtate left
                        if (INP_VALID_w==2'b11)
                            RES[N-1:0] <= (OPA_w << (OPB_w % N)) | (OPA_w >> (N - (OPB_w % N)));
                        else begin ERR<=1; RES <= 0; end
                    end
 
                    4'd13: begin//rotate right
                        if (INP_VALID_w==2'b11)
                         RES[N-1:0] <= (OPA_w >> (OPB_w % N)) | (OPA_w << (N - (OPB_w % N)));
                        else begin ERR<=1; RES <= 0; end
                     end
 
                    default: begin ERR <= 1; RES <= 0; end
 
                endcase
            end
        end
        else begin
            RES <= 0;
        end
    end
 
endmodule

 
 
