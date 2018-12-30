c = UnnormalizeCorrs(CcorrsNormInFil{1}, K);

[CX1, CC1] = RectifyAndDenseTriangulate(...
    {CropBackground(Cim{1},c(1:2,:),1.1), CropBackground(Cim{2},c(3:4,:),1.1)},...
    {K'\CEO{1}/K}, {K*CP{1}, K*CP{2}}, {'plotCorrespondences','plotDisparityMap'});

PlotDense([CX1{1}], [CC1{1}])
