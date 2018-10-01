function [ H, G, R, T, nep] = ep2inf( e, sz )
% EP2INF        Homography mapping the epipole to infinity ([15.5.2003/1]).
%    [ H, G, R, T, newEP ] = EP2INF( EP, SIZE ) compute homography mapping 
%      the epipole to infinity [0;1;0] using the method described
%      in [15.5.2003/1].
%
%    Input:
%      EP       .. epipole.
%      SZ       .. size of the image.
%    
%    Output:
%      H        .. homography mapping the epipole to infinity,
%                  H * EP -> [0;1;0]. Composed as H = G*R*T, where
%                  T is shift, R is xy-rotation and G is projective.
%      newEP    .. mapped epipole, newEP = H * EP;
%
%    For detailed variable specification and conventions see RECTIFY.
%
% See also RECTIFY.

% (c) 2004-04-07, Martin Matousek
% Last change: $Date: 2004/04/07 15:20:43 $
%              $Revision: 1.1 $

% shift origin to image center
T = [ 1 0 -sz(1)/2; 0 1 -sz(2)/2; 0 0 1 ];

% shift the epipole, normalize 3rd coordinate
ep = T * e;

if( sign( ep(3) ) == -1 )
  ep = -ep;
end

% R:Rotation such that epipole is [e1;e2;e3] -> [0;f;e3] or [0;-f;e3]
% (up to scale), where f = sqrt(e1^2 + e2^2). The direction of rotation is
% determined by signum of ep(2)

% G:Translation of epipole to inf, direction is based on signum of ep(2)

f = sqrt( ep(1)^2 + ep(2)^2 );
F = ep(3) / f;
S = 1 - F^2*sz(2)^2 / 4;

if( ep(2) >= 0 )
  R = [ ep(2) -ep(1) 0; ep(1) ep(2) 0; 0 0 f ];  % epipole -> [0;f;e3]
  G = [ sqrt(S) 0 0; 0 S 0; 0 -F 1 ];
else
  R = [-ep(2) ep(1) 0;-ep(1) -ep(2) 0; 0 0 f ];  % epipole -> [0;-f;e3]
  G = [ sqrt(S) 0 0; 0 S 0; 0 F 1 ];
end
  
H = G*R*T;

nep = H * e;