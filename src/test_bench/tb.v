timescale 1ns / 1ps

module sim_ref;

parameter N=8;
integer i;
reg clk;
reg rst;
reg [1:0] inp_valid;
reg mode,ce,cin;
reg [N-1:0] opa,opb;
reg [3:0] cmd;



wire dut_oflow,dut_cout,dut_g,dut_l,dut_e,dut_err;
wire [2*N-1:0] dut_res;



wire ref_oflow,ref_cout,ref_g,ref_l,ref_e,ref_err;
wire [2*N-1:0] ref_res;

reg [3:0] cmd_d1,cmd_d2,cmd_d3;
reg [N-1:0] opa_d1,opa_d2,opa_d3;
reg [N-1:0] opb_d1,opb_d2,opb_d3;

reg mode_d1,mode_d2,mode_d3;
reg cin_d1,cin_d2,cin_d3;
reg [2*N-1:0] exp_d1,exp_d2,exp_d3;
reg [1:0] valid_d1,valid_d2,valid_d3;
alu2 dut(
    opa,opb,cin,clk,rst,ce,mode,inp_valid,cmd,dut_res,
    dut_oflow,dut_cout,dut_g,dut_e,dut_l,dut_err
);


reference_module uut(
    opa,opb,cin,mode,ce,
    inp_valid,
    cmd,
    ref_res,
    ref_cout,
    ref_oflow,
    ref_g,
    ref_l,
    ref_e,
    ref_err
);



initial
    clk=0;

always #5 clk=~clk;


always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        ////////////////////////////////////////
        // expected results
        ////////////////////////////////////////

        exp_d1 <= 0;
        exp_d2 <= 0;
        exp_d3 <= 0;

        ////////////////////////////////////////
        // cmd
        ////////////////////////////////////////

        cmd_d1 <= 0;
        cmd_d2 <= 0;
        cmd_d3 <= 0;

        ////////////////////////////////////////
        // valid
        ////////////////////////////////////////

        valid_d1 <= 0;
        valid_d2 <= 0;
        valid_d3 <= 0;

        ////////////////////////////////////////
        // operands
        ////////////////////////////////////////

        opa_d1 <= 0;
        opa_d2 <= 0;
        opa_d3 <= 0;

        opb_d1 <= 0;
        opb_d2 <= 0;
        opb_d3 <= 0;

        ////////////////////////////////////////
        // mode
        ////////////////////////////////////////

        mode_d1 <= 0;
        mode_d2 <= 0;
        mode_d3 <= 0;

        ////////////////////////////////////////
        // cin
        ////////////////////////////////////////

        cin_d1 <= 0;
        cin_d2 <= 0;
        cin_d3 <= 0;
    end

    else
    begin

        ////////////////////////////////////////
        // expected result pipeline
        ////////////////////////////////////////

        exp_d1 <= ref_res;
        exp_d2 <= exp_d1;
        exp_d3 <= exp_d2;

        ////////////////////////////////////////
        // cmd pipeline
        ////////////////////////////////////////

        cmd_d1 <= cmd;
        cmd_d2 <= cmd_d1;
        cmd_d3 <= cmd_d2;

        ////////////////////////////////////////
        // valid pipeline
        ////////////////////////////////////////

        valid_d1 <= inp_valid;
        valid_d2 <= valid_d1;
        valid_d3 <= valid_d2;

        ////////////////////////////////////////
        // operand pipeline
        ////////////////////////////////////////

        opa_d1 <= opa;
        opa_d2 <= opa_d1;
        opa_d3 <= opa_d2;

        opb_d1 <= opb;
        opb_d2 <= opb_d1;
        opb_d3 <= opb_d2;

        ////////////////////////////////////////
        // mode pipeline
        ////////////////////////////////////////

        mode_d1 <= mode;
        mode_d2 <= mode_d1;
        mode_d3 <= mode_d2;

        ////////////////////////////////////////
        // cin pipeline
        ////////////////////////////////////////

        cin_d1 <= cin;
        cin_d2 <= cin_d1;
        cin_d3 <= cin_d2;

    end
end
initial
begin

    clk = 0;

    rst = 0;
    ce  = 0;

    mode = 0;
    cin  = 0;

    inp_valid = 0;

    opa = 0;
    opb = 0;

    cmd = 0;

