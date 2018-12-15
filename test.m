%% group 1
im1 = Cim{1};
im2 = Cim{2};
im3 = Cim{3};

fp1 = EstimateFeaturePoints(im1);
fp2 = EstimateFeaturePoints(im2);
fp3 = EstimateFeaturePoints(im3);

c12n = NormalizeCorrs(MatchFeaturePoints(fp1,fp2), K);
c23n = NormalizeCorrs(MatchFeaturePoints(fp2,fp3), K);

[E12, Cinliers] = RANSAC(num2cell(c12n,1),...
    @EstimateEssentialMatrix, 5, @SampsonDistance, 1e-5);
c12nin = cell2mat(Cinliers);
[E23, Cinliers] = RANSAC(num2cell(c23n,1),...
    @EstimateEssentialMatrix, 5, @SampsonDistance, 1e-5);
c23nin = cell2mat(Cinliers);

c12ninf = FilterBackgroundFromCorrs(CANONICAL_POSE,EstimateRealPose(E12,c12nin),...
    c12nin);
c23ninf = FilterBackgroundFromCorrs(CANONICAL_POSE,EstimateRealPose(E23,c23nin),...
    c23nin);

P11 = CANONICAL_POSE;
P12 = EstimateRealPose(E12,c12nin);
P13 = EstimateRealPose(E23,c23nin,P12);

P13 = OptimizeTranslationBaseline(P11,P12,P13,...
    IsolateTransitiveCorrs(CascadeTrack({c12ninf,c23ninf})));
P13 = MiniBundleAdjustment(P11,P12,P13,...
    IsolateTransitiveCorrs(CascadeTrack({c12ninf,c23ninf})));

%% group 2
im1 = Cim{3};
im2 = Cim{4};
im3 = Cim{5};

fp1 = EstimateFeaturePoints(im1);
fp2 = EstimateFeaturePoints(im2);
fp3 = EstimateFeaturePoints(im3);

c12n = NormalizeCorrs(MatchFeaturePoints(fp1,fp2), K);
c23n = NormalizeCorrs(MatchFeaturePoints(fp2,fp3), K);

[E12, Cinliers] = RANSAC(num2cell(c12n,1),...
    @EstimateEssentialMatrix, 5, @SampsonDistance, 1e-5);
c12nin = cell2mat(Cinliers);
[E23, Cinliers] = RANSAC(num2cell(c23n,1),...
    @EstimateEssentialMatrix, 5, @SampsonDistance, 1e-5);
c23nin = cell2mat(Cinliers);

c12ninf = FilterBackgroundFromCorrs(CANONICAL_POSE,EstimateRealPose(E12,c12nin),...
    c12nin);
c23ninf = FilterBackgroundFromCorrs(CANONICAL_POSE,EstimateRealPose(E23,c23nin),...
    c23nin);

P21 = CANONICAL_POSE;
P22 = EstimateRealPose(E12,c12nin);
P23 = EstimateRealPose(E23,c23nin,P22);

P23 = OptimizeTranslationBaseline(P21,P22,P23,...
    IsolateTransitiveCorrs(CascadeTrack({c12ninf,c23ninf})));
P23 = MiniBundleAdjustment(P21,P22,P23,...
    IsolateTransitiveCorrs(CascadeTrack({c12ninf,c23ninf})));

%% merge
X3 = Triangulate(P21,P22,c12ninf);
X4 = Triangulate(P22,P23,c23ninf);

PlotSparse({P21,P22,P23}, [X3 X4])
title('P21, P22, P23 before')

P21rec = [eye(3) P13(:,end)]*...
    HomogenizeMat([P13(1:3,1:3) P13(:,end)])*...
    HomogenizeMat([eye(3) -P13(:,end)])*...
    HomogenizeMat(P21);
P22rec = [P13(1:3,1:3) [0 0 0]']*HomogenizeMat(P22);
P23rec = [P13(1:3,1:3) [0 0 0]']*HomogenizeMat(P23);

X3 = Triangulate(P21rec,P22rec,c12ninf);
X4 = Triangulate(P22rec,P23rec,c23ninf);

PlotSparse({P21rec,P22rec,P23rec}, [X3 X4])
title('P21, P22, P23 recentered') 