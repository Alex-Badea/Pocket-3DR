%% Camera calibration
if ~exist('K', 'var')
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

%% Essential matrix estimation
x1Calib = Dehomogenize(K\Homogenize(x1));
x2Calib = Dehomogenize(K\Homogenize(x2));
[E, CxCalibIn,~,STEPS] = RANSAC(num2cell([x1Calib; x2Calib],1), @EstimateEssentialMatrix, 5, @SampsonDistance, 0.00001);
STEPS
xCalibIn = cell2mat(CxCalibIn);
x1CalibIn = xCalibIn(1:2,:);
x2CalibIn = xCalibIn(3:4,:);
x1In = Dehomogenize(K*Homogenize(x1CalibIn));
x2In = Dehomogenize(K*Homogenize(x2CalibIn));

PlotCorrespondences(im1, im2, x1, x2, x1In, x2In);

%% Finding R, t
