function [CorrsNorm] = NormalizeCorrs(Corrs,K)
%NORMALIZECORRS Summary of this function goes here
%   Detailed explanation goes here
CorrsNorm = [Dehomogenize(K\Homogenize(Corrs(1:2,:)));
    Dehomogenize(K\Homogenize(Corrs(3:4,:)))];
end

