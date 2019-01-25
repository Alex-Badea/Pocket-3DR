dataset = 'car';
method = 'FAST';
im1 = imread([dataset '01.jpg']);
im2 = imread([dataset '02.jpg']);
Cim = UndistortImages({im1,im2}, K, d);
im1 = Cim{1};
im2 = Cim{2};
tic
kp1 = EstimateFeaturePoints(im1,method);
kp2 = EstimateFeaturePoints(im2,method);
t=toc;
cc12 = MatchFeaturePoints(kp1,kp2);
cc12n = NormalizeCorrs(cc12,K);
n = 500;
in = nan(1,n);
cc12nin = cell(1,n);
parfor i = 1:n
    disp(['step ' num2str(i)]);
    [~, Cinliers] = RANSAC(num2cell(cc12n,1), @EstimateFundamentalMatrix, 8, @SampsonDistance, 1e-6);
    cc12nin{i} = cell2mat(Cinliers);
    in(i) = length(Cinliers);
end
tot = size(cc12n,2);
out = tot-in;
r = 100*in./tot;

%PlotCorrespondences(im1,im2,cc12n, cc12nin{1},K)
fprintf('%s & $%d$ & $%.1f(\\pm%.1f)$ & $%.1f(\\pm%.1f)$ & $%.3f(\\pm%.3f)$ & $%.3f$\n', method, tot, mean(in), sqrt(var(in)), mean(out), sqrt(var(out)), mean(r), sqrt(var(r)), t);