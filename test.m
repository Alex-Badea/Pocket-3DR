im1 = imread('cpl01.jpg');
im2 = imread('cpl02.jpg');

kp1 = EstimateFeaturePoints(im1);
kp2 = EstimateFeaturePoints(im2);

mc12 = MatchFeaturePoints(kp1,kp2);

[~, Cin] = RANSAC(num2cell(mc12,1),...
    @EstimateFundamentalMatrix, 8, @SampsonDistance, 12);

PlotCorrespondences(im1, im2, mc12, cell2mat(Cin))