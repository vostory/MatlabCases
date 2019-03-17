% close all
% clc
data=xn;
%% -------------------------------------------
PreStep=input('请输入预测步数(默认为10步)=');
if isempty(PreStep)
    PreStep=10
else
   PreStep
end

 max_m=input('请输入cao法和G_P法中max_m(默认为20)=');
if isempty(max_m)
    max_m=20
else
   max_m
end

 max_N=input('请输入小波分解层数(默认为3)=');
if isempty(max_N),
    max_N=3,
else
   max_N,
end

if max_N==0,
    main_process(data,PreStep,max_m);
else
    disp('---------小波多层分解-----------------')
    [A,D]=wave(data,max_N);
    main_process(A,PreStep,max_m);
    for i=1:max_N,
        main_process(D(i,:)',PreStep,max_m);
    end
end
    
    
    