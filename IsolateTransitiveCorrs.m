function [MIso] = IsolateTransitiveCorrs(M,displaySizeFlag)
%ISOLATETRANSITIVECORRS Summary of this function goes here
%   Detailed explanation goes here
MIso = M(:,all(~isnan(M)));
if exist('displaySizeFlag','var') && strcmp(displaySizeFlag,'displaySize')
    disp([num2str(size(MIso,2)) ' transitive corrs. found'])
end
end

