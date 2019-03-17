%多步预测(不回带数据)
tau=1;
m=2;
P=2;
lmd=.5948;
prestep=1;%预测步数要小于tau
newdata=data(1:length(data)-prestep);

[idx,min_d,idx1,min_d1]=nearest_point(m,newdata,length(newdata),P);
[x_1,x_2]=pre_by_lya1(m,lmd,newdata,length(newdata),idx,min_d,prestep);

plot(1:prestep,x_1,'*',1:prestep,x_2,'.',1:prestep,data(length(newdata)+1:length(data)),'+')

delt1=std(data(length(newdata)+1:length(data))-x_1')
delt2=std(data(length(newdata)+1:length(data))-x_2')

%-----------求RMSE----------------------
old=data(length(newdata)+1:length(data));
new1=x_1';
new2=x_2';
q=mean(old);
RMSE1=norm(new1-old,2)/norm(old-q,2)
RMSE2=norm(new1-old,2)/norm(old-q,2)
