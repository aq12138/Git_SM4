`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         维瓦（昆明）电子科技有限公司
// Engineer:        于奇
// 
// Create Date:     2024/05/27 13:13:45
// Design Name:     SM4
// Module Name:     Round_Function
// Project Name:    project_1
// Target Devices:  XC7Z035FFG676-2
// Tool Versions:   VIVADO2018.3
// Description:     SM4加密与解密算�?
//                  
// Dependencies:    �?
// 
// Revision:        V0.1
// Revision 0.01 - File Created
// Additional Comments: �?源代码；概不负责�?
// 
//////////////////////////////////////////////////////////////////////////////////


module Round_Function(
    input           i_clk       ,
    input           i_rst       ,
    input  [7  :0]  i_i         ,
    input  [31 :0]  i_rk        ,
    input  [127:0]  i_data      ,
    input           i_valid     ,
    output [31 :0]  o_data      ,
    output          o_valid     ,
    output [127:0]  o_next_data 
);

reg                 ro_valid        ;
reg  [127:0]        ri_data         ;
reg  [127:0]        ri_data_1d         ;
reg  [127:0]        ri_data_2d         ;
reg  [127:0]        ri_data_3d         ;
reg                 ri_valid        ;
reg  [31 :0]        r_rK_result     ;
reg                 r_rK_valid      ;
reg  [31 :0]        r_Ki_result     ;
reg                 r_Ki_valid      ;
reg  [31 :0]        r_X_i0          ;
reg  [31 :0]        r_X_i0_1d       ;
reg  [31 :0]        r_X_i0_1d_2d    ;
reg                 r_rK_valid_1d   ;
reg  [31 :0]        ro_data         ;
reg  [127:0]        ro_next_data    ;

wire [31 :0]        w_X_i0          ;
wire [31 :0]        w_X_i1          ;
wire [31 :0]        w_X_i2          ;
wire [31 :0]        w_X_i3          ;
wire                w_s_valid       ;           
wire [31 :0]        w_s_result      ;
wire [31 :0]        w_mid0          ;   
wire [31 :0]        w_mid1          ;  
wire [31 :0]        w_mid_result    ;

assign w_X_i0 = ri_data[127:96]     ;
assign w_X_i1 = ri_data[95 :64]     ;
assign w_X_i2 = ri_data[63 :32]     ;
assign w_X_i3 = ri_data[31 : 0]     ;
assign o_data  = ro_data            ;
assign o_valid = ro_valid           ;
assign w_mid0       = {w_s_result[29:0],w_s_result[31:30]} ^ {w_s_result[21:0],w_s_result[31:22]};
assign w_mid1       = {w_s_result[13:0],w_s_result[31:14]} ^ {w_s_result[7 :0],w_s_result[31: 8]};
assign w_mid_result = w_mid0 ^ w_mid1 ^ w_s_result;
assign o_next_data  = ro_next_data  ;

S_Box S_Box_u0(
    .i_clk              (i_clk                  ),
    .i_rst              (i_rst                  ),
    .i_data             (r_rK_result[31:24]     ),
    .i_valid            (r_rK_valid             ),
    .o_s_data           (w_s_result[31:24]      ),
    .o_s_valid          (w_s_valid              )
);

S_Box S_Box_u1(
    .i_clk              (i_clk                  ),
    .i_rst              (i_rst                  ),
    .i_data             (r_rK_result[23:16]     ),
    .i_valid            (r_rK_valid             ),
    .o_s_data           (w_s_result[23:16]      ),
    .o_s_valid          (                       )
);

S_Box S_Box_u2(
    .i_clk              (i_clk                  ),
    .i_rst              (i_rst                  ),
    .i_data             (r_rK_result[15:8]      ),
    .i_valid            (r_rK_valid             ),
    .o_s_data           (w_s_result[15:8]       ),
    .o_s_valid          (                       )
);

S_Box S_Box_u3(
    .i_clk              (i_clk                  ),
    .i_rst              (i_rst                  ),
    .i_data             (r_rK_result[7 : 0]     ),
    .i_valid            (r_rK_valid             ),
    .o_s_data           (w_s_result[7 : 0]      ),
    .o_s_valid          (                       )
);

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ri_data  <= 'd0;
        ri_valid <= 'd0;
        r_rK_valid_1d <= 'd0;
        ri_data_1d <= 'd0;
        ri_data_2d <= 'd0;
        ri_data_3d <= 'd0;
        r_X_i0_1d    <= 'd0;
        r_X_i0_1d_2d <= 'd0;
    end else begin
        ri_data  <= i_data ;
        ri_valid <= i_valid;
        r_rK_valid_1d <= r_rK_valid;
        ri_data_1d <= ri_data;
        ri_data_2d <= ri_data_1d;
        ri_data_3d <= ri_data_2d;
        r_X_i0_1d    <= r_X_i0;
        r_X_i0_1d_2d <= r_X_i0_1d;
    end
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_X_i0 <= 'd0;
    else if(ri_valid)
        r_X_i0 <= ri_data[127:96];
    else 
        r_X_i0 <= r_X_i0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_rK_result <= 'd0;
    else 
        r_rK_result <= (w_X_i1 ^ w_X_i2 ^ w_X_i3) ^ i_rk;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_rK_valid <= 'd0;
    else 
        r_rK_valid <= ri_valid;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_Ki_result <= 'd0;
    else 
        r_Ki_result <= r_X_i0_1d ^ w_mid_result;
end


always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_Ki_valid <= 'd0;
    else 
        r_Ki_valid <= w_s_valid;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_data <= 'd0;
    else 
        ro_data <= r_Ki_result;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_next_data <= 128'd0;
    else 
        ro_next_data <= {ri_data_3d[95:0],r_Ki_result};
end 

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_valid <= 'd0;
    else 
        ro_valid <= r_Ki_valid;
end

endmodule
