module top(
    input ext_rst,mclk,
    output dac_clk,awgclk,rel,
    output [13:0]dac,
    input [13:0]adc,
    input adc_clk_in,
    output adc_clkp,
    output adc_clkn,
    output [8:1]pmod,
    output sdio,sclk,csb,
    output logic sc1_ac_h,sc1_ac_l,sc2_ac_h,sc2_ac_l,sc1_gain_h,sc1_gain_l,sc2_gain_h,sc2_gain_l,com_sc_h,com_sc_l
    );
    
    logic clk,rst,locked;
    assign rst=!locked;
    assign awgclk=dac_clk;
    assign adc_clkn=!adc_clkp;
    assign rel=1;   //output relay on
    
    //in/out double latch. signed-unsigned change, bit width change
    logic signed [15:0]s_adc1,s_adc2,s_dac1,s_dac2;
    logic [13:0]dl1,dl2;    //input double latch
    logic [13:0]ol1,ol2;  //output latch
    assign  dac=(clk)?ol1:ol2;
    always_ff@(posedge clk)begin
        if(rst)begin
            dl1<=0;
            s_adc1<=0;
            s_adc2<=0;
            ol1<=0;
            ol2<=0;
        end else begin
            dl1<=adc;
            s_adc1<=$signed(dl1)<<<2;
            s_adc2<=$signed(dl2)<<<2;
            ol1<=$unsigned((s_dac1>>>2)+(1<<13));
            ol2<=$unsigned((s_dac2>>>2)+(1<<13));
        end
    end
    always_ff@(negedge clk)begin
        if(rst)begin
            dl2<=0;
        end else begin
            dl2<=adc;
        end
    end
    
    adc_init adc_init(
        .clk(clk),
        .rst(rst),
        .locked(locked),
        .sdio(sdio),
        .sclk(sclk),
        .csb(csb),
        .sc1_ac_h(sc1_ac_h),
        .sc1_ac_l(sc1_ac_l),
        .sc2_ac_h(sc2_ac_h),
        .sc2_ac_l(sc2_ac_l),
        .sc1_gain_h(sc1_gain_h),
        .sc1_gain_l(sc1_gain_l),
        .sc2_gain_h(sc2_gain_h),
        .sc2_gain_l(sc2_gain_l),
        .com_sc_h(com_sc_h),
        .com_sc_l(com_sc_l)
        );
    
    clk_wiz_0 mmcm(
        .clk_out1(clk),
        .clk_out2(dac_clk),
        .clk_out3(adc_clkp),
        .clk_in1(mclk),
        .locked(locked)
        );
        
    sub_top_fir_rate sub_top(
        .clk(clk),
        .rst(rst),
        .din1(s_adc1),
        .dout1(s_dac1),
        .din2(s_adc2),
        .dout2(s_dac2),
        .pmod(pmod)
        );
endmodule
