function [index,distance] = SearchNN2(X1,query_indices,K,exclude)
% 在重构相空间中寻找最近邻点对
% 输入:   X1                重构的相空间
%         query_indices     最近邻参考点缺省为,[1:size(xn,2)]'  
%         K                 最近邻点的个数,缺省为 1
%         exclude           限制短暂分离，大于序列平均周期,缺省为 0
% 输出:   index             最近邻点下标
%         distance          最近邻距离  

if nargin < 4 
    exclude = 0;        % 限制短暂分离，大于序列平均周期        
    if nargin < 3
        K = 1;                  % 最近邻点的个数
        if nargin < 2
            N = size(xn,2);             % 重构轨道点数
            query_indices = [1:N]';     % 参考点    
        end
    end
end

%--------------------------------------------------------------------------

L1 = 7;
L2 = 7;
[Tree] = KNN_Tree(X1,L1,L2);

% function [Tree] = KNN_Tree(X1,L1,L2)
% KNN分叉树算法
% 输入参数:
% X  - 样本点,每一列一个点
% L1 - 第一层树节点数
% L2 - 第二层树节点数
%
% 输出参数:
% Tree{i}.len                   % 每一类个数
% Tree{i}.C                     % 每一类中心
% Tree{i}.Rmax                  % 最大半径
% Tree{i}.Tree{j}.X             % 样本点
% Tree{i}.Tree{j}.I             % 类别标签
% Tree{i}.Tree{j}.len           % 无样本点时，为0
% Tree{i}.Tree{j}.C             % 无样本点时，为0
% Tree{i}.Tree{j}.Rmax          % 无样本点时，为0 
% Tree{i}.Tree{j}.R             % 每个样本对类别中心距离
%
% Tree{L1+1}.IJK                % 样本点所属的两层节点序号

%--------------------------------------------------------------------------

[index,distance] = KNN_Search(Tree,query_indices,K,exclude);

% function [index,distance] = KNN_Search(Tree,query_indices,K,exclude)
% 在重构相空间中寻找最近邻点对(批处理)
% 输入:   Tree               KNN分叉树
%         query_indices     最近邻参考点缺省为,[1:size(xn,2)]'  
%         K                 最近邻点的个数,缺省为 1
%         exclude           限制短暂分离，大于序列平均周期,缺省为 0
% 输出:   index             最近邻点下标
%         distance          最近邻距离  

%--------------------------------------------------------------------------

function [Tree] = KNN_Tree(X1,L1,L2)
% KNN分叉树算法
% 输入参数:
% X  - 样本点,每一列一个点
% L1 - 第一层树节点数
% L2 - 第二层树节点数
%
% 输出参数:
% Tree{i}.len                   % 每一类个数
% Tree{i}.C                     % 每一类中心
% Tree{i}.Rmax                  % 最大半径
% Tree{i}.Tree{j}.X             % 样本点
% Tree{i}.Tree{j}.I             % 数据下标 
% Tree{i}.Tree{j}.len           % 无样本点时，为0
% Tree{i}.Tree{j}.C             % 无样本点时，为0
% Tree{i}.Tree{j}.Rmax          % 无样本点时，为0 
% Tree{i}.Tree{j}.R             % 每个样本对类别中心距离
%
% Tree{L1+1}.IJK                % 样本点所属的两层节点序号

