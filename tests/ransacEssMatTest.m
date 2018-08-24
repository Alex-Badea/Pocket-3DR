im1 = imread('1.jpg');
im2 = imread('2.jpg');

if ~exist('kPts1', 'var') || ~exist('kPts2', 'var') || ~exist('matchesCoords12', 'var') || ~exist('matchesIndices12', 'var')
    kPts1 = EstimateImageKeypoints(im1);
    kPts2 = EstimateImageKeypoints(im2);
    [matchesCoords12, matchesIndices12] = EstimateKeypointCorrespondences(kPts1, kPts2);
end

[F, inliersSet, ~, steps] = RANSAC(num2cell(matchesCoords12,1), ...
    @EstimateFundamentalMatrix, 8, @SampsonDistance, 10);
steps
inliers = cell2mat(inliersSet);
x1Inliers = inliers(1:2,:);
x2Inliers = inliers(3:4,:);

PlotCorrespondences(im1, im2, matchesCoords12(1:2,:), matchesCoords12(3:4,:), ...
    x1Inliers, x2Inliers);
