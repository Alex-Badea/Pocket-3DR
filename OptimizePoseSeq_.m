function [P3Optim,error] = OptimizePoseSeq(...
    P1Optim, P2Optim, P3Unoptim, x1, x2, x3, displayIterFlag, itersNo)
%OPTIMIZEPOSESEQ Summary of this function goes here
%   Detailed explanation goes here
if ~exist('itersNo','var')
    itersNo = 3;
end
if ~exist('displayIterFlag','var')
    displayIterFlag = [];
end

P3 = P3Unoptim;
for i = 1:itersNo
    P3 = OptimizeRotationMatrix(P1Optim,P2Optim,P3,x1,x2,x3,...
        displayIterFlag);
    [P3,error] = OptimizeTranslationVector(P1Optim,P2Optim,P3,x1,x2,x3,...
        displayIterFlag);
end
P3Optim = P3;
end

