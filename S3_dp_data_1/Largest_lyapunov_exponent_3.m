function lambda_1=largest_lyapunov_exponent_2(data,m,tau,P)             

%注意："这个程序得到的lambda_1不能当做最大lyapunov指数，因根据所作出的曲线选择线性区进行拟合，此处的处理是为了程序的方便"

%本函数使用小数据量方法计算最大lyapunov指数
%data:时间序列
%m:嵌入维
%tau:时间延迟
%P:使用 FFT计算出的时间序列平均周期
%lambda_1:函数返回的最大最大lyapunov指数值

N=length(data); %序列长度
delt_t=1;
Y=reconstitution2(data,m,tau ); %重构相空间
M=N-(m-1)*tau; %M是m维重构相空间中总点数
d=zeros(M-1,M);

for j=1:M
    d_min=1e+100;
    for jj=1:M, %寻找相空间中每个点的最近距离点，并记下该点下标 
        if abs(j-jj)>P,%限制短暂分离
            d_s=norm(Y(:,j)-Y(:,jj));%计算分离后两点的距离
            if d_s<d_min
                d_min=d_s;
                idx_j=jj;
            end           
        end
    end
    max_i=min((M-j),(M-idx_j));%计算点j的最大演化时间步长i
    for k=1:max_i, %计算点j与其最近邻点在i个离散步后的距离
       d(k,j)=norm(Y(:,j+k)-Y(:,idx_j+k));
    end
end

%对每个演化时间步长i，求所有的j的lnd(i,j)平均
[l_i,l_j]=size(d);
for i=1:l_i,
    q=0;
    y_s=0;
    for j=1:l_j,
        if d(i,j)~=0
            q=q+1;
            y_s=y_s+log(d(i,j));
        end
    end
    if q>0
      y(i)=y_s/(q*delt_t);
    end
end

figure,
x1=1:length(y);
plot(x1,y);
hold on

%拟合线性区域
x2=1:10;%length(y);
pp=polyfit(x2,y(x2),1);
lambda_1=pp(1);%斜率
yp=polyval(pp,x2);

plot(x2,yp,'-r');
text(100,5,['k=',num2str(lambda_1)]);
hold off

