i=1;

E1 = CE{i};
E2 = CE{i+1};

P1 = CP{i};
P2 = CP{i+1};
P3 = EstimateRealPose(E2, CcorrsNormInFil{i+1}, P2);
P3i = OptimizeTranslationBaseline(P1,P2,P3,IsolateTransitiveCorrs(CascadeTrack(CcorrsNormInFil(i:i+1))));
%P3i = MiniBundleAdjustment(P1,P2,P3i,IsolateTransitiveCorrs(CascadeTrack(CcorrsNormInFil(i:i+1))));
C1 = -P1(1:3,1:3)'*P1(:,end);
C2 = -P2(1:3,1:3)'*P2(:,end);
C3 = -P3(1:3,1:3)'*P3(:,end); 
C3i = -P3i(1:3,1:3)'*P3i(:,end);

C2C3 = C3-C2;
C2C3i = C3i-C2;
C2C3i./C2C3

X1 = Triangulate(P1,P2,CcorrsNormInFil{i});
X2 = Triangulate(P2,P3i,CcorrsNormInFil{i+1});
PlotSparse({P1,P2,P3,P3i},[X1 X2])
hold on, plot3(C3(1),C3(2),C3(3),'gx'),hold on,plot3(C2(1),C2(2),C2(3),'rx'),hold on;plot3(C3i(1),C3i(2),C3i(3),'bx')