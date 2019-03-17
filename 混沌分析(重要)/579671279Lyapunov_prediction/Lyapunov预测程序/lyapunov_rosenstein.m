function LCE1=lyapunov_rosenstein(x,m,t,P,p,ts) 

% Syntax:LCE1=lyapunov_rosenstein(x,m,t,P,p)
% Calculate maximum lyapunov exponent from small sets
% "A practical method for calculating largest lyapunov
%  exponents from small sets"--Michael T.Rosenstein
%Input:
%     x----time series coloum format
%     m----embedding dimension
%     t----time delay
%     P----mean perieod time
%     p----p norm
%     ts---Sampling frequence
%Output:
%     LCE1-Dominant lyapunov exponents
%
%Usage:
%    x=[];!!!!Remember: in coloum format 
%    m=30;
%    t=10;
%    P=20;%gained by FFT
%    p=inf;
%    ts=0.001;
%    LCE1=lyapunov_rosenstein(x,m,t,P,p,ts);
%Related routine:
%        phasespace.m
%Author:skyhawk
% Created on 2004.3.8
% Modified on 2004.3.23
% Air Force Engineering University
% Air Force Engineering Institute
% Dept.1, Shaan Xi, Xi'an 710038, PR China.
% Email:xunkai_wei@163.com
%
[Y,M]=phasespace(x,m,t);
%calculate two points' distance in phase space and determine the nearest neighbor
%count computation times
for i=1:M
    %Calculate original distance
    count_refer=1;
    Refer=Y(i,:);
    for j=1:M
        if abs(j-i)<P     %constrain temporal seperation
             continue;           
        end
        dist(count_refer)=norm(Refer-Y(j,:),p);% record its value
        index_count_refer(count_refer)=j;% remember its index
        count_refer=count_refer+1;%modify counter
    end
    %sort distance
    [dist,h]=sort(dist);
    %get refer's nearest neighbor
    Dist0(i)=dist(1);
    Index_Neighbor(i)=index_count_refer(h(1));
end
%对于每个相点及其领域点离散k步后，计算当前的相空间距离
%
for j=1:M
    orignal_point=Y(j,:);
    neighbor_point=Y(Index_Neighbor(j),:);
    for i=1:min(M-j,M-Index_Neighbor(j))%i discrete times 
        orignal_point_i=Y(j+i,:);
        neighbor_point_i=Y(Index_Neighbor(j)+i,:);
        dist1_k(j,i)=norm(orignal_point_i-neighbor_point_i,p);% distance accordingly
    end
end
%work out <ln(dj(i))>
[row,col]=size(dist1_k);
for i=1:col
    cout_j_for_i=1;
    sum_j_for_i=0;
    for j=1:row
        if dist1_k(j,i)~=0
            sum_j_for_i=sum_j_for_i+log(dist1_k(j,i));
            cout_j_for_i=cout_j_for_i+1;
        end
    end
    aver_j_for_i(i)=sum_j_for_i/cout_j_for_i;
end
% X=1:col;
X=1:7;
Y=aver_j_for_i/ts;
FIT=polyfit(X,Y(X),1);
%plot(X,Y)%,X,polyval(FIT,X));
LCE1=FIT(1);