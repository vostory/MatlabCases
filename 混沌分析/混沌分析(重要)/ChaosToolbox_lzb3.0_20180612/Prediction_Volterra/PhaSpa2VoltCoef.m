function [Un,len_filter] = PhaSpa2VoltCoef(xn,p)
% 构造 Volterra 自适应 FIR 滤波器的输入信号矢量 Un
% [Un, len_filter] = PhaSpa2VoltCoef(xn, p)
% 输入参数：
% xn           相空间中的点序列(每一列为一个点)
% p            Volterra 级数阶数
% 输出参数：
% Un           Volterra 自适应 FIR 滤波器的输入信号矢量 Un

[m,xn_cols] = size(xn);         % m 为重构维数，xn_cols 为训练样本个数
Un(1,:) = ones(1,xn_cols);      % FIR 滤波器的抽头输入信号矢量 Un (第一个系数为 1)
h_cols_1 = 0;

for k = 1:p

    clear h;
    h(1,:) = zeros(1,k);        % k 阶 Volterra 核的下标 (第一个为 0,0,0... )
    i = 1;
    
    % 当上一行最后一列数值达到 m-1 结束循环
    while h(i,end)<m-1
        i = i + 1;
        % 从后往前考察上一行每一列
        for j = k:-1:1
            % 当上一行第 j 列数值达到 m-1 时，这一行的第 1 至第 j+1 列的数值均为上一行第 j+1 列数值加 1，其余不变
            if (h(i-1,j)==m-1)
                h(i,1:j+1) = ones(1,j+1) * (h(i-1,j+1)+1);
                h(i,j+2:end) = h(i-1,j+2:end);
                break;
            end
            
            % 当上一行数值都没有达到 m-1 时，这一行第 1 列数值加 1，其余不变
            h(i,1) = h(i-1,1)+1;
            h(i,2:end) = h(i-1,2:end);            
        end
    end
    %disp('------------------')
    h;                          % 构造 k 阶 Volterra 核的下标
    h_cols_1 = [h_cols_1;h(:,1)];
    
    index = m - h;
    [index_rows,index_cols] = size(index);
    
    un = zeros(index_rows,xn_cols);
    
    %for q = 1:xn_cols
    %    vector = xn(:,q);
    %    array = vector(index);    % 从列向量中提取出x(n),x(n-tau),x(n-2*tau)...
    %    un(:,q) = prod(array,2);    % 计算x(n),x(n-tau),x(n-2*tau)...之间的乘积      
    %end
   
    %------------------------------------------------
    % 上面是原始算法，下面是优化算法
    
    for j = 1:index_rows
        xn_rows_index = index(j,:);
        xn_rows = xn(xn_rows_index,:);
        un(j,:) = prod(xn_rows,1);
    end
    
    Un = [Un;un];       % FIR 滤波器的抽头输入信号矢量 Un
    clear un;
end
      
len_filter = size(Un,1);