function [LE,K] = LyapunovSpectrum_BBA(X,fs,t,t2,dl,dg,o,p)
% 计算混沌时间序列Lyapunov指数谱的BBA算法
% 使用平台 - Matlab7.0
% 作者：陆振波，海军工程大学
% 欢迎同行来信交流与合作，更多文章与程序下载请访问我的个人主页
% 电子邮件：luzhenbo@yahoo.com.cn
% 个人主页：http://luzhenbo.88uu.com.cn

% 参考文献:
%  Brown R, Bryant P, Abarbanel H D I. Computing the Lyapunov exponents of a dynamical system from oberseved time series[J]. Phys.Rev.A,1991,34:2787-2806.
%--------------------------------------------------------------------------
if nargin<8
    p = 0;
    if nargin<7
        o = 3;
    end
end

% 全局重构,对基准轨道求近邻点

XN1 = PhaSpaRecon2(X,t,t2,dg);      % 每一列一个相点
m = size(XN1,2);                    % 相空间点数

tmp = Taylor_lzb(ones(dl,1),o);
n = length(tmp);                    % Taylor展开式长度
nb = 2*n;                           % 近邻点个数

I1 = [1:m-1]';                      % 参考相点
I2 = SearchNN2(XN1(:,I1),I1,nb,max(0,floor(p/t2)));       % 近邻点下标

%--------------------------------------------------------------------------
% 局部重构求Jacobian矩阵,再QR分解

XN2 = XN1(1:dl,:);

Q = eye(dl);
LE = zeros(dl,m-1);
tmp = zeros(dl,1);
for j = 1:m-1
    
    A = XN2(:,I2(j,:))-repmat(XN2(:,I1(j)),1,nb);
    A = Taylor_lzb(A,o);
    A = A';
    
    B = XN2(:,I2(j,:)+1)-repmat(XN2(:,I1(j)+1),1,nb);
    B = B';
    
    DF = (A\B)';
    DF = DF(:,1:dl);
    
    [Q,R] = qr(DF*Q);
    
    tmp = tmp + log(diag(R))/t2*fs;
    LE(:,j) = real(tmp/j);
    
end

K = 1:m-1;



