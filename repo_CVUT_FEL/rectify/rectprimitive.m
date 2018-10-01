function [HH1, HH2, FF] = rectprimitive( F, sz1, sz2 )
% RECTPRIMITIVE Primitive rectification
%    [H1 H2 FR] = RECTPRIMITIVE( F, SZ1, SZ2 ) computes rectifying 
%    homographies using method described in [20.6.2002/1].
%
%    Input:
%      F        .. fundamental matrix between the first and the second image.
%      SZ1, SZ2 .. sizes of images.
%
%    Output: 
%      H1, H2   .. rectifying point homographies.
%      FR       .. fundamental matrix between rectified images,
%                  FR = inv(H2)'*F*inv(H1), 
%
%    For detailed variable specification and conventions see RECTIFY.
%
% See also RECTIFY, EP2INF.

% (c) 2004-04-07, Martin Matousek
% Last change: $Date: 2004/04/07 15:20:43 $
%              $Revision: 1.1 $

% Epipoles
e1 =  null( F );
e2 =  null( F' );

% Mapping the epipole to infinity ([15.5.2003/1])
[H1 G1 R1 T1] = ep2inf( e1, sz1 );
[H2 G2 R2 T2] = ep2inf( e2, sz2 );

% return if ep2inf not successful
if( isempty( H1 ) | isempty( H2 ) )
  HH1 = [];
  HH2 = [];
  FF = [];
  return;
end

% Correction of H1 to match H2

FF = inv(H2)'*F*inv(H1);
% now FF = [a 0 b; 0 0 0; c 0 d ];
% let find rot2 (tilt), such that b = c;

a = FF(1,1);
b = FF(1,3);
c = FF(3,1);
d = FF(3,3);

if(b > 0 )
  H = [ b 0 -a; 0 0 0; a 0 b ] ./ sqrt(a^2 + b^2 );
else
  H = [ -b 0 a; 0 0 0; -a 0 -b ] ./ sqrt(a^2 + b^2 );
end

H(2,2) = 1;

k = (a*d - b*c ) / (a^2 + b^2 );
H =  elemH( 'su', k ) * elemH( 'du', -(a*c + b*d)/(a*d -b*c) ) * H;

% mirroring detection / elimination (image is not mirrored but rotated)
if( k < 0 )
  H = elemH( 'sv', -1 ) * H;
end

HH1 = H * H1;
HH2 = H2;

FF = inv(HH2)'*F*inv(HH1);
