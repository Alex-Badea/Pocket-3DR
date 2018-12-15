function [corrsNorm] = NormalizeCorrs(corrs,K)
%NORMALIZECORRS Summary of this function goes here
%   Detailed explanation goes here
corrsNorm = [Dehomogenize(K\Homogenize(corrs(1:2,:)));
        Dehomogenize(K\Homogenize(corrs(3:4,:)))];
end

