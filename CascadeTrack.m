function [Map] = CascadeTrack(Cmatches, psorPrc, displaySizesFlag)
%CASCADETRACK Summary of this function goes here
%   psorPrc - Perspective Shift Occlusion Rate - chosen empirically
%   ...because the quality of a reseach project is directly proportional to
%   the number of fancy acronyms scattered throughout it.
if ~exist('psorPrc','var')
    psorPrc = 100;
end
wth = max(cellfun(@(M) size(M,2), Cmatches)) + ...
    fix(psorPrc/100*(length(Cmatches)-1)*...
    mean(cellfun(@(M) size(M,2), Cmatches)));
hth = 2*(length(Cmatches)+1);
Map = nan(hth,wth);
 
Map(1:4, 1:size(Cmatches{1},2)) = Cmatches{1};
for i = 2:length(Cmatches)
    m = Cmatches{i};
    [~,ind] = ismember(Map(2*i-1:2*i,:)', m(1:2,:)', 'rows');
    Map(2*i-1:2*i+2, ind~=0) = m(1:4, ind(ind~=0));
    [~,ind] = ismember(m(1:2,:)', Map(2*i-1:2*i,:)', 'rows');
    if sum(any(~isnan(Map)))+size(m(:,ind==0),2) > size(Map,2)
        error('Underallocation, PSOR too low')
    end
    Map(2*i-1:2*i+2, sum(any(~isnan(Map)))+1:sum(any(~isnan(Map)))+size(m(:,ind==0),2)) = ...
        m(:,ind==0);
end
 
% Remove trailing NaNs
Map = Map(:, ~all(isnan(Map)));
if exist('displaySizesFlag','var') && strcmp(displaySizesFlag,'displaySizes')
    disp(['Estimated width: ' num2str(wth)])
    disp(['Actual width: ' num2str(size(Map,2))])
end
end