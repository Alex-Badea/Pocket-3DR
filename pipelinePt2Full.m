if ~exist('K','var')
    error('K not found')
end

%% Compute correspondence map
imsDir = dir('ims/bst*.jpg');
imsNames = flip({imsDir.name});
imsNo = length(imsNames);
for i = 1:length(imsNames)
    Cim{i} = imread(imsNames{i});
end
if ~exist('CkeyPts','var') || ~exist('CmatchesCoords','var')
    CkeyPts{1} = EstimateImageKeypoints(Cim{1});
    for i = 2:length(Cim)
        CkeyPts{i} = EstimateImageKeypoints(Cim{i});
        CmatchesCoords{i-1,i} = EstimateKeypointCorrespondences(CkeyPts{i-1},CkeyPts{i}); 
    end
end

%% Direct Essential Matrix destimation
if ~exist('CE','var')
    load('OPTIMTHRESH_5PTALG')
    for i = 1:size(CmatchesCoords,1)
        x1 = CmatchesCoords{i,i+1}(1:2,:);
        x2 = CmatchesCoords{i,i+1}(3:4,:);
        x1Calib = Dehomogenize(K\Homogenize(x1));
        x2Calib = Dehomogenize(K\Homogenize(x2));
        [CE{i,i+1}, CxCalibIn] = RANSAC(num2cell([x1Calib; x2Calib],1), ...
            @EstimateEssentialMatrix, 5, @SampsonDistance, 1e-5);
        xCalibIn = cell2mat(CxCalibIn);
        Cx1CalibIn{i,i+1} = xCalibIn(1:2,:);
        Cx2CalibIn{i,i+1} = xCalibIn(3:4,:);
        CxIn{i,i+1} = [Dehomogenize(K*Homogenize(Cx1CalibIn{i,i+1}));
            Dehomogenize(K*Homogenize(Cx2CalibIn{i,i+1}))];
    end
end
%% Linear Succesionwise Camera Cluster
% A camera graph that bears the form of a single pathway passing through each
% camera in the system in the order of their succesion in time. Each pose
% is estimated from the current camera to the next and no more than two
% poses will be estimated from either of the two cameras.

LSCCMatches = CxIn(logical([zeros(imsNo-1,1) eye(imsNo-1)]))';

CP = {CANONICAL_POSE};
X = [];
M = CascadeTrack(LSCCMatches);
CrtM = M;

for i = 1:imsNo-1
    ind = all(~isnan(CrtM(1:2,:)));
    NewUntriangulatedMatches = CrtM(1:4,ind);
    [CP{i+1}, NewX] = EstimateRealPoseAndTriangulate(CE{i,i+1}, ...
        Dehomogenize(K\Homogenize(NewUntriangulatedMatches(1:2,:))), ...
        Dehomogenize(K\Homogenize(NewUntriangulatedMatches(3:4,:))), CP{i});
    X = [X NewX];
    CrtM = CrtM(3:end, ~ind);
end

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
disp(['Eroare �nainte de BA: ' num2str(vecnorm(ERRS)*vecnorm(ERRS)'/size(ERRS,2))]);
%PlotSparse(CP, X)

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
    figure('pos', [0 100 2600 300])
    histogram(D,fix(sum(sum(~isnan(D)))/(max(max(D)) - min(min(D)))))
    %figure('pos', [0 100 2600 300]), hist(D)
    lb = ginput(1);
    lb = lb(1);
    ub = ginput(1);
    ub = ub(1);
    hold on, plot([lb ub],[0 0],'rx','LineWidth',2), drawnow, hold off 
    D(D<lb | D>ub) = nan;
    mc12Rec = MatchesFromDisparity(D);
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