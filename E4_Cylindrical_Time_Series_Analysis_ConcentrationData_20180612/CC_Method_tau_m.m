function [tau,m]=CC_Method_tau_m(data,tau_max)
x=data;
x=x';
 
X = [x-mean(x)]/[max(x)-min(x)];    % 归一化到均值为 0，振幅为 1

maxLags = tau_max;                  % 最大时延
m_vector = 2:5;                 % m 取值范围
sigma = std(X);
r_vector = sigma/2*[1:4];       % r 取值范围

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %初始化
S_mean = zeros(1,maxLags);
Sj = zeros(1,length(r_vector));
delta_S_mean = zeros(1,maxLags);
delta_S = zeros(length(m_vector),maxLags);

tic
for t = 1:maxLags 
    temp = 0;
    for i = 1:length(m_vector)
        for j = 1:length(r_vector)
            m = m_vector(i);
            r = r_vector(j);
            S = ccFunction0(m,X,r,t);       % 文献中公式（13）
            temp = temp + S;               % 文献中公式（17） 
            Sj(j) = S;
        end
        delta_S(i,t) = max(Sj)-min(Sj);    % delta_S(m,t),文献中公式（15）
    end
    S_mean(t) = temp/(length(m_vector)*length(r_vector));   % 文献中公式（17）
    delta_S_mean = mean(delta_S);                           % 文献中公式（18）
end
S_cor = delta_S_mean + abs(S_mean);                         % 文献中公式（19）
toc

figure(1)    
subplot(311)
plot(1:maxLags,S_mean);
title('S mean');
grid;

subplot(312)
plot(1:maxLags,delta_S_mean);
title('delta S mean');
grid;

subplot(313)
plot(1:maxLags,S_cor);
title('Scor');
grid;

for t=1:maxLags
    if S_mean(t)==0
        St=t;
        break
    end
end

for t=1:maxLags-1
    if delta_S_mean(t)<delta_S_mean(t+1)
        tau=t;
        break
    end
end
    
TscorV=min(S_cor);
for t=1:maxLags
    if TscorV==S_cor(t)
        Tscor=t;
        break
    end
end

m=round(Tscor/tau)+1;
