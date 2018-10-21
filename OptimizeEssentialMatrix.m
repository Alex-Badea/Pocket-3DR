function [E] = OptimizeEssentialMatrix(E, x1, x2, errFcn, displayIterFlag)
%OPTIMIZEESSENTIALMATRIX Summary of this function goes here
%   Detailed explanation goes here
if ~exist('errFcn','var')
    errFcn = @SampsonDistance;
end
Cmc = num2cell([x1;x2], 1);
e = packEssMat(E,x1,x2);
f = @(e) sum(errFcn(unpackEssMat(e), Cmc)) / length(Cmc);
if exist('displayIterFlag','var') && strcmp(displayIterFlag,'displayIter')
    display = 'iter';
else
    display = 'none'; 
end
o = optimoptions(@fminunc,'Display',display,'MaxFunctionEvaluations',Inf,...
    'StepTolerance',1e-10);
e = fminunc(f,e,o);
E = unpackEssMat(e);
end

function e = packEssMat(E,x1,x2)
P = EstimateRealPoseAndTriangulate(E,x1,x2);
R = P(1:3,1:3);
t = P(:,end);
e = [rotationMatrixToVector(R)' t];
end

function E = unpackEssMat(e)
R = rotationVectorToMatrix(e(:,1));
t = e(:,2)/norm(e(:,2));
E = Skew(t)*R;
end