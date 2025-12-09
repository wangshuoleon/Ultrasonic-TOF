comPort = 'COM9';      % 修改为你的COM端口
numPoints = 600;       % 要接收的数据点数量

s = serial(comPort,'BaudRate',4800);
set(s, 'InputBufferSize', 5000000);
fopen(s);

fwrite(s,1,'uint8');

while (s.BytesAvailable<numPoints*4)
    pause(1)
end

rawData=fread(s,s.BytesAvailable/4,'uint32');

fread(s,s.BytesAvailable,'uint8');

s= instrfind;
if isempty(s)
else
fclose(s);
delete(s);
clear s;
end
