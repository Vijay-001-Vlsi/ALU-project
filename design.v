timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////

// Company: 

// Engineer: 

// 

// Create Date: 05/04/2026 02:29:27 PM

// Design Name: 

// Module Name: alu

// Project Name: 

// Target Devices: 

// Tool Versions: 

// Description: 

// 

// Dependencies: 

// 

// Revision:

// Revision 0.01 - File Created

// Additional Comments:

// 

//////////////////////////////////////////////////////////////////////////////////
 
 
module alu #(parameter width =8)(

    input clk,

    input rst,

    input [1:0] inp_valid,

    input mode,ce,cin,input [width-1:0] opa,opb,input [3:0]cmd,

    output reg oflow,cout,g,l,e,err,output reg [2*width-1:0]res

    );

wire signed [width-1:0] a,b;  

reg[1:0]count,count_1;

reg [width-1:0]opa_1,opb_1;

reg [2*width-1:0]temp;

reg signed [width:0] diff;

reg signed [width:0] sum;

reg [2*width-1:0] temp_res;

reg temp_cout,temp_oflow;

reg temp_g,temp_e,temp_l,temp_err;

    always@(posedge clk or posedge rst)

    begin

      if(rst)

      count<=2'b0;

      else begin

      if(cmd==4'd9&&inp_valid==3) begin

        if(count<2)

        count<=count+1;

        else

        count<=2'b0;

        end

      else

      count<=2'b0;   

    end

    end

   always@(posedge clk or posedge rst)

    begin

      if(rst)

      count_1<=2'b0;

      else begin

      if(cmd==4'd10&&inp_valid==3) begin

        if(count_1<2)

          count_1<=count_1+1;

        else 

         count_1<=2'b0;

        end 

      else

      count_1<=2'b0;   

    end

    end 

    always @(posedge clk or posedge rst)

    begin

    if(rst) begin

        res <= {2*width{1'b0}};

        cout <= 1'b0;

        oflow <= 1'b0;

        g <= 1'b0;

        l <= 1'b0;

        e <= 1'b0;

        err <= 1'b0;

    end

    else if(ce) begin

        res <= temp_res;

        cout <= temp_cout;

        oflow <= temp_oflow;

        g <= temp_g;

        l <= temp_l;

        e <= temp_e;

        err <= temp_err;

    end

   end

    always@(posedge clk or posedge rst)

    begin

    if(rst)

    begin

     temp_res <= {2*width{1'b0}};

     temp_cout <= 1'b0;

     temp_oflow <= 1'b0;

     temp_g <= 1'b0;

     temp_e <= 1'b0;

     temp_l <= 1'b0;

     temp_err <= 1'b0;

    end

    else begin

    //default

     temp_res <= {2*width{1'b0}};

     temp_cout <= 1'b0;

     temp_oflow <= 1'b0;

     temp_g <= 1'b0;

     temp_e <= 1'b0;

     temp_l <= 1'b0;

     temp_err <= 1'b0;

    if(ce)

     begin

     if(mode) begin

     case(cmd)

      4'd0: begin

           if(inp_valid==3)begin

           {temp_cout,temp_res[width-1:0]}<=opa+opb;

           temp_res[2*width-1:width] <= 0;

           end

           else

           temp_err<=1'b1;

          end

      4'd1:begin

         if(inp_valid==3)begin

           temp_res[width-1:0]<=opa-opb; 

            temp_res[2*width-1:width] <= 0;

           if(opa<opb)                          ///////////////////////////////////////////////////////

             temp_oflow<=1'b1;

           else

             temp_oflow<=1'b0;  

           end

           else

           temp_err<=1'b1;

        end  

     4'd2:begin

         if(inp_valid==3) begin

           {temp_cout,temp_res[width-1:0]}<=opa+opb+cin;

           temp_res[2*width-1:width] <= 0;

           end

            else

           temp_err<=1'b1;

        end

     4'd3:begin

         if(inp_valid==3)begin

           temp_res[width-1:0]<=opa-opb-cin;                      /////////////////////////////////////////

            temp_res[2*width-1:width] <= 0;

             if(opa<opb)                          ///////////////////////////////////////////////////////

             temp_oflow<=1'b1;

           else

             temp_oflow<=1'b0;  

            end 

           else

           temp_err<=1'b1;

        end

     4'd4:begin

         if(inp_valid==1||inp_valid==3) begin

           temp_res[width-1:0]<=opa+1;

           temp_res[2*width-1:width] <= 0;

           end

            else

           temp_err<=1'b1;

        end

     4'd5:begin

         if(inp_valid==1||inp_valid==3)begin 

           temp_res[width-1:0]<=opa-1;

           temp_res[2*width-1:width] <= 0;

           end

            else

           temp_err<=1'b1;

        end 

    4'd6:begin

         if(inp_valid==2||inp_valid==3)begin

           temp_res[width-1:0]<=opb+1;

           temp_res[2*width-1:width] <= 0;

           end

            else

           temp_err<=1'b1;

        end 

    4'd7:begin

         if(inp_valid==2||inp_valid==3) begin

           temp_res[width-1:0]<=opb-1;

           temp_res[2*width-1:width] <= 0;

           end

            else

           temp_err<=1'b1;

        end 

    4'd8:begin

         if(inp_valid==3)

           begin

                    if (opa == opb) begin

                        temp_g <= 0; temp_l <= 0; temp_e <= 1;

                    end else if (opa > opb) begin

                         temp_g <= 1; temp_l <= 0; temp_e <= 0;

                    end else begin

                          temp_g <= 0; temp_l <= 1; temp_e <= 0;

                    end

                end

             else

           temp_err<=1'b1;   

           end                

     4'd9:begin

          if(inp_valid==3) begin 

           if(count == 0) begin

              opa_1 <= opa;

              opb_1 <= opb;

              temp_res<= {2*width{1'bx}};

          end

          if(count==1)

          temp_res<= (opa_1+1)*(opb_1+1);                                     ///////////////////////////////////

//            if(count==2)

//           temp_res<=temp; 

           end

            else

           temp_err<=1'b1;

          end  

     4'd10:begin

           if(inp_valid==3)  begin                  ////////////////////////////////////

            if(count_1 == 0) begin

              opa_1 <= opa;

              opb_1 <= opb;

               temp_res<= {2*width{1'bx}};

          end

          if(count_1==1)

          temp_res<=(opa_1<<1)*opb_1;                                     ///////////////////////////////////

//           if(count_1==2)

//           temp_res<=temp; 

           end  

            else

           temp_err<=1'b1;

          end  

    4'd11:begin

            if(inp_valid == 3) begin

               sum = a + b;

               temp_res[width-1:0] <= sum[width-1:0];

               temp_res[2*width-1:width] <= 0;

               temp_cout <= sum[width];
 
            temp_oflow <= (a[width-1] == b[width-1]) && (sum[width-1] != a[width-1]);
 
           if (sum == 0) begin

               temp_g <= 0; temp_l <= 0; temp_e <= 1;

            end 

            else if (sum > 0) begin

               temp_g <= 1; temp_l <= 0; temp_e <= 0;

            end 

            else begin

               temp_g <= 0; temp_l <= 1; temp_e <= 0;

            end

           end

            else

           temp_err<=1'b1;

           end      

    4'd12:begin

          if(inp_valid == 3) begin

              diff = a - b;

              temp_res[width-1:0] <= diff[width-1:0];

              temp_res[2*width-1:width] <= 0;

              temp_cout <= diff[width];

              temp_oflow <= (a[width-1] != b[width-1]) && (diff[width-1] != a[width-1]);

         if (diff == 0) begin

           temp_g <= 0; temp_l <= 0; temp_e <= 1;

         end

         else if (diff > 0) begin

           temp_g <= 1; temp_l <= 0; temp_e <= 0;

         end 

         else begin

          temp_g <= 0; temp_l <= 1; temp_e <= 0;

         end

         end

          else

           temp_err<=1'b1;

          end 

     default:begin

             temp_res <= {2*width{1'b0}};

             temp_cout <= 1'b0;

             temp_oflow <= 1'b0;

             temp_g <= 1'b0;

             temp_e <= 1'b0;

             temp_l <= 1'b0;

             temp_err <= 1'b0;  

             end                         

        endcase

     end

  else begin

    case(cmd)

    4'd0:begin

         if(inp_valid==3)begin

         temp_res[width-1:0]<=opa&opb;

          temp_res[2*width-1:width] <= 0;

           end

            else

           temp_err<=1'b1;

         end 

    4'd1:begin

         if(inp_valid==3)begin

         temp_res[width-1:0]<=~(opa&opb);

          temp_res[2*width-1:width] <= 0;

           end

            else

           temp_err<=1'b1;

         end

    4'd2:begin

         if(inp_valid==3)begin

         temp_res[width-1:0]<=opa|opb;

          temp_res[2*width-1:width] <= 0;

           end

            else

           temp_err<=1'b1;

         end

    4'd3:begin

         if(inp_valid==3)begin

         temp_res[width-1:0]<=~(opa|opb);

          temp_res[2*width-1:width] <= 0;

           end

            else

           temp_err<=1'b1;

         end

    4'd4:begin

         if(inp_valid==3)begin

         temp_res[width-1:0]<=opa^opb;

          temp_res[2*width-1:width] <= 0;

           end

            else

           temp_err<=1'b1;

         end

    4'd5:begin

         if(inp_valid==3)begin

         temp_res[width-1:0]<=~(opa^opb);

          temp_res[2*width-1:width] <= 0;

           end

            else

           temp_err<=1'b1;

         end 

    4'd6:begin

         if(inp_valid==1||inp_valid==3)begin

         temp_res[width-1:0]<=~opa;

          temp_res[2*width-1:width] <= 0;

           end

            else

           temp_err<=1'b1;

         end 

    4'd7:begin

         if(inp_valid==2||inp_valid==3)begin

         temp_res[width-1:0]<=~opb;

          temp_res[2*width-1:width] <= 0;

           end

            else

           temp_err<=1'b1;

         end 

    4'd8:begin

         if(inp_valid==1||inp_valid==3)begin

         temp_res[width-1:0]<=(opa>>1);

          temp_res[2*width-1:width] <= 0;

           end

            else

           temp_err<=1'b1;

         end           

    4'd9:begin

         if(inp_valid==1||inp_valid==3)begin

         temp_res[width-1:0]<=(opa<<1);

          temp_res[2*width-1:width] <= 0;

           end

            else

           temp_err<=1'b1;

         end 

    4'd10:begin

         if(inp_valid==2||inp_valid==3)begin

         temp_res[width-1:0]<=(opb>>1);

          temp_res[2*width-1:width] <= 0;

           end

            else

           temp_err<=1'b1;

         end 

    4'd11:begin

         if(inp_valid==2||inp_valid==3)begin

         temp_res[width-1:0]<=(opb<<1);

          temp_res[2*width-1:width] <= 0;

           end

            else

           temp_err<=1'b1;

         end           

    4'd12:begin

          if(inp_valid==3) 

           begin

            temp_res[width-1:0]<=(opa<<opb[$clog2(width)-1:0])|(opa>>(width-opb[$clog2(width)-1:0]));

             temp_res[2*width-1:width] <= 0;

            temp_err<=|opb[width-1:($clog2(width)+1)];

          end

           else

           temp_err<=1'b1;

          end 

    4'd13:begin

          if(inp_valid==3) 

           begin

            temp_res[width-1:0]<=(opa>>opb[$clog2(width)-1:0])|(opa<<(width-opb[$clog2(width)-1:0]));

             temp_res[2*width-1:width] <= 0;

            temp_err<=|opb[width-1:($clog2(width)+1)];

          end

           else

           temp_err<=1'b1;

          end

     default:begin

             temp_res <= {2*width{1'b0}};

             temp_cout <= 1'b0;

             temp_oflow <= 1'b0;

             temp_g <= 1'b0;

             temp_e <= 1'b0;

             temp_l <= 1'b0;

             temp_err <= 1'b0;  

            end                                

    endcase

  end    

    end

    end

    end

assign a=opa;

assign b=opb;

endmodule

 