IJK = zeros(3,size(X1,2));
[M1,R1max,N1,T1,R1] = KMeans2(X1,L1);
IJK(1,:) = T1;                             % 类别标签
for i = 1:L1
    I = find(T1==i);
    X2 = X1(:,I);

    Tree{i}.len = N1(i);                    % 每一类个数
    Tree{i}.C = M1(:,i);                    % 每一类中心
    Tree{i}.Rmax = R1max(i);                % 最大半径
    
    [M2,R2max,N2,T2,R2] = KMeans2(X2,L2);
    IJK(2,I) = T2;                          % 类别标签
    for j = 1:L2
        J = find(T2==j);        
        X3 = X2(:,J);
        
        Tree{i}.Tree{j}.X = X3;             % 每一类数据
        Tree{i}.Tree{j}.I = I(J);           % 数据下标  
        Tree{i}.Tree{j}.len = N2(j);        % 每一类个数  
        Tree{i}.Tree{j}.C = M2(:,j);        % 每一类中心
        Tree{i}.Tree{j}.Rmax = R2max(j);    % 最大半径
        Tree{i}.Tree{j}.R = R2(J);          % 每个样本对类别中心距离
        
        IJK(3,I(J)) = 1:length(J);          % 样本序号
    end
end
Tree{L1+1}.IJK = IJK;                       % 样本点所属的两层节点序号

%--------------------------------------------------------------------------

function [M1,R1max,N1,T1,R1] = KMeans2(X,c)
% 标准 K-Means 聚类
% 输入参数:
% X - 样本点,每一列一个点
% c - 聚类中心数
%
% 输出参数:
% M1    - 聚类中心,每一列一个点
% R1max - 每类样本对类别中心距离的最大距离
% N1    - 每一类个数
% T1    - 类别标签,行矢量
% R1    - 每个样本对类别中心距离

M1 = Initialize(X,c);                % 从c-1聚类的结果得到c聚类的代表点

tmax = 20;
k = 0;
Je = zeros(1,tmax);
while k<tmax
    
    k = k+1;    
    
    [M2,T1,R1,N1,R1max,je1] = KMeans2_Center_Update(X,M1);  % 输出聚类结果和代价函数收敛曲线
    Je(k) = je1;                                            % 代价函数赋值
    
    if k>2 & abs(Je(k)-Je(k-1))/(Je(k-1)+1e-8)<0.005
        break;                                  % 连续2次迭代,je不变,提前结束
    end
    M1 = M2;
end
Je = Je(1:k);

%--------------------------------------------------------------------------

function [M] = Initialize(X,c)
% 从c-1聚类的结果得到c聚类的代表点
% 参考文献
% 边肇祺 编著. 模式识别[M]. 北京:清华大学出版社. 1999. p236
%
% 输入参数:
% X - 样本点,每一列一个点
% c - 聚类中心数
%
% 输出参数:
% M - 聚类中心,每一列一个点

n = size(X,2);              % 样本总数
M = zeros(size(X,1),c);     % 从c-1聚类的结果得到c聚类的代表点
M(:,1) = mean(X,2);
Dis = zeros(1,n);
for i = 2:c
    for k = 1:n
        d0 = inf;
        for j = 1:i-1
            d1 = norm(X(:,k)-M(:,j));
            if d1<d0
                d0 = d1;
            end
        end
        Dis(k) = d0;
    end
    [tmp,m] = max(Dis);
    M(:,i) = X(:,m);
end

%--------------------------------------------------------------------------

function [M2,T1,R1,N1,R1max,je1] = KMeans2_Center_Update(X,M1)
% K-Means 聚类(中心更新函数)
% 参考文献
% Richard O.Duda 著,李宏东 译. 模式分类[M]. 北京:机械工业出版社. 2003. p424
%
% 输入参数:
% X   - 样本点,每一列一个点
% M1  - 聚类中心,每一列一个点
%
% 输出参数:
% M2    - 新聚类中心,每一列一个点
% T1    - 类别标签,行矢量
% R1    - 每个样本对类别中心距离
% N1    - 每一类个数
% R1max - 每类样本对类别中心距离的最大距离
% je1   - 代价函数值

[d,n] = size(X);                        % 样本点数
[d,c] = size(M1);
D = zeros(c,n);                         % 距离矩阵
for i = 1:c
    tmp1 = X - repmat(M1(:,i),1,n);
    D(i,:) = sum(tmp1.^2);              % 样本对中心的距离的平方
