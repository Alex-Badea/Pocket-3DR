function [P3Optim,error] = OptimizePose(...
    P1Optim, P2Optim, P3Unoptim, x1, x2, x3, displayIterFlag)
%OPTIMIZEPOSE Summary of this function goes here
%   Detailed explanation goes here
X12 = Triangulate(P1Optim,P2Optim,x1,x2);
pUnoptim = [rotationMatrixToVector(P3Unoptim(1:3,1:3)) P3Unoptim(:,end)'];
f = @(p) mean(sum((X12 - Triangulate(P2Optim,...
    [rotationVectorToMatrix(p(1:3)) [p(4:5) pUnoptim(end)]'],x2,x3)).^2));
if exist('displayIterFlag','var') && strcmp(displayIterFlag,'displayIter')
    display = 'iter';
else
    display = 'none';
end
o = optimoptions(@fminunc,'Display',display,'MaxFunctionEvaluations',Inf,...
    'StepTolerance',1e-10,'OptimalityTolerance',1e-10);
[pOptim,error] = fminunc(f,pUnoptim,o);
P3Optim = [rotationVectorToMatrix(pOptim(1:3)) [pOptim(4:5) pUnoptim(end)]'];
end

