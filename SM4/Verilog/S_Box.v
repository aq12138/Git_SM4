`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         维瓦（昆明）电子科技有限公司
// Engineer:        于奇
// 
// Create Date:     2024/05/27 13:13:45
// Design Name:     SM4
// Module Name:     S_Box
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


module S_Box(
    input           i_clk       ,
    input           i_rst       ,
    input  [7 :0]   i_data      ,
    input           i_valid     ,
    output [7 :0]   o_s_data    ,
    output          o_s_valid   
);

// reg  [7  :0]        ri_data         ;
reg  [7  :0]        ro_s_data       ;
reg                 ro_s_valid      ;
reg  [127:0]        r_s_Box[0 :15]  ;

wire [3  :0]        w_X             ;
wire [3  :0]        w_Y             ;


assign o_s_data = ro_s_data         ;
assign o_s_valid= ro_s_valid        ;
assign w_X      = i_data[7 :4]      ;
assign w_Y      = i_data[3 :0]      ;


initial begin
    $readmemh("E:/Desktop/Work/Class/Class2_Program/SM4/project_1/project_1.srcs/sources_1/new/r_s_Box_Init.txt",r_s_Box,0,15);
end

// always@(posedge i_clk,posedge i_rst)
// begin
//     if(i_rst) 
//         ri_data <= 'd0;
//     else 
//         ri_data <= i_data;
// end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_s_valid <= 'd0;
    else 
        ro_s_valid <= i_valid;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_s_data <= 'd0;
    else case(w_Y)
        0       :ro_s_data <= r_s_Box[w_X][127:120];
        1       :ro_s_data <= r_s_Box[w_X][119:112];
        2       :ro_s_data <= r_s_Box[w_X][111:104];
        3       :ro_s_data <= r_s_Box[w_X][103: 96];
        4       :ro_s_data <= r_s_Box[w_X][95 : 88];
        5       :ro_s_data <= r_s_Box[w_X][87 : 80];
        6       :ro_s_data <= r_s_Box[w_X][79 : 72];
        7       :ro_s_data <= r_s_Box[w_X][71 : 64];
        8       :ro_s_data <= r_s_Box[w_X][63 : 56];
        9       :ro_s_data <= r_s_Box[w_X][55 : 48];
        10      :ro_s_data <= r_s_Box[w_X][47 : 40];
        11      :ro_s_data <= r_s_Box[w_X][39 : 32];
        12      :ro_s_data <= r_s_Box[w_X][31 : 24];
        13      :ro_s_data <= r_s_Box[w_X][23 : 16];
        14      :ro_s_data <= r_s_Box[w_X][15 :  8];
        15      :ro_s_data <= r_s_Box[w_X][7  :  0];
    endcase 
end

endmodule
