%% Camera calibration
if ~exist('K', 'var')
    warning('K matrix not found! Calculating...')
    K = CalibrateCamera('calib_ims');
end

%% Compute correspondences between first 2 images
im1 = imread('1.jpg');
im2 = imread('2.jpg');

if ~exist('kPts1', 'var') || ~exist('kPts2', 'var') ...
        || ~exist('matchesCoords12', 'var') || ~exist('matchesIndices12', 'var')
    kPts1 = EstimateImageKeypoints(im1);
    kPts2 = EstimateImageKeypoints(im2);
    [matchesCoords12, matchesIndices12] = EstimateKeypointCorrespondences(kPts1, kPts2);
end

x1 = matchesCoords12(1:2,:);
x2 = matchesCoords12(3:4,:);

x1Calib = Dehomogenize(K\Homogenize(x1));
x2Calib = Dehomogenize(K\Homogenize(x2));

%% Generating histogram data for elapsed steps and time
%load('OPTIMTHRESH_NORM8PTALG')
%load('OPTIMTHRESH_5PTALG')

stepsNo = 100;
%{
allStepsNorm8PtAlg = zeros(1, stepsNo);
allTimesNorm8PtAlg = zeros(1, stepsNo);
for i = 1:stepsNo
    disp(['Test case ' num2str(i) ' out of ' num2str(stepsNo)])
    tic
    [F, inliersSet, ~, steps] = RANSAC(num2cell(matchesCoords12,1), ...
        @EstimateFundamentalMatrix, 8, @SampsonDistance, OPTIMTHRESH_NORM8PTALG);
    allTimesNorm8PtAlg(i) = toc;
    allStepsNorm8PtAlg(i) = steps;
end
%}
allSteps5PtAlg = zeros(1, stepsNo);
allTimes5PtAlg = zeros(1, stepsNo);
for i = 1:stepsNo
    disp(['Test case ' num2str(i) ' out of ' num2str(stepsNo)])
    tic
    [E, inliersSet, ~, steps] = RANSAC(num2cell([x1Calib; x2Calib],1), ...
        @EstimateEssentialMatrix, 5, @SampsonDistance, OPTIMTHRESH_NORM8PTALG);
    allTimes5PtAlg(i) = toc;
    allSteps5PtAlg(i) = steps;
end

figure, histogram(allStepsNorm8PtAlg,100), title(['Num' char(259) 'rul de pa' ...
    char(537) 'i pentru Algoritmul celor opt puncte normalizat'])
figure, histogram(allTimesNorm8PtAlg,100), title(['Timpii pentru ' ...
    'Algoritmul celor opt puncte normalizat'])

figure, histogram(allSteps5PtAlg,100), title(['Num' char(259) 'rul de pa' ...
    char(537) 'i pentru Algoritmul celor cinci puncte'])
figure, histogram(allTimes5PtAlg,100), title(['Timpii pentru ' ...5
    'Algoritmul celor cinci pucte'])
% HISTFIT HERE@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
