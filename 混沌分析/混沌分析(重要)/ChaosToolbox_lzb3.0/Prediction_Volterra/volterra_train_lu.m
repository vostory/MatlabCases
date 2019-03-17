function [Wn,err_mse] = original_train_lu(xn_train,dn_train,p)
% 训练部分
% [Hn] = original_train(s_train, tau, m, p, Times)
% 输入参数：    xn_train   训练样本(每一列为一个样本)
%               dn_train   训练目标
%               p          Volterra 级数阶数
% 输出参数：    Wn         最小二乘估计滤波器权矢量 Hn

%--------------------------------------------------
% 由相空间构造 Volterra 自适应 FIR 滤波器的输入信号矢量 Un

[Un,len_filter] = PhaSpa2VoltCoef(xn_train,p);
% 输入参数：    xn_train     相空间中的点序列(每一列为一个点)
%               p            Volterra 级数阶数
% 输出参数：    Un           Volterra 自适应 FIR 滤波器的输入信号矢量 Un
%               len_filter   FIR 滤波器长度

%--------------------------------------------------
% 最小二乘估计滤波器权矢量 Hn

Wn = Un'\dn_train'; 

err = Wn' * Un - dn_train;
err_mse = sum(err.^2)/length(err);



