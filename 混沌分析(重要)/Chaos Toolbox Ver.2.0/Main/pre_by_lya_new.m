function [x_1,x_2]=pre_by_lya(m,lmd,whlsj,whlsl)
% m=7;
% imd=0.144076;
% data=load('f:\wuyouli\data\bk.txt');
% whlsj=data(:,4);
% [lll,whlsl]=size(whlsj);
% global a Y ind
for j=1:(whlsl-m+1)            %相空间重构
    for i=1:m
        Y(i,j)=whlsj(i+j-1);
    end
end

%******************************************************
% min_d=1e+100;
% for jj=1:(whlsl-m)          %求最小距离点
%     sum_d=0.;
%     for ii=1:m
%        sum_d=sum_d+(Y(ii,jj)-Y(ii,whlsl-m+1))^2;
%     end
%     d(jj)=sum_d;
%     if (min_d>d(jj))&(d(jj) > 0)
%         min_d=d(jj);
%         idx=jj;
%     end
% end
%**********************考虑相角后寻找中心点的近似相点********************************
% *可调参数
P = 5  ; %  &&选择演化相点距当前点的位置差，即若当前相点为I，则演化相点只能在|I－J|<P的相点中搜寻
min_point=1  ; %&&要求最少搜索到的点数
MAX_CISHU=5 ;  %&&最大增加搜索范围次数
% global lmd;
% min_m = 2;
% max_m = 10;
% data=load('f:\wuyouli\whl_program\bk.txt');%读取数据
% whlsj=data(:,4);
% [whlsl,lllll]=size(whlsj);
% *   m为嵌入维数

%     * 求最大、最小和平均相点距离
    max_d = 0;
    min_d = 1.0e+100;
    avg_d = 0;
    for i = 1 : whlsl-m
        avg_dd = 0;
        for j = i+1 : whlsl-m+1
            d = 0;
            for k = 1 : m
                d = d + (whlsj(i+k-1)-whlsj(j+k-1))*(whlsj(i+k-1)-whlsj(j+k-1));
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
        avg_dd = avg_dd/(whlsl-m+1-i-1+1);
        avg_d = avg_d + avg_dd;
    end
    avg_d = avg_d/(whlsl-m);
    
    dlt_eps = (avg_d - min_d) * 0.02 ;         %&&若在min_eps～max_eps中找不到演化相点时，对max_eps的宽大增幅
    min_eps = min_d + dlt_eps / 2 ;               %&&演化相点与当前相点距离的最小限
    max_eps = min_d + 2 * dlt_eps  ;           %&&演化相点与当前相点距离的最大限
    
%     *从1～whlsl-m+1-P-1个相点中找与中心点的前一个相点距离最近的相点位置(Loc_DK)及其最短距离DK
    DK = 1.0e+100;
   for jj=1:(whlsl-m)          %求最小距离点
       sum_d=0.;
       for ii=1:m
           sum_d=sum_d+(Y(ii,jj)-Y(ii,whlsl-m+1))^2;
       end
       d(jj)=sum_d;
       if (min_d>d(jj))&(d(jj) > 0)
        DK=d(jj);
        Loc_DK=jj;
       end
   end
    
%     * i 为相点序号，从1到(whlsl-m)，也是i-1点的演化点；Loc_DK为相点i-1对应最短距离的相点位置，DK为其对应的最短距离
%     * Loc_DK+1为Loc_DK的演化点，DK1为i点到Loc_DK+1点的距离，称为演化距离
%     * 前i个log2（DK1/DK）的累计和用于求i点的lamda值
    sum_lmd = 0 ;   %&&存放前i个log2（DK1/DK）的累计和
    for i = 2 : whlsl-m
       % * 计算演化距离
        DK1 = 0;
        for k = 1 : m
            DK1 = DK1 + (whlsj(i+k-1)-whlsj(Loc_DK+1+k-1))*(whlsj(i+k-1)-whlsj(Loc_DK+1+k-1));
        end
        DK1 = sqrt(DK1);
        old_Loc_DK = Loc_DK ;    %&&保存源最近点位置相点
        old_DK=DK;

