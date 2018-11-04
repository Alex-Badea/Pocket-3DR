function [MIso] = IsolateTransitiveCorrs(M)
%ISOLATETRANSITIVECORRS Summary of this function goes here
%   Detailed explanation goes here
MIso = M(:,all(~isnan(M)));
end

