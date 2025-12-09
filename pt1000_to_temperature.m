function temperature = pt1000_to_temperature(resistance, R0_calibration)
% PT1000_TO_TEMPERATURE 将PT1000电阻值转换为温度值
%
% 输入参数:
%   resistance - PT1000测量得到的电阻值(Ω)
%   R0_calibration - 校准参数(冰点电阻), 默认值 = 1000.0
%
% 输出参数:
%   temperature - 计算得到的温度值(°C)
%
% 使用示例:
%   temp = pt1000_to_temperature(1085.0, 1000.0); % 使用标准校准
%   temp = pt1000_to_temperature(1085.0, 1000.2); % 使用实测冰点电阻校准

    % 参数验证
    if nargin < 2
        R0_calibration = 1000.0; % 默认使用标准值
        fprintf('使用默认校准参数 R0 = %.2f Ω\n', R0_calibration);
    end
    
    if resistance <= 0
        error('电阻值必须为正数');
    end

    % IEC 60751 标准系数
    A = 3.9083e-3;
    B = -5.775e-7;
    
    % 使用校准后的R0进行计算
    R0 = R0_calibration;
    
    % 解二次方程: R = R0 * (1 + A*t + B*t^2)
    % 重排为: B*t^2 + A*t + (1 - R/R0) = 0
    a = B;
    b = A;
    c = 1 - resistance / R0;
    
    % 计算判别式
    discriminant = b^2 - 4*a*c;
    
    if discriminant < 0
        error('无实数解，请检查电阻值范围');
    end
    
    % 计算两个可能的解
    t1 = (-b + sqrt(discriminant)) / (2*a);
    t2 = (-b - sqrt(discriminant)) / (2*a);
    
    % 选择物理意义正确的解 (在-200°C ~ 850°C范围内)
    if t1 >= -200 && t1 <= 850
        temperature = t1;
    elseif t2 >= -200 && t2 <= 850
        temperature = t2;
    else
        error('计算得到的温度超出合理范围');
    end
end