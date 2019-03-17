function [log2_C,log2_r] = BoxDimension_TS(s,partition)
% 计算时间序列的广义维数
%
% 输入参数
% s - 时间序列
% partition - 每一维坐标上的分割数
%
% 输出参数
% log2_C - 盒子数的对数
% log2_r - 盒子边长的对数

%--------------------------------------------------------------------------
lens = length(s);

if nargin < 2
    partition = min(lens-1,4096);
end

if partition > lens-1
    error(['The value of the 2ed input parameter must be no more than ',num2str(lens-1)]);
end

if partition > 2^12
    error('The value of the 2ed input parameter must be no more than 4096');
end

n = ceil((lens-1)/partition);        % 最小的盒子含有的点数
   
%--------------------------------------------------------------------------
% 归一化到一个方形区域

s = s-min(s)+1e-50;
s = s/max(s)*(lens-1);              % 幅值归一化到[1e-50/max(s)*(lens-1),lens-1]

% figure; 
% hold on;
% plot([0,lens-1],repmat(0:lens-1,2,1),'g'); axis equal tight;
% plot(repmat(0:lens-1,2,1)',[0,lens-1],'g');  

%--------------------------------------------------------------------------
% 图像矩阵赋值

c = zeros(partition);                   % 图像矩阵
for j = 1:lens-1
    j;
    s0 = s(j:j+1);     
    s1 = ceil(min(s0));         % 下端点
    s2 = ceil(max(s0));         % 上端点
    for i = s1:s2
        ii = ceil(i/n);
        jj = ceil(j/n);
        c(ii,jj) = c(ii,jj)+1;                     
%         y = [i i-1 i-1 i];
%         x = [j j   j-1 j-1];
%         fill(x,y,'y');
    end    
end

% plot(0:lens-1,s,'r.-'); 
% hold off;

%--------------------------------------------------------------------------
% 边长补0到2的p次方

[rows,cols] = size(c);
p = ceil(log2(max(rows,cols)));
lens = 2^p;
tmp1 = zeros(lens);
tmp1(1:rows,1:cols) = c;
c = tmp1;                           % 边长补0到2的p次方

%--------------------------------------------------------------------------
% 计算盒子总数

c1 = c(:);
c1 = c1(find(c1>0));                % 找非0元素
L = sum(c1);                        % 计算盒子总数

%--------------------------------------------------------------------------
% 计算log2_C

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
        c1 = c1(find(c1>0));                    % 找非0元素
    end    
end

%--------------------------------------------------------------------------
% 定义log2_r
log2_r = -p:0;


