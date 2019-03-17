function [ln_r,ln_C]=G_P(data,N,tau,min_m,max_m,ss)
% the function is used to calculate correlation dimention with G-P algorithm
% data:the time series
% N: the length of the time series
% tau: the time delay
% min_m:the least embedded dimention m
% max_m:the largest embedded dimention m
% ss:the stepsize of r
%skyhawk
for m=min_m:max_m
    Y=reconstitution(data,N,m,tau);%reconstitute state space
    M=N-(m-1)*tau;%the number of points in state space
    for i=1:M-1
        for j=i+1:M
            d(i,j)=max(abs(Y(:,i)-Y(:,j)));%calculate the distance of each two           
        end                                %points in state space
    end
    max_d=max(max(d));%the max distance of all points
    d(1,1)=max_d;
    min_d=min(min(d));%the min distance of all points
    delt=(max_d-min_d)/ss;%the stepsize of r
    for k=1:ss
        r=min_d+k*delt;
        C(k)=correlation_integral(Y,M,r);%calculate the correlation integral
        ln_C(m,k)=log(C(k));%lnC(r)
        ln_r(m,k)=log(r);%lnr
        fprintf('%d/%d/%d/%d\n',k,ss,m,max_m);
    end
    plot(ln_r(m,:),ln_C(m,:));
    hold on;
end
fid=fopen('lnr.txt','w');
fprintf(fid,'%6.2f %6.2f\n',ln_r);
fclose(fid);
fid = fopen('lnC.txt','w');
fprintf(fid,'%6.2f %6.2f\n',ln_C);
fclose(fid);