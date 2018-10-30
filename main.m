addpath(genpath(fileparts(which(mfilename))))

im1 = imread('blc01.jpg');
im2 = imread('blc02.jpg');
im3 = imread('blc03.jpg');
fp1 = EstimateFeaturePoints(im1);
fp2 = EstimateFeaturePoints(im2);
fp3 = EstimateFeaturePoints(im3);
mc12 = MatchFeaturePoints(fp1,fp2);

mc12n = [Dehomogenize(K\Homogenize(mc12(1:2,:))); 
    Dehomogenize(K\Homogenize(mc12(3:4,:)))];
mc23 = MatchFeaturePoints(fp2,fp3);
mc23n = [Dehomogenize(K\Homogenize(mc23(1:2,:))); 
    Dehomogenize(K\Homogenize(mc23(3:4,:)))]; 
%%
[E1,Cmc12nin] = RANSAC(num2cell(mc12n,1), @EstimateEssentialMatrix, ...
    5, @SampsonDistance, 1e-6);
mc12nin = cell2mat(Cmc12nin);
[E2,Cmc23nin] = RANSAC(num2cell(mc23n,1), @EstimateEssentialMatrix, ...
    5, @SampsonDistance, 1e-6);
mc23nin = cell2mat(Cmc23nin);
%% MINIM. EPIP. ERR.
E1 = OptimizeEssentialMatrix(E1, mc12nin(1:2,:), mc12nin(3:4,:));
E2 = OptimizeEssentialMatrix(E2, mc23nin(1:2,:), mc23nin(3:4,:));
%%
P1 = CANONICAL_POSE;
[P2,X12] = EstimateRealPoseAndTriangulate(E1,mc12nin(1:2,:),mc12nin(3:4,:),P1);
[P3,X23] = EstimateRealPoseAndTriangulate(E2,mc23nin(1:2,:),mc23nin(3:4,:),P2);