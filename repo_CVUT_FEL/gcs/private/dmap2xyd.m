function [X]=dmap2xyd(D);
%converts disparity map to [u,v,d]-list format
%
% [X]=dmap2xyd(D);
%
% D...disprity map
% X...[u,v,d]-list
%

[u,v]=find(~isnan(D));
d=D(sub2ind(size(D),u,v));

X = [u,v,d];