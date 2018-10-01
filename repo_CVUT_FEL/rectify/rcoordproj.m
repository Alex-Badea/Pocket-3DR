function [UU, VV, WW] = rcoordproj( T, U, V )
% RCOORDPROJ    2D-to-2D coordinates projection
%     [UU, VV] = RCOORDPROJ( T, U, V ) 
%         T .. one-directional 2D-to-2D transformation (e.g. homography).
%         U,V .. equally-sized matrices of coordinates.
%
%     If T is cell, i.e general one-directional 2D-to-2D transformation 
%     T = {fun, args..}, then
%                   [UU VV] = feval( H{1}, U, V, H{2:end} )
%     is called. 
%                   
%     [UU,VV] = RCOORDPROJ( T, [MINC IMG_SIZE] ) constructs U and V for
%     rectangular image area.
%
%     [UU, VV, WW] = ... also returns projective multiplyers (but UU, VV
%     are still euclidean)
%

% (c) 2004-01-29, Martin Matousek
% Last change: $Date: 2005/05/27 12:11:06 $
%              $Revision: 1.2 $

if( nargin == 2 )
  minc = U(:,1);
  sz = U(:,2);
  
  U = [1:sz(1)]' + minc(1) - 1;
  U = U( :, ones( 1, sz(2) ) );
  V = [1:sz(2)] + minc(2) - 1;
  V = V( ones( sz(1), 1 ), : );
end

if( iscell(T) )  
  [UU VV] = feval( T{1}, U, V, T{2:end} );
  WW = ones( size( UU ) );
else % homography  
  WW = ( T(3,1) * U + T(3,2) * V + T(3,3) );
  UU = ( T(1,1) * U + T(1,2) * V + T(1,3) ) ./ WW;
  VV = ( T(2,1) * U + T(2,2) * V + T(2,3) ) ./ WW;
end

