module alu2 #(parameter N=8)(
input [N-1:0] opa,
input [N-1:0] opb,
input cin,
input clk,
input rst,
input ce,
input mode,
input [1:0] inp_valid,
input [(N/2)-1:0] cmd,
output reg [2*N-1:0] res,
output reg oflow,cout,g,e,l,err
);

reg [1:0] cnt;
reg [N-1:0] tempa,tempb;
reg rep=1'b0;
reg [2*N-1:0] temp;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        temp <= {2*N{1'b0}};
        res<=0;
        oflow <= 1'b0;
        cout <= 1'b0;
        g <= 1'b0;
        e <= 1'b0;
        l <= 1'b0;
        err <= 1'b0;
        cnt <= 2'b00;
    end
    else begin

        if(!ce) begin
           temp<= {2*N{1'b0}};
           res<=temp;
          oflow <= 1'b0;
                     cout <= 1'b0;
                      g <= 1'b0;
                     e <= 1'b0;
                     l <= 1'b0;
                      err <= 1'b0;
        end

        else begin

            if(mode) begin

                if(cmd != 4'd9) begin
                    cnt <= 2'b00;
                end

                case(inp_valid)

                    2'b00: begin
                      temp <= {2*N{1'b0}};
                      res<=temp;
                        oflow <= 1'b0;
                     cout <= 1'b0;
                      g <= 1'b0;
                     e <= 1'b0;
                     l <= 1'b0;
                      err <= 1'b1;
                    end

                    2'b01: begin
                     oflow <= 1'b0;
                     cout <= 1'b0;
                      g <= 1'b0;
                     e <= 1'b0;
                     l <= 1'b0;
                      err <= 1'b0;
                        case(cmd)
                            4'd4:begin temp <= opa + 1'b1; cout<=1'b0; res<=temp; end
                            4'd5:begin temp <= opa - 1'b1;cout<=1'b0;res<=temp;  end
                            default: begin temp <= {2*N{1'b0}}; err<=1'b1; res<=temp;end
                        endcase
                    end

                    2'b10: begin
                     oflow <= 1'b0;
                     cout <= 1'b0;
                     g <= 1'b0;
                     e <= 1'b0;
                     l <= 1'b0;
                     err <= 1'b0;
                        case(cmd)
                            4'd6:begin temp <= opb + 1'b1;cout<=1'b0;res<=temp; end
                            4'd7:begin temp <= opb - 1'b1;res<=temp; end
                            default:  begin temp <= {2*N{1'b0}}; err<=1'b1;res<=temp; end
                        endcase
                    end

                    2'b11: begin
                     temp <= {2*N{1'b0}};
                     res<=temp;
                     oflow <= 1'b0;
                     cout <= 1'b0;
                     g <= 1'b0;
                     e <= 1'b0;
                    l <= 1'b0;
                     err <= 1'b0;
                        case(cmd)

                            4'd0: begin
                               {cout, temp[N-1:0]} <= opa + opb;
                               temp[2*N-1:N]={N-1{1'b0}};
                               res<=temp;
                            end

                            4'd1: begin
                                temp <= opa - opb;
                                oflow <= (opa < opb) ? 1'b1 : 1'b0;
                                res<=temp;
                            end

                            4'd2: begin
                                {cout,temp[N-1:0]} <= opa + opb + cin;
                                temp[2*N-1:N]={N-1{1'b0}};
                                res<=temp;
                            end
                            
                            4'd3: begin
                                temp<= opa - opb - cin;
                                oflow <= (opa < opb) ? 1'b1 : 1'b0;
                                res<=temp;
                            end
                            
                            4'd4:begin temp <= opa + 1'b1; cout<=1'b0; res<=temp; end
                            4'd5:begin temp <= opa - 1'b1;cout<=1'b0;res<=temp;  end
                            4'd6:begin temp <= opb + 1'b1;cout<=1'b0;res<=temp; end
                            4'd7:begin temp <= opb - 1'b1;res<=temp; end
                            4'd8: begin
                                if(opa > opb) begin
                                    g <= 1'b1;
                                    e <= 1'b0;
                                    l <= 1'b0;
                                end
                                else if(opa == opb) begin
                                    g <= 1'b0;
                                    e <= 1'b1;
                                    l <= 1'b0;
                                end
                                else begin
                                    g <= 1'b0;
                                    e <= 1'b0;
                                    l <= 1'b1;
                                end
                                
                            end

                            4'd9: begin

                                if(mode != 1'b1 || cmd != 4'd9) begin
                                    cnt <= 2'b00;
                                    temp <= {2*N{1'b0}};
                                    res<=temp;
                                end

                                else begin

                                    if(cnt == 2'b00) begin
                                        tempa <= opa;
                                        tempb <= opb;
                                        cnt <= cnt + 1'b1;
                                        temp <= {2*N{1'b0}};
                                        res<=temp;
                                    end
//                                   else if(cnt==2'b10 && rep==1'b1)
//                                   begin
//                                      cnt<=2'b01;
//                                   end
                                   else if(cnt == 2'b01) begin
                                        cnt <= cnt + 1'b1;
                                        temp <= {2*N{1'b0}};
                                        res<=temp;
                                    end

                                    else if(cnt == 2'b10) begin
                                        temp <= (tempa + 1'b1) * (tempb + 1'b1);
                                        res<=temp;
                                       // cnt <= 2'b00;
                                        if(cmd==4'd9 )
                                           begin
                                            //rep=1'b1;
                                            tempa<=opa;
                                            tempb<=opb; 
                                            cnt<=2'b01; 
                                           end
                                         else
                                         cnt<=2'b00;  
                                    end

                                end
                                cout<=0;
                            end

                            4'd10: begin
                             if(mode != 1'b1 || cmd != 4'd10) begin
                                    cnt <= 2'b00;
                                    temp <= {2*N{1'b0}};
                                    res<=temp;
                                end

                                else begin

                                    if(cnt == 2'b00) begin
                                        tempa <= opa;
                                        tempb <= opb;
                                        cnt <= cnt + 1'b1;
                                        temp <= {2*N{1'b0}};
                                        res<=temp;
                                    end

                                   else if(cnt == 2'b01) begin
                                        cnt <= cnt + 1'b1;
                                        temp <= {2*N{1'b0}};
                                        res<=temp;
                                    end

                                    else if(cnt == 2'b10) begin
                                        temp <= (tempa << 1) * tempb;
                                        res<=temp;
                                        
                                        if(cmd==4'd10)
                                           begin
                                            tempa<=opa;
                                            tempb<=opb; 
                                            cnt<=2'b01; 
                                           end
                                        else
                                         cnt<=2'b00;   
                                    end

                                end
                                cout<=0;
                              //  res <= (opa << 1) * opb;
                           
                            end

                            4'd11: begin
                                temp <= $signed(opa) + $signed(opb);
                                res<=temp;
                                oflow <= (opa[N-1] == opb[N-1]) && (opa[N-1] != res[N-1]);

                                if(opa > opb) begin
                                    g <= 1'b1;
                                    e <= 1'b0;
                                    l <= 1'b0;
                                end
                                else if(opa == opb) begin
                                    g <= 1'b0;
                                    e <= 1'b1;
                                    l <= 1'b0;
                                end
                                else begin
                                    g <= 1'b0;
                                    e <= 1'b0;
                                    l <= 1'b1;
                                end
                              
                            end

                            4'd12: begin
                                temp <= $signed(opa) - $signed(opb);
                                res<=temp;
                                oflow <= (opa[N-1] != opb[N-1]) && (opa[N-1] != res[N-1]);

                                if($signed(opa) > $signed(opb)) begin
                                    g <= 1'b1;
                                    e <= 1'b0;
                                    l <= 1'b0;
                                end
                                else if($signed(opa) == $signed(opb)) begin
                                    g <= 1'b0;
                                    e <= 1'b1;
                                    l <= 1'b0;
                                end
                                else begin
                                    g <= 1'b0;
                                    e <= 1'b0;
                                    l <= 1'b1;
                                end
                            end

                            default:  begin temp <= {2*N{1'b0}}; err<=1'b1;res<=temp; end

                        endcase
                    end

                    default:  begin temp <= {2*N{1'b0}}; err<=1'b1; res<=temp;end

                endcase
             
            end

            else begin

                temp <= {2*N{1'b0}};
                res<=temp;
                oflow <= 1'b0;
                cout <= 1'b0;
                g <= 1'b0;
                e <= 1'b0;
                l <= 1'b0;
                err <= 1'b0;

                case(inp_valid)

                    2'b00: begin
                 temp <= {2*N{1'b0}};
                 res<=temp;
                oflow <= 1'b0;
                cout <= 1'b0;
                g <= 1'b0;
                e <= 1'b0;
                l <= 1'b0;
                err <= 1'b1;
                    end

                    2'b01: begin
                        temp <= {2*N{1'b0}};
                        res<=temp;
                        oflow <= 1'b0;
                cout <= 1'b0;
                g <= 1'b0;
                e <= 1'b0;
                l <= 1'b0;
                err <= 1'b0;
                        case(cmd)
                            4'd6: begin temp <={{N{1'b0}},~opa};res<=temp; end
                            4'd8:begin temp <= (opa >> 1);res<=temp; end
                            4'd9:begin temp <= (opa << 1);res<=temp; end
                            default:  begin temp <= {2*N{1'b0}}; err<=1'b1;res<=temp; end
                        endcase
                    end

                    2'b10: begin
                temp <= {2*N{1'b0}};
                res<=temp;
                oflow <= 1'b0;
                cout <= 1'b0;
                g <= 1'b0;
                e <= 1'b0;
                l <= 1'b0;
                err <= 1'b0;
                        case(cmd)
                           4'd6: begin temp <={{N{1'b0}},~opa};res<=temp; end
                            4'd8:begin temp <= (opa >> 1);res<=temp; end
                            4'd9:begin temp <= (opa << 1);res<=temp; end
                            default: begin temp <= {2*N{1'b0}}; err<=1'b1;res<=temp; end
                        endcase
                    end

2'b11: begin
    temp <= {2*N{1'b0}};
    res  <= temp;

    oflow <= 1'b0;
    cout  <= 1'b0;
    g     <= 1'b0;
    e     <= 1'b0;
    l     <= 1'b0;
    err   <= 1'b0;

    case(cmd)

        4'd0: begin
            temp <= {{N{1'b0}}, opa & opb};
            res  <= temp;
        end

        4'd1: begin
            temp <= {{N{1'b0}}, ~(opa & opb)};
            res  <= temp;
        end

        4'd2: begin
            temp <= {{N{1'b0}}, (opa | opb)};
            res  <= temp;
        end

        4'd3: begin
            temp <= {{N{1'b0}}, ~(opa | opb)};
            res  <= temp;
        end

        4'd4: begin
            temp <= {{N{1'b0}}, (opa ^ opb)};
            res  <= temp;
        end

        4'd5: begin
            temp <= {{N{1'b0}}, ~(opa ^ opb)};
            res  <= temp;
        end
        4'd6: begin temp <={{N{1'b0}},~opa};res<=temp; end
        4'd8:begin temp <= (opa >> 1);res<=temp; end
        4'd9:begin temp <= (opa << 1);res<=temp; end
       4'd6: begin temp <={{N{1'b0}},~opa};res<=temp; end
        4'd8:begin temp <= (opa >> 1);res<=temp; end
        4'd9:begin temp <= (opa << 1);res<=temp; end
        4'd12: begin
            err <= (|opb[7:4]) ? 1'b1 : 1'b0;

            case(opb[2:0])

                3'b000: begin
                    temp <= opa;
                    res  <= temp;
                end

                3'b001: begin
                    temp <= {{N{1'b0}}, opa[6:0], opa[7]};
                    res  <= temp;
                end

                3'b010: begin
                    temp <= {{N{1'b0}}, opa[5:0], opa[7:6]};
                    res  <= temp;
                end

                3'b011: begin
                    temp <= {{N{1'b0}}, opa[4:0], opa[7:5]};
                    res  <= temp;
                end

                3'b100: begin
                    temp <= {{N{1'b0}}, opa[3:0], opa[7:4]};
                    res  <= temp;
                end

                3'b101: begin
                    temp <= {{N{1'b0}}, opa[2:0], opa[7:3]};
                    res  <= temp;
                end

                3'b110: begin
                    temp <= {{N{1'b0}}, opa[1:0], opa[7:2]};
                    res  <= temp;
                end

                3'b111: begin
                    temp <= {{N{1'b0}}, opa[0], opa[7:1]};
                    res  <= temp;
                end

                default: begin
                    temp <= {2*N{1'b0}};
                    res  <= temp;
                end
            endcase
        end

        4'd13: begin
            err <= (|opb[7:4]) ? 1'b1 : 1'b0;

            case(opb[2:0])

                3'b000: begin
                    temp <= opa;
                    res  <= temp;
                end

                3'b001: begin
                    temp <= {{N{1'b0}}, opa[0], opa[7:1]};
                    res  <= temp;
                end

                3'b010: begin
                    temp <= {{N{1'b0}}, opa[1:0], opa[7:2]};
                    res  <= temp;
                end

                3'b011: begin
                    temp <= {{N{1'b0}}, opa[2:0], opa[7:3]};
                    res  <= temp;
                end

                3'b100: begin
                    temp <= {{N{1'b0}}, opa[3:0], opa[7:4]};
                    res  <= temp;
                end

                3'b101: begin
                    temp <= {{N{1'b0}}, opa[4:0], opa[7:5]};
                    res  <= temp;
                end

                3'b110: begin
                    temp <= {{N{1'b0}}, opa[5:0], opa[7:6]};
                    res  <= temp;
                end

                3'b111: begin
                    temp <= {{N{1'b0}}, opa[6:0], opa[7]};
                    res  <= temp;
                end

                default: begin
                    temp <= {2*N{1'b0}};
                    res  <= temp;
                    err  <= 1'b1;
                end
            endcase
        end

        default: begin
            temp <= {2*N{1'b0}};
            res  <= temp;
            err  <= 1'b1;
        end


                        endcase
                    end
                endcase
            end
        end
    end
end

endmodule

