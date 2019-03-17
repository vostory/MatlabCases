%function x=quadratic(n,c,x0)
%_________________________________
%
% Simulation of the Quadratic map.
%    x'=c-x^2
%
% x is the simulated time series.
% n is the number of the simulated points.
% c is the a parameter
% x0 is the initial value for x.
%
%
clear;
close;
clc;

n=200;
c=1.95;
x0=0.1;

% Initialize
x(1,1)=c-x0^2;

% Simulate
for i=2:n
    x(i,1)=c-x(i-1,1)^2;
end

plot(x);
xlabel('n');
ylabel('x');
title('Quadratic map');