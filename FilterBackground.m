function [X] = FilterBackground(X, binSize)
%FILTERBACKGROUND Summary of this function goes here
%   Detailed explanation goes here
if ~exist('binSize','var')
    binSize = 2;
end

% Filtering out negative-Z points
i = X(3,:) >= 0;
X = X(:,i);

% Dominant bin sliding window filtering
bestInd = [];
for i = 1:size(X,2)
    z = X(3,i);
    ind = X(3,:) >= z & X(3,:) <= z+binSize;
    if sum(ind) > sum(bestInd)
        bestInd = ind;
    end
end
X = X(:,bestInd);
end