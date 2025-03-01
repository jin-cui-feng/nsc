`include "lib/defines.vh"
module mycpu_core(
    input wire clk,
    input wire rst,
    input wire [5:0] int,

    output wire inst_sram_en,
    output wire [3:0] inst_sram_wen,
    output wire [31:0] inst_sram_addr,
    output wire [31:0] inst_sram_wdata,
    input wire [31:0] inst_sram_rdata,

    output wire data_sram_en,
    output wire [3:0] data_sram_wen,
    output wire [31:0] data_sram_addr,
    output wire [31:0] data_sram_wdata,
    input wire [31:0] data_sram_rdata,

    output wire [31:0] debug_wb_pc,
    output wire [3:0] debug_wb_rf_wen,
    output wire [4:0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata
);
    wire [`IF_TO_ID_WD-1:0] if_to_id_bus;
    wire [`ID_TO_EX_WD-1:0] id_to_ex_bus;
    wire [`EX_TO_MEM_WD-1:0] ex_to_mem_bus;
    wire [`MEM_TO_WB_WD-1:0] mem_to_wb_bus;
    wire [`BR_WD-1:0] br_bus; 
    wire [`DATA_SRAM_WD-1:0] ex_dt_sram_bus;
    wire [`WB_TO_RF_WD-1:0] wb_to_rf_bus;
    wire [`StallBus-1:0] stall;

    wire [37:0] ex_to_id_bus;
    wire [37:0] mem_to_id_bus;
    wire [37:0] wb_to_id_bus;
    wire inst_is_load;
    //
    wire [65:0] ex_to_mem_1 ;
    wire [65:0] ex_to_id_2;
    wire [65:0] mem_to_id_2;
    wire [65:0] wb_to_id_2;
    wire [65:0]mem_to_wb_1;
    wire [65:0] wb_to_id_wf;

    wire stallreq_for_ex;
    wire stallreq_for_id;
    wire ready_ex_to_id;

    IF u_IF(
    	.clk             (clk             ),
        .rst             (rst             ),
        .stall           (stall           ),
        .br_bus          (br_bus          ),
        .if_to_id_bus    (if_to_id_bus    ),
        .inst_sram_en    (inst_sram_en    ),
        .inst_sram_wen   (inst_sram_wen   ),
        .inst_sram_addr  (inst_sram_addr  ),
        .inst_sram_wdata (inst_sram_wdata )
    );
    

    ID u_ID(
    	.clk             (clk             ),
        .rst             (rst             ),
        .stall           (stall           ),
        .stallreq        (stallreq        ),
        .if_to_id_bus    (if_to_id_bus    ),
        .inst_sram_rdata (inst_sram_rdata ),
        .wb_to_rf_bus    (wb_to_rf_bus    ),
        .id_to_ex_bus    (id_to_ex_bus    ),

        .ex_to_id_bus    (ex_to_id_bus    ),
        .mem_to_id_bus   (mem_to_id_bus   ),
        .wb_to_id_bus    (wb_to_id_bus    ),
        .br_bus          (br_bus          ),
        .stallreq_for_id (stallreq_for_id ),
        .inst_is_load    (inst_is_load    ),
        .ready_ex_to_id  (ready_ex_to_id  ),
        //
        .ex_to_id_2      (ex_to_id_2 ),
        .mem_to_id_2     (mem_to_id_2 ),
        .wb_to_id_2      (wb_to_id_2),
        .wb_to_id_wf     (wb_to_id_wf)
        //
    );

    EX u_EX(
    	.clk             (clk             ),
        .rst             (rst             ),
        .stall           (stall           ),
        .id_to_ex_bus    (id_to_ex_bus    ),
        .ex_to_mem_bus   (ex_to_mem_bus   ),

        .ex_to_id_bus    (ex_to_id_bus    ),

        .data_sram_en    (data_sram_en    ),
        .data_sram_wen   (data_sram_wen   ),
        .data_sram_addr  (data_sram_addr  ),
        .data_sram_wdata (data_sram_wdata ),
        .inst_is_load    (inst_is_load),//
        .stallreq_for_ex(stallreq_for_ex),
        .ready_ex_to_id  (ready_ex_to_id  ),
        //
        .ex_to_mem_1     (ex_to_mem_1),
        .ex_to_id_2      (ex_to_id_2)
        //
    );

    MEM u_MEM(
    	.clk             (clk             ),
        .rst             (rst             ),
        .stall           (stall           ),
        .ex_to_mem_bus   (ex_to_mem_bus   ),
        .mem_to_id_bus   (mem_to_id_bus   ),
        .data_sram_rdata (data_sram_rdata ),
        .mem_to_wb_bus   (mem_to_wb_bus   ),
        .ex_to_mem_1     (ex_to_mem_1),
        //
        .mem_to_wb_1      (mem_to_wb_1),
        .mem_to_id_2     (mem_to_id_2)
        //

    );
    
    WB u_WB(
    	.clk               (clk               ),
        .rst               (rst               ),
        .stall             (stall             ),
        .mem_to_wb_bus     (mem_to_wb_bus     ),
        //添加回ID段的数据总线
        .wb_to_id_bus      (wb_to_id_bus      ),

        .wb_to_rf_bus      (wb_to_rf_bus      ),
        .debug_wb_pc       (debug_wb_pc       ),
        .debug_wb_rf_wen   (debug_wb_rf_wen   ),
        .debug_wb_rf_wnum  (debug_wb_rf_wnum  ),
        .debug_wb_rf_wdata (debug_wb_rf_wdata ),
        //
        .mem_to_wb_1        (mem_to_wb_1),
        .wb_to_id_wf      (wb_to_id_wf),
        .wb_to_id_2       (wb_to_id_2)
        //
    );

    CTRL u_CTRL(
    	.rst   (rst   ),
        .stall (stall ),
        
        .stallreq_for_id(stallreq_for_id),
        .stallreq_for_ex(stallreq_for_ex)
    );
    
endmodule