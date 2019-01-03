%混沌和噪声识别
function sigma= PCA(data,m,tau)
%该函数用主分量分析(PCA)方法识别混沌和噪声。混沌信号的主分量谱图应是一条过定
%点且斜率为负值的直线，而噪声信号的主分量谱图应是一条与X轴接近平行的直线，故
%可以用主分量分布标准方差作为识别混沌和噪声的一种特征。
%data：输入的待分析时间序列
%m：重构相空间的维数
%tau:重构相空间的时间延迟
%sigma：主分量分布的标准方差

Data=reconstitution2(data,m,tau);%对时间序列进行相空间重构
KLX=mean(Data');%计算重构相空间矩阵每一行的平均值
KLdata=Data-KLX'*ones(1,length(data)-(m-1)*tau);%相空间矩阵每一行元素减去此行的平均值
A=(KLdata*KLdata')/(length(data)-(m-1)*tau);%求协方差矩阵
%A=(Data*Data');

lamda=eig(A);%计算协方差矩阵的特征值
lamda=-sort(-lamda);%将特征值从大到小排序
lamda_PCA=log(lamda/sum(lamda));

plot(lamda_PCA);%做主分量谱图
ylabel('主分量分析(PCA)')
title('主分量谱图')
sigma=std(lamda_PCA);%计算主分量分布的标准方差
