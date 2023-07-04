module adc_init(
    input clk,rst,locked,
    output sdio,sclk,csb,
    output logic sc1_ac_h,sc1_ac_l,sc2_ac_h,sc2_ac_l,sc1_gain_h,sc1_gain_l,sc2_gain_h,sc2_gain_l,com_sc_h,com_sc_l
    );
    
    logic one,act;
    always_ff@(posedge clk)begin
        if(rst)begin
            act<=0;
            one<=0;
        end else begin
            if(locked&&!one)begin
                act<=1;
                one<=1;
            end else begin
                act<=0;
            end
        end
    end
    
    //relay setting
    logic busy;
    enum logic [2:0] {START,RESET,WAIT1,SET,WAIT2,FIN}state;
    logic [$clog2(10000):0]cnt;
    always_ff@(posedge clk)begin
        if(rst)begin
            cnt<=0;
            busy<=0;
            state<=START;
            sc1_ac_h<=1;
            sc1_ac_l<=1;
            sc2_ac_h<=1;
            sc2_ac_l<=1;
            sc1_gain_h<=1;
            sc1_gain_l<=1;
            sc2_gain_h<=1;
            sc2_gain_l<=1;
            com_sc_h<=1;
            com_sc_l<=1;
        end else begin
            if(act&&!busy)begin
                busy<=1;
            end else begin
                if(busy)begin
                    case(state)
                        START:begin
                            state<=RESET;
                        end
                        RESET:begin
                            state<=WAIT1;
                            com_sc_h<=1;
                            com_sc_l<=0;
                            sc1_ac_h<=0;
                            sc1_ac_l<=1;
                            sc2_ac_h<=0;
                            sc2_ac_l<=1;
                            sc1_gain_h<=0;
                            sc1_gain_l<=1;
                            sc2_gain_h<=0;
                            sc2_gain_l<=1;
                        end
                        WAIT1:begin
                            cnt<=cnt+1;
                            if(cnt==10000)begin
                                state<=SET;
                                cnt<=0;
                            end
                        end
                        SET:begin
                            state<=WAIT2;
                            com_sc_h<=0;
                            com_sc_l<=1;
                            sc1_ac_h<=1;
                            sc1_ac_l<=0;
                            sc2_ac_h<=1;
                            sc2_ac_l<=0;
                            sc1_gain_h<=1;
                            sc1_gain_l<=0;
                            sc2_gain_h<=1;
                            sc2_gain_l<=0;
                        end
                        WAIT2:begin
                            cnt<=cnt+1;
                            if(cnt==10000)begin
                                state<=FIN;
                            end
                        end
                        FIN:begin
                            busy<=0;
                            sc1_ac_h<=1;
                            sc1_ac_l<=1;
                            sc2_ac_h<=1;
                            sc2_ac_l<=1;
                            sc1_gain_h<=1;
                            sc1_gain_l<=1;
                            sc2_gain_h<=1;
                            sc2_gain_l<=1;
                            com_sc_h<=1;
                            com_sc_l<=1;
                        end
                        default:begin
                            busy<=0;
                        end
                    endcase
                end
            end
        end
    end
    
    //spi setting
    parameter [23:0]w_reg=(16'h14<<8)+8'h21;   //reg 16'h14 data 8'h21. spi ip is lsb first send. but adc is msb first send. transverse
    spi #(.div_ratio(50)) spi(
        .clk(clk),
        .rst(rst),
        .act(act),
        .miso(0),
        .tx_data({'b0,w_reg}),
        .len(24),
        .mode(0),
        .rx_data(),
        .busy(),
        .valid(),
        .mosi(sdio),
        .sck(sclk),
        .cs(csb)
        );
endmodule
