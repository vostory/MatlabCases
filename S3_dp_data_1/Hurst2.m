%Hurst指数分析
function [ln_RS,ln_n]=Hurst2(data,n_max)
% data=xn';
% n_max=251;
%本函数是用Hurst指数分析时间序列
%data：待分析的时间序列
%n_max：子序列的最大长度
%ln_RS：返回的ln(R/S)的值
%ln_n：返回的ln(n)的值
N=length(data); %待分析时间序列的长度
ln_n=log(10:10:n_max)';  %返回的ln(n)的值

for n=10:10:n_max
    a=floor(N/n); %时间序列分成子序列的个数
    X=reshape(data(1:n*a),n,a); %把时间序列分成a个长度为n的子序列
    aver=mean(X); %计算每一个子序列的平均值
    cumdev=X-ones(n,1)*aver; %每个子序列的元素减去本列的平均值
    cumdev=cumsum(cumdev); %计算每一个子序列的积累离差
    stdev=std(X); %计算每一个子序列的均方差
    RS=(max(cumdev)-min(cumdev))./stdev; %计算每一个子序列的R/S值
    ln_RS(n/10,1)=log(mean(RS)); %计算所有子序列R/S值的平均值
end

% 绘图
figure,
plot(ln_n,ln_RS)
xlabel('ln（n）');
ylabel('ln（RS）');