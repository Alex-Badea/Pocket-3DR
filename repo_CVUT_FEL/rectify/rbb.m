function [cmin, cmax, csz, corners1, corners2] = rbb( T, sz )
% RBB           Projected image bounding box.
%   [cmin cmax sz corners1 corners2] = rbb( T, IMG_SIZE )
%
% See also RCOORDPROJ

% (c) 2004-01-29, Martin Matousek
% Last change: $Date: 2006/06/07 08:28:56 $
%              $Revision: 1.3 $

corners1 = [ 1 sz(1) sz(1) 1      1;
            1 1     sz(2) sz(2)  1 ];

[c1 c2 t] = rcoordproj( T, corners1(1,:), corners1(2,:) );
% check if projective transformation keeps convex hull 
% (for T be homography) (Hartley2000,2nd, p.516/Cheirality)
% - same sign of t, no zero
t = sign( t );
if( any( t == 0 ) | ~ ( all( t == 1 ) | all( t == -1 ) ) )
  warning 'No bounding box, line in infty in convex hull.'
  
  cmin = [];
  cmax = [];
  csz = [];
  corners2 = [];
  return
end 

corners2 = [c1;c2];

cmin = floor( min( corners2, [], 2 ) );
cmax = ceil( max( corners2, [], 2 ) );
csz = [cmax - cmin + 1];

% TODO numeric problems (see ralign)
