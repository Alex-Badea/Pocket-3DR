addpath(genpath(fileparts(which(mfilename))))
dataset = 'cpl';
load('calib_AV_P9L_2MPIX.mat')

%% Reading image dataset
disp(['Running pipeline for dataset "' dataset '" and calibration matrix ']), disp(K)
imsDir = dir(['ims/' dataset '*.jpg']);
imsNames = {imsDir.name};
imsNo = length(imsNames);
Cim = cell(1,imsNo);
for i = 1:length(imsNames)
    Cim{i} = imread(imsNames{i});
end
Cim = ResizeImages(Cim, [1600 1200]);

%% Computing correspondences
CfeatPts = cell(1,imsNo);
for i = 1:imsNo
    disp(['Feature points estimation: image ' num2str(i) ' of ' num2str(imsNo)])
    CfeatPts{i} = EstimateFeaturePoints(Cim{i});
end
CcorrsNorm = cell(1,imsNo-1);
for i = 1:imsNo-1
    disp(['Feature matching: pair ' num2str(i) ' of ' num2str(imsNo-1)])
    corrs = MatchFeaturePoints(CfeatPts{i}, CfeatPts{i+1});
    CcorrsNorm{i} = [Dehomogenize(K\Homogenize(corrs(1:2,:)));
        Dehomogenize(K\Homogenize(corrs(3:4,:)))];
end

%% Essential Matrix estimation
CcorrsNormIn = cell(1,imsNo-1);
CE = cell(1,imsNo-1);
for i = 1:imsNo-1
    disp(['Essential Matrix estimation: pair ' num2str(i) ' of ' num2str(imsNo-1)])
    [CE{i},Cinliers] = RANSAC(num2cell(CcorrsNorm{i},1), ...
        @EstimateEssentialMatrix, 5, @SampsonDistance, 1e-6);
    CcorrsNormIn{i} = cell2mat(Cinliers);
end

%% Background Filtering
CcorrsNormInFil = cell(1,imsNo-1);
for i = 1:imsNo-1
    disp(['Background Filtering: pair ' num2str(i) ' of ' num2str(imsNo-1)])
    P = EstimateRealPose(CE{i}, ...
        CcorrsNormIn{i}(1:2,:), CcorrsNormIn{i}(3:4,:));
    CcorrsNormInFil{i} = FilterBackgroundFromCorrs(CANONICAL_POSE, P, ...
        CcorrsNormIn{i}, 5);
    CE{i} = OptimizeEssentialMatrix(CE{i}, ...
        CcorrsNormInFil{i}(1:2,:), CcorrsNormInFil{i}(3:4,:));
end

%% Structure from Motion
disp('Pose estimation: default first pair')
CP = cell(1,imsNo);
CP{1} = CANONICAL_POSE;
CP{2} = EstimateRealPose(CE{1}, ...
    CcorrsNormInFil{1}(1:2,:), CcorrsNormInFil{1}(3:4,:));
for i = 2:imsNo-1
    disp(['Pose estimation: ' num2str(i+1) ' of ' num2str(imsNo)])
    CP{i+1} = EstimateRealPose(CE{i}, ...
        CcorrsNormInFil{i}(1:2,:), CcorrsNormInFil{i}(3:4,:), CP{i});
    TrackedCorrs = CascadeTrack({CcorrsNormInFil{i-1}, CcorrsNormInFil{i}});
    TrackedCorrsIso = IsolateTransitiveCorrs(TrackedCorrs);
    %%%
    disp(['trans ' num2str(size(TrackedCorrsIso,2))])
    %%%
    CP{i+1} = OptimizeTranslationVector(CP{i-1}, CP{i}, CP{i+1}, ...
        TrackedCorrsIso(1:2,:), TrackedCorrsIso(3:4,:), TrackedCorrsIso(5:6,:));
end
return
%% Bundle Adjustment
[X, CP] = BundleAdjustment(M,K,X,CP);

CPExt = [nan(3,4) CP];
Guide = (1:size(M,1)/2)'.* ~isnan(M(1:2:end,:));

XExt = repmat(X,1,size(M,1)/2);
Guide = reshape(Guide',1,numel(Guide));
MRpj = bsxfun(@(X, camInd) K*CPExt{camInd+1}*Homogenize(X), XExt, Guide);
MRpj = Dehomogenize(MRpj);
MRpj = BlockReshape(MRpj,size(M,1)/2);
ERRS = M-MRpj;
ERRS(:,sum(~isnan(ERRS))>4);
ERRS(isnan(ERRS)) = 0;
disp(['Eroare dup? BA: ' num2str(vecnorm(ERRS)*vecnorm(ERRS)'/size(ERRS,2))]);
%PlotSparse(CP, X)

%% Dense reconstruction
CX = cell(1,imsNo-1);
for i = 1:imsNo-1
    disp(['Dense reconstruction ' num2str(i) '/' num2str(imsNo-1)])
    F = K'\CE{i,i+1}/K;
    [H1, H2, im1Rec, im2Rec] = rectify(F, Cim{i}, Cim{i+1});
    im1Rec(im1Rec==0) = -1;
    KP1Rec = H1*K*CP{i};
    KP2Rec = H2*K*CP{i+1};

    pars = [];
    pars.mu = -10.6;
    pars.window = 4;
    pars.zonegap = 10;
    pars.pm_tau = 0.95;
    D = gcs(im1Rec, im2Rec, [], pars);
    mc12Rec = CorrsFromDisparity(D);
    x1Rec = mc12Rec(1:2,:);
    x2Rec = mc12Rec(3:4,:);
    CX{i} = LinearTriangulation(KP1Rec, KP2Rec, x1Rec, x2Rec);
end
%{
%% Denoising the triangulated points
for i = 1:imsNo-1
    disp(['Denoising ' num2str(i) '/' num2str(imsNo-1)])
    CX{i} = pcdenoise(pointCloud(CX{i}'),'Threshold',0.001,'NumNeighbors',500);
    CX{i} = CX{i}.Location';
end
%}