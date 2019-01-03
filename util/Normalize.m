function [xNorm] = Normalize(x,K)
%NORMALIZE Summary of this function goes here
%   Detailed explanation goes here
xNorm = Dehomogenize(K\Homogenize(x));
end

