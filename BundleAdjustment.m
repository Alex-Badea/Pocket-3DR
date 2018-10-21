function [X, CP, repjErrs] = BundleAdjustment(CascadeMatches, X, CP)
%BUNDLEADJUSTMENT Summary of this function goes here
%   Detailed explanation goes here
% Consistency checks
if length(CP) ~= size(CascadeMatches,1)/2
    error('No. of camera poses differs from cascade track length')
end
if size(X,2) ~= size(CascadeMatches,2)
    error('No. of triangulated points differs from total no. of 2D points')
end
% Converting into MATLAB Bundle Adjustment format
xyzPoints = X';
pointTracks = pointTracksFromCascade(CascadeMatches);
cameraPoses = poseTableFromCell(CP);
cameraParams = cameraParameters('IntrinsicMatrix',eye(3));
% MATLAB Bundle Adjustment
[xyzRefinedPoints, refinedPoses, repjErrs] = ...
    bundleAdjustment(xyzPoints, pointTracks, cameraPoses, cameraParams, ...
    'FixedViewIDs', [1 2], 'AbsoluteTolerance', 1e-15, 'RelativeTolerance', 1e-20);
repjErrs = repjErrs';
% Reverting to proprietary format
X = xyzRefinedPoints';
CP = poseCellFromTable(refinedPoses);
end

function pt = pointTracksFromCascade(c)
Cc = mat2cell(c,size(c,1), ones(1,size(c,2)));
Cc = cellfun(@pointTrackFromCascade, Cc, 'UniformOutput', false);
pt = [Cc{:}];

function pt = pointTrackFromCascade(c)
c = reshape(c,2,[])';
pt = pointTrack(find(all(~isnan(c)')'), c(all(~isnan(c)')',:));
end
end

function TP = poseTableFromCell(CP)
ViewId = uint32((1:length(CP))');
Orientation = cellfun(@(P) P(1:3,1:3), CP, 'UniformOutput', false)';
Location = cellfun(@(P) (-P(1:3,1:3)'*P(1:3,4))', CP, 'UniformOutput', false)';
TP = table(ViewId, Orientation, Location);
end

function CP = poseCellFromTable(TP)
CR = (TP.Orientation)';
CC = (TP.Location)';
CP = cellfun(@(R,C) [R -R*C'], CR, CC, 'UniformOutput', false);
end