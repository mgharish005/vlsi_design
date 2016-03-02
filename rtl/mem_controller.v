module mem_controller
(
    input histogram_en, 
    input cdf_en, 
    input divider_en
  
    input histogram_scratch_mem_rdata0, 
    input histogram_scratch_mem_rdata1, 
    input histogram_scratch_mem_raddr0, 
    input histogram_scratch_mem_raddr1, 
    input histogram_scratch_mem_waddr, 
    input histogram_scratch_mem_wdata, 
    input histogram_scratch_mem_WE, 


    input cdf_scratch_mem_rdata0, 
    input cdf_scratch_mem_rdata1, 
    input cdf_scratch_mem_raddr0, 
    input cdf_scratch_mem_raddr1, 
    input cdf_scratch_mem_waddr, 
    input cdf_scratch_mem_wdata, 
    input cdf_scratch_mem_WE, 


    input divider_scratch_mem_rdata0, 
    input divider_scratch_mem_rdata1, 
    input divider_scratch_mem_raddr0, 
    input divider_scratch_mem_raddr1, 



    output reg final_scratch_mem_rdata0, 
    output reg final_scratch_mem_rdata1, 
    output reg final_scratch_mem_raddr0, 
    output reg final_scratch_mem_raddr1,
    output reg final_scratch_mem_waddr, 
    output reg final_scratch_mem_wdata, 
    output reg final_scratch_mem_WE, 
); 


always@(*)
begin
    
case({histogram_en, cdf_en, divider_en}) 

    3'b100 : 
    begin
        final_scratch_mem_rdata0 = histogram_scratch_mem_rdata0; 
        final_scratch_mem_rdata1 = histogram_scratch_mem_rdata1; 
        final_scratch_mem_raddr0 = histogram_scratch_mem_raddr0; 
        final_scratch_mem_raddr1 = histogram_scratch_mem_raddr1; 
        final_scratch_mem_waddr = histogram_scratch_mem_waddr; 
        final_scratch_mem_wdata = histogram_scratch_mem_wdata; 
        final_scratch_mem_WE = histogram_scratch_mem_WE
    end
    3'b010 : 
    begin
        final_scratch_mem_rdata0 = cdf_scratch_mem_rdata0; 
        final_scratch_mem_rdata1 = cdf_scratch_mem_rdata1; 
        final_scratch_mem_raddr0 = cdf_scratch_mem_raddr0; 
        final_scratch_mem_raddr1 = cdf_scratch_mem_raddr1; 
        final_scratch_mem_waddr = cdf_scratch_mem_waddr; 
        final_scratch_mem_wdata = cdf_scratch_mem_wdata; 
        final_scratch_mem_WE = cdf_scratch_mem_WE
    end
    3'b001 : 
    begin
        final_scratch_mem_rdata0 = divider_scratch_mem_rdata0; 
        final_scratch_mem_rdata1 = divider_scratch_mem_rdata1; 
        final_scratch_mem_raddr0 = divider_scratch_mem_raddr0; 
        final_scratch_mem_raddr1 = divider_scratch_mem_raddr1; 
        final_scratch_mem_waddr = 0; 
        final_scratch_mem_wdata = 0; 
        final_scratch_mem_WE = 0; 
    end
    default : 
    begin
        final_scratch_mem_rdata0 = histogram_scratch_mem_rdata0; 
        final_scratch_mem_rdata1 = histogram_scratch_mem_rdata1; 
        final_scratch_mem_raddr0 = histogram_scratch_mem_raddr0; 
        final_scratch_mem_raddr1 = histogram_scratch_mem_raddr1; 
        final_scratch_mem_waddr = histogram_scratch_mem_waddr; 
        final_scratch_mem_wdata = histogram_scratch_mem_wdata; 
        final_scratch_mem_WE = histogram_scratch_mem_WE
    end

end

