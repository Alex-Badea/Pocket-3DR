function [P, X] = DisambiguateCameraPose(CP, CX)
bestSize = 0;
bestP = [];
bestX = [];
for i = 1:4
    P = CP{i};
    X = CX{i};
    x = P*Homogenize(X);
    w = x(3,:);      
    if sum(w > 0 & X(3,:) > 0) > bestSize
        bestSize = sum(w > 0 & X(3,:) > 0);
        bestP = P;
        bestX = X;
    end
end
P = bestP;
X = bestX;
end