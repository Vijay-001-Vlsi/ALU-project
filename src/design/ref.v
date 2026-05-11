module reference_module #(parameter N=8 ,parameter cmdn=4)(
input [N-1:0]opa,opb,
input cin,mode,ce,
input [1:0]in_val,
input [cmdn-1:0]cmd,
output reg [N*2-1:0]res,
output reg cout,oflow,g,l,e,err);

reg [7:0]opa_1,opb_1;
always @(*)begin
    res={2*N{1'b0}};
    cout=1'b0;
    oflow=1'b0;
    g=1'b0;
    l=1'b0;
    e=1'b0;
    err=1'b0;
    if(ce)begin
        if(mode)begin
            case(cmd)
                4'd0:begin
                    if(in_val==3)
                        {cout,res[N-1:0]}=opa+opb;
                    else
                        err=1;
                        end
                4'd1:begin
                    if(in_val==3)begin
                        res[N-1:0] =opa-opb;
                        oflow=(opa<opb);
                        end
                        else
                        err=1;
                        end
                4'd2:begin
                    if(in_val==3)
                        {cout,res[N-1:0]}=opa+opb+cin;
                        else
                        err=1;
                        end
                4'd3:begin
                    if(in_val==3)begin
                        res[N-1:0]=opa-opb-cin;
                        oflow=(opa<(opb+cin));
                        end
                        else
                        err=1;
                        end
                4'd4:begin
                    if(in_val==1 || in_val==3)begin
                        res=opa+1;
                        end
                        else
                        err=1;
                        end
                4'd5:begin
                    if(in_val==1 || in_val==3)begin
                        res=opa-1;
                        end
                        else
                        err=1;
                        end
                4'd6:begin
                    if(in_val==2 || in_val==3)begin
                        res=opb+1;
                        end
                        end
                4'd7:begin
                    if(in_val==2 || in_val==3)begin
                        res=opb-1;
                        end
                        else
                        err=1;
                        end
                4'd8:begin
                    if(in_val==3)begin
                        {g,e,l}={opa>opb,opa==opb,opa<opb};
                        end
                        else
                        err=1;
                        end
                4'd9:begin
			if(in_val==3||in_val==1||in_val==2)begin
                        res=(opa+1)*(opb+1);
                        end
                        else
                        err=1;
                        end
                4'd10:begin
                    if(in_val==3||in_val==1||in_val==2)begin
                        res=(opa<<1)*opb;
                        end
                        else
                        err=1;
                         end
                    4'd11: begin
        if(in_val == 3) begin
    
            res = $signed(opa) + $signed(opb);
    
            // Signed addition overflow
            oflow = ( opa[N-1] &  opb[N-1] & ~res[N-1]) |
                     (~opa[N-1] & ~opb[N-1] &  res[N-1]);
    
            {g,l,e} = {res > 0, res < 0, res == 0};
    
        end
        else
                        err=1;
    end
    
    4'd12: begin
        if(in_val == 3) begin
    
            res = $signed(opa) - $signed(opb);
    
            // Signed subtraction overflow
            oflow = ( opa[N-1] & ~opb[N-1] & ~res[N-1]) |
                     (~opa[N-1] &  opb[N-1] &  res[N-1]);
    
            {g,l,e} = {res > 0, res < 0, res == 0};
    
        end
        else
                        err=1;
    end
                        
    endcase
    end
    else
        begin
            case(cmd)
                4'd0:begin
                    if(in_val==3)
                        res=opa & opb;
                        else
                        err=1;
                        end
                4'd1:begin
                    if(in_val==3)
                        res=~(opa&opb);
                    else
                        err=1;
                    end
                4'd2:begin
                    if(in_val==3)
                        res=opa | opb;
                        else
                        err=1;
                        end  
                4'd3:begin
                    if(in_val==3)
                        res=~(opa | opb);
                        else
                        err=1;
                        end          
                4'd4:begin
                    if(in_val==3)
                        res=(opa ^ opb);
                        else
                        err=1;
                        end    
                4'd5:begin
                    if(in_val==3)
                        res=~(opa ^ opb);
                        else
                        err=1;
                        end    
                4'd6:begin
                    if(in_val==3 || in_val==1)
                        res=(~opa);
                        else
                        err=1;
                        end    
                4'd7:begin
                    if(in_val==3 || in_val==2)
                        res=(~opb);
                        else
                        err=1;
                       end  
                       
                  4'd8:begin
                    if(in_val==3 || in_val==1)
                        res=(opa>>1);
                        else
                        err=1;
                       end  
                       
                    4'd9:begin
                    if(in_val==3 || in_val==1)
                        res=(opa<<1);
                        else
                        err=1;
                       end   
                       
                   4'd10:begin
                    if(in_val==3 || in_val==2)
                        res=(opb>>1);
                        else
                        err=1;
                       end 
                    4'd11:begin
                    if(in_val==3 || in_val==2)
                        res=(opb<<1);
                        else
                        err=1;
                       end  
                    4'd12:begin
                         if(in_val==3 )begin
                            res[2*N-1:N]=0;
                            res[N-1:0]=(opa<<opb[$clog2(N)-1:0])|(opa>>(N-opb[$clog2(N)-1:0]));
                            err=(opb[N-1:$clog2(N)+1]>1);
                            end
                            else
                              err=1;
                            end
                    4'd13:begin
                         if(in_val==3 )begin
                            res[2*N-1:N]=0;
                            res[N-1:0]=(opa>>opb[$clog2(N)-1:0])|(opa<<(N-opb[$clog2(N)-1:0]));
                            err=(opb[N-1:$clog2(N)+1]>1);
                            end
                            else
                              err=1;
                            end
                            endcase
                            end     
                            end
                             end
                               
                     
endmodule

