addpath(genpath(fileparts(which(mfilename))))

%% Program arguments
dataset = 'mer';
calib = 'calib_AV_X2S_4MPIX.mat';
drp = [...
    1 ...
    %fix(length(dir(['ims/' dataset '*.jpg']))/8)+1 ...
    %fix(2*length(dir(['ims/' dataset '*.jpg']))/8)+1 ...
    %fix(3*length(dir(['ims/' dataset '*.jpg']))/8)+1 ...
    %fix(4*length(dir(['ims/' dataset '*.jpg']))/8)+1 ...
    %fix(5*length(dir(['ims/' dataset '*.jpg']))/8)+1 ...
    %fix(6*length(dir(['ims/' dataset '*.jpg']))/8)+1 ...
    %fix(7*length(dir(['ims/' dataset '*.jpg']))/8)+1 ...
    ];
threads = 1;

%% Reading image dataset
disp(['Running pipeline for dataset "' dataset '"'])
imsDir = dir(['ims/' dataset '*.jpg']);
disp(['Dataset contains ' num2str(length(imsDir)) ' images'])
imsNames = {imsDir.name};
imsNo = length(imsNames);
Cim = cell(1,imsNo);
for i = 1:length(imsNames)
    Cim{i} = imread(imsNames{i});
end

load(calib)
disp('Calibration matrix: '), disp(K)
if exist('d','var')
    disp('Radial distortion parameters: '), disp(d)
    Cim = UndistortImages(Cim,K,d);
end
if threads ~= 1 && isempty(gcp('nocreate')), parpool(threads); end

%% Feature extraction and matching
CfeatPts = cell(1,imsNo);
for i = 1:imsNo
    disp(['Feature points estimation: image ' num2str(i) ' of ' num2str(imsNo)])
    CfeatPts{i} = EstimateFeaturePoints(Cim{i});
end

Ccorrs = cell(1,imsNo-1);
CfeatPtsPlusOne = CfeatPts(2:end);
parfor i = 1:imsNo-1
    disp(['Feature matching: pair ' num2str(i) ' of ' num2str(imsNo-1)])
    Ccorrs{i} = MatchFeaturePoints(CfeatPts{i}, CfeatPtsPlusOne{i});
end

%% Correspondence filtering
CcorrsIn = cell(1,imsNo-1);
CF = cell(1,imsNo-1);
parfor i = 1:imsNo-1
    disp(['Correspondence filtering: pair ' num2str(i) ' of ' num2str(imsNo-1)])
    [CF{i}, Cinliers] = RANSAC(num2cell(Ccorrs{i},1),...
        @EstimateFundamentalMatrix, 8, @SampsonDistance, 12);
    CcorrsIn{i} = cell2mat(Cinliers);
end

%% Fundamental Matrix estimation
parfor i = 1:imsNo-1
    disp(['Fundamental Matrix estimation: pair ' num2str(i) ' of ' num2str(imsNo-1)])
    CF(i) = EstimateFundamentalMatrix(num2cell(CcorrsIn{i},1));
end

