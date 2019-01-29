function [fPts] = EstimateFeaturePoints(im,method)
%ESTIMATEFEATUREPOINTS Summary of this function goes here
%   Detailed explanation goes here
if ~exist('method','var')
    method = 'SURF';
end

ROI = [10 10 size(im,2)-20 size(im,1)-20]; 
if strcmp(method,'SURF')
    kPts = detectSURFFeatures(rgb2gray(im), 'MetricThreshold', 100, 'ROI', ROI);
    [desc,kPts] = extractFeatures(rgb2gray(im), kPts, 'Method', 'Auto',...
        'Upright', true);
    loc = kPts.Location';
    fPts = {loc,desc};
elseif strcmp(method,'KAZE')
    kPts = detectKAZEFeatures(rgb2gray(im), 'Threshold', 1e-4, 'ROI', ROI);
    [desc,kPts] = extractFeatures(rgb2gray(im), kPts, 'Method', 'Auto',...
        'Upright', true);
    loc = kPts.Location';
    fPts = {loc,desc};
elseif strcmp(method,'FAST')
    kPts = detectFASTFeatures(rgb2gray(im), 'MinQuality', 3e-2,...
        'MinContrast', 3e-2, 'ROI', ROI);
    [desc,kPts] = extractFeatures(rgb2gray(im), kPts, 'Method', 'Auto',...
        'Upright', true);
    loc = kPts.Location';
    fPts = {loc,desc};
elseif strcmp(method,'BRISK')
    kPts = detectBRISKFeatures(rgb2gray(im), 'MinQuality', 6e-2, 'MinContrast',...
        6e-2, 'ROI', ROI);
    [desc,kPts] = extractFeatures(rgb2gray(im), kPts, 'Method', 'Auto',...
        'Upright', true);
    loc = kPts.Location';
    fPts = {loc,desc};
    
% Non-native:
elseif strcmp(method,'SIFT')
    im = vl_imdown(single(rgb2gray(im)));
    [kPts,desc] = vl_sift(im,'Levels',12,'EdgeThresh',100,'Magnif',2);
    loc = 2*kPts(1:2,:);
    fPts = {loc,desc'};
elseif strcmp(method,'AKAZE')
    d = cv.AKAZE('Threshold',1e-4);
    [kPts,desc] = d.detectAndCompute(im);
    loc = vertcat(kPts.pt)';
    fPts = {loc,desc};
elseif strcmp(method,'ORB')
    d = cv.ORB('MaxFeatures',1e5);
    [kPts,desc] = d.detectAndCompute(im);
    loc = vertcat(kPts.pt)';
    fPts = {loc,desc};
else
    error('Unknown method')
end
end

