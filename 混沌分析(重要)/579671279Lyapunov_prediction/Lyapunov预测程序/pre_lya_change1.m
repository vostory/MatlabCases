function MSE=pre_lya_change1(data,tau,m,P,lmd,MaxStep)
%单步预测
% clc

% tau=1;
% m=35;
% P=2;
% lmd=.016;

% disp('--------最大预测步数---------')
%  MaxStep=round(1/lmd)
 
% MaxStep=5;%避免预测太长控制在10步
 
prestep=MaxStep;

%-----------最近距离不考虑相角--------------
for step=1:prestep
    step
    newdata1=data(1:length(data)-prestep+step-1);
    [idx,min_d,idx1,min_d1]=nearest_point(tau,m,newdata1,length(newdata1),P);
    %[x_1,x_2]=prebylya_new(newdata1,m,tau,lmd,P,idx);
   % [x_1,x_2]=pre_by_lya_new(m,lmd,newdata1,length(newdata1),P,idx1);
    [x_1,x_2]=pre_by_lya1(tau,m,lmd,newdata1,length(newdata1),idx1,min_d1,1);
    pre_value1(step)= x_1;
end
%-----------最近距离考虑相角--------------
% for step=1:prestep
%     step
%     newdata2=data(1:length(data)-prestep+step-1);
%     [idx,min_d,idx1,min_d1]=nearest_point(tau,m,newdata2,length(newdata2),P);
%     [x_1,x_2]=pre_by_lya1(tau,m,lmd,newdata2,length(newdata2),idx,min_d,1);
%     pre_value2(step) = x_1;
% end

% % plot(length(data)-prestep+1:length(data),data(length(data)-prestep+1:length(data)),'b-',length(data)-prestep+1:length(data),pre_value1,'r-')
% % hold on
%plot(length(data)-prestep+1:length(data),pre_value2,'m--');
% % legend('原数据','lyap指数法');%,'Predict(考虑相角)');
% disp('-----------求标准差-----------------')
% delt1=std(data(length(newdata)+1:length(data))-newdata1(length(newdata)+1:length(data)))
% delt2=std(data(length(newdata)+1:length(data))-newdata2(length(newdata)+1:length(data)))

disp('-----------求RMSE----------------------')
old=data(length(data)-prestep+1:length(data))';
q=mean(old);
RMSE1=norm(pre_value1-old,2)/norm(old-q,2)
%RMSE2=norm(pre_value2-old,2)/norm(old-q,2)

disp('-------------中误差-----------------')
v=abs(pre_value1-old);
MSE=sqrt(sum(v.^2)/length(old))
disp('----------MAPE平均绝对百分比误差---------------')
for i=1:length(old)
    a1(i)=abs((old(i)-pre_value1(i))/old(i));
%    a2(i)=abs((old(i)-pre_value2(i))/old(i));
end
MAPE1=sum(a1)/length(old)*100
%MAPE2=sum(a2)/length(old)*100