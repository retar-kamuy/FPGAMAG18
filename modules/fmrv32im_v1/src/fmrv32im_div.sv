module fmrv32im_div (
    input               RST_N,
    input               CLK,
    input               INST_DIV,
    input               INST_DIVU,
    input               INST_REM,
    input               INST_REMU,
    input        [31:0] RS1,
    input        [31:0] RS2,
    output logic        WAIT,
    output logic        READY,
    output logic [31:0] RD
);

    enum logic [1:0] {
        S_IDLE  = 0,
        S_EXEC  = 1,
        S_FIN   = 2
    } state;

    logic start;
    assign start = INST_DIV | INST_DIVU | INST_REM | INST_REMU;

    logic [31:0] dividend;
    logic [62:0] divisor;
    logic [31:0] quotient, quotient_mask;
    logic outsign;
    logic reg_inst_div, reg_inst_rem;

    always @(posedge CLK or negedge RST_N)
        if (~RST_N) begin
            dividend <= 0;
            divisor <= 0;
            outsign <= 0;
            quotient <= 0;
            quotient_mask <= 0;
            reg_inst_div <= 0;
            reg_inst_rem <= 0;
            RD <= 0;
        end else
            case (state)
                S_IDLE:
                    if (start) begin
                        dividend <= ((INST_DIV | INST_REM) & RS1[31]) ? -RS1 : RS1;
                        divisor[62:31] <= ((INST_DIV | INST_REM) & RS2[31]) ? -RS2 : RS2;
                        divisor[30:0] <= 31'd0;
                        outsign <= ((INST_DIV & (RS1[31] ^ RS2[31])) & |RS2) | (INST_REM & RS1[31]);
                        quotient <= 32'd0;
                        quotient_mask <= (INST_DIVU | INST_REMU) & RS2[31] ? 32'h0000_0000 : 32'h8000_0000;
                        reg_inst_div <= INST_DIV | INST_DIVU;
                        reg_inst_rem <= INST_REM | INST_REMU;
                    end
                S_EXEC: begin
                    if (divisor <= dividend) begin
                        dividend <= dividend - divisor;
                        quotient <= quotient | quotient_mask;
                    end
                    divisor <= divisor >> 1;
                    quotient_mask <= quotient_mask >> 1;
                end
                S_FIN:
                    if (reg_inst_div) 
                        RD <= outsign ? -quotient : quotient;
                    else if (reg_inst_rem)
                        RD <= outsign ? -dividend : dividend;
                    else
                        RD <= 32'd0;
            endcase

    always @(posedge CLK or negedge RST_N)
        if (~RST_N)
            state <= S_IDLE;
        else
            case (state)
                S_IDLE:
                    if (start)
                        state <= S_EXEC;
                S_EXEC:
                    if (!quotient_mask)
                        state <= S_FIN;
                S_FIN:
                    state <= S_IDLE;
            endcase

    assign WAIT  = (state != S_IDLE);
    assign READY = (state == S_FIN);

endmodule
