function [D]=seeds2dmap(SEEDs,SIZ)
%dmap2seeds - converts the SEEDs structure into (sparse) disparity map
%
% [D]=seeds2dmap(SEEDs);
%
% SEEDs - structure of initial correspondences [xl,xr,yl] (nx3)
%   SIZ - size of the disparity map
%
%     D - (sparse) disparity map
%

D = repmat(NaN, SIZ);
D(sub2ind(SIZ,SEEDs(:,3),SEEDs(:,1))) = SEEDs(:,1)-SEEDs(:,2);