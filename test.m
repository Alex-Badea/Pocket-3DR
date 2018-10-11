addpath(genpath(fileparts(which(mfilename))))

im1 = imread('car08.jpg');
im2 = imread('car09.jpg');
kp1 = EstimateImageKeypoints(im1);
kp2 = EstimateImageKeypoints(im2);
mc12 = EstimateKeypointCorrespondences(kp1,kp2);

mc12n = [Dehomogenize(K\Homogenize(mc12(1:2,:))); 
    Dehomogenize(K\Homogenize(mc12(3:4,:)))];
load('OPTIMTHRESH_5PTALG')
[E1,Cmc12nin] = RANSAC(num2cell(mc12n,1), @EstimateEssentialMatrix, ...
    5, @SampsonDistance, 1e-5);
mc12nin = cell2mat(Cmc12nin);
mc12in = [Dehomogenize(K*Homogenize(mc12nin(1:2,:))); 
    Dehomogenize(K*Homogenize(mc12nin(3:4,:)))];
Cmc12in = num2cell(mc12in,1);
disp(['Eroare rap. la adev. crt. INAINTE: ' num2str(sum(SummedEpipolarDistance...
    (K'\E1/K, Cmc12in))/length(Cmc12in))])
%% MINIM. EPIP. ERR.
P = EstimateRealPoseAndTriangulate(E1,mc12nin(1:2,:),mc12nin(3:4,:));
R = P(1:3,1:3);
r = rotationMatrixToVector(R)';
t = P(:,end);
f = @(x) sum(SummedEpipolarDistance(...
    Skew(x(:,2))*rotationVectorToMatrix(x(:,1)), Cmc12nin))/length(Cmc12nin);
o = optimoptions(@fminunc,'Display','iter','MaxFunctionEvaluations',Inf,...
    'StepTolerance',1e-10);
rt = fminunc(f, [r t], o);
E1 = Skew(rt(:,2))*rotationVectorToMatrix(rt(:,1));
%%
mc12in = [Dehomogenize(K*Homogenize(mc12nin(1:2,:))); 
    Dehomogenize(K*Homogenize(mc12nin(3:4,:)))];

PlotCorrespondences(im1,im2,mc12(1:2,:),mc12(3:4,:),...
    mc12in(1:2,:),mc12in(3:4,:));

load('GROUND_TRUTH_INLIERS')
GROUND_TRUTH_INLIERS = cell2mat(GROUND_TRUTH_INLIERS);
figure
PlotCorrespondences(im1,im2,mc12(1:2,:),mc12(3:4,:),...
    GROUND_TRUTH_INLIERS(1:2,:),GROUND_TRUTH_INLIERS(3:4,:));

load('GROUND_TRUTH_INLIERS')
disp(['Eroare rap. la adev-adev: ' num2str(sum(SummedEpipolarDistance...
    (K'\E1/K, GROUND_TRUTH_INLIERS))/length(GROUND_TRUTH_INLIERS))])
Cmc12in = num2cell(mc12in,1);
disp(['Eroare rap. la adev. crt.: ' num2str(sum(SummedEpipolarDistance...
    (K'\E1/K, Cmc12in))/length(Cmc12in))])

P1 = CANONICAL_POSE;
P2 = EstimateRealPoseAndTriangulate(E1,mc12nin(1:2,:),mc12nin(3:4,:));

    F = K'\E1/K;
    [H1, H2, im1r, im2r] = rectify(F, im1, im2);
    im1r(im1r==0) = -1;
    KP1r = H1*K*P1;
    KP2r = H2*K*P2;
    
    pars = [];
    pars.mu = -10.6;
    pars.window = 4;
    pars.zonegap = 10;
    pars.pm_tau = 0.95;
    D = gcs(im1r, im2r, [], pars);
    mc12r = MatchesFromDisparity(D);
    X1 = LinearTriangulation(KP1r, KP2r, mc12r(1:2,:), mc12r(3:4,:));

pcshow(X1')