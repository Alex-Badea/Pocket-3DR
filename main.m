addpath(genpath(fileparts(which(mfilename))))

im1 = imread('bst01.jpg');
im2 = imread('bst02.jpg');
im3 = imread('bst03.jpg');
kp1 = EstimateImageKeypoints(im1);
kp2 = EstimateImageKeypoints(im2);
kp3 = EstimateImageKeypoints(im3);
mc12 = EstimateKeypointCorrespondences(kp1,kp2);
mc12n = [Dehomogenize(K\Homogenize(mc12(1:2,:))); 
    Dehomogenize(K\Homogenize(mc12(3:4,:)))];
mc23 = EstimateKeypointCorrespondences(kp2,kp3);
mc23n = [Dehomogenize(K\Homogenize(mc23(1:2,:))); 
    Dehomogenize(K\Homogenize(mc23(3:4,:)))]; 
%%
[E1,Cmc12nin] = RANSAC(num2cell(mc12n,1), @EstimateEssentialMatrix, ...
    5, @SampsonDistance, 1e-5);
mc12nin = cell2mat(Cmc12nin);
[E2,Cmc23nin] = RANSAC(num2cell(mc23n,1), @EstimateEssentialMatrix, ...
    5, @SampsonDistance, 1e-5);
mc23nin = cell2mat(Cmc23nin);
%% MINIM. EPIP. ERR.
E1 = OptimizeEssentialMatrix(E1, mc12nin(1:2,:), mc12nin(3:4,:));
E2 = OptimizeEssentialMatrix(E2, mc23nin(1:2,:), mc23nin(3:4,:));
%%
P1 = CANONICAL_POSE;
[P2,X] = EstimateRealPoseAndTriangulate(E1,mc12nin(1:2,:),mc12nin(3:4,:),P1);
M = CascadeTrack({mc12nin, mc23nin});
commonInd = all(~isnan(M));
mc123nin = M(:,commonInd);
X = X(:,commonInd);
P3 = PnP(X,mc123nin(5:6,:));

x1 = Dehomogenize(K*Homogenize(mc123nin(1:2,:)));
x2 = Dehomogenize(K*Homogenize(mc123nin(5:6,:)));
PlotCorrespondences(im1,im3,x1,x2)
PlotSparse({P3},X)

mean(ReprojectionError(P3, num2cell([X;mc123nin(5:6,:)],1)))

X_ = LinearTriangulation(P2,P3,mc23nin(1:2,:),mc23nin(3:4,:));
mean(ReprojectionError(P3, num2cell([X_;mc23nin(3:4,:)],1)))

X2 = LinearTriangulation(P2,P3,mc123nin(3:4,:),mc123nin(5:6,:));

mean(sum((X-X2).^2))
%%
CX = RectifyAndDenseTriangulate({im1,im2,im3}, {K'\E1/K,K'\E2/K},...
    {K*P1,K*P2,K*P3});%, {'plotCorrespondences','plotDisparityMap'});
figure, pcshow(CX{1}')
figure, pcshow(CX{2}')
figure, pcshow([CX{1} CX{2}]')