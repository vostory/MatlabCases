function [a,b] = LM(Log2_R,Log2_Cr,Linear)

    

len_m = size(Log2_Cr,1);         % Log2_Cr 每一行对应一个嵌入维
a = zeros(len_m,1);
b = zeros(len_m,1);

F = zeros(len_m,2);
for i = 1:len_m
    p = polyfit(Log2_R(Linear),Log2_Cr(i,Linear),1);    % 最小二乘拟合
    a(i) = p(1);
    b(i) = p(2);
end



