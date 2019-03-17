% function s_t_m=C_CMethod_m(data)
%this function calculate time delay and embedding demension with C-C
%Method,which proved by H.S.Kim
%skyhawk&flyinghawk
%****************调试程序段****************************
clear all;
data=load('f:/sunpot/monthly sunpot number.txt');
data=data(:,3)';
%************************************************

N=length(data);
max_d=9;%the maximum value of the time delay

sigma=std(data);%calcute standard deviation s_d

for m=2:5
    for t=1:max_d
        t
        for j=1:4
            r=sigma*j/2;
            data_d=disjoint(data,N,t);%将时间序列分解成t个不相交的时间序列
            [ll,N_d]=size(data_d);
            s_t3=0;
           for i=1:t
                Y=data_d(i,:);
                C_1(i)=correlation_integral(Y,N_d,r);%计算C(1,N_d,r,t)
                X=reconstitution(Y,N_d,m,t);%相空间重构
                N_r=N_d-(m-t)*t;
                C_I(i)=correlation_integral(X,N_r,r);%计算C(m,N_r,r,t)
                s_t3=s_t3+(C_I(i)-C_1(i)^m);%对t个不相关的时间序列求和
            end
            s_t2(j)=s_t3/t;
        end
        s_t_m(t,m)=max(s_t2)-min(s_t2);
    end
end
fid=fopen('s_t_m.txt','w');
fprintf(fid,'%f %f %f %f\n',s_t_m);
fclose(fid);
t=1:max_d;
plot(t,s_t_m(:,2),t,s_t_m(:,3),'+',t,s_t_m(:,4),'.',t,s_t_m(:,5),'*')
        
            
            
                
            