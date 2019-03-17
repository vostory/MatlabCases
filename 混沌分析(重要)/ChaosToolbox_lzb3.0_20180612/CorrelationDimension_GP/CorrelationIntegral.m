function Cr = CorrelationIntegral(X,tau,M,R,p)

X = X - mean(X);        % 0均值 
X = X/(max(X)-min(X));  % 幅度归一化

n = length(X);
len_m = length(M);
len_r = length(R);


        
Cr = zeros(len_m,len_r);
for u = 1:len_m
    for v = 1:len_r
        m = M(u);
        r = R(v);

        num = n-(m-1)*tau;
        tmp1 = 0;
        for i = 1:num
            for j = i+p:num
                for k = 0:m-1
                    if abs(X(i+k*tau)-X(j+k*tau))>r
                        tmp1 = tmp1+1;   
                        break;
                    end
                end
            end
        end
        
        Cr(u,v) = 1-2*tmp1/((num-p)*(num-p+1));
    end
end

