%AOLMM多步预测函数
function [FChaosPredict] = FunctionChaosPredict(Data,N,mtbp,deltaT,tao,d,MaxStep)
%Data是一维信号时间序列，N是信号数据长度，mtbp,deltaT,tao,d分别是重构相空间的平均时间序列、采样周期、时延及嵌入维

roll=Data;%取横摇数据
M = N - (d - 1)*tao;
for i = 1 : M
    for j = 1 : d
        MatrixX(i,j) = roll(i + (j - 1)*tao);
    end
end

%计算相空间中第M点与各点的距离
for j = 1 : (M - 1)
    Dis(j) = norm(MatrixX(M,:) - MatrixX(j,:),2);
end
%排序计算相空间中第M点的(m+1)个参考邻近点
for i = 1 : (d + 1)
    NearDis(i) = Dis(i);
    NearPos(i) = i;
end
for i = (d + 2) : (M - mtbp)
    for j = 1 : (d + 1)
        if (abs(i-j)>mtbp) %& abs(i-j)<10*mtbp
            if(Dis(i) < NearDis(j))
                NearDis(j) = Dis(i);
                NearPos(j) = i;
                break;
            end
        end
    end
end
SortedDis = sort(NearDis);
MinDis = SortedDis(1);
%计算第M点的(m+1)个参考邻近点的权P[i]
SumP = 0;
for i = 1 : (d + 1)
    P(i) = exp(-NearDis(i)/MinDis);
    SumP = SumP + P(i);
end
P = P/SumP;
%用最小二乘法计算a[],b[]
for step=1:1:MaxStep
    aCoe1 = 0;
    aCoe2 = d;
    bCoe1 = 0;
    bCoe2 = 0;
    e = 0;
    f = 0;
    for i = 1 : (d + 1)
        aCoe1 = aCoe1 + P(i)*sum(MatrixX(NearPos(i),:));
        bCoe1 = bCoe1 + P(i)*(MatrixX(NearPos(i),:)*MatrixX(NearPos(i),:)');
        e = e + P(i)*(MatrixX(NearPos(i) + step,:)*MatrixX(NearPos(i),:)');
        f = f + P(i)*sum(MatrixX(NearPos(i) + step,:));
    end
    bCoe2 = aCoe1;
    CoeMatrix = [aCoe1,bCoe1;aCoe2,bCoe2];
    ResultMatrix = [e;f];
    abResult = CoeMatrix\ResultMatrix;
    a = abResult(1);
    b = abResult(2);
    %----------------------------------------------
    for j = 1 : d
        %     MatrixX(M + step,j) = a + b*MatrixX(M,j); %以历史上相近点的演化规律作为中心点的演化规律以中心点为基准进行预报

        MatrixX(M + step,j) = 0;
        for i = 1 : (d + 1)
            MatrixX(M + step,j) = MatrixX(M + step,j) + P(i)*(a + b*MatrixX(NearPos(i),j)); %以历史上相近点的演化加权和直接作为中心点的演化点进行预报
        end
    end
    %---------------------------------------------------
  %MatrixX(M + step,d)=a+b*roll(N);
    PredictedData(step) = MatrixX(M + step,d);
    FChaosPredict(step) = PredictedData(step);

end