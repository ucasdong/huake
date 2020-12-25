fpga code 

记录

FPGA上电后默认不工作，FIFO为空状态。

先写0  再写1  FPGA使用0--1 的跳变沿复位FIFO，同时启动AD的采集。写满FIFO后，将FIFO状态值1(36)  上位机开始读数

ISE 工程建立：

将文件全部ADD后，点击生成bit即可。














