function res = minkadd(im, mask, full)
%
% MINKADD(im, mask) morphological operation: Minkowski sum
%	MINKADD(im, ones(3,3)) is 8-connected dilation
%	MINKADD(im, mask, 'full') does not reduce the result matrix size
%
% note: mask elements are to be ones and/or zeros, mask is centered 
%
% See also: MINKSUB

% November 3, 1994: Radim Sara, CVL Prague

if min(isodd(size(mask))) == 0
 error('mask size must be odd');
end

sizm = fix(size(mask)/2);
rm = sizm(1);
cm = sizm(2);
[ri, ci] = size(im);
res = ones(ri+2*rm, ci+2*cm);
res(:) = min(min(im));

for dr = 1:size(mask,1)
 for dc = 1:size(mask,2)
  if mask(dr, dc) > 0
   res(dr:ri+dr-1, dc:ci+dc-1) = max(res(dr:ri+dr-1, dc:ci+dc-1), im);
  end
 end
end

if nargin < 3
 res = cutoff(res, size(mask));
end