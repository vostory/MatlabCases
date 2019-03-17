%function [x,y]=ikeda(n,mu,x0,y0)
%Syntax: [x,y]=ikeda(n,mu,x0,y0)
%_____________________________________
%
% Simulation of the Ikeda map.
%    x'=1+mu*(xcos(t)-ysin(t)
%    y'=mu*(xsin(t)+ycos(t))
%
% x and y are the simulated time series.
% n is the number of the simulated points.
% mu is the parameter.
% x0 is the initial value for x.
% y0 is the initial value for y.
%
%
% Reference:
%
% Ikeda K (1979): Multiple-valued stationary state and its instability of the
% transmitted light by a ring cavity system. Optics Communications 30: 257
clc
clear
close all

n=5000;
mu=0.9;
x0=0.1;
y0=0.1;


% Initialize
t=0.4-6/(1+x0^2+y0^2);
x(1,1)=1+mu*(x0*cos(t)-y0*sin(t));
y(1,1)=mu*(x0*sin(t)+y0*cos(t));

% Simulate
for i=2:n
    t=0.4-6/(1+x(i-1,1)^2+y(i-1,1)^2);
    x(i,1)=1+mu*(x(i-1,1)*cos(t)-y(i-1,1)*sin(t));
    y(i,1)=mu*(x(i-1,1)*sin(t)+y(i-1,1)*cos(t));
end

plot(x,y,'.','MarkerSize',1)
xlabel('x');ylabel('y')
title('ikeda attractor')

% Add normal white noise
% level is the noise standard deviation divided by the standard deviation of
%   the noise-free time series. We assume Gaussian noise with zero mean.
%x=x+randn(n,1)*level*std(x);
%y=y+randn(n,1)*level*std(y);
