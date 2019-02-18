dataset = 'cpl';
method = 'AKAZE';

%im1 = imread([dataset '01.jpg']);
%im2 = imread([dataset '02.jpg']);
im1 = cell2mat(getfield(UndistortImages({imread([dataset '01.jpg'])},K,d),{1}));
im2 = cell2mat(getfield(UndistortImages({imread([dataset '02.jpg'])},K,d),{1}));

tic
fp1 = EstimateFeaturePoints(im1,method);
fp2 = EstimateFeaturePoints(im2,method);
TIMPX2 = toc;
cc12 = MatchFeaturePoints(fp1,fp2,'Approximate');
TOT = size(cc12,2);
n = 200;
VCONF = nan(1,n);
VABER = nan(1,n);
PCONF = nan(1,n);
parfor i = 1:n
    disp(['step ' num2str(i)])
    [~,Cin] = RANSAC(num2cell(cc12,1), @EstimateFundamentalMatrix, 8,...
        @SampsonDistance, 10);
    VCONF(i) = length(Cin);
    VABER(i) = TOT-VCONF(i);
    PCONF(i) = VCONF(i)/TOT*100;
end
fprintf('%s & $%d$ & $%.1f(\\pm%.1f)$ & $%.1f(\\pm%.1f)$ & $%.2f(\\pm%.2f)$ & $%.3f$ \\\\\n',...
    method,TOT,mean(VCONF),std(VCONF),mean(VABER),std(VABER),mean(PCONF),std(PCONF),TIMPX2);