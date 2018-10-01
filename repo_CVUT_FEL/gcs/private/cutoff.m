function y = cutoff(x, siz)
%
% CUTOFF(imsrc, [r,c])
%	cuts off floor(r/2) rows and floor(c/2) columns at image edges
%	the result is of (size(imsrc,1)-r x size(imsrc,2)-c)
%
% See also: MIRROR, REPEAT, BORDER

% May 31, 1994: Radim Sara, CVL Prague
% Modified for Matlab 5.2 May 4, 1998 R. Sara

siz = floor(siz/2);

if length(siz) == 2
 [rows,cols] = size(x);
 y = x(1+siz(1):rows-siz(1), 1+siz(2):cols-siz(2));
else
 [rows,cols,layers] = size(x);
 eval('y = x(1+siz(1):rows-siz(1), 1+siz(2):cols-siz(2), 1+siz(3):layers-siz(3));')
end