%         * 计算前i个log2（DK1/DK）的累计和以及保存i点的李氏指数
        if (DK1 ~= 0)&( DK ~= 0)
           sum_lmd = sum_lmd + log(DK1/DK) /log(2);
        end
        lmd(i-1) = sum_lmd/(i-1);
        max_eps = min_d + 2 * dlt_eps ;            %&&演化相点与当前相点距离的最大限
%         *以下寻找i点的最短距离：要求距离在指定距离范围内尽量短，与DK1的角度最小
        point_num = 0  ; % &&在指定距离范围内找到的候选相点的个数
        cos_sita = 0  ; %&&夹角余弦的比较初值 ——要求一定是锐角
        zjfwcs=0     ;%&&增加范围次数
         while (point_num == 0)
           % * 搜索相点
            for j = 1 : whlsl-m
                if abs(j-i) <=( P-1)      %&&候选点距当前点太近，跳过！
                   continue;     
                end
                
                %*计算候选点与当前点的距离
                dnew = 0;
                for k = 1 : m
                   dnew = dnew + (whlsj(i+k-1)-whlsj(j+k-1))*(whlsj(i+k-1)-whlsj(j+k-1));
                end
                dnew = sqrt(dnew);
                
                if (dnew < min_eps)|( dnew > max_eps )   %&&不在距离范围，跳过！
                  continue;             
                end
                
                
                %*计算夹角余弦及比较
                DOT = 0;
                for k = 1 : m
                    DOT = DOT+(whlsj(i+k-1)-whlsj(j+k-1))*(whlsj(i+k-1)-whlsj(old_Loc_DK+1+k-1));
                end
                CTH = DOT/(dnew*DK1);
                
                if acos(CTH) > (3.14151926/4)      %&&不是小于45度的角，跳过！
                  continue;
                end
                
                if CTH > cos_sita   %&&新夹角小于过去已找到的相点的夹角，保留
                    cos_sita = CTH;
                    Loc_DK = j;
                    DK = dnew;
                end

                point_num = point_num +1;
                
            end        
        
            if point_num <= min_point
               max_eps = max_eps + dlt_eps;
               zjfwcs =zjfwcs +1;
               if zjfwcs > MAX_CISHU    %&&超过最大放宽次数，改找最近的点
                   DK = 1.0e+100;
                   for ii = 1 : whlsl-m
                      if abs(i-ii) <= P-1      %&&候选点距当前点太近，跳过！
                       continue;     
                      end
                      d = 0;
                      for k = 1 : m
                          d = d + (whlsj(i+k-1)-whlsj(ii+k-1))*(whlsj(i+k-1)-whlsj(ii+k-1));
                      end
                      d = sqrt(d);
        
                      if (d < DK) & (d > min_eps) 
                         DK = d;
                         Loc_DK = ii;
                      end
                   end
                   break  
               end
               point_num = 0          ;     %&&扩大距离范围后创新搜索
               cos_sita = 0;
            end
        end
   end

%     * 计算各λ及最大李雅普诺夫指数lmd_m(m)
    lmd_m(m) = 0;
    for i=(whlsl-m-50):1:(whlsl-m-1)
        lmd_m(m) = lmd_m(m) + lmd(i);
    end
    lmd_m(m) = lmd_m(m)/50;        %&&(whlsl-m-zero_num(m))
end





%*******************************************************
a_1=0.;
for k=1:(m-1)
    a_1=a_1+(Y(k,idx+1)-whlsj(whlsl-m+1+k))*(Y(k,idx+1)-whlsj(whlsl-m+1+k));
end
deta=sqrt(min_d*2^(2*lmd)-a_1);
x_1=Y(m,idx+1)+deta;
x_2=Y(m,idx+1)-deta;
