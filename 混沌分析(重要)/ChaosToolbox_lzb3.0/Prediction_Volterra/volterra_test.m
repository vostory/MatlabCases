function [dn_pred] = original_test(xn_test,p,Wn);
% 测试部分
% [Hn] = original_train(s_train, tau, m, p, Times)
% 输入参数：    xn_test    测试样本
%               p          Volterra 级数阶数
%               Wn         最小二乘估计滤波器权矢量 Wn
% 输出参数：    dn_pred    一步预测值

%--------------------------------------------------
% 由相空间构造 Volterra 自适应 FIR 滤波器的输入信号矢量 Un

[Un,len_filter] = PhaSpa2VoltCoef(xn_test,p);
% 输入参数：    xn           相空间中的点序列(每一列为一个点)
%               p            Volterra 级数阶数
% 输出参数：    Un           Volterra 自适应 FIR 滤波器的输入信号矢量 Un
%               len_filter   FIR 滤波器长度

dn_pred = Wn' * Un;