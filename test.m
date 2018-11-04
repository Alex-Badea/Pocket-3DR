im1 = imread('csk16.jpg');
im2 = imread('csk17.jpg');
fp1 = EstimateFeaturePoints(im1);
fp2 = EstimateFeaturePoints(im2);
C12 = MatchFeaturePoints(fp1,fp2);
C12n = NormalizeCorrs(C12,K);

X = Triangulate(CP{16},CP{17},C12n(1:2,:),C12n(3:4,:));
figure,pcshow(X','MarkerSize',80),axis([-10 10 -10 10 0 20])