%% Background Filtering
CcorrsInFil = cell(1,imsNo-1);
parfor i = 1:imsNo-1
    disp(['Background Filtering: pair ' num2str(i) ' of ' num2str(imsNo-1)])
    CcorrsInFil{i} = FilterBackgroundFromCorrs(K*CANONICAL_POSE,...
        K*EstimateRealPose(K'*CF{i}*K, NormalizeCorrs(CcorrsIn{i},K)), CcorrsIn{i});
    CF(i) = EstimateFundamentalMatrix(num2cell(CcorrsInFil{i},1));
end

%% Essential Matrix from Fundamental Matrix
CE = cell(1,imsNo-1);
CcorrsNormInFil = cell(1,imsNo-1);
for i = 1:imsNo-1
    disp(['Essential Matrix from Fundamental Matrix: '...
        num2str(i) ' of ' num2str(imsNo-1)])
    CE{i} = K'*CF{i}*K/norm(K'*CF{i}*K)*sqrt(2)/2;
    CcorrsNormInFil{i} = NormalizeCorrs(CcorrsInFil{i}, K);
end

%% Structure from Motion
disp('Pose estimation: default first pair')
CP = cell(1,imsNo);
CP{1} = CANONICAL_POSE; 
CP{2} = EstimateRealPose(CE{1}, CcorrsNormInFil{1});

LOCALBA_OCCUR_PER1 = 6;
LOCALBA_OCCUR_PER2 = 8;
for i = 2:imsNo-1
    disp(['Pose estimation: ' num2str(i+1) ' of ' num2str(imsNo)])
    CP{i+1} = EstimateRealPose(CE{i}, CcorrsNormInFil{i}, CP{i});
    TrackedCorrs = CascadeTrack({CcorrsNormInFil{i-1}, CcorrsNormInFil{i}});
    TrackedCorrsIso = IsolateTransitiveCorrs(TrackedCorrs);
    disp(['Transitivity: ' num2str(size(TrackedCorrsIso,2))])
    CP{i+1} = OptimizeTranslationBaseline(CP{i-1}, CP{i}, CP{i+1}, TrackedCorrsIso);
    
    if ~mod(i-1, LOCALBA_OCCUR_PER1-2)
        disp('Local Bundle Adjustment 1...')
        disp(['Refine ' num2str(i-(LOCALBA_OCCUR_PER1-2)) '->' num2str(i+1)])
        C = IsolateTransitiveCorrs(CascadeTrack(...
            CcorrsNormInFil(i-(LOCALBA_OCCUR_PER1-2) : i)), 'displaySize');
        if size(C,2) > 1
            CPBA = BundleAdjustment(CP(i-(LOCALBA_OCCUR_PER1-2) : i+1), C);
            CP(i-(LOCALBA_OCCUR_PER1-2) : i+1) = CPBA;
        end
    end
    if ~mod(i-1, LOCALBA_OCCUR_PER2-2)
        disp('Local Bundle Adjustment 2...')
        disp(['Refine ' num2str(i-(LOCALBA_OCCUR_PER2-2)) '->' num2str(i+1)])
        C = IsolateTransitiveCorrs(CascadeTrack(...
            CcorrsNormInFil(i-(LOCALBA_OCCUR_PER2-2) : i)), 'displaySize');
        if size(C,2) > 1
            CPBA = BundleAdjustment(CP(i-(LOCALBA_OCCUR_PER2-2) : i+1), C);
            CP(i-(LOCALBA_OCCUR_PER2-2) : i+1) = CPBA;
        end
    end
end

if imsNo > LOCALBA_OCCUR_PER1
    disp(['Refine ' num2str((imsNo-1)-(LOCALBA_OCCUR_PER1-2)) '->' num2str(imsNo)])
    C = IsolateTransitiveCorrs(CascadeTrack(...
        CcorrsNormInFil((imsNo-1)-(LOCALBA_OCCUR_PER1-2) : imsNo-1)), 'displaySize');
    if size(C,2) > 1
        CPBA = BundleAdjustment(CP((imsNo-1)-(LOCALBA_OCCUR_PER1-2) : imsNo), C);
        CP((imsNo-1)-(LOCALBA_OCCUR_PER1-2) : imsNo) = CPBA;
    end
end
if imsNo > LOCALBA_OCCUR_PER2
    disp(['Refine ' num2str((imsNo-1)-(LOCALBA_OCCUR_PER2-2)) '->' num2str(imsNo)])
    C = IsolateTransitiveCorrs(CascadeTrack(...
        CcorrsNormInFil((imsNo-1)-(LOCALBA_OCCUR_PER2-2) : imsNo-1)), 'displaySize');
    if size(C,2) > 1
        CPBA = BundleAdjustment(CP((imsNo-1)-(LOCALBA_OCCUR_PER2-2) : imsNo), C);
        CP((imsNo-1)-(LOCALBA_OCCUR_PER2-2) : imsNo) = CPBA;
    end
end

Tracks = CascadeTrack(CcorrsNormInFil);
X = TriangulateCascade(CP,Tracks);
C = SampleColors(Tracks,Cim,K);
MakePly([dataset '-sparse.ply'], X, [], C) 
PlotSparse(CP,X,C);

%% Dense Matching
CX = cell(1,length(drp));
CC = cell(1,length(drp));
CXSc = cell(1,length(drp));
CCSc = cell(1,length(drp));
% Parallel groundwork
CimDrp = Cim(drp);
CimDrpPlusOne = Cim(drp+1);
CcorrsNormInFilDrp = CcorrsNormInFil(drp);
CFDrp = CF(drp);
CPDrp = CP(drp);
CPDrpPlusOne = CP(drp+1);
for i = 1:length(drp)
    disp(['Dense Reconstruction: pair ' num2str(i) ' of ' num2str(length(drp))])
    zRange = ExtractZRange(CANONICAL_POSE, DehomogenizeMat(...
        HomogenizeMat(CPDrpPlusOne{i})/HomogenizeMat(CPDrp{i})),...
        CcorrsNormInFilDrp{i});
    [CX{i}, CC{i}, CXSc{i}, CCSc{i}] = RectifyAndDenseTriangulate(CropBackground(...
        CimDrp{i},Unnormalize(CcorrsNormInFilDrp{i}(1:2,:),K),1.1),...
        CropBackground(CimDrpPlusOne{i},Unnormalize(CcorrsNormInFilDrp{i}(3:4,:),...
        K),1.1), CFDrp{i}, K, CPDrp{i}, CPDrpPlusOne{i}, zRange);
end

MakePly([dataset '-dense.ply'], cell2mat(CX), [], cell2mat(CC)) 
PlotDense(cell2mat(CX),cell2mat(CC))

%% Remeshing
CXFil = cell(1,length(drp));
CCFil = cell(1,length(drp));
CNFil = cell(1,length(drp));
for i = 1:length(drp)
    disp(['Computing normals: set ' num2str(i) ' of ' num2str(length(drp))])
    [CNFil{i}, filInd] = ComputeNormalsAndFilter(CXSc{i});
    CXFil{i} = CX{i}(:,filInd);
    CCFil{i} = CC{i}(:,filInd);
end

disp('Remeshing')
RemeshToPly([dataset '-colored.ply'],...
    cell2mat(CXFil), cell2mat(CNFil), cell2mat(CCFil))

%% Retexturing
% TODO