end
task reset;
begin
    rst=1;
    ce=0;

    repeat(2) @(posedge clk);

    rst=0;
    ce=1;
end
endtask


task gen_driver;
begin
	@(negedge clk);
	rst=1;
	repeat(3)@(posedge clk);
 	@(negedge clk);
rst=0;

    //////////////////////////////////////////////////
    // CONDITION COVERAGE FOR CMD 9
    //////////////////////////////////////////////////

    // cmd == 9

    @(negedge clk);

    mode      = 1;
    cmd       = 9;
    inp_valid = 3;
    cin       = 0;
    ce=0;
    opa = 8'd10;
    opb = 8'd5;


    repeat(2) @(posedge clk);

    //////////////////////////////////////////////////
    // cmd != 9
    //////////////////////////////////////////////////

    @(negedge clk);

    mode      = 1;
    cmd       = 2;
    inp_valid = 3;
    cin       = 0;
    ce=1;
    opa = 8'd20;
    opb = 8'd3;

    repeat(2) @(posedge clk);

    //////////////////////////////////////////////////
    // CONDITION COVERAGE FOR CMD 10
    //////////////////////////////////////////////////

    // cmd == 10

    @(negedge clk);

    mode      = 1;
    cmd       = 10;
    inp_valid = 3;
    cin       = 0;

    opa = 8'd8;
    opb = 8'd2;

    repeat(2) @(posedge clk);

    //////////////////////////////////////////////////
    // cmd != 10
    //////////////////////////////////////////////////

    @(negedge clk);

    mode      = 1;
    cmd       = 1;
    inp_valid = 3;
    cin       = 0;

    opa = 8'd15;
    opb = 8'd7;

    repeat(3) @(posedge clk);

    //////////////////////////////////////////////////
    // signed subtraction overflow coverage
    //////////////////////////////////////////////////

    @(negedge clk);

    mode      = 1;
    cmd       = 12;
    inp_valid = 3;
    cin       = 0;

    opa = 8'd100;
    opb = -8'd50;

    repeat(5) @(posedge clk);

    //////////////////////////////////////////////////
    // equality coverage
    //////////////////////////////////////////////////

    @(negedge clk);

    mode      = 1;
    cmd       = 8;
    inp_valid = 3;

    opa = 8'd25;
    opb = 8'd25;

    repeat(1) @(posedge clk);

    //////////////////////////////////////////////////
    // equality back to zero
    //////////////////////////////////////////////////

    @(negedge clk);

    mode      = 1;
    cmd       = 8;
    inp_valid = 3;

    opa = 8'd10;
    opb = 8'd20;

    repeat(1) @(posedge clk);

    //////////////////////////////////////////////////
    // large multiplication for toggle coverage
    //////////////////////////////////////////////////

    @(negedge clk);

    mode      = 1;
    cmd       = 9;
    inp_valid = 3;

    opa = 8'd255;
    opb = 8'd255;
@(negedge clk);

mode      = 1;
cmd       = 11;
inp_valid = 3;
cin       = 0;

opa = 8'd100;
opb = 8'd50;

repeat(5) @(posedge clk);
@(negedge clk);
mode=1;
opa = -8'b01011000;
opb = -8'b10101001;
cmd=11;
inp_valid=3;
repeat(5)@(posedge clk);
@(negedge clk);
mode=0;
cmd=10;
repeat(5)@(posedge clk);
    //////////////////////////////////////////////////
    // RANDOM TESTING
    //////////////////////////////////////////////////

    repeat(300)
    begin

        @(negedge clk);

        opa = $unsigned($random);
        opb = $unsigned($random);

        inp_valid = $unsigned($random)%4;

        mode = $unsigned($random)%2;

        cin = $unsigned($random)%2;

        cmd = $unsigned($random)%14;
        repeat(3)@(posedge clk);
    end

/////////////////////////////////////////////////
// CMD 12 coverage
/////////////////////////////////////////////////

for(i=0;i<8;i=i+1)
begin

    @(negedge clk);

    mode      = 0;
    cmd       = 12;
    inp_valid = 3;
    ce        = 1;

    opa = 8'b10101010;

    opb = i;

    repeat(1) @(posedge clk);

end

/////////////////////////////////////////////////
// CMD 13 coverage
/////////////////////////////////////////////////

