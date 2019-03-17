
function main_process(data,PreStep,max_m)
% clear all
% clc
% close all
% load data.dat
% data=x(:,1);

N=length(data);
disp('---------互信息法求tau----------')
tau1=Mutual_Information_main(data)
%pause
% disp('---------CC法求tau和m----------')
%   [tauc,mc]=CC_Method(data)
  disp('---------确认tau----------')
  tau=input('请输入tau(默认为tau1)=');
if isempty(tau)
    tau=tau1,
else
   tau,
end

%  pause
 disp('---------cao法求m----------')
min_m=1;
max_m=20;
m_c=cao_m(data,min_m,max_m,tau)
m_cao=input('请输入cao最小嵌入维数m=')
 if isempty(m_cao)
    m_cao=m_c     
else
    m_cao
 end
 close
 
%  disp('---------GP法求m----------')
%  D=GP_Algorithm(data,tau,max_m);
 m_cao
m=input('确认最小嵌入维数m(默认为cao法)=');
if isempty(m)
    m=m_cao     
else
   m
end

disp('-------求平均周期 P-----------')
P1=ave_period(data);
%pause
P=input('请输入平均周期P(默认为P1)=');
if isempty(P)
    P=P1
else
   P=(m+1)*tau
end

close
%disp('-------求lya指数-------------')
% lambda_1=largest_lyapunov_exponent_revised(data,N,m,tau,P);
% pause

% LCE1=lyapunov_rosenstein(data,m,tau,P,2,1);
% pause
 disp('-------最小数据法求最大lyapunov指数-------------')
  Lyapunov1=LargestLyapunov(data,m,tau,P)
  pause(5)
  disp('-------wolf法求最大lyapunov指数-------------')
 lmd1_wolf=lyapunov_wolf(data,N,m,tau,P)
 %lmd1=lmd1_wolf
lmd1=input('请选择最大lyapunov指数(默认为wolf法,1为最小数据法)=');
if isempty(lmd1)
    lmd1=lmd1_wolf
else
   lmd1=Lyapunov1
end

%lya(data,tau,max_m,P);
close all
disp('---------lya指数预测-----------')
pre_lya_change(data,tau,m,P,lmd1,PreStep);  %预测结果带回源数据
pause
disp('---------一阶加权局域法预测-----------')
%disp('---把每次预测后的值作为已知值带入源数据进行预测----')
Predict(data,m,tau,P,lmd1,PreStep);   
pause
disp('---------一次多步预测-----------')
PredictMain(data,m,tau,P,lmd1,PreStep);
pause
hold off