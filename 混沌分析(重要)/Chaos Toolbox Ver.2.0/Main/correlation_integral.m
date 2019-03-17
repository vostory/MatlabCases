function C_I=correlation_integral(X,M,r)
%the function is used to calculate correlation integral
%C_I:the value of the correlation integral
%X:the reconstituted state space,M is a m*M matrix
%m:the embedding demention
%M:M is the number of embedded points in m-dimensional sapce
%r:the radius of the Heaviside function,sigma/2<r<2sigma
%calculate the sum of all the values of Heaviside
%skyhawk
sum_H=0;
for i=1:M
%     fprintf('%d/%d\n',i,M);
    for j=i+1:M
        d=norm((X(:,i)-X(:,j)),inf);%calculat the distances of each two points in matris M with sup-norm
        sita=heaviside(r,d);%calculate the value of the heaviside function
        sum_H=sum_H+sita;
    end
end
C_I=2*sum_H/(M*(M-1));%the value of correlation integral