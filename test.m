tic
X12DN = FilterBackground(X12);
toc
figure,pcshow(X12DN','MarkerSize',120)
Z = X12DN(3,:);
figure('pos', [10 100 1350 300]),histogram(Z,2000)

figure,pcshow(X12','MarkerSize',120)
Z = X12(3,:);
figure('pos', [10 100 1350 300]),histogram(Z,2000)
