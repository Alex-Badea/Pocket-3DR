function [cmin1, cmax1, csz1, corners11, corners12, ...
          cmin2, cmax2, csz2, corners21, corners22 ] = ...
    rpairbb( T1, T2, sz1, sz2, crop )
% RPAIRBB       Bounding box of two projected corresponding images.
%
%   [cmin1, cmax1, csz1, corners11, corners12, ...
%    cmin2, cmax2, csz2, corners21, corners22 ] = ...
%       rpairbb( T1, T2, sz1, sz2, [ crop_to_common | [min max] ] )
%
%   Note: cmin1(1) = cmin2(1), cmax1(1) = cmax2(1)
%
% See also RBB

% (c) 2005-05-25, Martin Matousek
% Last change: $Date: 2005/06/23 10:44:29 $
%              $Revision: 1.2 $

[cmin1, cmax1, csz1, corners11, corners12] = rbb( T1, sz1 );
[cmin2, cmax2, csz2, corners21, corners22] = rbb( T2, sz2 );

if( isempty( cmin1 ) | isempty( cmin2 ) )
  cmin1 = [];
  cmin2 = [];
  return
end
  
if( nargin < 5 ), crop = 0; end

if( any( crop ) )
  if( length( crop ) == 2 )
    umin = crop( 1 );
    umax = crop( 2 );
  else
    umin = max( cmin1(1), cmin2(1) );
    umax = min( cmax1(1), cmax2(1) );
  end
  
  if( umin >= umax ) % no overlapping lines
    [ cmin1, cmax1, csz1, cmin2, cmax2, csz2 ] = deal( [] );
    return;
  else
    corners12 = crop_convex_polygon( corners12, umin, umax );
    corners22 = crop_convex_polygon( corners22, umin, umax );
  end
else
  umin = min( cmin1(1), cmin2(1) );
  umax = max( cmax1(1), cmax2(1) );
end

% set bounding box according to boundary polygons
cmin1 = [ umin; floor( min( corners12(2,:) ) ) ];
cmin2 = [ umin; floor( min( corners22(2,:) ) ) ];

cmax1 = [ umax; floor( max( corners12(2,:) ) ) ];
cmax2 = [ umax; floor( max( corners22(2,:) ) ) ];

csz1 = [cmax1 - cmin1 + 1];
csz2 = [cmax2 - cmin2 + 1];
