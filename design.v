`timescale 1ns / 1ps
        //////////////////////////////////////////////////////////////////////////////////
        // Company: 
        // Engineer: 
        // 
        // Create Date: 05/04/2026 02:29:27 PM
        // Design Name: 
        // Module Name: alu_1
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
        
         
        
         
        
        module alu_1 #(parameter N =4)(
            input clk,
            input rst,
            input [1:0] inp_valid,
            input mode,ce,cin,input [N-1:0] opa,opb,input [3:0]cmd,
            output reg oflow,cout,g,l,e,err,output reg [2*N-1:0]res
            );
        wire signed [N-1:0] a,b;  
        reg[1:0]count,count_1,count_2;
        reg [N-1:0]opa_1,opb_1;
        reg [2*N-1:0]temp;
        reg signed [N:0] diff;
        reg signed [N:0] sum;
            always@(posedge clk or posedge rst)
            begin
              if(rst)
              count<=2'b0;
              else begin
              if(cmd==4'd9)
                count<=count+1;
              else
              count<=2'b0;   
            end
            end
        
           always@(posedge clk or posedge rst)
            begin
              if(rst)
              count_1<=2'b0;
              else begin
              if(cmd==4'd10)
                count_1<=count_1+1;
              else
              count_1<=2'b0;   
            end
            end 
            always @(posedge clk or posedge rst)
            begin
            if(rst)
             count_2 <= 0;
            else begin
            if(cmd==4'd0)
                count_2 <= count_2 + 1;
            else
                count_2 <= 0;
             end
            end
            always@(posedge clk or posedge rst)
            begin
            if(rst)
            begin
             res <= {2*N{1'b0}};
             cout <= 1'b0;
             oflow <= 1'b0;
             g <= 1'b0;
             e <= 1'b0;
             l <= 1'b0;
             err <= 1'b0;
            end
            else begin
            //default
             res <= {2*N{1'b0}};
             cout <= 1'b0;
             oflow <= 1'b0;
             g <= 1'b0;
             e <= 1'b0;
             l <= 1'b0;
             err <= 1'b0;
            if(ce)
             begin
             if(mode) begin
             case(cmd)
             4'd0: begin
             if(inp_valid==3)begin
             res<=opa+opb;
             cout<=res[N];
             end
             end
              4'd1:begin
                 if(inp_valid==3)begin
                     res<=opa-opb; 
                   if(opa<opb)                          
                     oflow<=1'b1;
                   else
                     oflow<=1'b0;  
                   end
                end  
             4'd2:begin
                 if(inp_valid==3) begin
                    res<=opa+opb+cin;
                    cout<=res[N];
                   end
                end
             4'd3:begin
                 if(inp_valid==3)begin
                   res<=opa-opb-cin;                      
                    if(opa<(opb+cin))                          
                     oflow<=1'b1;
                    else
                     oflow<=1'b0;  
                   end
                end         
             4'd4:begin
                 if(inp_valid==1) begin
                   res[N-1:0]<=opa+1;
                   res[2*N-1:N] <= 0;
                   end
                end
             4'd5:begin
                 if(inp_valid==1)begin 
                   res[N-1:0]<=opa-1;
                   res[2*N-1:N] <= 0;
                   end
                end 
            4'd6:begin
                 if(inp_valid==2)begin
                   res[N-1:0]<=opb+1;
                   res[2*N-1:N] <= 0;
                   end
                end 
            4'd7:begin
                 if(inp_valid==2) begin
                   res[N-1:0]<=opb-1;
                   res[2*N-1:N] <= 0;
                   end
                end 
            4'd8:begin
                 if(inp_valid==3)
                   begin
                            if (opa == opb) begin
                                g <= 0; l <= 0; e <= 1;
                            end else if (opa > opb) begin
                                 g <= 1; l <= 0; e <= 0;
                            end else begin
                                  g <= 0; l <= 1; e <= 0;
                            end
                        end
                   end                
             4'd9:begin
                  if(inp_valid==3) begin 
                   if(count == 0) begin
                      opa_1 <= opa;
                      opb_1 <= opb;
                  end
                  if(count==1)
                  temp<= (opa_1+1)*(opb_1+1);                                     
                    if(count==2)
                   res<=temp; 
                   end
                  end  
             4'd10:begin
                   if(inp_valid==3)  begin                  
                    if(count_1 == 0) begin
                      opa_1 <= opa;
                      opb_1 <= opb;
                  end
                  if(count_1==1)
                  temp<=(opa_1<<1)*opb_1;                                     
                   if(count_1==2)
                   res<=temp; 
                   end  
                  end  
            4'd11:begin
                    if(inp_valid == 3) begin
                       sum = a + b;
                       res[N-1:0] <= sum[N-1:0];
                       res[2*N-1:N] <= 0;
                       cout <= sum[N];
                       oflow <= (a[N-1] == b[N-1]) && (sum[N-1] != a[N-1]);
                   if (sum == 0) begin
                       g <= 0; l <= 0; e <= 1;
                    end 
                    else if (sum > 0) begin
                       g <= 1; l <= 0; e <= 0;
                    end 
                    else begin
                       g <= 0; l <= 1; e <= 0;
                    end
                   end
                   end      
            4'd12:begin
                  if(inp_valid == 3) begin
                      diff = a - b;
                      res[N-1:0] <= diff[N-1:0];
                      res[2*N-1:N] <= 0;
                      cout <= diff[N];
                      oflow <= (a[N-1] != b[N-1]) && (diff[N-1] != a[N-1]);
                 if (diff == 0) begin
                   g <= 0; l <= 0; e <= 1;
                 end
                 else if (diff > 0) begin
                   g <= 1; l <= 0; e <= 0;
                 end 
                 else begin
                  g <= 0; l <= 1; e <= 0;
                 end
                 end
                  end                   
                endcase
             end
        
          else begin
            case(cmd)
            4'd0:begin
                 if(inp_valid==3)begin
                 res[N-1:0]<=opa&opb;
                  res[2*N-1:N] <= 0;
                   end
                 end 
            4'd1:begin
                 if(inp_valid==3)begin
                 res[N-1:0]<=~(opa&opb);
                  res[2*N-1:N] <= 0;
                   end
                 end
            4'd2:begin
                 if(inp_valid==3)begin
                 res[N-1:0]<=opa|opb;
                  res[2*N-1:N] <= 0;
                   end
                 end
            4'd3:begin
                 if(inp_valid==3)begin
                 res[N-1:0]<=~(opa|opb);
                  res[2*N-1:N] <= 0;
                   end
                 end
            4'd4:begin
                 if(inp_valid==3)begin
                 res[N-1:0]<=opa^opb;
                  res[2*N-1:N] <= 0;
                   end
                 end
            4'd5:begin
                 if(inp_valid==3)begin
                 res[N-1:0]<=~(opa^opb);
                  res[2*N-1:N] <= 0;
                   end
                 end 
            4'd6:begin
                 if(inp_valid==1)begin
                 res[N-1:0]<=~opa;
                  res[2*N-1:N] <= 0;
                   end
                 end 
            4'd7:begin
                 if(inp_valid==2)begin
                 res[N-1:0]<=~opb;
                  res[2*N-1:N] <= 0;
                   end
                 end 
            4'd8:begin
                 if(inp_valid==1)begin
                 res[N-1:0]<=(opa>>1);
                  res[2*N-1:N] <= 0;
                   end
                 end           
            4'd9:begin
                 if(inp_valid==1)begin
                 res[N-1:0]<=(opa<<1);
                  res[2*N-1:N] <= 0;
                   end
                 end 
            4'd10:begin
                 if(inp_valid==2)begin
                 res[N-1:0]<=(opb>>1);
                  res[2*N-1:N] <= 0;
                   end
                 end 
            4'd11:begin
                 if(inp_valid==2)begin
                 res[N-1:0]<=(opb<<1);
                  res[2*N-1:N] <= 0;
                   end
                 end           
            4'd12:begin
                  if(inp_valid==3) 
                   begin
                     res<=(opa<<opb[$clog2(N)-1:0]) | (opa>>(N-opb[$clog2(N)-1:0]));
                     res[2*N-1:N] <= 0;
                    err<=|opb[N-1:($clog2(N)+1)];
                  end
                  end 
            4'd13:begin
                  if(inp_valid==3) 
                   begin
                    res[N-1:0]<=(opa>>opb[$clog2(N)-1:0])|(opa<<(N-opb[$clog2(N)-1:0]));
                     res[2*N-1:N] <= 0;
                    err<=|opb[N-1:($clog2(N)+1)];
                  end
                  end       
            endcase
          end    
        
            end
            end
            end
        assign a=opa;
        assign b=opb;
        
        endmodule
        

