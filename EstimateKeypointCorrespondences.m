function [ matchesCoords, matchesIndices ] = EstimateKeypointCorrespondences( kPts1, kPts2 )
%ESTIMATEKEYPOINTCORRESPONDENCES Summary of this function goes here
%   Detailed explanation goes here
[matchesCoords, matchesIndices] = wbs_match_descriptions(kPts1, kPts2, wbs_default_cfg);
end

