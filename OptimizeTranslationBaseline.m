function [P3Optim,s,error] = OptimizeTranslationBaseline(...
    P1Optim, P2Optim, P3Unoptim, corrs123, displayIterFlag)
%OPTIMIZETRANSLATIONBASELINE Summary of this function goes here
%   Detailed explanation goes here
R3 = P3Unoptim(1:3,1:3);
t3 = P3Unoptim(:,end);
R3R2Tt2 = R3*P2Optim(1:3,1:3)'*P2Optim(:,end);
X12 = Triangulate(P1Optim,P2Optim,corrs123(1:4,:));
f = @(s) mean(sum((X12 - Triangulate(P2Optim,[R3...
    s*t3-(s-1)*R3R2Tt2],corrs123(3:6,:))).^2));
if exist('displayIterFlag','var') && strcmp(displayIterFlag,'displayIter')
    display = 'iter';
else
    display = 'none';
end
o = optimoptions(@fminunc,'Display',display,'MaxFunctionEvaluations',Inf,...
    'StepTolerance',1e-10,'OptimalityTolerance',1e-10);
[s,error] = fminunc(f,1,o);
P3Optim = [R3 s*t3-(s-1)*R3R2Tt2];
end

