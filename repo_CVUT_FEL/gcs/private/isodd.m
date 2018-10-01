function odd = isodd(x)
% ISODD(x) returns matrix where ones correspond to odd elements in x
%	   zero is considered even

% October 29, 1994: Radim Sara, CVL Prague

odd = (x == fix(x)) & (x/2 ~= fix(x/2));