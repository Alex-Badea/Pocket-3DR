addpath(genpath(fileparts(which(mfilename))))
dataset = 'mer';
load('calib_AV_X2S_4MPIX.mat')

%% Reading image dataset
disp(['Running pipeline for dataset "' dataset '"'])
disp('Calibration matrix: '), disp(K)
if exist('d','var')
    disp('Radial distortion parameters: '), disp(d)
end

imsDir = dir(['ims/' dataset '*.jpg']); imsDir = imsDir(1:2);
imsNames = {imsDir.name};
imsNo = length(imsNames);
Cim = cell(1,imsNo);
for i = 1:length(imsNames)
    Cim{i} = imread(imsNames{i});
end
if exist('d','var')
    Cim = UndistortImages(Cim,K,d);
end

%% Computing correspondences
CfeatPts = cell(1,imsNo);
for i = 1:imsNo
    disp(['Feature points estimation: image ' num2str(i) ' of ' num2str(imsNo)])
    CfeatPts{i} = EstimateFeaturePoints(Cim{i});
end
CcorrsNorm = cell(1,imsNo-1);
Ccorrs = cell(1,imsNo-1);
for i = 1:imsNo-1
    disp(['Feature matching: pair ' num2str(i) ' of ' num2str(imsNo-1)])
    corrs = MatchFeaturePoints(CfeatPts{i}, CfeatPts{i+1});
    Ccorrs{i} = corrs;
    CcorrsNorm{i} = [Dehomogenize(K\Homogenize(corrs(1:2,:)));
        Dehomogenize(K\Homogenize(corrs(3:4,:)))];
end

%% Essential Matrix estimation
CcorrsNormIn = cell(1,imsNo-1);
CE = cell(1,imsNo-1);
for i = 1:imsNo-1
    disp(['Essential Matrix estimation: pair ' num2str(i) ' of ' num2str(imsNo-1)])
    [CE{i}, Cinliers] = RANSAC(num2cell(CcorrsNorm{i},1),...
        @EstimateEssentialMatrix, 5, @SampsonDistance, 1e-7);
    CcorrsNormIn{i} = cell2mat(Cinliers);
end

%% Background Filtering
CcorrsNormInFil = cell(1,imsNo-1);
for i = 1:imsNo-1
    disp(['Background Filtering: pair ' num2str(i) ' of ' num2str(imsNo-1)])
    P = EstimateRealPose(CE{i}, CcorrsNormIn{i});
    CcorrsNormInFil{i} = CcorrsNormIn{i};%FilterBackgroundFromCorrs(CANONICAL_POSE, P, CcorrsNormIn{i});
    CE{i} = OptimizeEssentialMatrix(CE{i}, CcorrsNormInFil{i});
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PlotCorrespondences(Cim{i},Cim{i+1},CcorrsNorm{i},CcorrsNormIn{i},K)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

%% Structure from Motion
disp('Pose estimation: default first pair')
CP = cell(1,imsNo);
CP{1} = CANONICAL_POSE; 
CP{2} = EstimateRealPose(CE{1}, CcorrsNorm{1});
%{
for i = 2:imsNo-1
    disp(['Pose estimation: ' num2str(i+1) ' of ' num2str(imsNo)])
    CP{i+1} = EstimateRealPose(CE{i}, CcorrsNormInFil{i});
    TrackedCorrs = CascadeTrack({CcorrsNormInFil{i-1}, CcorrsNormInFil{i}});
    TrackedCorrsIso = IsolateTransitiveCorrs(TrackedCorrs);
    disp(['Transitivity: ' num2str(size(TrackedCorrsIso,2))])
    CP{i+1} = OptimizeTranslationVector(CP{i-1}, CP{i}, CP{i+1}, ...
        TrackedCorrsIso(1:2,:), TrackedCorrsIso(3:4,:), TrackedCorrsIso(5:6,:));
end

%% Bundle Adjustment
disp('Bundle Adjustment')
C = CascadeTrack(CcorrsNormInFil);
X = TriangulateCascade(CP,C);
CPBA = BundleAdjustment(CP,X,C);
%}
CPBA=CP;

%% FIDDLE ZONE
X = Triangulate(CPBA{1},CPBA{2},CcorrsNormInFil{1});
PlotSparse(CPBA,X)
axis(30*[-5 5 -5 5 -10 10])