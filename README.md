# Python API for Ultrasonic TOF
This is the python api for operating TOF measurement

## 连接设备
```python
pip install pyserial  # 安装串口模块
import serial         # 导入 pyserial 库
```
### 1. 获取从下拉列表中选择的串口名称
```python
selected_port = "COM3"  # 示例值，实际应从ports = serial.tools.list_ports.comports()中选取
```
### 2. 创建串口对象，设置波特率为 4800
```python
instrument_object = serial.Serial(
    port=selected_port,     # 串口名称
    baudrate=4800,          # 波特率
    timeout=1               # 可选的读取超时设置（单位：秒）
)
```
### 3. 配置输入缓冲区大小（单位：字节）
```python
instrument_object.input_buffer_size = 5000000  # 设置缓冲区为 5,000,000 字节
```
### 4. 打开串口（在 pyserial 中，创建对象时若未设置 open()，则需显式打开）
### 注意：如果在创建 Serial 对象时未指定 lazy_open=True，串口会在创建时自动打开。
```python
if not instrument_object.is_open:
    instrument_object.open()
```

### 此时串口已打开，可以开始读写操作
```python
print(f"串口 {selected_port} 已成功打开，波特率 4800，输入缓冲区大小 {instrument_object.input_buffer_size} 字节")
```

## 配置设备

### 寄存器
```python
       sel_tsto1 = 0;
       sel_tsto2 = 0;
       
       sel_timo_mb=2;
       hitin=9;
      
       neg_stop=0;
       neg_start=0; 
       # 1 晶振持续开启， 2tdc启动之后，开启晶振
       start_clkhs=1;
       div_clkhs=0;
       div_fire=3;
       anz_fire=8;
       
       # register1
       offset=0;
       DELVAL1=120;
       RFEDGE=0;
       EN_INT_ALU=1;
       EN_INT_HIT=0;
       EN_INT_TO=0;
```

