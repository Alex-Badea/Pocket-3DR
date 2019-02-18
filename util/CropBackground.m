function [im] = CropBackground(im, foregroundPts, overcropFactor)
%CROPBACKGROUND Summary of this function goes here
%   Detailed explanation goes here
hullInd = convhull(foregroundPts(1,:), foregroundPts(2,:));
hull = foregroundPts(:,hullInd);
if exist('overcropFactor','var')
    hull = (hull-mean(hull,2))*overcropFactor+mean(hull,2);
end
rp = roipoly(im, hull(1,:), hull(2,:));
im(repmat(~rp,1,1,3)) = 0;
end