for(i=0;i<8;i=i+1)
begin

    @(negedge clk);

    mode      = 0;
    cmd       = 13;
    inp_valid = 3;
    ce        = 1;

    opa = 8'b10101010;

    opb = i;

    repeat(1) @(posedge clk);

end 
    $finish;

end
endtask

task monitor_scb;

begin

forever
begin

    @(posedge clk);

    //////////////////////////////////////////////////////
    // MULTIPLICATION OPERATIONS (3-cycle delay)
    //////////////////////////////////////////////////////

    if((cmd_d3 == 9 || cmd_d3 == 10) && valid_d3 == 3)
    begin

        if(dut_res == exp_d3)
        begin

            $display("\nPASS MUL");

            $display("TIME=%0t", $time);

            $display("INPUTS -> mode=%0d cmd=%0d cin=%0d inp_valid=%0d opa=%0d opb=%0d",
                     mode_d3,cmd_d3,cin_d3,valid_d3,
                     opa_d3,opb_d3);

            $display("DUT -> res=%0d oflow=%0d cout=%0d g=%0d e=%0d l=%0d err=%0d",
                     dut_res,dut_oflow,dut_cout,
                     dut_g,dut_e,dut_l,dut_err);

            $display("REF -> res=%0d oflow=%0d cout=%0d g=%0d e=%0d l=%0d err=%0d",
                     exp_d3,ref_oflow,ref_cout,
                     ref_g,ref_e,ref_l,ref_err);

        end

        else
        begin

            $display("\nFAIL MUL");

            $display("TIME=%0t", $time);

            $display("INPUTS -> mode=%0d cmd=%0d cin=%0d inp_valid=%0d opa=%0d opb=%0d",
                     mode_d3,cmd_d3,cin_d3,valid_d3,
                     opa_d3,opb_d3);

            $display("DUT -> res=%0d oflow=%0d cout=%0d g=%0d e=%0d l=%0d err=%0d",
                     dut_res,dut_oflow,dut_cout,
                     dut_g,dut_e,dut_l,dut_err);

            $display("REF -> res=%0d oflow=%0d cout=%0d g=%0d e=%0d l=%0d err=%0d",
                     exp_d3,ref_oflow,ref_cout,
                     ref_g,ref_e,ref_l,ref_err);

        end

    end

    //////////////////////////////////////////////////////
    // NORMAL OPERATIONS (2-cycle delay)
    //////////////////////////////////////////////////////

    else if(valid_d2 == 3 || valid_d2 == 1||valid_d2 == 2)
    begin

        if(dut_res == exp_d2)
        begin

            $display("\nPASS");

            $display("TIME=%0t", $time);

            $display("INPUTS -> mode=%0d cmd=%0d cin=%0d inp_valid=%0d opa=%0d opb=%0d",
                     mode_d2,cmd_d2,cin_d2,valid_d2,
                     opa_d2,opb_d2);

            $display("DUT -> res=%0d oflow=%0d cout=%0d g=%0d e=%0d l=%0d err=%0d",
                     dut_res,dut_oflow,dut_cout,
                     dut_g,dut_e,dut_l,dut_err);

            $display("REF -> res=%0d oflow=%0d cout=%0d g=%0d e=%0d l=%0d err=%0d",
                     exp_d2,ref_oflow,ref_cout,
                     ref_g,ref_e,ref_l,ref_err);

        end

        else
        begin

            $display("\nFAIL");

            $display("TIME=%0t", $time);

            $display("INPUTS -> mode=%0d cmd=%0d cin=%0d inp_valid=%0d opa=%0d opb=%0d",
                     mode_d2,cmd_d2,cin_d2,valid_d2,
                     opa_d2,opb_d2);

            $display("DUT -> res=%0d oflow=%0d cout=%0d g=%0d e=%0d l=%0d err=%0d",
                     dut_res,dut_oflow,dut_cout,
                     dut_g,dut_e,dut_l,dut_err);

            $display("REF -> res=%0d oflow=%0d cout=%0d g=%0d e=%0d l=%0d err=%0d",
                     exp_d2,ref_oflow,ref_cout,
                     ref_g,ref_e,ref_l,ref_err);

        end

    end

end

end

endtask
initial
begin

    reset();

    fork
        gen_driver();
        monitor_scb();
    join

   

end

endmodule
