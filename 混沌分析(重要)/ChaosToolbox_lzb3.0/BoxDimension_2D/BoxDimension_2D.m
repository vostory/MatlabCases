function [log2_C,log2_r] = BoxDimension_2D(c)
% 计算二进制图像的盒维数
%
% 输入参数
% c - 图像矩阵，补0到2^p*2^p
%
% 输出参数
% log2_C - 盒子数的对数，长度为p+1
% log2_r - 盒子边长的对数，这里r = 2.^[-p:0]，max(size(c))<=2^p，长度为p+1

%--------------------------------------------------------------------------

[rows,cols] = size(c);

if (rows>2^12 | cols>2^12)
    error('The size of figure must be less than 4096*4096');
end

if (ndims(c)~=2)
    error('The dimension of input data must be equal to 2!');
end

%--------------------------------------------------------------------------
% 边长补0到2的p次方

p = ceil(log2(max(rows,cols)));
lens = 2^p;
tmp1 = zeros(lens);
tmp1(1:rows,1:cols) = c;
c = tmp1;                    % 补0

%--------------------------------------------------------------------------
% 计算log2_C

c1 = c(:);
c1 = c1(find(c1>0));         % 找非0元素

log2_C = zeros(1,p+1);
for i = 1:p+1
    log2_C(i) = -log2(length(c1));
    
    if (i~=p+1)
        tmp2 = zeros(lens/2,lens);
        for j = 1:lens/2
            tmp2(j,:) = c(2*j-1,:)+c(2*j,:);        % 相邻行合并
        end
        c = zeros(lens/2,lens/2);                   % 新矩阵为原来的1/4
        for j = 1:lens/2
            c(:,j) = tmp2(:,2*j-1)+tmp2(:,2*j);     % 相邻列合并
        end
    
        lens = size(c,1);   
        c1 = c(:);
        c1 = c1(find(c1>0));                        % 找非0元素
    end
end

%--------------------------------------------------------------------------
% 定义log2_r

log2_r = -p:0;


