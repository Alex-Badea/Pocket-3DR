function [fPts] = EstimateFeaturePoints(im)
%ESTIMATEFEATUREPOINTS Summary of this function goes here
%   Detailed explanation goes here
kPts = detectSURFFeatures(rgb2gray(im), 'MetricThreshold', 10);
[feats,kPts] = extractFeatures(rgb2gray(im), kPts);
fPts = {feats,kPts};
end

