`timescale 1ns / 1ps

module power_management_unit (    
    input  wire        clk,
    input  wire        rst_n, 
    input  wire [15:0] request_wakeup,
    input  wire [15:0] access_done, 
    output wire [15:0] power_gate_en,
    output wire [15:0] rbb_en,
    output wire [15:0] bank_active_status
);
    parameter DEEP_SLEEP = 2'b00;
    parameter STANDBY    = 2'b01;
    parameter ACTIVE     = 2'b10;
    parameter T_WAKEUP_CYCLES      = 50;
    parameter T_IDLE_CYCLES        = 150;
    parameter T_DEEP_SLEEP_CYCLES  = 1000;
    reg [1:0]  current_state [15:0];
    reg [1:0]  next_state [15:0];
    reg [$clog2(T_WAKEUP_CYCLES)-1:0]      wakeup_timer [15:0];
    reg [$clog2(T_IDLE_CYCLES)-1:0]        idle_timer [15:0];
    reg [$clog2(T_DEEP_SLEEP_CYCLES)-1:0]  deep_sleep_timer [15:0];

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : bank_fsm
       
            wire wakeup_timer_done;
            wire idle_timer_done;
            wire deep_sleep_timer_done;

            always @* begin
                case (current_state[i])
                    DEEP_SLEEP: begin
                        if (request_wakeup[i])
                            next_state[i] = STANDBY;
                        else
                            next_state[i] = DEEP_SLEEP;
                    end
                    STANDBY: begin
                       
                        if (wakeup_timer_done)
                            next_state[i] = ACTIVE;
                        else if (deep_sleep_timer_done)
                            next_state[i] = DEEP_SLEEP;
                        else
                            next_state[i] = STANDBY;
                    end
                    ACTIVE: begin
                       
                        if (idle_timer_done && !request_wakeup[i])
                            next_state[i] = STANDBY;
                        else
                            next_state[i] = ACTIVE;
                    end
                    default: begin
                        next_state[i] = DEEP_SLEEP;
                    end
                endcase
            end
         
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    current_state[i]    <= DEEP_SLEEP;
                    wakeup_timer[i]     <= 0;
                    idle_timer[i]       <= 0;
                    deep_sleep_timer[i] <= 0;
                end else begin                  
                    current_state[i] <= next_state[i];                  
                    if (current_state[i] == DEEP_SLEEP && next_state[i] == STANDBY) begin
                        wakeup_timer[i] <= 1;
                    end else if (current_state[i] == STANDBY && wakeup_timer[i] > 0 && !wakeup_timer_done) begin
                        wakeup_timer[i] <= wakeup_timer[i] + 1;
                    end else begin
                        wakeup_timer[i] <= 0;
                    end                   
                    if (request_wakeup[i] && current_state[i] == ACTIVE) begin
                        idle_timer[i] <= 0; 
                    end else if (access_done[i] && current_state[i] == ACTIVE) begin
                        idle_timer[i] <= 1; 
                    end else if (current_state[i] == ACTIVE && idle_timer[i] > 0 && !idle_timer_done) begin
                        idle_timer[i] <= idle_timer[i] + 1; 
                    end else begin
                        idle_timer[i] <= 0; 
                    end                    
                    if (current_state[i] == ACTIVE && next_state[i] == STANDBY) begin
                        deep_sleep_timer[i] <= 1;
                    end else if (current_state[i] == STANDBY && deep_sleep_timer[i] > 0 && !deep_sleep_timer_done) begin
                        deep_sleep_timer[i] <= deep_sleep_timer[i] + 1;
                    end else begin
                        deep_sleep_timer[i] <= 0; 
                    end
                end
            end

            assign bank_active_status[i] = (current_state[i] == ACTIVE);
            assign power_gate_en[i]      = (current_state[i] != DEEP_SLEEP);
            assign rbb_en[i]             = (current_state[i] == STANDBY);
          
            assign wakeup_timer_done     = (wakeup_timer[i] >= T_WAKEUP_CYCLES);
            assign idle_timer_done       = (idle_timer[i]   >= T_IDLE_CYCLES);
            assign deep_sleep_timer_done = (deep_sleep_timer[i] >= T_DEEP_SLEEP_CYCLES);
        end
    endgenerate

endmodule

