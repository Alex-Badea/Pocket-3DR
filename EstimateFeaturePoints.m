function [fPts] = EstimateFeaturePoints(im)
%ESTIMATEFEATUREPOINTS Summary of this function goes here
%   Detailed explanation goes here
ROI = [25 25 size(im,2)-50 size(im,1)-50]; 
kPts = detectSURFFeatures(rgb2gray(im), 'MetricThreshold', 100, 'ROI', ROI);
%kPts = detectKAZEFeatures(rgb2gray(im), 'Threshold', 6e-5, 'ROI', ROI);
%kPts = detectFASTFeatures(rgb2gray(im), 'MinQuality', 2.6e-2,...
%    'MinContrast', 2.6e-2, 'ROI', ROI);
%kPts = detectBRISKFeatures(rgb2gray(im), 'MinQuality', 6e-2, 'MinContrast', 6e-2,...
%    'ROI', ROI);
[feats,kPts] = extractFeatures(rgb2gray(im), kPts, 'Method', 'SURF',...
    'Upright', true);
fPts = {feats,kPts};
end