end

[R1,T1] = sort(D);
T1 = T1(1,:);
R1 = sqrt(R1(1,:));
    
N1 = zeros(1,c);
M2 = zeros(d,c);
R1max = zeros(1,c);
for i = 1:c
    J = find(T1==i);

    if ~isempty(J)
        N1(i) = length(J);              % 每一类个数        
        M2(:,i) = mean(X(:,J),2);       % 中心矢量更新(批量更新)                  
        R1max(i) = max(R1(J));
    else
        N1(i) = 0;                      % 无样本点时，为0
        M2(:,i) = 0;                    % 无样本点时，为0
        R1max(i) = 0;                   % 无样本点时，为0
    end
end
je1 = sum(R1);                        % 代价函数值

%--------------------------------------------------------------------------

function [index,distance] = KNN_Search(Tree,query_indices,K,exclude)
% 在重构相空间中寻找最近邻点对(批处理)
% 输入:   Tree               KNN分叉树
%         query_indices     最近邻参考点缺省为,[1:size(xn,2)]'  
%         K                 最近邻点的个数,缺省为 1
%         exclude           限制短暂分离，大于序列平均周期,缺省为 0
% 输出:   index             最近邻点下标
%         distance          最近邻距离  
%
% 其中Tree为
% Tree{i}.len                   % 每一类个数
% Tree{i}.C                     % 每一类中心
% Tree{i}.Rmax                  % 最大半径
% Tree{i}.Tree{j}.X             % 样本点
% Tree{i}.Tree{j}.I             % 数据下标 
% Tree{i}.Tree{j}.len           % 无样本点时，为0
% Tree{i}.Tree{j}.C             % 无样本点时，为0
% Tree{i}.Tree{j}.Rmax          % 无样本点时，为0 
% Tree{i}.Tree{j}.R             % 每个样本对类别中心距离
%
% Tree{L1+1}.IJK                % 样本点所属的两层节点序号

n = length(query_indices);
index = zeros(n,K);
distance = zeros(n,K);
for i = 1:n
    [in,di] = KNN_Search_1P(Tree,query_indices(i),K,exclude);
    index(i,:) = in;
    distance(i,:) = di;
end

%--------------------------------------------------------------------------
% 在重构相空间中寻找最近邻点对(1个点的K近邻算法 )

function [index,distance] = KNN_Search_1P(Tree,i,K,exclude)

IJK = Tree{end}.IJK;
ijk = IJK(:,i);
x = Tree{ijk(1)}.Tree{ijk(2)}.X(:,ijk(3));      % 第i个样本点

d = length(x);                                  % 数据维数
m = size(IJK,2);                                % 样本个数

if exclude>=0
    I = max(1,i-exclude):min(m,i+exclude);
    for j = 1:length(I)
        Tree = X_Inf(Tree,I(j));     % 将样本集X中第m个样本剪枝，并返回新树Tree
    end
end

%--------------------------------------------------------------------------
% K近邻初选

L1 = length(Tree)-1;             % 第一层树节点数
L2 = length(Tree{1}.Tree);       % 第二层树节点数

Len = zeros(1,L1*L2);
C = zeros(d,L1*L2);
IJ = zeros(2,L1*L2);
k = 0;
for i = 1:L1
    for j = 1:L2
        k = k+1;
        IJ(1,k) = i;                        % 第一层树节点序号
        IJ(2,k) = j;                        % 第二层树节点序号
        Len(k) = Tree{i}.Tree{j}.len;       % 每一类个数
        C(:,k) = Tree{i}.Tree{j}.C;         % 每一类中心
    end
end
C(:,find(Len==0))=inf;                      % 0个数节点中心最大化

tmp1 = C-repmat(x,1,L1*L2);
D = sum(tmp1.^2);
[tmp2,I] = sort(D);                         % 观测点与节点中心距离排序
Len = Len(I);    
IJ = IJ(:,I);

