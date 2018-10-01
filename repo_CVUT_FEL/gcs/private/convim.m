function res=convim(im, msk, roi)
%
% CONVIM(im, msk)  convolution of an image and a centered mask,
%                  does not change the size of 'im'
% CONVIM(im, msk, roi)  performs on region of interest which is 
%			a list of coordinates, couple per row;
%			returns a list of results
%
% See also: SOBEL, GAUSSIAN, CORRIM, DECOMP, INNERB, OUTERB

% May 30, 1994: Radim Sara, CVL Prague
% roi added on January 21, 1995: Radim Sara, CVL Prague

if min(rem(size(msk), 2)) == 0
 error('Mask size must be odd');
end

sm = floor(size(msk)/2); % :size of mask

if nargin==3 % ___________ WITH ROI ____________
 if size(roi,2) ~= 2
  error('Bad ROI');
 end
 res = zeros(size(roi,1),1);	% :preallocate the vector
 msk = fliplr(flipud(msk)); 	% :because of convolution definition
 msk = msk(:)';
 for i = 1:size(roi,1)
  pos = roi(i,:);
  ul = pos - sm; 		% :upper left corner
  lr = pos + sm; 		% :lower right corner
  neighbourhood = im(ul(1):lr(1), ul(2):lr(2));
  res(i) = msk*neighbourhood(:); % :convolve with mask
 end
else % ______________ WITHOUT ROI ______________
%  res = conv2(double(im), msk);
%  res = res((sm(1)+1):size(im,1)+sm(1), (sm(2)+1):size(im,2)+sm(2));
 % in higher Matlab versions this is it:
 res = conv2(double(im),msk,'same');
end

