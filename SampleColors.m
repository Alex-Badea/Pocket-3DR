function [C] = SampleColors(Tracks,Cim,K)
%PROBECOLORS Summary of this function goes here
%   Detailed explanation goes here
if ~exist('K','var')
    K = eye(3);
end
[~,i] = max(~isnan(Tracks));
c = [Tracks(logical(full(ind2vec(i,size(Tracks,1)))))';
    Tracks(logical(full(ind2vec(i+1,size(Tracks,1)))))'];
c = K*[c;ones(1,size(c,2))];
i = (i-1)/2+1;

C = bsxfun(@(x,y) permute(Cim{y}(fix(x(2)),fix(x(1)),:),[3 1 2]), c, i);
end

