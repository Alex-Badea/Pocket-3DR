function y = border(x, siz, value)
%
% imdst = BORDER(imsrc, [r,c], value)
%	adds floor(r/2) rows and floor(c/2) columns of value
%       'value' at image edges.
%	The result is of (size(imsrc,1)+r x size(imsrc,2)+c)
%
% See also: MIRROR, CUTOFF, REPEAT

% May 31, 1994: Radim Sara, CVL Prague
% revised June 8, 1999

siz = floor(siz/2);
[rows,cols] = size(x);

y = zeros(rows+2*siz(1), cols+2*siz(2));
y(:) = value;
y(1+siz(1):rows+siz(1), 1+siz(2):cols+siz(2)) = x;
