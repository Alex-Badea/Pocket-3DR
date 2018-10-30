function [matchesCoords] = MatchFeaturePoints(fPts1,fPts2)
%MATCHFEATUREPOINTS Summary of this function goes here
%   Detailed explanation goes here
i = matchFeatures(fPts1{1}, fPts2{1});
matchesCoords = double([fPts1{2}(i(:,1)).Location';
    fPts2{2}(i(:,2)).Location']);
end

