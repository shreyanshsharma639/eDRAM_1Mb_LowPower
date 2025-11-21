`timescale 1ns / 1ps

module controller ( 
    input  wire        clk,
    input  wire        rst_n,
    input  wire [14:0] addr,
    input  wire        ce_n,
    input  wire        we_n,
    input  wire [15:0] bank_active_status,
    output reg  [15:0] bank_sel,
    output reg  [10:0] bank_addr,
    output reg         precharge_en,
    output reg         row_decode_en,
    output reg         col_decode_en,
    output reg         sense_amp_en,
    output reg         write_driver_en,
    output reg  [15:0] request_wakeup,
    output reg  [15:0] access_done
);
    parameter IDLE       = 3'b000;
    parameter WAIT_PMU   = 3'b001;
    parameter PRECHARGE  = 3'b010;
    parameter DECODE     = 3'b011;
    parameter ACCESS     = 3'b100;
    parameter FINISH     = 3'b101;
    parameter T_PRECHARGE_CYCLES = 2;
    parameter T_DECODE_CYCLES    = 1;
    parameter T_ACCESS_CYCLES    = 3;
    reg [2:0]  current_state;
    reg [2:0]  next_state;
    reg [14:0] captured_addr;
    reg        captured_we_n;
    reg [1:0]  timer_counter; 
    wire       timer_done;

    always @* begin
        case (current_state)
            IDLE: begin
                
                if (!ce_n)
                    next_state = WAIT_PMU;
                else
                    next_state = IDLE;
            end
            WAIT_PMU: begin
               
                if (bank_active_status[captured_addr[14:11]])
                    next_state = PRECHARGE;
                else
                    next_state = WAIT_PMU;
            end
            PRECHARGE: begin
                if (timer_done)
                    next_state = DECODE;
                else
                    next_state = PRECHARGE;
            end
            DECODE: begin
                if (timer_done)
                    next_state = ACCESS;
                else
                    next_state = DECODE;
            end
            ACCESS: begin
                if (timer_done)
                    next_state = FINISH;
                else
                    next_state = ACCESS;
            end
            FINISH: begin
                next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end
     
    assign timer_done = (current_state == PRECHARGE && timer_counter >= T_PRECHARGE_CYCLES) ||
                        (current_state == DECODE    && timer_counter >= T_DECODE_CYCLES)    ||
                        (current_state == ACCESS    && timer_counter >= T_ACCESS_CYCLES);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            timer_counter <= 0;
            captured_addr <= 0;
            captured_we_n <= 1'b1;
        end else begin
            
            current_state <= next_state;
        
            if (current_state == IDLE && next_state == WAIT_PMU) begin
                captured_addr <= addr;
                captured_we_n <= we_n;
            end
           
            if (next_state != current_state) begin
                timer_counter <= 1; 
            end else if (!timer_done) begin
                timer_counter <= timer_counter + 1;
            end
        end
    end

    always @* begin
        
        bank_sel        = 16'b0;
        bank_addr       = 11'b0;
        precharge_en    = 1'b0;
        row_decode_en   = 1'b0;
        col_decode_en   = 1'b0;
        sense_amp_en    = 1'b0;
        write_driver_en = 1'b0;
        request_wakeup  = 16'b0;
        access_done     = 16'b0;
   
        case (current_state)
            WAIT_PMU: begin
                
                bank_sel       = 1'b1 << captured_addr[14:11];
                bank_addr      = captured_addr[10:0];
                request_wakeup = 1'b1 << captured_addr[14:11];
            end
            PRECHARGE: begin
                
                bank_sel     = 1'b1 << captured_addr[14:11];
                bank_addr    = captured_addr[10:0];
                precharge_en = 1'b1;
            end
            DECODE: begin
                
                bank_sel        = 1'b1 << captured_addr[14:11];
                bank_addr       = captured_addr[10:0];
                row_decode_en   = 1'b1;
                col_decode_en   = 1'b1;
            end
            ACCESS: begin
                
                bank_sel        = 1'b1 << captured_addr[14:11];
                bank_addr       = captured_addr[10:0];
                row_decode_en   = 1'b1;
                col_decode_en   = 1'b1;

                
                if (captured_we_n) begin 
                    sense_amp_en = 1'b1;
                end else begin 
                    write_driver_en = 1'b1;
                end
            end
            FINISH: begin
                
                bank_sel    = 1'b1 << captured_addr[14:11];
                bank_addr   = captured_addr[10:0];
                access_done = 1'b1 << captured_addr[14:11];
            end
        endcase
    end

endmodule

