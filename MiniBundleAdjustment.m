function [P3Optim,disparityLeft] = MiniBundleAdjustment(...
    P1Optim, P2Optim, P3Unoptim, corrs123)
%MINIBUNDLEADJUSTMENT Summary of this function goes here
%   Detailed explanation goes here
CP = BundleAdjustment({P1Optim,P2Optim,P3Unoptim}, corrs123);
P3Optim = CP{3};
disparityLeft = DehomogenizeMat(HomogenizeMat(P3Optim)/HomogenizeMat(P3Unoptim));
end