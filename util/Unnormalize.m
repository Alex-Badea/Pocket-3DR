function [xNorm] = Unnormalize(x,K)
%UNNORMALIZE Summary of this function goes here
%   Detailed explanation goes here
xNorm = Dehomogenize(K*Homogenize(x));
end

