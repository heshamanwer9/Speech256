// 
// PWMDAC testbench
//
// Niels Moseley - Moseley Instruments 2017
// http://www.moseleyinstruments.com
//

module SPEECH256_TOP_TB;
    reg clk, rst_an; 
    reg [5:0] data_in;
    reg data_stb;
    wire sample_stb;
    wire signed [15:0] sample_out;
    wire ldq,pwm_out;

    reg [7:0] allophones[0:10];
    reg [3:0] allo_idx;

    SPEECH256_TOP u_speech256_top (
        .clk        (clk),
        .rst_an     (rst_an),
        .ldq        (ldq),
        .data_in    (data_in),
        .data_stb   (data_stb),
        .pwm_out    (pwm_out),
        .sample_out (sample_out),
        .sample_stb (sample_stb)
    );

    integer fd; // file descriptor

    initial
    begin
        // hello, world
        allophones[0] = 6'h1B;
        allophones[1] = 6'h07;
        allophones[2] = 6'h2D;
        allophones[3] = 6'h35;
        allophones[4] = 6'h03;
        allophones[5] = 6'h2E;
        allophones[6] = 6'h1E;
        allophones[7] = 6'h33;
        allophones[8] = 6'h2D;
        allophones[9] = 6'h15;
        allophones[10] = 6'h03;
        allophones[11] = 6'h00;

        fd = $fopen("dacout.sw","wb");
        $dumpfile ("speech256_top.vcd");
        $dumpvars;
        clk = 0;
        rst_an = 0;
        allo_idx = 0;
        #5
        rst_an <= 1;
        //#5
        //#9000000
        //$fclose(fd);
        //$finish;
    end

    reg last_sample_stb;
    always @(posedge clk)
    begin
        // check for new output sample
        if ((sample_stb == 1) && (last_sample_stb != sample_stb))
        begin
            $fwrite(fd,"%u", $signed( {sample_out, 16'h0000} ));
        end
        last_sample_stb <= sample_stb;

        // check for next allophone
        if ((ldq == 1) && (data_stb == 0))
        begin
            data_stb <= 1;
            data_in  <= allophones[allo_idx];
            $display("Allophone %d", allo_idx);
            allo_idx <= allo_idx + 1;
            if (allo_idx == 11)
                $finish;
        end
        else
            data_stb <= 0;
    end

    always
        #5 clk = !clk;

endmodule
