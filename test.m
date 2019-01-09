load('calib_AV_X2S_4MPIX.mat')

im1 = imread('mer01.jpg');
im2 = imread('mer02.jpg');
Cim = UndistortImages({im1,im2},K,d);
im1 = Cim{1};
im2 = Cim{2};

fp1 = EstimateFeaturePoints(im1);
fp2 = EstimateFeaturePoints(im2);

corrs12 = MatchFeaturePoints(fp1,fp2);

corrs12n = NormalizeCorrs(corrs12,K);
[E,Ccorrs12nin,~,g] = RANSAC(num2cell(corrs12n,1),...
    @EstimateFundamentalMatrix,8,@SampsonDistance,1e-6);
corrs12in = UnnormalizeCorrs(cell2mat(Ccorrs12nin),K);

PlotCorrespondences(im1,im2,corrs12,corrs12in);