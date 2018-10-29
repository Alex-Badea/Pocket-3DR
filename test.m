M = CascadeTrack({mc12nin,mc23nin});
commonInd = all(~isnan(M));
mc123nin = M(:,commonInd);

X1 = Triangulate(P1,P2,mc123nin(1:2,:),mc123nin(3:4,:));
X2 = Triangulate(P2,P3,mc123nin(3:4,:),mc123nin(5:6,:));

%% Translation adjustment
P3TO = OptimizeTranslationVector(P1,P2,P3,...
    mc123nin(1:2,:),mc123nin(3:4,:),mc123nin(5:6,:),'displayIter');

X2TO = Triangulate(P2,P3TO,mc123nin(3:4,:),mc123nin(5:6,:));

%% Pose adjustment
P3O = OptimizePose(P1,P2,P3TO,...
    mc123nin(1:2,:),mc123nin(3:4,:),mc123nin(5:6,:),'displayIter');

X2O = Triangulate(P2,P3O,mc123nin(3:4,:),mc123nin(5:6,:));

%%
figure('Name','Before any adjustment')
pcshow(X1',repmat([1 0 0]',1,size(X1,2))','MarkerSize',300),drawnow
hold on
pcshow(X2',repmat([0 1 0]',1,size(X2,2))','MarkerSize',150),drawnow
hold off

figure('Name','After translation adjustment')
pcshow(X1',repmat([1 0 0]',1,size(X1,2))','MarkerSize',300),drawnow
hold on
pcshow(X2TO',repmat([0 1 0]',1,size(X2TO,2))','MarkerSize',150),drawnow
hold off

figure('Name','After translation+pose adjustment')
pcshow(X1',repmat([1 0 0]',1,size(X1,2))','MarkerSize',300),drawnow
hold on
pcshow(X2O',repmat([0 1 0]',1,size(X2O,2))','MarkerSize',150),drawnow
hold off

CX = RectifyAndDenseTriangulate({im1,im2,im3}, {K'\E1/K,K'\E2/K}, ...
    {K*P1,K*P2,K*P3O});