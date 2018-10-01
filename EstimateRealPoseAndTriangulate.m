function [P, X] = EstimateRealPoseAndTriangulate(E, x1Calib, x2Calib, CoordSys)
%TRIANGULATEANDESTIMATEREALPOSE Summary of this function goes here
%   Detailed explanation goes here
if ~exist('CoordSys','var')
    CoordSys = CANONICAL_POSE;
end
CP = EstimateAmbiguousPose(E);
CP = cellfun(@(P) P*[CoordSys; 0 0 0 1], CP, 'UniformOutput', false);

X1 = LinearTriangulation(CoordSys, CP{1}, x1Calib, x2Calib);
X2 = LinearTriangulation(CoordSys, CP{2}, x1Calib, x2Calib);
X3 = LinearTriangulation(CoordSys, CP{3}, x1Calib, x2Calib);
X4 = LinearTriangulation(CoordSys, CP{4}, x1Calib, x2Calib);

[P, X] = DisambiguateCameraPose(CP, {X1, X2, X3, X4});
end

