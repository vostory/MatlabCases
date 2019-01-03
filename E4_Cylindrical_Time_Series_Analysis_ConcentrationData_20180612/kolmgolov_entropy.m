function  [Km,Kmean]=kolmgolov_entropy(data0,Fs,p,name11,filepath)
%%%%%%%%%%%%%%%%%%%%%%kolmgolov entropy%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% 作者：李兰兰
%%%% 日期：2010.07.08
%%%  关于输入：
%          A为需要计算特征的数据（单导）；
%          Fs为输入的采样率，
%          p如果等于1则画出kolmogolov熵随时间变化的曲线图
%%%  关于输出：
%         Km代表程序计算得到的kolmogolov熵的特征值，每window_t s个点得到一个值，计算时每次重叠window_t/2 s，
%         Average为输出kolmogolov熵的平均值
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
window_t=10;
N=window_t;%每次计算的序列长度
m=15;
G=length(data0);
g=Fs*(window_t/2);%每次滑动的点数
t=((G-N)/g);
h=floor(t);
LKm=zeros(h,1);

for i=0:h %滑动的次数
    data=data0(1+i*g:N+i*g);
    tau=3*0.02;
    %tau=C_C_delay(data,name11,filepath)
    LKm(i+1)=log((CK(data,m,N,tau))./(CK(data,m+13,N,tau)));
    Km=(1/(tau*13))*LKm;
    %Ke=Km(3);
end

if p==1,
    figure,
    plot(Km);
    print(gcf,'-dtiff',[filepath,'Km_',name11,'.tiff']);   %保存tiff格式的图片到指定路径
    close all;
end

Kmean=mean(Km);

