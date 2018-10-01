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

%% Fundamental matrix estimation
load('OPTIMTHRESH_NORM8PTALG')
load('GROUND_TRUTH_INLIERS')

[F, CxIn] = RANSAC(num2cell([x1; x2],1), ...
    @EstimateFundamentalMatrix, 8, @SampsonDistance, OPTIMTHRESH_NORM8PTALG);

xIn = cell2mat(CxIn);
x1In = xIn(1:2,:);
x2In = xIn(3:4,:);
 
disp(['Eroare: ' num2str(sum(SummedEpipolarDistance...
    (F, GROUND_TRUTH_INLIERS))/length(GROUND_TRUTH_INLIERS))])

PlotCorrespondences(im1, im2, x1, x2, x1In, x2In);

%% Camera calibration
if ~exist('K', 'var')
    warning('K matrix not found! Calculating...')
    K = CalibrateCamera('calib_ims');
end

x1CalibIn = Dehomogenize(K\Homogenize(x1In));
x2CalibIn = Dehomogenize(K\Homogenize(x2In));

%% Essential matrix estimation
E = K'*F*K;

%% Ambiguous pose from Essential matrix
CP = EstimateCameraMatrices(E);

%% Triangulating points
X1 = LinearTriangulation([eye(3) [0 0 0]'], CP{1}, x1CalibIn, x2CalibIn);
X2 = LinearTriangulation([eye(3) [0 0 0]'], CP{2}, x1CalibIn, x2CalibIn);
X3 = LinearTriangulation([eye(3) [0 0 0]'], CP{3}, x1CalibIn, x2CalibIn);
X4 = LinearTriangulation([eye(3) [0 0 0]'], CP{4}, x1CalibIn, x2CalibIn);

%% Real pose estimation
[P, X] = DisambiguateCameraPose(CP, {X1, X2, X3, X4});

R = P(1:3,1:3);
t = P(:,end);
Display3D({[0 0 0]', -R'*t}, {eye(3), R}, X);
