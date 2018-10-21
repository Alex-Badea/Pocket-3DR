addpath(genpath(fileparts(which(mfilename))))

im1 = imread('bst01.jpg');
im2 = imread('bst02.jpg');
im3 = imread('bst03.jpg');
kp1 = EstimateImageKeypoints(im1);
kp2 = EstimateImageKeypoints(im2);
kp3 = EstimateImageKeypoints(im3);
mc12 = EstimateKeypointCorrespondences(kp1,kp2);
mc23 = EstimateKeypointCorrespondences(kp2,kp3);

mc12n = [Dehomogenize(K\Homogenize(mc12(1:2,:))); 
    Dehomogenize(K\Homogenize(mc12(3:4,:)))];
[E1,Cmc12nin] = RANSAC(num2cell(mc12n,1), @EstimateEssentialMatrix, ...
    5, @SampsonDistance, 1e-5);
mc12nin = cell2mat(Cmc12nin);
mc12in = [Dehomogenize(K*Homogenize(mc12nin(1:2,:)));
    Dehomogenize(K*Homogenize(mc12nin(3:4,:)))];
Cmc12in = num2cell(mc12in,1);
disp(['Eroare rap. la adev. crt. INAINTE: ' num2str(sum(SummedEpipolarDistance(...
    K'\E1/K, Cmc12in))/length(Cmc12in))])

mc23n = [Dehomogenize(K\Homogenize(mc23(1:2,:))); 
    Dehomogenize(K\Homogenize(mc23(3:4,:)))]; 
[E2,Cmc23nin] = RANSAC(num2cell(mc23n,1), @EstimateEssentialMatrix, ...
    5, @SampsonDistance, 1e-5);
mc23nin = cell2mat(Cmc23nin);
mc23in = [Dehomogenize(K*Homogenize(mc23nin(1:2,:)));
    Dehomogenize(K*Homogenize(mc23nin(3:4,:)))];
Cmc23in = num2cell(mc23in,1);
disp(['Eroare rap. la adev. crt. INAINTE: ' num2str(sum(SummedEpipolarDistance(...
    K'\E2/K, Cmc23in))/length(Cmc23in))])
%% MINIM. EPIP. ERR.
E1 = OptimizeEssentialMatrix(E1, mc12nin(1:2,:), mc12nin(3:4,:),...
    @SummedEpipolarDistance);
E2 = OptimizeEssentialMatrix(E2, mc23nin(1:2,:), mc23nin(3:4,:),...
    @SummedEpipolarDistance);
%%
mc12in = [Dehomogenize(K*Homogenize(mc12nin(1:2,:))); 
    Dehomogenize(K*Homogenize(mc12nin(3:4,:)))];
Cmc12in = num2cell(mc12in,1);
disp(['Eroare rap. la adev. crt.: ' num2str(sum(SummedEpipolarDistance(...
    K'\E1/K, Cmc12in))/length(Cmc12in))])

mc23in = [Dehomogenize(K*Homogenize(mc23nin(1:2,:))); 
    Dehomogenize(K*Homogenize(mc23nin(3:4,:)))];
Cmc23in = num2cell(mc23in,1);
disp(['Eroare rap. la adev. crt.: ' num2str(sum(SummedEpipolarDistance(...
    K'\E2/K, Cmc23in))/length(Cmc23in))])
%%
P1 = CANONICAL_POSE;
P2 = EstimateRealPoseAndTriangulate(E1,mc12nin(1:2,:),mc12nin(3:4,:), P1);
P3 = EstimateRealPoseAndTriangulate(E2,mc23nin(1:2,:),mc23nin(3:4,:), P2);
%% BA
M = CascadeTrack({mc12nin, mc23nin});
X = TriangulateCascade(M, {P1,P2,P3});
[~, CP, repjErrs] = BundleAdjustment(M, X, {P1,P2,P3});
P1 = CP{1};
P2 = CP{2};
P3 = CP{3};
%%
CX = RectifyAndDenseTriangulate({im1,im2,im3}, {K'\E1/K,K'\E2/K},...
 {K*P1,K*P2,K*P3});%, {'plotCorrespondences','plotDisparityMap'});
figure, pcshow(CX{1}')
figure, pcshow(CX{2}')
figure, pcshow([CX{1} CX{2}]')