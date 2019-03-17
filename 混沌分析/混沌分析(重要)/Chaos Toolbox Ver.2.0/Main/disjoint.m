function data_d=disjoint(data,N,t)
%the function is used to subdivid the time series into t disjoint time
%series.
%data:the time series
%N:the length of the time series
%t:the index lag
%skyhawk
for i=1:t
    for j=1:(N/t)
        data_d(i,j)=data(i+(j-1)*t);
    end
end