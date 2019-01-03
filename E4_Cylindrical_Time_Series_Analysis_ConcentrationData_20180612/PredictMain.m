function PredictMain(data,m,tau,P,lmd,MaxStep)
%一次多步预测

% disp('--------最大预测步数---------')
%  MaxStep=round(1/lmd)
%  
%  MaxStep=5;%避免预测太长控制在10步
% MaxStep=MaxStep+5;

newdata=data(1:length(data)-MaxStep);

PredictedData = FunctionChaosPredict(newdata,length(newdata),P,1,tau,m,MaxStep);%调用AOLMM进行多步预报

plot(length(newdata)+1:length(data),data(length(newdata)+1:length(data)),'b-',length(newdata)+1:length(data),PredictedData,'r--');
legend('Original','Predict(一次多步)');

% delt=std(data(length(newdata)+1:length(data))-PredictedData')
disp('-----------求RMSE----------------------')
old=data(length(newdata)+1:length(data));
new=PredictedData';
q=mean(old);
RMSE=norm(new-old,2)/norm(old-q,2)
%disp('-------------中误差-----------------')
%v=abs(new-old);
%MSE=sqrt(v'*v/length(new))

disp('----------MAPE平均绝对百分比误差---------------')
for i=1:length(old)
    a(i)=abs((old(i)-new(i))/old(i));
end
MAPE=sum(a)/length(old)*100

disp('-------------中误差-----------------')
v=abs(new-old);
MSE=sqrt(sum(v.^2)/length(old))



%此方式预测效果好