for i = 1:L1*L2
    if sum(Len(1:i))>2*K
        n = i;                              % 前n个节点样本点数总和大于2倍近邻点数
        break
    end
end
n = max(n,2);                               % 至少包括两个节点

Len = Len(1:n);                              % 取前n个节点
IJ = IJ(:,1:n);

X1 = [];
I1 = [];
for k = 1:n
        i = IJ(1,k);
        j = IJ(2,k);
        X1 = [X1,Tree{i}.Tree{j}.X];        % 第二层节点数据
        I1 = [I1,Tree{i}.Tree{j}.I];        % 第二层节点下标
end

tmp1 = X1-repmat(x,1,size(X1,2));           
E = sum(tmp1.^2);
[tmp2,I2] = sort(E);                        % 观测点与前n个节点所有样本距离排序
E = E(I2);
I1 = I1(I2);

index = I1(1:K);                          % 前K个近邻下标
distance = sqrt(E(1:K));                  % 前K个近邻距离

%--------------------------------------------------------------------------
% K近邻检验

for i = 1:L1
    len = Tree{i}.len;
    C = Tree{i}.C;                          % 第一层第i个节点的中心
    Rmax = Tree{i}.Rmax;                    % 第一层第i个节点的最大半径
    dmax = distance(end);                   % 观测点与第K个近邻的距离
    d = norm(x-C);
    if len==0 | d>dmax+Rmax                 % 第一层节点整体剪枝
        continue;
    end
    
    for j = 1:L2
        tmp1 = abs(IJ-repmat([i;j],1,size(IJ,2)));
        tmp2 = ~sum(tmp1);
        if ~isempty(find(tmp2==1))          % 如果[i;j]在IJ中剪枝  
            continue;
        end   
        
        len = Tree{i}.Tree{j}.len;
        C = Tree{i}.Tree{j}.C;
        Rmax = Tree{i}.Tree{j}.Rmax;
        d = norm(x-C);
        if len==0 | d>dmax+Rmax             % 第二层节点整体剪枝
            continue;
        end

        for k = 1:len
            R = Tree{i}.Tree{j}.R(k);
            if d>dmax+R                     % 第二层节点单独剪枝                    
                continue;                
            end
            
            x2 = Tree{i}.Tree{j}.X(:,k);         
            d2 = norm(x-x2);
            if d2>dmax                      % 距离大于第K个近邻的距离剪枝
                continue;
            end
            index(K) = Tree{i}.Tree{j}.I(k);        % 近邻点替换
            distance(K) = d2;
                        
            [tmp3,I3] = sort(distance);
            index = index(I3);                      % 重新排序
            distance = distance(I3);
            dmax = distance(K);                  % dmax更新 
        end
    end
end

%--------------------------------------------------------------------------
% 将样本集X中第m个样本剪枝，并返回新树Tree

function [Tree] = X_Inf(Tree,m)

IJK = Tree{end}.IJK;
i = IJK(1,m);
j = IJK(2,m);
k = IJK(3,m);

% 剪枝操作

Tree{i}.Tree{j}.X(:,k) = inf;
Tree{i}.Tree{j}.R(k) = inf;

% 其中Tree为
% Tree{i}.len                   % 每一类个数
% Tree{i}.C                     % 每一类中心
% Tree{i}.Rmax                  % 最大半径
% Tree{i}.Tree{j}.X             % 样本点
% Tree{i}.Tree{j}.I             % 数据下标 
% Tree{i}.Tree{j}.len           % 无样本点时，为0
% Tree{i}.Tree{j}.C             % 无样本点时，为0
% Tree{i}.Tree{j}.Rmax          % 无样本点时，为0 
% Tree{i}.Tree{j}.R             % 每个样本对类别中心距离
%
% Tree{L1+1}.IJK                % 样本点所属的两层节点序号
