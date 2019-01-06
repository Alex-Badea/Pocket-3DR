function [corrs] = UnnormalizeCorrs(corrsNorm,K)
%UNNORMALIZECORRS Summary of this function goes here
%   Detailed explanation goes here
corrs = [Dehomogenize(K*Homogenize(corrsNorm(1:2,:)));
    Dehomogenize(K*Homogenize(corrsNorm(3:4,:)))];
end

