%% Compute correspondences between first 2 images
im1 = imread('face2.jpg');
im2 = imread('face3.jpg');

if ~exist('kPts1', 'var') || ~exist('kPts2', 'var') ...
        || ~exist('matchesCoords12', 'var') || ~exist('matchesIndices12', 'var')
    kPts1 = EstimateImageKeypoints(im1);
    kPts2 = EstimateImageKeypoints(im2);
    [matchesCoords12, matchesIndices12] = EstimateKeypointCorrespondences(kPts1, kPts2);
end

x1 = matchesCoords12(1:2,:);
x2 = matchesCoords12(3:4,:);

%% Camera calibration
if ~exist('K','var')
    warning('K matrix not found! Calculating...')
    K = CalibrateCamera('calib_ims');
end

x1Calib = Dehomogenize(K\Homogenize(x1));
x2Calib = Dehomogenize(K\Homogenize(x2));

%% Direct Essential matrix estimation
load('OPTIMTHRESH_5PTALG')
load('GROUND_TRUTH_INLIERS')

[E, CxCalibIn] = RANSAC(num2cell([x1Calib; x2Calib],1), ...
    @EstimateEssentialMatrix, 5, @SampsonDistance, OPTIMTHRESH_5PTALG);

xCalibIn = cell2mat(CxCalibIn);
x1CalibIn = xCalibIn(1:2,:);
x2CalibIn = xCalibIn(3:4,:);
x1In = Dehomogenize(K*Homogenize(x1CalibIn));
x2In = Dehomogenize(K*Homogenize(x2CalibIn));

disp(['Eroare: ' num2str(sum(SummedEpipolarDistance...
    (K'\E/K, GROUND_TRUTH_INLIERS))/length(GROUND_TRUTH_INLIERS))])
PlotCorrespondences(im1,im2,x1,x2,x1In,x2In)


%% Ambiguous pose from Essential matrix
P1 = [eye(3) [0 0 0]'];
P2 = EstimateRealPoseAndTriangulate(E, x1CalibIn, x2CalibIn);

%% Epipolar Rectification and Stereo-matching
F = K'\E/K;
[H1, H2, im1Rec, im2Rec] = rectify(F, im1, im2);
im1Rec(im1Rec==0) = -1;
pars.zonegap = 1;
pars.tau = 0.7;
pars.csalgorithm = 'cFXS-fast';
D = gcs(im1Rec, im2Rec, [], pars);

mc12Rec = MatchesFromDisparity(D);
x1Rec = mc12Rec(1:2,:);
x2Rec = mc12Rec(3:4,:);
KP1 = K*P1;
KP2 = K*P2;
KP1Rec = H1*KP1;
KP2Rec = H2*KP2;

PlotCorrespondences(im1Rec,im2Rec,mc12Rec(1:2,1:100:end),mc12Rec(3:4,1:100:end))

%% Dense triangulation
x1CalibRec = Dehomogenize(K\Homogenize(x1Rec));
x2CalibRec = Dehomogenize(K\Homogenize(x2Rec));
X = LinearTriangulation(KP1Rec, KP2Rec, x1Rec, x2Rec);
XDN = pcdenoise(pointCloud(X'),'Threshold',0.001,'NumNeighbors',500);
figure,pcshow(XDN);