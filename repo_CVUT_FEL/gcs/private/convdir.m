function im = convdir(im, msk, dir)
%
% imc = convdir(im, msk, dir)
%  2-D convolution in a direction in 3-D matrix
%  the direction is perpendicular to the layers that are to be convolved,
%  i.e.  dir convolved with
%      1  im(:,:,i)
%      3  im(i,:,:)
%
%      1  im(i,:,:)
%      2  im(:,i,:)
%      3  im(:,:,i)
%  under development

imc = zeros(size(im));
ms = size(msk);
switch dir
 case 1,
  for i=1:size(im,3) 
   imc(:,:,i) = convim(im(:,:,i), msk);
  end
  
% case 2,
%  for i=1:size(im,2)
%   imc(:,i,:) = convim(reshape(im(:,i,:), size(im,1), size(im,3)), msk);
%  end
 
 case 3,
  for i=1:size(im,1)
   imc(i,:,:) = convim(reshape(im(i,:,:), size(im,2), size(im,3)), msk);
  end
 
 otherwise
  error 'Wrong direction'
end
