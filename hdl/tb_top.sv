`timescale 1ns / 1ps
module tb_top();
    bit mclk,ext_rst;
    logic signed [9:0]out;
    logic dac_clk,awgclk,rel,adc_clk_in,adc_clkp,adc_clkn;
    logic [13:0]dac,adc;
    logic [8:1]pmod;
    logic sdio,sclk,csb;
    logic sc1_ac_h,sc1_ac_l,sc2_ac_h,sc2_ac_l,sc1_gain_h,sc1_gain_l,sc2_gain_h,sc2_gain_l,com_sc_h,com_sc_l;
    
    assign adc=out;
    
    always #4ns mclk<=!mclk;
    
    initial begin
        @(posedge dut.locked);
        #100us
        $finish;
    end
    
    top dut(.*);
    nco_sim nco(.*);
endmodule