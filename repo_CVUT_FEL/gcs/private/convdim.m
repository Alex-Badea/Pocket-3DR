function imc = convdim(im, msk, dim)
%
% imc = convdim(im, msk, dim)
%  Convolves ND matrix im with a [k,1] (single-column) convolution
%  kernel msk(:) in a given direction dim.
%
% See also: DG, SIMDIFF, GAUSSDIF, DDIF

% (c) Radim Sara (sara@cmp.felk.cvut.cz), May 6, 1998

if sum(size(msk)>1)>1
 error 'Convolution kernel is not K x 1'
end

 % make sure the mask is a single column
msk=msk(:);

 % permute the dimensions to pull the dim to the columns
perm = [dim, ssub(1:ndims(im),dim)]; 
imc = permute(im,perm);
sz = size(imc);

 % make it a long 2-D array, columns will be convolved
imc = convim(reshape(imc,sz(1),prod(sz)/sz(1)),msk(:));

 % put the dimensions back in order
imc = ipermute(reshape(imc,sz),perm);

return

