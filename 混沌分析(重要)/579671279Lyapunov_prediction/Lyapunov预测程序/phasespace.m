function [Y,T]=phasespace(x,m,t)
%Syntax: [Y,T]=phasespace(x,dim,tau) 
% The phase space reconstruction of a time series x whith the Method Of Delays
% (MOD), in embedding dimension m and for time dalay tau. 
% Y : trajectory matrix in the reconstructed phase space.
% T : phase space length.
% x : time series. 
% m : embedding dimension.
% t : time delay.
%Author:skyhawk
% Created on 2004.3.8
% Air Force Engineering University
% Air Force Engineering Institute
% Dept.1, Shaan Xi, Xi'an 710038, PR China.
% Email:xunkai_wei@163.com
N=length(x);
T=N-(m-1)*t;
% Initialize the phase space
Y=zeros(T,m);
% Phase space reconstruction with MOD
for i=1:T
   Y(i,:)=x(i+(0:m-1)*t)';
end
