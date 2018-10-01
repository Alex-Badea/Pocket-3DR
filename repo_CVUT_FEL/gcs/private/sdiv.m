function d = sdiv(x,y,val)
%
% d = SDIV(x, y, val) gives 'safe' quotient:
% d = x ./ y  <=> y != 0
%   = val           otherwise
%
%     by default val = 0

% October 14, 1994: Radim Sara, CVL Prague
% revised March 21, 1996
% revised June 8, 1999

if nargin<3
 val = 0;
end

zero = abs(y) < realmin;
zero = zero(:);
y(zero) = 1;
d = x./y;
d(zero) = val;

return

%zero = abs(y) < realmin; 
%d = ((~zero) .* x) ./ (y + zero);

%if nargin>2
% d = d + zero.*val;
%end
