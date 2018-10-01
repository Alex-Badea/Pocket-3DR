function y = repeat(x, siz)
%
% imdst = REPEAT(imsrc, [r,c])
%	repeats floor(r/2) rows and floor(c/2) columns at image edges
%	the result is of (size(imsrc,1)+r x size(imsrc,2)+c)
%
% See also: MIRROR, CUTOFF, BORDER

% May 31, 1994: Radim Sara, CVL Prague
% corrected February 9, 1995 R. Sara
% updated for Matlab 5.2 May 4, 1998 R. Sara

siz = floor(siz/2);
if length(siz) == 2
 [rows,cols] = size(x);

 y = x(:,[ones(1,siz(2)), 1:cols, cols*ones(1,siz(2))]);
 y = y([ones(siz(1),1); (1:rows)'; rows*ones(siz(1),1)],:);
else
 [rows,cols,layers] = size(x);
 
 eval('y = x(:,:,[ones(1,siz(3)), 1:layers, layers*ones(1,siz(3))]);');
 eval('y = y(:,[ones(1,siz(2)),1:cols,cols*ones(1,siz(2))],:);');
 eval('y = y([ones(siz(1),1); (1:rows)''; rows*ones(siz(1),1)],:,:);');
end

return
