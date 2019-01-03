 i=1;
for m=15:20
   
   % lmd1_wolf(i)=lyapunov_wolf(data,N,m,tau,P);
    Lyapunov1(i)=LargestLyapunov(data,m,tau,P)
    i=i+1;
end
%plot(2:20,lmd1_wolf)
plot(15:20,Lyapunov1)
xlabel('嵌入维数')
ylabel('最大李氏指数')