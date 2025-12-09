function reg = build_write_reg1_param(offset, DELVAL1, RFEDGE, EN_INT_ALU, EN_INT_HIT, EN_INT_TO)
% BUILD_WRITE_REG1_PARAM 带参数的寄存器1构建函数
% 输入参数:
%   offset      - bits 11:0 (12位)
%   DELVAL1     - bits 27:12 (16位)
%   RFEDGE      - bit 28
%   EN_INT_ALU  - bit 29
%   EN_INT_HIT  - bit 30  
%   EN_INT_TO   - bit 31
% 输出:
%   reg - 32位无符号整数寄存器值

    % 输入验证和类型转换
    offset = uint32(offset);
    DELVAL1 = uint32(DELVAL1);
    RFEDGE = uint32(RFEDGE);
    EN_INT_ALU = uint32(EN_INT_ALU);
    EN_INT_HIT = uint32(EN_INT_HIT);
    EN_INT_TO = uint32(EN_INT_TO);
    
    reg = uint32(0);
    
    % 构建寄存器值
    reg = bitor(reg, bitand(offset, 4095));                    % bits 11:0 (12位) - 掩码0xFFF
    reg = bitor(reg, bitshift(bitand(DELVAL1, 65535), 12));    % bits 27:12 (16位) - 掩码0xFFFF
    reg = bitor(reg, bitshift(bitand(RFEDGE, 1), 28));         % bit 28
    reg = bitor(reg, bitshift(bitand(EN_INT_ALU, 1), 29));     % bit 29
    reg = bitor(reg, bitshift(bitand(EN_INT_HIT, 1), 30));     % bit 30
    reg = bitor(reg, bitshift(bitand(EN_INT_TO, 1), 31));      % bit 31
    
end