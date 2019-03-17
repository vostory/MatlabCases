 function MSE=Predict1(data,m,tau,P,lmd,MaxStep)
%单步预测

% disp('--------最大预测步数---------')
%  MaxStep=round(1/lmd)
% % MaxStep=5;
% % MaxStep=MaxStep+5;%避免预测太长控制在10步
deltaT=1;



for i=1:MaxStep
    i
    newdata=data(1:length(data)-MaxStep+i-1);
    pre_value(i) = FunctionChaosPredict(newdata,length(newdata),P,deltaT,tau,m,1);%调用AOLMM进行多步预报
end

%figure(1)
%  plot(length(data)-MaxStep+1:length(data),data(length(data)-MaxStep+1:length(data)),'b-',length(data)-MaxStep+1:length(data),pre_value,'r-*');
% legend('Original','Predict(局域法)');
% %-----------求标准差-----------------
% delt=std(data(length(newdata)+1:length(data))-newdata1(length(newdata)+1:length(data)))

disp('-----------求RMSE----------------------')
old=data(length(data)-MaxStep+1:length(data))';
q=mean(old);
RMSE=norm(pre_value-old,2)/norm(old-q,2)
disp('-------------中误差-----------------')
v=abs(pre_value-old);
MSE=sqrt(sum(v.^2)/length(old))


disp('----------MAPE平均绝对百分比误差---------------')
for i=1:length(old)
    a(i)=abs((old(i)-pre_value(i))/old(i));
end
MAPE=sum(a)/length(old)*100
