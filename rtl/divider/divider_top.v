`include "../../rtl/divider/divider.v"
`include "../../rtl/divider/divider_mem_ctrl.v"
`include "../../rtl/divider/divider_mem_datapath.v"

module divider_top(
input  wire         clk,
input  wire         reset,
input  wire         enable,
input  wire [31:0]  cdf_min,
input  wire [127:0] div_sc_mem_rd_data1,
input  wire [127:0] div_sc_mem_rd_data2,
output wire [127:0] div_sc_mem_wt_data,
output wire [15:0]  div_sc_mem_rd_addr1,
output wire [15:0]  div_sc_mem_rd_addr2,
output wire [15:0]  div_sc_mem_wt_addr,
output wire         div_sc_mem_wt_en,
output wire         div_sc_mem_rd_done,
output wire         div_sc_mem_wt_done,
output wire         div_InProgress
);

//Wires for modules
wire                div1_done;
wire                div2_done;
wire                div3_done;
wire                div4_done;
wire                div5_done;
wire                div6_done;
wire                div7_done;
wire                div8_done;
wire                divider_en;
wire                divider_en_D1;
wire                divider_en_D2;
wire                divider_en_D3;
wire                sc_mem_rd_data_rdy;
wire     [31:0]     div1_value;
wire     [31:0]     div2_value;
wire     [31:0]     div3_value;
wire     [31:0]     div4_value;
wire     [31:0]     div5_value;
wire     [31:0]     div6_value;
wire     [31:0]     div7_value;
wire     [31:0]     div8_value;
wire     [31:0]     cdfval_todiv1;
wire     [31:0]     cdfval_todiv2;
wire     [31:0]     cdfval_todiv3;
wire     [31:0]     cdfval_todiv4;
wire     [31:0]     cdfval_todiv5;
wire     [31:0]     cdfval_todiv6;
wire     [31:0]     cdfval_todiv7;
wire     [31:0]     cdfval_todiv8;


//DIVIDER INTERNAL MEMORY CONTROLLER
divider_mem_ctrl divider_mem_ctrl (
	.clk                       (clk),
	.reset                     (reset),
	.enable                    (enable),
	.div1_done                 (div1_done),
	.div2_done                 (div2_done),
	.div3_done                 (div3_done),
	.div4_done                 (div4_done),
	.div5_done                 (div5_done),
	.div6_done                 (div6_done),
	.div7_done                 (div7_done),
	.div8_done                 (div8_done),
	.sc_mem_rd_addr1           (div_sc_mem_rd_addr1),
	.sc_mem_rd_addr2           (div_sc_mem_rd_addr2),
	.sc_mem_wt_addr            (div_sc_mem_wt_addr),
	.sc_mem_rd_data_rdy        (sc_mem_rd_data_rdy),
	.div_en                    (divider_en),
	.div_en_D1                 (divider_en_D1),
	.div_en_D2                 (divider_en_D2),
	.div_en_D3                 (divider_en_D3),
	.sc_mem_wt_en              (div_sc_mem_wt_en),
	.sc_mem_rd_done            (div_sc_mem_rd_done),
	.sc_mem_wt_done            (div_sc_mem_wt_done),
	.div_InProgress            (div_InProgress)
	);

//DIVIDER DATAPATH LOGIC
divider_mem_datapath divider_mem_datapath (
	.clk                       (clk),
	.reset                     (reset),
	.enable                    (enable),
	.sc_mem_rd_data_rdy        (sc_mem_rd_data_rdy),
	.sc_mem_rd_data1           (div_sc_mem_rd_data1),
	.sc_mem_rd_data2           (div_sc_mem_rd_data2),
	.div1_done                 (div1_done),
	.div2_done                 (div2_done),
	.div3_done                 (div3_done),
	.div4_done                 (div4_done),
	.div5_done                 (div5_done),
	.div6_done                 (div6_done),
	.div7_done                 (div7_done),
	.div8_done                 (div8_done),
	.div1_value                (div1_value),
	.div2_value                (div2_value),
	.div3_value                (div3_value),
	.div4_value                (div4_value),
	.div5_value                (div5_value),
	.div6_value                (div6_value),
	.div7_value                (div7_value),
	.div8_value                (div8_value),
	.cdfval_todiv1             (cdfval_todiv1),
	.cdfval_todiv2             (cdfval_todiv2),
	.cdfval_todiv3             (cdfval_todiv3),
	.cdfval_todiv4             (cdfval_todiv4),
	.cdfval_todiv5             (cdfval_todiv5),
	.cdfval_todiv6             (cdfval_todiv6),
	.cdfval_todiv7             (cdfval_todiv7),
	.cdfval_todiv8             (cdfval_todiv8),
	.sc_mem_wt_data            (div_sc_mem_wt_data)
	);
	
//DIVIDER CORE 1
divider  divider1(
	.clk                       (clk),
	.reset                     (reset),
	.enable                    (enable),
	.div_en                    (divider_en_D3),
	.cdf_min                   (cdf_min),
	.cdf_in                    (cdfval_todiv1),
	.g_out                     (div1_value),
	.ready_g_out               (div1_done)
	);

//DIVIDER CORE 2
divider  divider2(
	.clk                       (clk),
	.reset                     (reset),
	.enable                    (enable),
	.div_en                    (divider_en_D3),
	.cdf_min                   (cdf_min),
	.cdf_in                    (cdfval_todiv2),
	.g_out                     (div2_value),
	.ready_g_out               (div2_done)
	);
	
//DIVIDER CORE 3
divider  divider3(
	.clk                       (clk),
	.reset                     (reset),
	.enable                    (enable),
	.div_en                    (divider_en_D3),
	.cdf_min                   (cdf_min),
	.cdf_in                    (cdfval_todiv3),
	.g_out                     (div3_value),
	.ready_g_out               (div3_done)
	);

//DIVIDER CORE 4
divider  divider4(
	.clk                       (clk),
	.reset                     (reset),
	.enable                    (enable),
	.div_en                    (divider_en_D3),
	.cdf_min                   (cdf_min),
	.cdf_in                    (cdfval_todiv4),
	.g_out                     (div4_value),
	.ready_g_out               (div4_done)
	);

//DIVIDER CORE 5
divider  divider5(
	.clk                       (clk),
	.reset                     (reset),
	.enable                    (enable),
	.div_en                    (divider_en_D3),
	.cdf_min                   (cdf_min),
	.cdf_in                    (cdfval_todiv5),
	.g_out                     (div5_value),
	.ready_g_out               (div5_done)
	);

//DIVIDER CORE 6
divider  divider6(
	.clk                       (clk),
	.reset                     (reset),
	.enable                    (enable),
	.div_en                    (divider_en_D3),
	.cdf_min                   (cdf_min),
	.cdf_in                    (cdfval_todiv6),
	.g_out                     (div6_value),
	.ready_g_out               (div6_done)
	);
	
//DIVIDER CORE 7
divider  divider7(
	.clk                       (clk),
	.reset                     (reset),
	.enable                    (enable),
	.div_en                    (divider_en_D3),
	.cdf_min                   (cdf_min),
	.cdf_in                    (cdfval_todiv7),
	.g_out                     (div7_value),
	.ready_g_out               (div7_done)
	);

//DIVIDER CORE 8
divider  divider8(
	.clk                       (clk),
	.reset                     (reset),
	.enable                    (enable),
	.div_en                    (divider_en_D3),
	.cdf_min                   (cdf_min),
	.cdf_in                    (cdfval_todiv8),
	.g_out                     (div8_value),
	.ready_g_out               (div8_done)
	);
	
endmodule