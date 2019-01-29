function [matchesCoords] = MatchFeaturePoints(fPts1,fPts2)
%MATCHFEATUREPOINTS Summary of this function goes here
%   Detailed explanation goes here
i = matchFeatures(fPts1{2}, fPts2{2}, 'Method', 'Approximate', 'Unique', true,...
        'MaxRatio', 0.6);
    matchesCoords = double([fPts1{1}(:,i(:,1)); fPts2{1}(:,i(:,2))]);
end

