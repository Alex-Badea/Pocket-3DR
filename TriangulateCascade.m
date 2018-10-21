function [X] = TriangulateCascade(CascadeMatches, CP)
%TRIANGULATECASCADE Summary of this function goes here
%   Detailed explanation goes here
if size(CascadeMatches,1)/2 ~= length(CP)
    error('No. of correspondences and no. of poses differ')
end

CrtM = CascadeMatches;
X = nan(3, size(CascadeMatches,2));
for i = 1:length(CP)-1
    ind = all(~isnan(CrtM(1:2,:)));
    NewUntriangulatedMatches = CrtM(1:4,ind);
    NewX = LinearTriangulation(CP{i}, CP{i+1},  ...
        NewUntriangulatedMatches(1:2,:), NewUntriangulatedMatches(3:4,:));
    idx = find(all(isnan(X)),1):find(all(isnan(X)),1)+size(NewX,2)-1;
    X(:,idx) = NewX;
    CrtM = CrtM(3:end, ~ind);
end
end

