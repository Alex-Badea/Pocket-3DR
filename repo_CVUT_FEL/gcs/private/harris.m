function f = harris(im,ngh,sig,k)
%
% f = harris(im)
%      Harris interest point detector.
%
% Detects local maxima of the operator L = det(K) - k*tr(A)/2, where K is
% the local autocovariance matrix estimate computed from image gradient and
% k is the Harris coefficient.
%
% The f is a non-maximum suppressed interest point map.
%
% f = harris(im,ngh,sig,k)
%      sets various parameters (empty matrix = default value)
%       ngh - neighborhood size over which the operator is computed
%             (default ngh=3)
%       sig - standard deviation of discrete gaussian used to compute
%             image derivatives (default sig=1)
%         k - Harris coefficient for the operator (default k=0.1).
 
% (c) Radim Sara (sara@cmp.felk.cvut.cz) FEE CTU Prague, 17 May 99
 
 if ~exist('ngh','var')
  ngh = []; 
 end
 if ~exist('sig','var')
  sig = [];
 end
 if ~exist('k','var')
  k = [];
 end
 
 if isempty(ngh)
  ngh = 3;
 end
 if isempty(sig)
  sig = 1;
 end
 if isempty(k)
  k = 0.1;
 end
 
 img = dg(im,[0 0], sig);
 ix = convim(img,ddif([1 0]));
 iy = convim(img,ddif([0 1]));
 
% ix = dg(im,[1 0],sig);
% iy = dg(im,[0 1],sig);

 ixxs = boxing(ix.^2, [ngh ngh]);
 iyys = boxing(iy.^2, [ngh ngh]);
 ixys = boxing(ix.*iy, [ngh ngh]);

 % Harris
 h = ixxs.*iyys - ixys.^2 - k*(ixxs+iyys).^2/4;
 detected = nonmaxsup(h,[ngh,ngh]);

 f = zeros(size(im));
 d = find(detected(:));
 f(d) = h(d);
return

