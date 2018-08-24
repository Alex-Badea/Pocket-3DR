%% Finding optimal threshold for each Fun. Mat. computation methods
im1 = imread('1.jpg');
im2 = imread('2.jpg');

if ~exist('kPts1', 'var') || ~exist('kPts2', 'var') || ~exist('matchesCoords12', 'var') || ~exist('matchesIndices12', 'var')
    kPts1 = EstimateImageKeypoints(im1);
    kPts2 = EstimateImageKeypoints(im2);
    [matchesCoords12, matchesIndices12] = EstimateKeypointCorrespondences(kPts1, kPts2);
end

testsNo = 200;
thresholdsSize = 40;
thresholdLimit = 3000;
thresholds = linspace(1, thresholdLimit, thresholdsSize);
%{
% WARNING: The following loops might take up to 30 MIN to run on a 4-core
% computer!!! The test results are readily available in the
% ERRORS_NORM8PTALG.mat and ERRORS_7PTALG.mat files.
errorsNorm8PtAlg = zeros(1, length(thresholds));
parfor i = 1:thresholdsSize
    disp(['Threshold no. ' num2str(i) ' out of ' num2str(thresholdsSize)])
    t = thresholds(i);
    cumulErr = 0;
    for j = 1:testsNo
        %disp(['Test case ' num2str(j) ' out of ' num2str(testsNo)])
        [F, inliersSet, ~, steps] = RANSAC(num2cell(matchesCoords12,1), ...
            @(Cx) EstimateFundamentalMatrix(Cx, 'Norm8PtAlg'), 8, @SampsonDistance, t);
        if isempty(inliersSet), disp('UH-OH...'), continue, end
        cumulErr = cumulErr + sum(SummedEpipolarDistance(F, GROUND_TRUTH_INLIERS))/length(GROUND_TRUTH_INLIERS);
    end
    err = cumulErr/testsNo;
    errorsNorm8PtAlg(i) = err;
end

errors7PtAlg = zeros(1, length(thresholds));
parfor i = 1:thresholdsSize
    disp(['Threshold no. ' num2str(i) ' out of ' num2str(thresholdsSize)])
    t = thresholds(i);
    cumulErr = 0;
    for j = 1:testsNo
        %disp(['Test case ' num2str(j) ' out of ' num2str(testsNo)])
        [F, inliersSet, ~, steps] = RANSAC(num2cell(matchesCoords12,1), ...
            @(Cx) EstimateFundamentalMatrix(Cx, '7PtAlg'), 7, @SampsonDistance, t);
        if isempty(inliersSet), disp('UH-OH...'), continue, end
        cumulErr = cumulErr + sum(SummedEpipolarDistance(F, GROUND_TRUTH_INLIERS))/length(GROUND_TRUTH_INLIERS);
    end
    err = cumulErr/testsNo;
    errors7PtAlg(i) = err;
end
%}
plot(thresholds, errorsNorm8PtAlg, 'ro--');
hold on
plot(thresholds, errors7PtAlg, 'b^--');