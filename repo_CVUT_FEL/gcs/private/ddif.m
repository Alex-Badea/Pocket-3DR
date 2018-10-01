function [kernel, kernelL] = ddif(order)
%
% [kernel, kernelList] = DDIF([orderR, orderC, ...])
%   Symmetric (steerable) discrete difference kernels for convolution
%   Can be used for any dimension. Creates one kernel per dimension,
%   kernels for odd dimensions are columns, kernels for even dimensions
%   are rows. 
%
%   kernel     - the aggregate kernel of dimension 
%                length([orderR, orderC, ...])
%   kernelList - kernels for individual dimensions, a Matlab5 list.
%
% See also: GAUSSDIF, SIMDIFF, DG

% Matlab 5.2 syntax
% (c) Radim Sara, GRASP UPenn, May 8, 1997
%  Modified for any dimension, 6/5/98, R. Sara

if nargin < 2
 Dx1 = [1 -1]';  % they become flipped in the convolution
 Dy1 = [1 -1];
else
 Dx1 = flipud(dx(:));
 Dy1 = Dx1';
end

for dim=1:length(order)
 n = order(dim);

  % construct the kernel in direction dim
 kernelx = 1;
 for i=1:n
  kernelx = conv(kernelx,Dx1)/2;
 end
  % make it even number of taps
 if mod(n,2) == 1
  kernelx = [kernelx; 0] + [0; kernelx];
 end
 
 if mod(dim,2) == 0
  kernelL{dim} = kernelx';
 else
  kernelL{dim} = kernelx;
 end
end

% kernelL is a list of row kernels, one per dimension

% make the aggregate convolution kernel
kernel = kernelL{1};
for i = 2:length(order)
 k = kernelL{i};
 kl = {};
 for j=1:length(k)
  kl{j} = kernel*k(j);
 end
 kernel = cat(i,kl{:});
end

return


%----------- old 2-D version -----------------

 % construct the kernel in y-direction
kernely = 1;
for i=1:ny
 kernely = conv2(kernely,Dy1)/2;
end
if mod(ny,2) == 1
 kernely = [kernely, 0] + [0, kernely];
end
kernelL{2} = kernely;

kernel = conv2(kernelx,kernely);

if 0 % makeItRectangular
 if size(kernel,1) < size(kernel,2)
  kernel = ones(fliplr(size(kernel)))*kernel;
 elseif size(kernel,1) > size(kernel,2)
  kernel = kernel*ones(fliplr(size(kernel)));
 end
end

return

nx = order(1);
ny = order(2);

if nargin < 2
 Dx1 = [1 -1]';  % they become flipped in the convolution
 Dy1 = [1 -1];
else
 Dx1 = flipud(dx(:));
 Dy1 = Dx1';
end

kernel = 1;
for i=1:nx
 kernel = conv(kernel,Dx1)/2;
end
if mod(nx,2) == 1
 kernel = [kernel; 0] + [0; kernel];
end

for i=1:ny
 kernel = conv2(kernel,Dy1)/2;
end
if mod(ny,2) == 1
 kernel = [kernel zeros(size(kernel,1),1)] + [zeros(size(kernel,1),1) kernel];
end

if size(kernel,1) < size(kernel,2)
 kernel = ones(fliplr(size(kernel)))*kernel;
elseif size(kernel,1) > size(kernel,2)
 kernel = kernel*ones(fliplr(size(kernel)));
end
