function [P3Optim] = OptimizeRotationMatrix(...
    P1Optim, P2Optim, P3Unoptim, x1, x2, x3, displayIterFlag)
%OPTIMIZEROTATIONMATRIX Summary of this function goes here
%   Detailed explanation goes here
X12 = Triangulate(P1Optim,P2Optim,x1,x2);
rUnoptim = rotationMatrixToVector(P3Unoptim(1:3,1:3))';
t = P3Unoptim(:,end);
f = @(r) mean(sum((X12 - Triangulate(P2Optim,...
    [rotationVectorToMatrix(r) t],x2,x3)).^2));
if exist('displayIterFlag','var') && strcmp(displayIterFlag,'displayIter')
    display = 'iter';
else
    display = 'none';
end
o = optimoptions(@fminunc,'Display',display,'MaxFunctionEvaluations',Inf,...
    'StepTolerance',1e-10,'OptimalityTolerance',1e-10);
rOptim = fminunc(f,rUnoptim,o);
P3Optim = [rotationVectorToMatrix(rOptim) t];
end