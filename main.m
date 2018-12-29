addpath(genpath(fileparts(which(mfilename))))
dataset = 'mer';
load('calib_AV_X2S_4MPIX.mat')

%% Reading image dataset
disp(['Running pipeline for dataset "' dataset '"'])
disp('Calibration matrix: '), disp(K)
if exist('d','var')
    disp('Radial distortion parameters: '), disp(d)
end

imsDir = dir(['ims/' dataset '*.jpg']);
disp(['Dataset contains ' num2str(length(imsDir)) ' images'])
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
    Ccorrs{i} = MatchFeaturePoints(CfeatPts{i}, CfeatPts{i+1});
    CcorrsNorm{i} = NormalizeCorrs(Ccorrs{i},K);
end

%% Essential Matrix estimation
CcorrsNormIn = cell(1,imsNo-1);
CE = cell(1,imsNo-1);
for i = 1:imsNo-1
    disp(['Essential Matrix estimation: pair ' num2str(i) ' of ' num2str(imsNo-1)])
    [CE{i}, Cinliers] = RANSAC(num2cell(CcorrsNorm{i},1),...
        @EstimateEssentialMatrix, 5, @SampsonDistance, 1e-5);
    CcorrsNormIn{i} = cell2mat(Cinliers);
    CE{i} = OptimizeEssentialMatrix(CE{i}, CcorrsNormIn{i});
end

%% Background Filtering ######################## NEEDS MORE WORK: MAKE ADAPTIVE
CEO = cell(1,imsNo-1);
CcorrsNormInFil = cell(1,imsNo-1);
for i = 1:imsNo-1
    disp(['Background Filtering: pair ' num2str(i) ' of ' num2str(imsNo-1)])
    P = EstimateRealPose(CE{i}, CcorrsNormIn{i});
    CcorrsNormInFil{i} = FilterBackgroundFromCorrs(CANONICAL_POSE, P,...
        CcorrsNormIn{i});
    CEO{i} = OptimizeEssentialMatrix(CE{i}, CcorrsNormInFil{i});
end

%% Sparse Reconstruction ###################### NEEDS MORE WORK: MAKE PARALLEL
disp('Pose estimation: default first pair')
CP = cell(1,imsNo);
CP{1} = CANONICAL_POSE; 
CP{2} = EstimateRealPose(CEO{1}, CcorrsNormInFil{1});

LOCALBA_OCCUR_PER1 = 4;
LOCALBA_OCCUR_PER2 = 6;
for i = 2:imsNo-1
    disp(['Pose estimation: ' num2str(i+1) ' of ' num2str(imsNo)])
    CP{i+1} = EstimateRealPose(CEO{i}, CcorrsNormInFil{i}, CP{i});
    TrackedCorrs = CascadeTrack({CcorrsNormInFil{i-1}, CcorrsNormInFil{i}});
    TrackedCorrsIso = IsolateTransitiveCorrs(TrackedCorrs);
    disp(['Transitivity: ' num2str(size(TrackedCorrsIso,2))])
    CP{i+1} = OptimizeTranslationVector(CP{i-1}, CP{i}, CP{i+1}, TrackedCorrsIso);
    CP{i+1} = MiniBundleAdjustment(CP{i-1}, CP{i}, CP{i+1}, TrackedCorrsIso);
    
    if ~mod(i-1, LOCALBA_OCCUR_PER1-2)
        disp('Local Bundle Adjustment 1...')
        disp(['Refine ' num2str(i-(LOCALBA_OCCUR_PER1-2)) '->' num2str(i+1)])
        CPBA = BundleAdjustment(CP(i-(LOCALBA_OCCUR_PER1-2) : i+1),...
            IsolateTransitiveCorrs(CascadeTrack(...
            CcorrsNormInFil(i-(LOCALBA_OCCUR_PER1-2) : i)), 'displaySize'));
        CP(i-(LOCALBA_OCCUR_PER1-2) : i+1) = CPBA;
    end
    
    if ~mod(i-1, LOCALBA_OCCUR_PER2-2)
        disp('Local Bundle Adjustment 2...')
        disp(['Refine ' num2str(i-(LOCALBA_OCCUR_PER2-2)) '->' num2str(i+1)])
        CPBA = BundleAdjustment(CP(i-(LOCALBA_OCCUR_PER2-2) : i+1),...
            IsolateTransitiveCorrs(CascadeTrack(...
            CcorrsNormInFil(i-(LOCALBA_OCCUR_PER2-2) : i)), 'displaySize'));
        CP(i-(LOCALBA_OCCUR_PER2-2) : i+1) = CPBA;
    end
end

disp('Last Local Bundle Adjustments...')
disp(['Refine ' num2str((imsNo-1)-(LOCALBA_OCCUR_PER1-2)) '->' num2str(imsNo)])
CPBA = BundleAdjustment(CP((imsNo-1)-(LOCALBA_OCCUR_PER1-2) : imsNo),...
    IsolateTransitiveCorrs(CascadeTrack(...
    CcorrsNormInFil((imsNo-1)-(LOCALBA_OCCUR_PER1-2) : imsNo-1)), 'displaySize'));
CP((imsNo-1)-(LOCALBA_OCCUR_PER1-2) : imsNo) = CPBA;
disp(['Refine ' num2str((imsNo-1)-(LOCALBA_OCCUR_PER2-2)) '->' num2str(imsNo)])
CPBA = BundleAdjustment(CP((imsNo-1)-(LOCALBA_OCCUR_PER2-2) : imsNo),...
    IsolateTransitiveCorrs(CascadeTrack(...
    CcorrsNormInFil((imsNo-1)-(LOCALBA_OCCUR_PER2-2) : imsNo-1)), 'displaySize'));
CP((imsNo-1)-(LOCALBA_OCCUR_PER2-2) : imsNo) = CPBA;

%% Global Bundle Adjustment
disp('Global Bundle Adjustment')
C = CascadeTrack(CcorrsNormInFil);
CPBA = BundleAdjustment(CP,C);
X = TriangulateCascade(CPBA,C);

%% Dense Reconstruction