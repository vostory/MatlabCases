function [xn,dn] = PhaSpaRecon(s,tau,m,T)
% 混沌序列的相空间重构 (phase space reconstruction)
% [xn, dn, xn_cols] = PhaSpaRecon(s, tau, m)
% 输入参数：    s          混沌序列(列向量)
%               tau        重构时延
%               m          重构维数
%               T          直接预测步数
% 输出参数：    xn         相空间中的点序列(每一列为一个点)
%               dn         一步预测的目标(行向量)

[rows,cols] = size(s);
if (rows>cols)
    len = rows;
    s = s';
else
    len = cols;
end

if (nargin < 4)
    T = 1;
end

if (nargout==1)

    if (len-(m-1)*tau < 1)
        disp('err: delay time or the embedding dimension is too large!')
        xn = [];
    else
        xn = zeros(m,len-(m-1)*tau);
        for i = 1:m
            xn(i,:) = s(1+(i-1)*tau : len-(m-i)*tau);   % 相空间重构，每一行为一个点 
        end
    end
    
elseif (nargout==2)
    
    if (len-T-(m-1)*tau < 1)
        disp('err: delay time or the embedding dimension is too large!')
        xn = [];
        dn = [];
    else
        xn = zeros(m,len-T-(m-1)*tau);
        for i = 1:m
            xn(i,:) = s(1+(i-1)*tau : len-T-(m-i)*tau);   % 相空间重构，每一行为一个点 
        end
        dn = s(1+T+(m-1)*tau : end);    % 预测的目标
    end
    
end



