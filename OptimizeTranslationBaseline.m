function [P3Optim,error] = OptimizeTranslationBaseline(...
    P1Optim, P2Optim, P3Unoptim, corrs123, displayIterFlag)
%OPTIMIZETRANSLATIONBASELINE Summary of this function goes here
%   Detailed explanation goes here
P3W = [P2Optim(1:3,1:3)' -P2Optim(1:3,1:3)'*...
    P2Optim(:,end)]*HomogenizeMat(P3Unoptim);
RW = P3W(1:3,1:3);
tW = P3W(:,end);
X12 = Triangulate(P1Optim,P2Optim,corrs123(1:4,:));
f = @(s) mean(sum((X12 - Triangulate(P2Optim,...
    P2Optim*HomogenizeMat([RW s*tW]),corrs123(3:6,:))).^2));
if exist('displayIterFlag','var') && strcmp(displayIterFlag,'displayIter')
    display = 'iter';
else
    display = 'none';
end
o = optimoptions(@fminunc,'Display',display,'MaxFunctionEvaluations',Inf,...
    'StepTolerance',1e-10,'OptimalityTolerance',1e-10);
[s,error] = fminunc(f,1,o);
P3Optim = P2Optim*HomogenizeMat([RW s*tW]);
end

