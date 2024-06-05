`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         维瓦（昆明）电子科技有限公司
// Engineer:        于奇
// 
// Create Date:     2024/05/27 13:13:45
// Design Name:     SM4
// Module Name:     SM4_Decrypt
// Project Name:    project_1
// Target Devices:  XC7Z035FFG676-2
// Tool Versions:   VIVADO2018.3
// Description:     SM4加密与解密算法
//                  
// Dependencies:    无
// 
// Revision:        V0.1
// Revision 0.01 - File Created
// Additional Comments: 开源代码；概不负责；
// 
//////////////////////////////////////////////////////////////////////////////////
//pipe line处理
//潜伏期193 cycle

module SM4_Decrypt#(
    parameter [127:0] P_INITIAL_KEY = 128'h000102030405060708090A0B0C0D0E0F
)(
    input           i_clk           ,
    input           i_rst           ,
    
    input  [127:0]  i_Initial_Key   ,
    input           i_Initial_valid ,

    input  [127:0]  i_axis_data     ,
    input           i_axis_valid    ,
    output          o_axis_ready    ,      

    output [127:0]  o_axim_data     ,
    output          o_axim_valid    
);

reg  [127:0]        r_Initial_key[0 :32]    ;
reg                 r_Initial_valid[0 :32]  ;
reg  [31 :0]        r_rK[0 :31]             ;
reg  [127:0]        ri_axis_data            ;
reg                 ri_axis_valid           ;
reg  [127:0]        r_round_data[0:32]      ;
reg  [127:0]        r_round_data_old        ;
reg                 r_round_valid[0:32]     ;
reg                 ro_axis_ready           ;
reg  [127:0]        ro_axim_data            ;
reg                 ro_axim_valid           ;
reg  [31 :0]        r_round_result28[0:17]  ;
reg  [31 :0]        r_round_result29[0:11]  ;
reg  [31 :0]        r_round_result30[0:5]   ;

wire [31:0]         w_Encrypt_Key[0 :31]    ;
wire                w_Encrypt_valid[0 :31]  ;
wire [31:0]         w_round_data[0:31]      ;
wire                w_round_valid[0:31]     ;
wire                w_axis_active           ;
wire [127:0]        w_K[0:31]               ; 
wire [127:0]        w_round_next_data[0:63] ;

assign o_axis_ready = ro_axis_ready         ;
assign w_axis_active = i_axis_valid & o_axis_ready;  
assign o_axim_data  = ro_axim_data          ;
assign o_axim_valid = ro_axim_valid         ;

genvar i;
generate 
    for(i = 0 ; i < 32 ; i = i + 1)
    begin:Gen_Key
        Key_Extending Key_Extending_ux(
            .i_clk               (i_clk                     ),
            .i_rst               (i_rst | i_Initial_valid   ),
            .i_i                 (i                         ),
            .i_Initial_Key       (r_Initial_key[i]          ),
            .i_Initial_valid     (r_Initial_valid[i]        ),
            .o_Encrypt_Key       (w_Encrypt_Key[i]          ),
            .o_Encrypt_valid     (w_Encrypt_valid[i]        ),
            .o_K                 (w_K[i]                    )
        );
    

    
    always@(posedge i_clk,posedge i_rst)
    begin
        if(i_rst)
            r_rK[i] <= 'd0;
        else 
            r_rK[i] <= w_Encrypt_Key[i];
    end

    if(i > 0) begin
        always@(posedge i_clk,posedge i_rst)
        begin
            if(i_rst) begin
                r_Initial_key[i]   <= 'd0;
                r_Initial_valid[i] <= 'd0;
            end else if(i_Initial_valid) begin
                r_Initial_key[i]   <= 'd0;
                r_Initial_valid[i] <= 'd0;
            end else begin
                r_Initial_key[i]   <= w_K[i - 1];
                r_Initial_valid[i] <= w_Encrypt_valid[i - 1]    ;
            end
        end
    end
    
    end
    
endgenerate

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        r_Initial_key[0]   <= P_INITIAL_KEY;
        r_Initial_valid[0] <= 'd0;
    end else if(i_Initial_valid) begin
        r_Initial_key[0]   <= i_Initial_Key;
        r_Initial_valid[0] <= 'd1;
    end else begin
        r_Initial_key[0]   <= r_Initial_key[0]      ;
        r_Initial_valid[0] <= 'd1;
    end
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        r_Initial_key[32]   <= 'd0;
        r_Initial_valid[32] <= 'd0;
    end else if(i_Initial_valid) begin 
        r_Initial_key[32]   <= 'd0;
        r_Initial_valid[32] <= 'd0;
    end else begin
        r_Initial_key[32]   <= w_K[31];
        r_Initial_valid[32] <= w_Encrypt_valid[31];
    end
end
/*----data encrypt----*/

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        r_round_result28[0]<= 'd0;
        r_round_result29[0]<= 'd0;
        r_round_result30[0]<= 'd0;
    end else begin
        r_round_result28[0]<= w_round_data[28];
        r_round_result29[0]<= w_round_data[29];
        r_round_result30[0]<= w_round_data[30];
    end
end

genvar G_i;
generate
    for(G_i = 1 ; G_i < 6 ; G_i = G_i + 1)
    begin:Gen_30
        always@(posedge i_clk)
            r_round_result30[G_i] <= r_round_result30[G_i - 1];
    end

    for(G_i = 1 ; G_i < 12 ; G_i = G_i + 1)
    begin:Gen_29
        always@(posedge i_clk)
            r_round_result29[G_i] <= r_round_result29[G_i - 1];
    end

    for(G_i = 1 ; G_i < 18 ; G_i = G_i + 1)
    begin:Gen_28
        always@(posedge i_clk)
            r_round_result28[G_i] <= r_round_result28[G_i - 1];
    end

endgenerate

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_axis_ready <= 'd0;
    else if(i_Initial_valid)
        ro_axis_ready <= 'd0;
    else if(r_Initial_valid[32])
        ro_axis_ready <= 'd1;
    else 
        ro_axis_ready <= ro_axis_ready;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_axis_data  <= 'd0;
        ri_axis_valid <= 'd0;
    end else if(w_axis_active) begin
        ri_axis_data  <= i_axis_data ;
        ri_axis_valid <= 'd1;
    end else begin
        ri_axis_data  <= ri_axis_data ;
        ri_axis_valid <= 'd0;
    end
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        r_round_data[0]  <= 'd0;
        r_round_valid[0] <= 'd0;
    end else if(w_axis_active) begin
        r_round_data[0]  <= i_axis_data;
        r_round_valid[0] <= 'd1;
    end else begin
        r_round_data[0]  <= r_round_data[0];
        r_round_valid[0] <= 'd0;
    end
end

genvar j;
generate 
    for(j = 0;j < 32;j = j + 1)
    begin:Gen_Round
        Round_Function Round_Function_ux(
            .i_clk       (i_clk                 ),
            .i_rst       (i_rst                 ),
            .i_i         (j                     ),
            .i_rk        (r_rK[31 - j]               ),
            .i_data      (r_round_data[j]       ),
            .i_valid     (r_round_valid[j]      ),
            .o_data      (w_round_data[j]       ),
            .o_valid     (w_round_valid[j]      ),
            .o_next_data (w_round_next_data[j]  )
        );
        
            always@(posedge i_clk,posedge i_rst)
            begin
                if(i_rst) begin
                    r_round_data[j + 1]  <= 'd0;
                    r_round_valid[j + 1] <= 'd0;
                end else if(w_round_valid[j]) begin
                    r_round_data[j + 1]  <= w_round_next_data[j];
                    r_round_valid[j + 1] <= w_round_valid[j];
                end else begin
                    r_round_data[j + 1]  <= r_round_data[j + 1];
                    r_round_valid[j + 1] <= 'd0;
                end
            end

    end
endgenerate

/*----output data----*/

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ro_axim_data  <= 'd0;
        ro_axim_valid <= 'd0;
    end else begin
        ro_axim_data  <= {w_round_data[31],r_round_result30[5],r_round_result29[11],r_round_result28[17]};
        ro_axim_valid <= w_round_valid[31];
    end
end

endmodule