function KL_Data=K_L_GP(data,m,tau)
%该函数用来对时间序列的重构相空间进行K_L变换
%data:输入的时间序列
%m:重构相空间的维数
%tau:重构相空间的时间延迟
%KL_lamda:重构相空间协方差矩阵的m个特征值
%KL_Data:进行K_L变换后的m*m维矩阵

Data=reconstitution2(data,m,tau); %对时间序列进行相空间重构
KLX=mean(Data'); %计算重构相空间矩阵每一行的平均值
KLdata=Data-KLX'*ones(1,length(data)-(m-1)*tau); %相空间矩阵每一行元素减去此行的平均值
KLData=(KLdata*KLdata')/(length(data)-(m-1)*tau); %求协方差矩阵
[V,D]=eig(KLData);

%计算协方差矩阵的m个特征值和特征向量
%KL_lamda=zeros(1,m);
% for ii=1:m
%     KL_lamda(ii)=D(ii,ii); %将协方差矩阵的特征值赋给KL_D
% end

KL_Data=V'*Data; %计算K_L变换后的矩阵
