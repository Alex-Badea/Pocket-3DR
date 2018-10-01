function [H1, H2] = rpairalign( aH1, aH2, sz1, sz2, crop )
% RPAIRALIGN        Align (rectifying) homographies.
%   [H1 H2] = RPAIRALIGN( aH1, aH2, size1, size2, crop ) 'shifts'
%   the two homographies such that the image areas (from [1,1] to size or
%   epipolarly corresponding sub-parts) are projected to the positive
%   coordinates as near to [1,1] as possible. I.e., the bounding boxes
%   (RPAIRBB) are from [1,1].
%
%   Note: the shift in the first (u) coordinate is simultaneous, the shift in
%   the second  (v) coordinate is different for each H (i.e. rectification
%   condition holds).
%
%   See also RPAIRBB.

% (c) 2005-05-26, Martin Matousek
% Last change: $Date: 2005/06/23 10:43:02 $
%              $Revision: 1.2 $

[cmin1, cmax1, csz1, corners11, corners12, ...
 cmin2, cmax2, csz2, corners21, corners22] = ...
    rpairbb( aH1, aH2, sz1, sz2, crop);


if( isempty( cmin1 ) )
  H1 = [];
  H2 = [];
  return;
end

du = - cmin1(1) + 1;
dv1 = - cmin1(2) + 1;
dv2 = - cmin2(2) + 1;

H1 = [ 1 0 du; 0 1 dv1; 0 0 1 ] * aH1;
H2 = [ 1 0 du; 0 1 dv2; 0 0 1 ] * aH2;

[cmin1, cmax1, csz1, corners11, corners12, ...
 cmin2, cmax2, csz2, corners21, corners22] = ...
    rpairbb( H1, H2, sz1, sz2, crop);

if( cmin1(1) ~= 1 | cmin1(2) ~= 1 | cmin2(1) ~= 1 | cmin2(2) ~= 1 )
  warning( [ 'rpairalign failed due to numeric inaccuracy ' ...
             '(flooring/ceiling in rpairbb). Trying second pass.' ] );
  
  du = - cmin1(1) + 1;
  dv1 = - cmin1(2) + 1;
  dv2 = - cmin2(2) + 1;
  
  H1 = [ 1 0 du; 0 1 dv1; 0 0 1 ] * H1;
  H2 = [ 1 0 du; 0 1 dv2; 0 0 1 ] * H2;
  
  [cmin1, cmax1, csz1, corners11, corners12, ...
   cmin2, cmax2, csz2, corners21, corners22] = ...
      rpairbb( aH1, aH2, sz1, sz2, crop);

  if( cmin1(1) ~= 1 | cmin1(2) ~= 1 | cmin2(1) ~= 1 | cmin2(2) ~= 1 )
    error( [ 'rpairalign (second pass) failed due to numeric inaccuracy ' ...
               '(flooring/ceiling in rpairbb).' ] );
  end
end
