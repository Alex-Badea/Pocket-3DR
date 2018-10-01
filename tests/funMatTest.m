%% Estimating correspondences
im1 = imread('1.jpg');
im2 = imread('2.jpg');

if ~exist('kPts1', 'var') || ~exist('kPts2', 'var') || ~exist('matchesCoords12', 'var') || ~exist('matchesIndices12', 'var')
    kPts1 = EstimateImageKeypoints(im1);
    kPts2 = EstimateImageKeypoints(im2);
    [matchesCoords12, matchesIndices12] = EstimateKeypointCorrespondences(kPts1, kPts2);
end

%% Finding the algorithm with best results
load('GROUND_TRUTH_INLIERS.mat')
%{
testsNo = 500;
thresholdsSize = 20;
thresholdLimit = 10000;
thresholds = SmootherLogspace(1, thresholdLimit, thresholdsSize, 0.01);

% WARNING: The following loops might take up to 30 MIN to run on a 4-core
% computer (granted, it's a very old 4-core computer...)!!!
% The test results are readily available in the
% ERRORS_NORM8PTALG.mat and ERRORS_7PTALG.mat files.
errorsNorm8PtAlg = zeros(1, length(thresholds));
parfor i = 1:thresholdsSize
    disp(['Threshold no. ' num2str(i) ' out of ' num2str(thresholdsSize)])
    t = thresholds(i);
    cumulErr = 0;
    for j = 1:testsNo
        %disp(['Test case ' num2str(j) ' out of ' num2str(testsNo)])
        [F, inliersSet, ~, steps] = RANSAC(num2cell(matchesCoords12,1), ...
            @EstimateFundamentalMatrix, 8, @SampsonDistance, t);
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
            @EstimateFundamentalMatrix, 7, @SampsonDistance, t);
        if isempty(inliersSet), disp('UH-OH...'), continue, end
        cumulErr = cumulErr + sum(SummedEpipolarDistance(F, GROUND_TRUTH_INLIERS))/length(GROUND_TRUTH_INLIERS);
    end
    err = cumulErr/testsNo;
    errors7PtAlg(i) = err;
end
%}
load('ERRORS_NORM8PTALG')
load('ERRORS_7PTALG')

figure, hold on
title(['Algoritmul celor opt puncte normalizat vs. Algoritmul celor ' char(537) 'apte puncte'])
xlabel('Prag')
ylabel('Eroare')
plot(ERRORS_NORM8PTALG(1,:), ERRORS_NORM8PTALG(2,:), 'ro--');
plot(ERRORS_7PTALG(1,:), ERRORS_7PTALG(2,:), 'b^--');
legend('Algoritmul celor opt puncte normalizat', ['Algoritmul celor ' char(537) 'apte puncte'])
hold off

%% Finding optimal threshold for normalized Eight-Point Algorithm
%{
testsNo = 500;
thresholdsSize = 10;
thresholdLimit = 100;
thresholds = SmootherLogspace(1, thresholdLimit, thresholdsSize, 0.2);

% The test results are readily available in the
% ERRORS_NORM8PTALG_CLOSE.mat file.
errorsNorm8PtAlgClose = zeros(1, length(thresholds));
parfor i = 1:thresholdsSize
    disp(['Threshold no. ' num2str(i) ' out of ' num2str(thresholdsSize)])
    t = thresholds(i);
    cumulErr = 0;
    for j = 1:testsNo
        %disp(['Test case ' num2str(j) ' out of ' num2str(testsNo)])
        [F, inliersSet, ~, steps] = RANSAC(num2cell(matchesCoords12,1), ...
            @EstimateFundamentalMatrix, 8, @SampsonDistance, t);
        if isempty(inliersSet), disp('UH-OH...'), continue, end
        cumulErr = cumulErr + sum(SummedEpipolarDistance(F, GROUND_TRUTH_INLIERS))/length(GROUND_TRUTH_INLIERS);
    end
    err = cumulErr/testsNo;
    errorsNorm8PtAlgClose(i) = err;
end
%}
load('ERRORS_NORM8PTALG_CLOSE')

figure, hold on
title('Pragul optim pentru Algoritmul celor opt puncte normalizat')
xlabel('Prag')
ylabel('Eroare')
plot(ERRORS_NORM8PTALG_CLOSE(1,:), ERRORS_NORM8PTALG_CLOSE(2,:), 'ro--');
hold off
%{
testsNo = 1000;
thresholdsSize = 40;
thresholdLimit = 20;
thresholds = SmootherLogspace(5, thresholdLimit, thresholdsSize, 0.1);

% The test results are readily available in the
% ERRORS_NORM8PTALG_CLOSER.mat file.
errorsNorm8PtAlgCloser = zeros(1, length(thresholds));
parfor i = 1:thresholdsSize
    disp(['Threshold no. ' num2str(i) ' out of ' num2str(thresholdsSize)])
    t = thresholds(i);
    cumulErr = 0;
    for j = 1:testsNo
        %disp(['Test case ' num2str(j) ' out of ' num2str(testsNo)])
        [F, inliersSet, ~, steps] = RANSAC(num2cell(matchesCoords12,1), ...
            @EstimateFundamentalMatrix, 8, @SampsonDistance, t);
        if isempty(inliersSet), disp('UH-OH...'), continue, end
        cumulErr = cumulErr + sum(SummedEpipolarDistance(F, GROUND_TRUTH_INLIERS))/length(GROUND_TRUTH_INLIERS);
    end
    err = cumulErr/testsNo;
    errorsNorm8PtAlgCloser(i) = err;
end
%}
load('ERRORS_NORM8PTALG_CLOSER')
[minVal, minInd] = min(ERRORS_NORM8PTALG_CLOSER(2,:));
optimalThreshold = ERRORS_NORM8PTALG_CLOSER(1,minInd);

figure, hold on
title('Pragul optim pentru Algoritmul celor opt puncte normalizat')
xlabel('Prag')
ylabel('Eroare')
plot(ERRORS_NORM8PTALG_CLOSER(1,:), ERRORS_NORM8PTALG_CLOSER(2,:), 'ro--');
plot(optimalThreshold, minVal, 'g+', 'LineWidth', 2)
legend('Algoritmul celor opt puncte normalizat', ['Pragul optim = ' num2str(optimalThreshold)])
hold off

%% Visualising results
groundTruthInliers = cell2mat(GROUND_TRUTH_INLIERS);
PlotCorrespondences(im1, im2, matchesCoords12(1:2,:), matchesCoords12(3:4,:), ...
    groundTruthInliers(1:2,:), groundTruthInliers(3:4,:))
title(['Coresponden' char(539) 'e verificate empiric'])

[F, CxIn, ~, steps] = RANSAC(num2cell(matchesCoords12,1), ...
            @EstimateFundamentalMatrix, 8, @SampsonDistance, optimalThreshold);
xIn = cell2mat(CxIn);
x1In = xIn(1:2,:);
x2In = xIn(3:4,:);
PlotCorrespondences(im1, im2, matchesCoords12(1:2,:), matchesCoords12(3:4,:), ...
    x1In, x2In)
title(['Coresponden' char(539) 'e rezultate ' char(238) 'n urma rul' ...
    char(259) 'rii algoritmului celor opt puncte cu pragul optim'])
disp(['Eroare: ' num2str(sum(SummedEpipolarDistance(F, GROUND_TRUTH_INLIERS))/length(GROUND_TRUTH_INLIERS))])