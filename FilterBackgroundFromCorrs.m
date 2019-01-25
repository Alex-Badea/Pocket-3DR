function [corrs,bestI] = FilterBackgroundFromCorrs(P1, P2, corrs, binSize)
%FILTERBACKGROUNDFROMCORRS Summary of this function goes here
%   Detailed explanation goes here
if ~exist('binSize','var')
    binSize = 3;
end

X = Triangulate(P1, P2, corrs);
i = X(3,:) >= 0;
X = X(:,i);
corrs = corrs(:,i);
i = X(3,:) <= 1e3;
X = X(:,i);
corrs = corrs(:,i);
bestInd = [];
bestI = nan;
for i = 1:size(X,2)
    z = X(3,i);
    ind = X(3,:) >= z & X(3,:) <= z+binSize;
    if sum(ind) > sum(bestInd)
        bestInd = ind;
        bestI = i;
    end
end

corrs = corrs(:,bestInd);
end