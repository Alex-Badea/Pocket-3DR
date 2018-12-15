function [P3Optim,disparityLeft] = MiniBundleAdjustment(...
    P1Optim, P2Optim, P3Unoptim, corrs123)
%MINIBUNDLEADJUSTMENT Summary of this function goes here
%   Detailed explanation goes here
X = Triangulate(P1Optim, P2Optim, corrs123(1:4,:));
CP = BundleAdjustment({P1Optim,P2Optim,P3Unoptim}, corrs123, X);
P3Optim = CP{3};
disparity = DehomogenizeMat(HomogenizeMat(P3Optim)/HomogenizeMat(P3Unoptim));
end