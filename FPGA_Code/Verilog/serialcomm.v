`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:13:07 12/04/2017 
// Design Name: 
// Module Name:    serialcomm 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module serialcomm(
    input clk,
    input rst_n,
    input rxd,
    input [7:0] outd,
    output txd,
    output [7:0] data
    );
	 //中间参数定义
	
	//接口参数定义
	wire clk_baud;//波特率时钟
	wire sent_trig;
	wire sent_switch;
	
	//状态参数定义
	
	//子模块实例化定义
	//9600波特率时钟产生模块
	clk_baud_gen U1(
		.clk(clk),
		.clr(rst_n),
		.clk_baud(clk_baud)
	);
	clk_sent U2(
		.clk(clk),
		.clr(rst_n),
		.sent_switch(sent_switch),
		.senttrig(sent_trig)
	);
	//接收模块
	serial_rxd U3(
		.clk(clk_baud),//波特率时钟
		.clr(rst_n),//全局复位端
		.rxd(rxd),	//FPGA接收数据端
		.sent_switch(sent_switch),
		.data(data)	//8位数据寄存器输出
    );
	 //发送模块
	 serial_txd U4(
		.clk(clk_baud),//波特率时钟
		.clr(rst_n),//全局复位端
		.enable(sent_trig),//发送使能端
		.data(outd),//FPGA数据发送时，所发送的数据
		.txd(txd)//FPGA数据发送端
	 );
	
	//初始化寄存器
	
	//显示数据模块
endmodule


module clk_baud_gen(
    input clk,
    input clr,
    output reg clk_baud
    );
	//clk为50MHz，而clk_baud需要为9600Hz，则一个clk_baud周期包含5208.3333个clk周期
	reg [11:0]divclk;
	
	initial
	begin
		divclk<=0;
		clk_baud<=0;
	end
	
	always @(posedge clk or posedge clr)
	begin
		//复位
		if(clr)
		begin
			divclk<=0;
			clk_baud<=0;
		end
		//半周期翻转
		else if(divclk>=2603)
		begin
			divclk<=0;
			clk_baud<=~clk_baud;
		end
		//计数
		else
			divclk<=divclk+1;
	end

endmodule

module clk_sent(
	 input clk,
    input clr,
	 input sent_switch,
    output reg senttrig
    );
	 //clk为50MHz，而clk_senttrig需要为100Hz，则一个clk_baud周期包含500000个clk周期
	reg [19:0]divclk;
	
	initial
	begin
		divclk<=0;
		senttrig<=0;
	end
	
	always @(posedge clk or posedge clr)
	begin
		//复位
		if(clr)
		begin
			divclk<=0;
			senttrig<=0;
		end
		//半周期翻转
		else if(divclk>=250000)
		begin
			divclk<=0;
			if(sent_switch)
			senttrig<=~senttrig;
			else senttrig<=0;
		end
		//计数
		else
			divclk<=divclk+1;
	end
endmodule


module serial_rxd(
    input clk,			//波特率时钟
    input clr,			//全局复位端
    input rxd,			//FPGA接收数据端
	 output reg sent_switch,
    output reg [7:0]data	//8位移位寄存器
    );

	//中间参数定义
	reg [3:0]count;//计数器，用于记录接收的数据位数
	reg [1:0]rec_state;//起始位检测寄存器，同时作为FPGA当前工作状态指示器
	
	
	//初始化寄存器
	initial
	begin
		count<=0;
		rec_state<=2'b11;//处于空闲状态（待接收状态）
		data<=8'bzzzzzzzz;//指示灯高阻不亮
		sent_switch<=0;
	end
	
	
	//接收数据模块
	always @(posedge clk or posedge clr)
	begin
		//复位清零动作
		if(clr)
		begin
			rec_state<=2'b11;//处于空闲状态（待接收状态）
			count<=0;//当前计数位数
			sent_switch<=0;
			data<=8'bzzzzzzzz;//指示灯高阻不亮
		end
		//以下为波特率时钟发生的动作
		//当前处于空闲状态，则接收上位机数据至rec_state寄存器中
		else if(rec_state==2'b11)
			rec_state[0]<=rxd;
		//当前处于接收数据状态，且接收位数小于8，则接收上位机数据至data移位寄存器中
		else if(rec_state==2'b10 && count<8)
		begin
			data[7]<=data[6];
			data[6]<=data[5];
			data[5]<=data[4];
			data[4]<=data[3];
			data[3]<=data[2];
			data[2]<=data[1];
			data[1]<=data[0];
			data[0]<=rxd;//FPGA接收到的数据进入低位
			count<=count+1;//接收位数记录
		end
		//当前处于接收数据状态，且接收位数大于等于8，让其工作在空闲状态，清空接收位数记录器
		else
		begin
			count<=0;
			rec_state<=2'b11;
			if(data[6]==0 && data[7]==0) sent_switch<=1;
			else sent_switch<=0;
		end
	end
	
endmodule


module serial_txd(
    input clk,			//波特率时钟
    input clr,			//全局复位端
    input enable,		//发送使能端
    input [7:0]data,	//FPGA数据发送时，所发送的数据
    output reg txd	//FPGA数据发送端
    );
	//中间参数定义
	//reg [7:0]reg_data;	//原始数据的移位寄存器
	reg [3:0] cnt;       //发送数据位数计数器

	


always @(posedge clk or posedge clr)
      if(clr)
        cnt<=4'd0;                        //串口发送计数器复位
      else if(enable==0)                    
        cnt<=4'd0;                        //若没有检测到串口发送标志位，则计数器等待
      else if(enable==1)
        cnt<=(cnt>=10)?11:cnt+1; //检测到串口发送标志位，启动计数器
always @(posedge clk or posedge clr)
      if(clr)
        txd<=1'bz;              //发送端复位，高阻态        
  else 
        case (cnt)
    4'd0:txd<=1'bz;         
    4'd1:txd<=1'b0;         //发送起始位
    4'd2:txd<=data[0];      //发送第一位
    4'd3:txd<=data[1];      //发送第二位
    4'd4:txd<=data[2];      //发送第三位
    4'd5:txd<=data[3];      //发送第四位
    4'd6:txd<=data[4];      //发送第五位
    4'd7:txd<=data[5];      //发送第六位
    4'd8:txd<=data[6];      //发送第七位
    4'd9:txd<=data[7];      //发送第八位
    4'd10:txd<=1'b1;        //发送停止位
    default:txd<=1'bz;
  endcase


endmodule