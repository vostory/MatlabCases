function KE = KolmogorovEntropy_STB(X,fs,t,D,bmax,p)
% 计算混沌时间序列Kolmogorov熵的STB算法 - 所有点对(无穷范数)

if nargin<6
    p = 1;                      % 限制短暂分离
end

X = X(1:t:end);                 % 按时延重采样

r0 = mean(abs(X-mean(X)));      % r0计算,采用无穷范数
ln = length(X);                 % 重采样后序列长度 
ld = length(D);                 % 嵌入维个数

KE = zeros(1,ld);
for k = 1:ld

    d = D(k);
    n = ln-(d-1);               % 重构点数
    
    B = zeros(1,n);
    for i = 1:n-bmax
        for j = i+p:n-bmax
            
            v = 0;
            for u = 0:d-1
                if abs(X(i+u)-X(j+u))>r0
                    v = 1;
                    break;
                end
            end
            
            if v==1
                continue;
            end
            
            b = 0;
            dis = 0;
            while dis<=r0
                b = b+1;
                if i+d-1+b>n | j+d-1+b>n
                    error('错误: bmax 取值太小!');
                end
                dis = abs(X(i+d-1+b)-X(j+d-1+b)); 
            end
            
            if b~=0
                B(b) = B(b)+1;
            end         
        end
    end
    I = find(B>0);
    B = B(I);
    lb = length(B);
    
%     figure(m);
%     plot(B);                            % 横坐标为b的值,纵坐标为b值所对应的个数
    
    bm = sum([1:lb].*B)/sum(B);           % b的平均值
    ke = -log(1-1/bm)*fs/t;
    KE(k) = ke;
    
end

