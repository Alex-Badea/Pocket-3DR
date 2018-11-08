function [P, X] = EstimateRealPose(E, x1Calib, x2Calib, CoordSys)
%ESTIMATEREALPOSE Summary of this function goes here
%   Detailed explanation goes here
if ~exist('CoordSys','var')
    CoordSys = CANONICAL_POSE;
end
CP = EstimateAmbiguousPose(E);

X1 = Triangulate(CANONICAL_POSE, CP{1}, x1Calib, x2Calib);
X2 = Triangulate(CANONICAL_POSE, CP{2}, x1Calib, x2Calib);
X3 = Triangulate(CANONICAL_POSE, CP{3}, x1Calib, x2Calib);
X4 = Triangulate(CANONICAL_POSE, CP{4}, x1Calib, x2Calib);

[P, X] = DisambiguateCameraPose(CP, {X1, X2, X3, X4});
P = P*[CoordSys; 0 0 0 1];
end

