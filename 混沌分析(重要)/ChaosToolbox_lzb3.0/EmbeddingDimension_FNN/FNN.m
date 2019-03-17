function [Percent,Percent1,Percent2] = FNN(x,tau,d_max,R_tol,A_tol)

%--------------------------------------------------

R_A = std(x);       % 吸引子平均尺度
xn = PhaSpaRecon(x,tau,d_max+1);    % 每列为一个点
N = size(xn,2);
ref = [1:N]';

Percent = zeros(d_max,1);
for d = 1:d_max
    xn_d = xn(1:d,:);
    
    if d==1
        xn_d = [xn_d;xn_d];
    end
    
    [index,R_d] = SearchNN2(xn_d,ref);               % 在d维相空间中寻找最近邻点对,及距离
    index_pair = [ref,index];
    
    xn_d1 = xn(d+1,:);
    dis_d1 = abs(diff(xn_d1(index_pair),1,2));      % 第d+1维坐标点之间距离
    
    test1 = dis_d1./R_d;                            % 判剧1
    
    xn_d_1 = xn(1:d+1,:);    
    R_d_1 = (sqrt(sum((xn_d_1(:,index_pair(:,1))-xn_d_1(:,index_pair(:,2))).^2)))';     % d+1维最近邻点对之间的距离
    
    test2 = R_d_1/R_A;                              % 判剧2
   
    NN = find(test1>R_tol | test2>A_tol);           % 综合判剧1与判剧2
    Percent(d) = length(NN)/length(test1)*100;      % 统计假近邻率(单位为: %)
    
    NN = find(test1>R_tol);           % 综合判剧1与判剧2
    Percent1(d) = length(NN)/length(test1)*100;      % 统计假近邻率(单位为: %)
    
    NN = find(test2>A_tol);           % 综合判剧1与判剧2
    Percent2(d) = length(NN)/length(test1)*100;      % 统计假近邻率(单位为: %)    
end


