`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         维瓦（昆明）电子科技有限公司
// Engineer:        于奇
// 
// Create Date:     2024/05/27 13:13:45
// Design Name:     SM4
// Module Name:     XC7Z035_TOP
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

/***************************/
//使用时请修改"Key_Extendint.v"中的$readmemh函数读取初始化文件路径
//使用时请修改"S_Box.v"中的$readmemh函数读取初始化文件路径
/***************************/

module XC7Z035_TOP(
    input           i_clk_p             ,
    input           i_clk_n             ,

    output [3 :0]   o_led       
);

assign o_led = 4'b1110                  ;

reg  [15:0]     r_cnt                   ;
(* MARK_DEBUG = "TRUE" *)reg  [127:0]        ri_initial_data     ;
(* MARK_DEBUG = "TRUE" *)reg                 ri_initial_valid    ;

wire                w_clk_250MHz        ;
wire                w_rst_250MHz        ; 
wire                w_pll_locked        ;
wire                w_encrypt_ready     ;
(* MARK_DEBUG = "TRUE" *)wire [127:0]        w_encrypt_data      ;
(* MARK_DEBUG = "TRUE" *)wire                w_encrypt_valid     ;
wire                w_decrypt_ready     ;
(* MARK_DEBUG = "TRUE" *)wire [127:0]        w_decrypt_data      ;
(* MARK_DEBUG = "TRUE" *)wire                w_decrypt_valid     ;

clk_wiz_0 clk_wiz_u0
(
    .clk_out1           (w_clk_250MHz       ),     
    .locked             (w_pll_locked       ),      
    .clk_in1_p          (i_clk_p            ),   
    .clk_in1_n          (i_clk_n            )
);      

rst_gen_module#(        
    .P_RST_CYCLE        (100                )   
)
rst_gen_module_u0
(      
    .i_rst              (~w_pll_locked      ),
    .i_clk              (w_clk_250MHz       ),
    .o_rst              (w_rst_250MHz       )
);

SM4_Encrypt#(
    .P_INITIAL_KEY      (128'h000102030405060708090A0B0C0D0E0F  )
)
SM4_Encrypt_u0
(
    .i_clk              (w_clk_250MHz       ),
    .i_rst              (w_rst_250MHz       ),
    .i_Initial_Key      (0                  ),
    .i_Initial_valid    (0                  ),
    .i_axis_data        (ri_initial_data    ),
    .i_axis_valid       (ri_initial_valid   ),
    .o_axis_ready       (w_encrypt_ready    ),      
    .o_axim_data        (w_encrypt_data     ),
    .o_axim_valid       (w_encrypt_valid    )
);

SM4_Decrypt#(
    .P_INITIAL_KEY      (128'h000102030405060708090A0B0C0D0E0F  )
)
SM4_Decrypt_u0
(
    .i_clk              (w_clk_250MHz       ),
    .i_rst              (w_rst_250MHz       ),
    .i_Initial_Key      (0                  ),
    .i_Initial_valid    (0                  ),
    .i_axis_data        (w_encrypt_data     ),
    .i_axis_valid       (w_encrypt_valid    ),
    .o_axis_ready       (w_decrypt_ready    ),      
    .o_axim_data        (w_decrypt_data     ),
    .o_axim_valid       (w_decrypt_valid    )
);

/*----Test Data----*/

always@(posedge w_clk_250MHz,posedge w_rst_250MHz)
begin
    if(w_rst_250MHz)
        r_cnt <= 'd0;
    else if(w_encrypt_ready)
        r_cnt <= r_cnt + 1;
    else 
        r_cnt <= 'd0;
end

always@(posedge w_clk_250MHz,posedge w_rst_250MHz)
begin
    if(w_rst_250MHz) begin
        ri_initial_data  <= 128'd0;
        ri_initial_valid <= 'd0;
    end else if(w_encrypt_ready) begin
        ri_initial_data  <= {r_cnt,r_cnt,r_cnt,r_cnt,r_cnt,r_cnt,r_cnt,r_cnt};
        ri_initial_valid <= 'd1;
    end else  begin
        ri_initial_data  <= 128'd0;
        ri_initial_valid <= 'd0;
    end
end

endmodule
