%% Camera calibration
if ~exist('K', 'var')
    warning('K matrix not found! Calculating...')
    K = CalibrateCamera('calib_ims');
end

%% Compute correspondences between first 2 images
im1 = imread('1.jpg');
im2 = imread('2.jpg');

if ~exist('kPts1', 'var') || ~exist('kPts2', 'var') || ~exist('matchesCoords12', 'var') || ~exist('matchesIndices12', 'var')
    kPts1 = EstimateImageKeypoints(im1);
    kPts2 = EstimateImageKeypoints(im2);
    [matchesCoords12, matchesIndices12] = EstimateKeypointCorrespondences(kPts1, kPts2);
end

x1 = matchesCoords12(1:2,:);
x2 = matchesCoords12(3:4,:);

%% Finding optimal threshold for normalized Eight-Point Algorithm
x1Calib = Dehomogenize(K\Homogenize(x1));
x2Calib = Dehomogenize(K\Homogenize(x2));

load('GROUND_TRUTH_INLIERS')
load('ERRORS_5PTALG')
%{
testsNo = 500;
thresholdsSize = 20;
thresholdLimit = 1e-3;
thresholds = SmootherLogspace(1e-11, thresholdLimit, thresholdsSize, 0.01);

% The test results are readily available in the
% ERRORS_5PTALG.mat file.
errors5PtAlg = zeros(1, length(thresholds));
parfor i = 1:thresholdsSize
    disp(['Threshold no. ' num2str(i) ' out of ' num2str(thresholdsSize)])
    t = thresholds(i);
    cumulErr = 0;
    for j = 1:testsNo
        disp(['Test case ' num2str(j) ' out of ' num2str(testsNo)])
        [E, inliersSet] = RANSAC(num2cell([x1Calib; x2Calib],1), ...
            @EstimateEssentialMatrix, 5, @SampsonDistance, t);
        if isempty(inliersSet), disp('UH-OH...'), continue, end
        cumulErr = cumulErr + sum(SummedEpipolarDistance(K'\E/K, GROUND_TRUTH_INLIERS))/length(GROUND_TRUTH_INLIERS);
    end
    err = cumulErr/testsNo;
    errors5PtAlg(i) = err;
end
%}
figure, hold on
title('Pragul optim pentru Algoritmul celor cinci puncte')
xlabel('Prag')
ylabel('Eroare')
plot(thresholds, ERRORS_5PTALG, 'ro--');
hold off
%{
testsNo = 200;
thresholdsSize = 40;
thresholdLimit = 1e-7;
thresholds = SmootherLogspace(5e-10, thresholdLimit, thresholdsSize, 0.2);

% The test results are readily available in the
% ERRORS_5PTALG_CLOSE.mat file.
errors5PtAlgClose = zeros(1, length(thresholds));
parfor i = 1:thresholdsSize
    disp(['Threshold no. ' num2str(i) ' out of ' num2str(thresholdsSize)])
    t = thresholds(i);
    cumulErr = 0;
    for j = 1:testsNo
        disp(['Test case ' num2str(j) ' out of ' num2str(testsNo)])
        [E, inliersSet] = RANSAC(num2cell([x1Calib; x2Calib],1), ...
            @EstimateEssentialMatrix, 5, @SampsonDistance, t);
        if isempty(inliersSet), disp('UH-OH...'), continue, end
        cumulErr = cumulErr + sum(SummedEpipolarDistance(K'\E/K, GROUND_TRUTH_INLIERS))/length(GROUND_TRUTH_INLIERS);
    end
    err = cumulErr/testsNo;
    errors5PtAlgClose(i) = err;
end
%}
load('ERRORS_5PTALG_CLOSE')

[minVal, minInd] = min(ERRORS_5PTALG_CLOSE);
optimalThreshold = thresholds(minInd);

figure, hold on
title('Pragul optim pentru Algoritmul celor cinci puncte')
xlabel('Prag')
ylabel('Eroare')
plot(thresholds, ERRORS_5PTALG_CLOSE, 'ro--');
plot(optimalThreshold, minVal, 'g+', 'LineWidth', 2)
legend('Algoritmul celor cinci puncte', ['Pragul optim = ' num2str(optimalThreshold)])
hold off

%% Visualising results
groundTruthInliers = cell2mat(GROUND_TRUTH_INLIERS);
PlotCorrespondences(im1, im2, x1, x2, ...
    groundTruthInliers(1:2,:), groundTruthInliers(3:4,:))
title(['Coresponden' char(539) 'e verificate empiric'])

[E, CxCalibIn, ~, steps] = RANSAC(num2cell([x1Calib; x2Calib],1), ...
            @EstimateEssentialMatrix, 5, @SampsonDistance, optimalThreshold);
xCalibIn = cell2mat(CxCalibIn);
x1CalibIn = xCalibIn(1:2,:);
x2CalibIn = xCalibIn(3:4,:);
x1In = Dehomogenize(K*Homogenize(x1CalibIn));
x2In = Dehomogenize(K*Homogenize(x2CalibIn));
PlotCorrespondences(im1, im2, x1, x2, ...
    x1In, x2In)
title(['Coresponden' char(539) 'e rezultate ' char(238) 'n urma rul' ...
    char(259) 'rii algoritmului celor cinci puncte cu pragul optim'])
disp(['Eroare: ' num2str(sum(SummedEpipolarDistance(K'\E/K, GROUND_TRUTH_INLIERS))/length(GROUND_TRUTH_INLIERS))])