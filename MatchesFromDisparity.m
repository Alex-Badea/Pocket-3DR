function [ M ] = MatchesFromDisparity( D )
%MATCHESFROMDISPARITY Summary of this function goes here
%   Detailed explanation goes here
[r,c] = size(D);
M = zeros(r,c,4);
M(:,:,1) = repmat(1:c,r,1);
M(:,:,2) = repmat((1:r)',1,c);
M(:,:,3) = M(:,:,1) - D;
M(:,:,4) = M(:,:,2);
M = reshape(M,r*c,4)';
M = M(:,all(~isnan(M)));
end

