function x = pred(x)
%通过神经网络预测峰值超压峰值p和冲量峰值i
%   输入变量：泄压板泄压压力以及对应的超压峰值和冲量峰值
%   用途：还原泄压板压力，求解逆问题
%   注意：BP中每一列是一组输入训练集，行数代表输入层神经元个数，列数输入训练集组数。结果需为行向量
%   来源：https://blog.csdn.net/weixin_39505820/article/details/80204829
%BP神经网络开始
    close all
    clear all
    clc
    %导入数据
    x_train=(xlsread('原始数据-1.xlsx','sheet1','B4:F150'))';
    y_train=(xlsread('原始数据-1.xlsx','sheet1','G4:H150'))';%超压+冲量同时训练
    %训练集归一化
    [x_train_regular,x_train_maxmin] = mapminmax(x_train);
    [y_train_regular,y_train_maxmin] = mapminmax(y_train);
    %创建网络
    net=newff(x_train_regular,y_train_regular,8,{'tansig','purelin'},'trainbr');%10为隐藏层神经元个数，trainlm为L-M续联函数，trainbr为贝叶斯正则化法
    %估算公式(n+m)^0.5+a, n为输入层神经元个数，m为输出层神经元个数，a为1~10之间的常数,tansig激活函数值域为-1~1
    %设置训练次数
    net.trainParam.epochs = 5000;
    %设置收敛误差
    net.trainParam.goal=0.1;
    %s=设置学习速率
    net.trainParam.lr=0.01
    %训练网络
    [net,tr]=train(net,x_train_regular,y_train_regular);
%BP神经网络结束-------------------------------------------------------------
    pr = 2.76; %实验2点平均峰值压力2.76bar
    ir = 37942; %实验2点平均峰值冲量37942Pa.s
    error1=0.3;
    error2=0.2;
    error3=0.1;
    error4=0.01;  %error1~error4为30%~5%的4个误差等级 
    for m=1.8:0.05:3.0;   %n为点火点一侧的泄压压力,x4
        for n=m+0.1:0.05:m+0.5;  %x47
                x=[0.00047,0.00251,0.057975,m,n]'  %枚举生成泄压压力
                %开始调用神经网络结果；将预测数据归一化
                x_test_regular = mapminmax('apply',x,x_train_maxmin);
                %放入到网络输出数据
                y_test_regular=sim(net,x_test_regular);
                %将得到的数据反归一化得到预测数据
                y_test_regular=mapminmax('reverse',y_test_regular,y_train_maxmin);
                %结束调用神经网络
                p=y_test_regular(1,1);  %ANN训练结果计算pressure
                i=y_test_regular(2,1);  %ANN训练结果计算impulse
            if abs((p-pr)/pr)<error4 & abs((i-ir)/ir)<error4
                x1=x
                y1=y_test_regular
                dlmwrite('y1',y1,'-append')
                dlmwrite('x1',x1,'-append')
                return
            elseif abs((p-pr)/pr)<error3 & abs((i-ir)/ir)<error3
                x10=x
                y10=y_test_regular
                dlmwrite('y10',y10,'-append')
                dlmwrite('x10',x10,'-append')  
            elseif abs((p-pr)/pr)<error2 & abs((i-ir)/ir)<error2
                x20=x
                y20=y_test_regular
                dlmwrite('y20',y20,'-append')
                dlmwrite('x20',x20,'-append')
            elseif abs((p-pr)/pr)<error1 & abs((i-ir)/ir)<error1
                x30=x
                y30=y_test_regular
                dlmwrite('y30',y30,'-append')
                dlmwrite('x30',x30,'-append')
            end
        end
    end
end