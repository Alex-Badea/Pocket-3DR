R = P3(1:3,1:3);
t = P3(:,end);

P3 = [R t];

CX = RectifyAndDenseTriangulate({im1,im2,im3}, {K'\E1/K,K'\E2/K},...
 {K*P1,K*P2,K*P3});%, {'plotCorrespondences','plotDisparityMap'});
figure, pcshow([CX{1} CX{2}]')