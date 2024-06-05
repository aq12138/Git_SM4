`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         维瓦（昆明）电子科技有限公司
// Engineer:        于奇
// 
// Create Date:     2024/05/27 13:13:45
// Design Name:     SM4
// Module Name:     Key_Extending
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


module Key_Extending(
    input               i_clk               ,
    input               i_rst               ,
    input  [7  :0]      i_i                 ,
    input  [127:0]      i_Initial_Key       ,
    input               i_Initial_valid     ,
    output [31 :0]      o_Encrypt_Key       ,
    output              o_Encrypt_valid     ,
    output [127:0]      o_K                  
);

reg  [127:0]            ri_Initial_Key      ;
reg                     ri_Initial_valid    ;
reg  [127:0]            r_FK={32'hA3B1BAC6,32'h56AA3350,32'h677D9197,32'hB27022DC};
reg  [31 :0]            r_CK[0 :31]         ;
reg  [31 :0]            r_CK_result         ;
reg                     r_in_s_valid        ;
reg  [31 :0]            r_Ki_result         ;
reg                     ro_Encrypt_valid    ;
reg  [127:0]            ro_K                ;

wire [31 :0]            w_MK_i0             ;
wire [31 :0]            w_MK_i1             ; 
wire [31 :0]            w_MK_i2             ;
wire [31 :0]            w_MK_i3             ; 
wire                    w_MK_valid          ;
wire [31 :0]            w_FK_0              ;
wire [31 :0]            w_FK_1              ; 
wire [31 :0]            w_FK_2              ;
wire [31 :0]            w_FK_3              ; 
wire [31 :0]            w_K_i0              ;
wire [31 :0]            w_K_i1              ; 
wire [31 :0]            w_K_i2              ;
wire [31 :0]            w_K_i3              ; 
wire [31 :0]            w_K_result          ;
wire                    w_s_valid           ;
wire [31 :0]            w_s_result          ;
wire [31 :0]            w_mid0              ;
wire [31 :0]            w_mid1              ;
wire [31 :0]            w_mid_result        ;

assign w_MK_i0 = ri_Initial_Key[127:96]     ;
assign w_MK_i1 = ri_Initial_Key[95 :64]     ;
assign w_MK_i2 = ri_Initial_Key[63 :32]     ;
assign w_MK_i3 = ri_Initial_Key[31 : 0]     ;
assign w_MK_valid = ri_Initial_valid        ;
assign w_FK_0  = r_FK[127:96]               ;
assign w_FK_1  = r_FK[95 :64]               ;
assign w_FK_2  = r_FK[63 :32]               ;
assign w_FK_3  = r_FK[31 : 0]               ;
assign w_K_i0  = i_i == 0 ? w_MK_i0 ^ w_FK_0 : w_MK_i0;
assign w_K_i1  = i_i == 0 ? w_MK_i1 ^ w_FK_1 : w_MK_i1;
assign w_K_i2  = i_i == 0 ? w_MK_i2 ^ w_FK_2 : w_MK_i2;
assign w_K_i3  = i_i == 0 ? w_MK_i3 ^ w_FK_3 : w_MK_i3;
assign w_K_result = w_K_i1 ^ w_K_i2 ^ w_K_i3;
assign w_mid0       = {w_s_result[18:0],w_s_result[31:19]}  ;
assign w_mid1       = {w_s_result[8:0],w_s_result[31:9]}  ;
assign w_mid_result = w_mid0 ^ w_mid1 ^ w_s_result;
assign o_Encrypt_Key = r_Ki_result;
assign o_Encrypt_valid = ro_Encrypt_valid   ;
assign o_K          = ro_K                  ;

S_Box S_Box_u0(
    .i_clk              (i_clk                  ),
    .i_rst              (i_rst                  ),
    .i_data             (r_CK_result[31:24]     ),
    .i_valid            (r_in_s_valid           ),
    .o_s_data           (w_s_result[31:24]      ),
    .o_s_valid          (w_s_valid              )
);

S_Box S_Box_u1(
    .i_clk              (i_clk                  ),
    .i_rst              (i_rst                  ),
    .i_data             (r_CK_result[23:16]     ),
    .i_valid            (r_in_s_valid           ),
    .o_s_data           (w_s_result[23:16]      ),
    .o_s_valid          (                       )
);

S_Box S_Box_u2(
    .i_clk              (i_clk                  ),
    .i_rst              (i_rst                  ),
    .i_data             (r_CK_result[15:8]      ),
    .i_valid            (r_in_s_valid           ),
    .o_s_data           (w_s_result[15:8]       ),
    .o_s_valid          (                       )
);

S_Box S_Box_u3(
    .i_clk              (i_clk                  ),
    .i_rst              (i_rst                  ),
    .i_data             (r_CK_result[7 :0]      ),
    .i_valid            (r_in_s_valid           ),
    .o_s_data           (w_s_result[7 : 0]      ),
    .o_s_valid          (                       )
);

initial begin
    $readmemh("E:/Desktop/Work/Class/Class2_Program/SM4/project_1/project_1.srcs/sources_1/new/r_CK_Init.txt",r_CK);
end

always@(posedge i_clk,posedge i_rst)
begin
  if(i_rst) begin
    ri_Initial_Key   <= 'd0;
    ri_Initial_valid <= 'd0;
    r_in_s_valid <= 'd0;
  end else begin
    ri_Initial_Key   <= i_Initial_Key  ;
    ri_Initial_valid <= i_Initial_valid;
    r_in_s_valid <= ri_Initial_valid;
  end
end

always@(posedge i_clk,posedge i_rst)
begin
  if(i_rst)
        r_CK_result <= 'd0;
  else 
        r_CK_result <= w_K_result ^ r_CK[i_i];
end

always@(posedge i_clk,posedge i_rst)
begin
  if(i_rst)
        r_Ki_result <= 'd0;
  else 
        r_Ki_result <= w_mid_result ^ w_K_i0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
      ro_K <= 128'd0;
    else 
      ro_K <= {w_K_i1,w_K_i2,w_K_i3,w_mid_result ^ w_K_i0}; 
end

always@(posedge i_clk,posedge i_rst)
begin
  if(i_rst)
        ro_Encrypt_valid <= 'd0;
  else      
        ro_Encrypt_valid <= w_s_valid;
end

endmodule
