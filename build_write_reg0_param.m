function reg = build_write_reg0_param(sel_tsto1, sel_tsto2, sel_timo_mb, hitin, ...
                                     neg_stop, neg_start, start_clkhs, div_clkhs, ...
                                     div_fire, anz_fire)
% BUILD_WRITE_REG0_PARAM 带参数的寄存器构建函数
% 输入参数:
%   sel_tsto1   - bit 0
%   sel_tsto2   - bits 2-1 (2位)
%   sel_timo_mb - bits 5-3 (3位)  
%   hitin       - bits 11-8 (4位)
%   neg_stop    - bit 12
%   neg_start   - bit 13
%   start_clkhs - bits 15-14 (2位)
%   div_clkhs   - bits 17-16 (2位)
%   div_fire    - bits 23-18 (6位)
%   anz_fire    - bits 29-24 (6位)
% 输出:
%   reg - 32位无符号整数寄存器值

    % 输入验证和类型转换
    sel_tsto1 = uint32(sel_tsto1);
    sel_tsto2 = uint32(sel_tsto2);
    sel_timo_mb = uint32(sel_timo_mb);
    hitin = uint32(hitin);
    neg_stop = uint32(neg_stop);
    neg_start = uint32(neg_start);
    start_clkhs = uint32(start_clkhs);
    div_clkhs = uint32(div_clkhs);
    div_fire = uint32(div_fire);
    anz_fire = uint32(anz_fire);
    
    reg = uint32(0);
    
    % 构建寄存器值
    reg = bitor(reg, bitand(sel_tsto1, 1));                    % bit 0
    reg = bitor(reg, bitshift(bitand(sel_tsto2, 3), 2));       % bits 2-1
    reg = bitor(reg, bitshift(bitand(sel_timo_mb, 7), 4));     % bits 5-3
    reg = bitor(reg, bitshift(bitand(hitin, 15), 8));          % bits 11-8
    reg = bitor(reg, bitshift(bitand(neg_stop, 1), 12));       % bit 12
    reg = bitor(reg, bitshift(bitand(neg_start, 1), 13));      % bit 13
    reg = bitor(reg, bitshift(bitand(start_clkhs, 3), 14));    % bits 15-14
    reg = bitor(reg, bitshift(bitand(div_clkhs, 3), 17));      % bits 17-16
    reg = bitor(reg, bitshift(bitand(div_fire, 63), 19));      % bits 23-18
    reg = bitor(reg, bitshift(bitand(anz_fire, 63), 25));      % bits 29-24
    
end