function dif = ssub(s1, s2)
%
% dif = SSUB(s1, s2)
%      integer sets difference dif = s1 - s2

% (c) Radim Sara, GRASP UPenn, March 29, 1996

if isempty(s2)
 dif = s1;
 return
end

s1 = s1(:);
s2 = s2(:);
super = zeros(1,max([s1; s2]));

super(s1) = ones(size(s1));
super(s2) = zeros(size(s2));
dif = find(super);