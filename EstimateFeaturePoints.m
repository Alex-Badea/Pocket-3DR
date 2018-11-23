function [fPts] = EstimateFeaturePoints(im)
%ESTIMATEFEATUREPOINTS Summary of this function goes here
%   Detailed explanation goes here
kPts = detectSURFFeatures(rgb2gray(im), 'MetricThreshold', 20, 'NumOctaves', 4,...
   'NumScaleLevels', 6);
%kPts = detectKAZEFeatures(rgb2gray(im), 'Threshold', 6e-5);
%kPts = detectFASTFeatures(rgb2gray(im), 'MinQuality', 3e-2, 'MinContrast', 3e-2);
%kPts = detectBRISKFeatures(rgb2gray(im), 'MinQuality', 6e-2, 'MinContrast', 6e-2);
[feats,kPts] = extractFeatures(rgb2gray(im), kPts, 'Method', 'Auto',...
    'Upright', true);
fPts = {feats,kPts};
end

