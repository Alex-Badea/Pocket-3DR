function nm = nonmaxsup(im, ngh)
%
% nm = NONMAXSUP(im, [r,c])
%
%       Non-maximum suppression on neigborhood r x c pixels.
%
% See also: NONMINSUP
 
% (c) Radim Sara (sara@cmp.felk.cvut.cz) FEE CTU Prague, 13 Dec 99

 if length(ngh) < 2
  ngh = [ngh,ngh];
 end
 
 nm = minkadd(minkadd(im,ones(1,ngh(2))),ones(ngh(1),1)) == im;
return
