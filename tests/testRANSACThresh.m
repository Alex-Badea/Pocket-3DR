dataset = 'mer';
minThresh = 2/norm(K)^2;
maxThresh = 50/norm(K)^2;
steps = 25;
tries = 100;

%im1 = imread([dataset '01.jpg']);
%im2 = imread([dataset '02.jpg']);
im1 = cell2mat(getfield(UndistortImages({imread([dataset '01.jpg'])},K,d),{1}));
im2 = cell2mat(getfield(UndistortImages({imread([dataset '02.jpg'])},K,d),{1}));

fp1 = EstimateFeaturePoints(im1);
fp2 = EstimateFeaturePoints(im2);
cc12 = NormalizeCorrs(MatchFeaturePoints(fp1,fp2,'Exhaustive'),K);
s = size(cc12,2);
t = SmootherLogspace(minThresh,maxThresh,steps,0.2);
C = cell(1,steps);
T = cell(1,steps);
for i = 1:steps
    disp(['step ' num2str(i)])
    res = nan(1,tries);
    time = nan(1,tries);
    curT = t(i);
    parfor j = 1:tries
        tic
        [~,Cin] = RANSAC(num2cell(cc12,1), @EstimateEssentialMatrix, 5,...
            @SampsonDistance, curT);
        time(j) = toc;
        res(j) = length(Cin);
    end
    C{i} = res;
    T{i} = time;
end
p = 10;
n = cell2mat(cellfun(@(x) mean(x),C,'UniformOutput',false));
e = cell2mat(cellfun(@(x) std(x),C,'UniformOutput',false));
figure,errorbar(t*norm(K)^2,n,e)
hold on
xl = xlim;
yl = ylim;
plot([xl(1) xl(2)],[s s],'--')
xl = xlim;
yl = ylim;
plot([p p],[yl(1) yl(2)],'k-')
%ylim(yl(1:2))
hold off
xlabel('Prag')
ylabel('Coresponden?e conforme')
legend({'Coresponden?e g?site de RANSAC','Nr. maxim de coresponden?e','Prag optim'},...
    'Location','southeast')
n_ = cell2mat(cellfun(@(x) mean(x),T,'UniformOutput',false));
e_ = cell2mat(cellfun(@(x) std(x),T,'UniformOutput',false));
figure,errorbar(t*norm(K)^2,n_,e_)