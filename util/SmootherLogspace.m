function [ x ] = SmootherLogspace( lb, ub, size, smoothness )
%SMOOTHLOGSPACE Summary of this function goes here
%   Detailed explanation goes here
xNorm = (logspace(0, 1-smoothness, size)-1)/(10^(1-smoothness)-1);
x = xNorm*(ub-lb);
x = x + lb;
end

