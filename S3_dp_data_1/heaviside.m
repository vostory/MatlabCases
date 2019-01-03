%Heaviside函数的计算
function sita=heaviside(r,d)
% 该函数用来计算Heaviside函数的值
%sita:Heaviside函数的值
%r:Heaviside函数的搜索半径
%d:两点之间的距离

if (r-d)<0
    sita=0;
else 
    sita=1;
end
