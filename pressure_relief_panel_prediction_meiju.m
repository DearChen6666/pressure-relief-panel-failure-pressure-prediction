function x = pred(x)
%ͨ��������Ԥ���ֵ��ѹ��ֵp�ͳ�����ֵi
%   ���������йѹ��йѹѹ���Լ���Ӧ�ĳ�ѹ��ֵ�ͳ�����ֵ
%   ��;����ԭйѹ��ѹ�������������
%   ע�⣺BP��ÿһ����һ������ѵ���������������������Ԫ��������������ѵ���������������Ϊ������
%   ��Դ��https://blog.csdn.net/weixin_39505820/article/details/80204829
%BP�����翪ʼ
    close all
    clear all
    clc
    %��������
    x_train=(xlsread('ԭʼ����-1.xlsx','sheet1','B4:F150'))';
    y_train=(xlsread('ԭʼ����-1.xlsx','sheet1','G4:H150'))';%��ѹ+����ͬʱѵ��
    %ѵ������һ��
    [x_train_regular,x_train_maxmin] = mapminmax(x_train);
    [y_train_regular,y_train_maxmin] = mapminmax(y_train);
    %��������
    net=newff(x_train_regular,y_train_regular,8,{'tansig','purelin'},'trainbr');%10Ϊ���ز���Ԫ������trainlmΪL-M����������trainbrΪ��Ҷ˹���򻯷�
    %���㹫ʽ(n+m)^0.5+a, nΪ�������Ԫ������mΪ�������Ԫ������aΪ1~10֮��ĳ���,tansig�����ֵ��Ϊ-1~1
    %����ѵ������
    net.trainParam.epochs = 5000;
    %�����������
    net.trainParam.goal=0.1;
    %s=����ѧϰ����
    net.trainParam.lr=0.01
    %ѵ������
    [net,tr]=train(net,x_train_regular,y_train_regular);
%BP���������-------------------------------------------------------------
    pr = 2.76; %ʵ��2��ƽ����ֵѹ��2.76bar
    ir = 37942; %ʵ��2��ƽ����ֵ����37942Pa.s
    error1=0.3;
    error2=0.2;
    error3=0.1;
    error4=0.01;  %error1~error4Ϊ30%~5%��4�����ȼ� 
    for m=1.8:0.05:3.0;   %nΪ����һ���йѹѹ��,x4
        for n=m+0.1:0.05:m+0.5;  %x47
                x=[0.00047,0.00251,0.057975,m,n]'  %ö������йѹѹ��
                %��ʼ����������������Ԥ�����ݹ�һ��
                x_test_regular = mapminmax('apply',x,x_train_maxmin);
                %���뵽�����������
                y_test_regular=sim(net,x_test_regular);
                %���õ������ݷ���һ���õ�Ԥ������
                y_test_regular=mapminmax('reverse',y_test_regular,y_train_maxmin);
                %��������������
                p=y_test_regular(1,1);  %ANNѵ���������pressure
                i=y_test_regular(2,1);  %ANNѵ���������impulse
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