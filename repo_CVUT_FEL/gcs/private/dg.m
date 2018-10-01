function [im,kers] = dg(im, order, sigma, msksize)
%
% [dim,kers] = DG(im {,order, sigma, msksize})
%       ND Discrete symmetric Gaussian image derivatives
%       im    - input image (of any dimension)
%       order - derivative order list, coordinates are in the order
%               row, column, ...; default value is zeros(1,ndims(im))
%       sigma - scale parameter in pixels of the Gaussian (standard deviation?),
%               default 1
%     msksize - size of the convolution kernel for sigma = 1, default 9
%               the kernel size used will be 1 + 2*floor(msksize*sigma/2)
%
%        kers - list of decomposed convolution kernels compontents,
%               one kernel per dimension
%
%  bw = dg({[], order, sigma, msksize})
%       returns the the width in pixels affected by boundary effect
%
% See also: SIMDIFF, GAUSSDIF, DDIF

% (c) Radim Sara, GRASP UPenn, May 8, 1997
% Modified for N-D images. R. Sara 5/7/98
% Modified for boundary width query R. Sara 12/10/98
% Returns convolution kernel R. Sara 4/12/2003
 
if nargin < 1, im = []; end
if nargin < 2, order = zeros(1,ndims(im)); end
if nargin < 3, sigma = 1; end
if nargin < 4, msksize = 9;  end

order=order(:);
if ndims(im) ~= length(order)
 error 'Derivative order list length must be equal to the dimension of the image'
end

kers = {};
ms = max(1, msksize*sigma/2);

x = [1:ms];
sm = exp(-sigma).*[fliplr(besseli(x,sigma)), besseli(0,sigma), ...
      besseli(x,sigma)];

sm = sm/sum(sm);  % for small kernels
[dd,ddl] = ddif(order);

if isempty(im)
 % return the boundary width
 im = length(sm);
 bw = [];
 return
end

ams = length(sm)*ones(1:ndims(im));
im = repeat(im,ams);
for d=1:ndims(im)
 kers{end+1} = conv(ddl{d},sm);
 im = convdim(im,kers{end},d);  
end

im = cutoff(im,ams);
return



switch ndims(im)
 
 case 2,
  dim = cutoff(convim(repeat( im,size(sm )), sm ), size(sm ));
  dim = cutoff(convim(repeat(dim,size(sm')), sm'), size(sm'));

  dd = ddif(order);
  dim = cutoff(convim(repeat(dim, size(dd)), dd), size(dd));  
  % :this is difference
  
 case 3,
  dim = repeat(im,length(sm)*[1 1 1]);
  dim = convdir(imd,sm,1);   
  dim = convdir(imd,sm,2);
  dim = convdir(imd,sm,3);
  [dd,ddl] = ddif(order);
  dim = convdir(imd,ddl{1},1);
  dim = convdir(imd,ddl{2},2);
  dim = convdir(imd,ddl{3},3);
 otherwise
  error 'Unsupported convolution kernel dimension'
end
