%skyhawk#flyinghawk
%计算最后一个相点的最近相点的位置及最短距离
function [idx,min_d,idx1,min_d1]=nearest_point(tau,m,whlsj,whlsl,P)
%参数说明：
%输入：m - 嵌入维数， whlsj － 待分析数据， whlsl - 待分析的数据个数， P - 平均循环周期
%      idx - 最后一个相点的最近相点的位置， min_d - 最后一个相点与其最近相点间的距离 (考虑相角)
%      idx1 - 最后一个相点的最近相点的位置， min_d1 - 最后一个相点与其最近相点间的距离 (不考虑相角)
% *可调参数
% P = 5  ; %  &&选择演化相点距当前点的位置差，即若当前相点为I，则演化相点只能在|I－J|<P的相点中搜寻
min_point=5  ; %&&要求最少搜索到的点数
MAX_CISHU=5 ;  %&&最大增加搜索范围次数
% global lmd;

% 相空间重构
LAST_POINT = whlsl-(m-1)*tau;  %相点个数
for j=1:LAST_POINT            
    for k=1:m
        Y(k,j)=whlsj((k-1)*tau+j);
    end
end

% 求最大、最小和平均相点距离
max_d = 0.;
min_d = 1.0e+100;
avg_d = 0.;
for i = 1 : LAST_POINT-1
    avg_dd = 0.;
    for j = i+1 : LAST_POINT
        d = 0.;
        for k = 1 : m
            d = d + (Y(k,i)-Y(k,j))*(Y(k,i)-Y(k,j));
        end
        d = sqrt(d);
        if max_d < d
           max_d = d;
        end
        if min_d > d
           min_d = d;
        end
        avg_dd = avg_dd + d;
    end
    avg_dd = avg_dd/(LAST_POINT-i-1+1);
    avg_d = avg_d + avg_dd;
end
avg_d = avg_d/(LAST_POINT-1);
  
dlt_eps = (avg_d - min_d) * 0.08 ;         % 若在min_eps～max_eps中找不到演化相点时，对max_eps的宽大增幅
min_eps = min_d + dlt_eps / 8 ;            % 演化相点与当前相点距离的最小限
max_eps = min_d + 2 * dlt_eps  ;           % 演化相点与当前相点距离的最大限
    
% 从P～N-m个相点中找与第一个相点最近的相点位置(Loc_DK)及其最短距离DK
DK = 1.0e+100;
Loc_DK = LAST_POINT-P;
for i = 1 : LAST_POINT-P
    d = 0.;
    for k = 1 : m
        d = d + (Y(k,i)-Y(k,LAST_POINT-1))*(Y(k,i)-Y(k,LAST_POINT-1));
    end
    d = sqrt(d);
        
    if (d < DK) & (d > min_eps) 
        DK = d;
        Loc_DK = i;
    end
end

DK1 = 0.;
for k = 1 : m
    DK1 = DK1 + (Y(k,LAST_POINT)-Y(k,Loc_DK+1))*(Y(k,LAST_POINT)-Y(k,Loc_DK+1));
end
DK1 = sqrt(DK1);

old_Loc_DK=Loc_DK;
  
% 以下程序计算最后一个相点的最近距离点  （考虑相角）：要求距离在指定距离范围内尽量短，与DK1的角度最小

max_eps = min_d + 2 * dlt_eps ;            % 演化相点与当前相点距离的最大限

point_num = 0  ; % 在指定距离范围内找到的候选相点的个数
cos_sita = 0.  ; % 夹角余弦的比较初值 ——要求一定是锐角
zjfwcs=0       ; % 增加范围次数
        
while (point_num == 0)
    % 搜索相点
    for j = 1 : LAST_POINT-1
        if abs(j-LAST_POINT) <=( P-1)      % 候选点距当前点太近，跳过！
           continue;      
        end
                
        % 计算候选点与当前点的距离
        dnew = 0.;
        for k = 1 : m
            dnew = dnew + (Y(k,LAST_POINT)-Y(k,j))*(Y(k,LAST_POINT)-Y(k,j));
        end
        dnew = sqrt(dnew);
                
        if (dnew < min_eps)|( dnew > max_eps )   % 不在距离范围，跳过！
           continue;              
        end                
                
        % 计算夹角余弦及比较
        DOT = 0.;
        for k = 1 : m
            DOT = DOT+(Y(k,LAST_POINT)-Y(k,j))*(Y(k,LAST_POINT)-Y(k,old_Loc_DK+1));
        end
        CTH = DOT/(dnew*DK1);
                
        if acos(CTH) > (3.14151926/4)      % 不是小于45度的角，跳过！
           continue;
        end
                
        if CTH > cos_sita   % 新夹角小于过去已找到的相点的夹角，保留
            cos_sita = CTH;
            Loc_DK = j;
            DK = dnew;
        end
        point_num = point_num +1;
    end  % end of for j = 1 : LAST_POINT-1     
        
    if point_num < min_point
        point_num = 0          ;     %&&扩大距离范围后创新搜索
        cos_sita = 0.;
        max_eps = max_eps + dlt_eps;
        zjfwcs =zjfwcs +1;
        if zjfwcs > MAX_CISHU    %&&超过最大放宽次数，改找最近的点
           DK = 1.0e+100;
           for ii = 1 : LAST_POINT-1
               if abs(LAST_POINT-ii) <= P-1      %&&候选点距当前点太近，跳过！
                   continue;     
               end
               d = 0.;
               for k = 1 : m
                   d = d + (Y(k,LAST_POINT)-Y(k,ii))*(Y(k,LAST_POINT)-Y(k,ii));
               end
               d = sqrt(d);
        
               if (d < DK) & (d > min_eps) 
                   DK = d;
                   Loc_DK = ii;
               end
           end  % end of for ii = 1 : LAST_POINT-1
           break  
        end %end of if zjfwcs > MAX_CISHU
    end %end of if point_num <= min_point
end  % end of while (point_num == 0)
idx=Loc_DK;  %返回中心点最近相点的位置
min_d=DK;    %返回中心点到其最近相点的距离
point_num;
% 以下程序计算最后一个相点的最近距离点  （不考虑相角）
 
% 求最小距离点
min_d1 = 1e+100;
idx1 = LAST_POINT-1;

for jj = 1:LAST_POINT-1         

    if abs(jj-LAST_POINT) <=( P-1)      % 候选点距当前点太近，跳过！
       continue;      
    end

    sum_d=0.;
    for k=1:m
       sum_d = sum_d+(Y(k,jj)-Y(k,LAST_POINT))^2;
    end
    sum_d = sqrt(sum_d);
    
    if (min_d1 > sum_d)&(sum_d > 0)
        min_d1 = sum_d;
        idx1 = jj;
    end
end
