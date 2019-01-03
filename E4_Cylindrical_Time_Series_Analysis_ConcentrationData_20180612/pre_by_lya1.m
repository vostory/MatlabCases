%计算基于最大李雅谱诺夫方法的预测值
function [x_1,x_2]=pre_by_lya1(tau,m,lmd,whlsj,whlsl,idx,min_d,prestep)
% x_1 - 第一预测值， x_2 - 第二预测值，
% m －嵌入维数，lmd - 最大李雅谱诺夫值，whlsj - 数据数组，whlsl - 数据个数， idx - 中心点的最近距离点位置， min_d - 中心点与最近距离点的距离

%相空间重构
LAST_POINT = whlsl-(m-1)*tau;  %相点个数
for j=1:LAST_POINT            
    for k=1:m
        Y(k,j)=whlsj((k-1)*tau+j);
    end
end

for step=1:prestep
    a_1=0.;
    for k=1:(m-1)
        a_1=a_1+(Y(k,idx+step)-Y(k+step,LAST_POINT))*(Y(k,idx+step)-Y(k+step,LAST_POINT));  % 此处Y(k+1,LAST_POINT)实际上就是Y(k,LAST_POINT+1)
    end

    deta=sqrt(min_d^2*2^(lmd*step)-a_1);
    if (isreal(deta)==0) | (deta>Y(m,idx+step)*0.001)
        deta=Y(m,idx+step)*0.001;
    end
    x_1(step)=Y(m,idx+step)+deta;
    x_2(step)=Y(m,idx+step)-deta;
end
