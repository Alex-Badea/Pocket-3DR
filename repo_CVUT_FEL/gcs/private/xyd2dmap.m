function [D]=xyd2dmap(X,SIZ);
%converts xyd-list to disparity map
%
% [D]=xyd2dmap(X,SIZ);
%
% D...disprity map
% X...[u,v,d]-list
% SIZ..size of the disparity map
% 
%


D = repmat(NaN,SIZ);
ind=sub2ind(SIZ,X(:,1),X(:,2));
D(ind)=X(:,3);
