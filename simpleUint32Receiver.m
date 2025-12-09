% 简化版本 - 直接运行这个脚本
function simpleUint32Receiver()
% 配置参数
comPort = 'COM9';      % 修改为你的COM端口
baudRate = 4800;     % 修改为你的波特率
numPoints = 5000;       % 要接收的数据点数量

    fprintf('开始从 %s 接收 %d 个uint32数据点...\n', comPort, numPoints);
    
    try
        % 创建串口对象
        % s = serial(, baudRate);
        s = serial(comPort,'BaudRate',4800);
        % configureTerminator(s, "LF");
        
        % 初始化数据缓冲区
        data = zeros(1, numPoints, 'uint32');
        count = 0;
        
        % 接收数据
        while count < numPoints
            if s.NumBytesAvailable > 0
                lineData = readline(s);
                value = str2double(char(lineData));
                
                if ~isnan(value)
                    count = count + 1;
                    data(count) = uint32(value);
                    
                    % 显示进度
                    if mod(count, 50) == 0
                        fprintf('进度: %d/%d\n', count, numPoints);
                    end
                end
            end
            pause(0.001);
        end
        
        % 关闭串口
        clear s;
        
        % 绘图
        figure('Position', [200, 200, 1000, 400]);
        
        % 折线图
        subplot(1,2,1);
        plot(1:numPoints, double(data), 'b-');
        grid on;
        xlabel('样本序号');
        ylabel('数值');
        title('数据序列');
        
        % 直方图
        subplot(1,2,2);
        histogram(double(data), 30, 'FaceColor', 'green');
        grid on;
        xlabel('数值');
        ylabel('频数');
        title('数据分布');
        
        sgtitle(sprintf('uint32数据可视化 (共%d个点)', numPoints));
        
        fprintf('完成！数据显示在图形窗口中。\n');
        
    catch ME
        fprintf('错误: %s\n', ME.message);
    end
end

