function pre_lya_new(data,tau,m,P,lmd)
%预测结果带回源数据
% clc

% tau=1;
% m=35;
% P=2;
% lmd=.016;

disp('--------最大预测步数---------')
 MaxStep=round(1/lmd)
 
 MaxStep=5;%避免预测太长控制在10步
 
prestep=MaxStep;
newdata=data(1:length(data)-prestep);
newdata1=newdata;
newdata2=newdata;
%-----------最近距离不考虑相角--------------
for i=1:prestep
    i
    [idx,min_d,idx1,min_d1]=nearest_point(tau,m,newdata1,length(newdata1),P);
   [x_1,x_2]=prebylya_new(newdata1,m,tau,lmd,P,idx1);
%     [x_1,x_2]=pre_by_lya_new(m,lmd,newdata1,length(newdata1);
%     [x_1,x_2]=pre_by_lya1(tau,m,lmd,newdata1,length(newdata1),idx1,min_d1,1);
    newdata1(length(newdata)+i) = x_1;
end
%-----------最近距离考虑相角--------------
for i=1:prestep
    i
    [idx,min_d,idx1,min_d1]=nearest_point(tau,m,newdata2,length(newdata2),P);
       [x_1,x_2]=prebylya_new(newdata2,m,tau,lmd,P,idx);
    newdata2(length(newdata)+i) = x_1;
end

plot(length(newdata)+1:length(data),data(length(newdata)+1:length(data)),'b-',length(newdata)+1:length(data),newdata1(length(newdata)+1:length(data)),'r-')
hold on
plot(length(newdata)+1:length(data),newdata2(length(newdata)+1:length(data)),'m--');
 legend('Original','Predict(不考虑相角)','Predict(考虑相角)');
%-----------求标准差-----------------
delt1=std(data(length(newdata)+1:length(data))-newdata1(length(newdata)+1:length(data)))
delt2=std(data(length(newdata)+1:length(data))-newdata2(length(newdata)+1:length(data)))

%-----------求RMSE----------------------
old=data(length(newdata)+1:length(data));
new1=newdata1(length(newdata)+1:length(data));
new2=newdata2(length(newdata)+1:length(data));
q=mean(old);
RMSE1=norm(new1-old,2)/norm(old-q,2)
RMSE2=norm(new2-old,2)/norm(old-q,2)

%-------------中误差-----------------
v1=abs(new1-old);
v2=abs(new2-old);
MSE1=sqrt(v1'*v1/length(new1))
MSE2=sqrt(v2'*v2/length(new2))