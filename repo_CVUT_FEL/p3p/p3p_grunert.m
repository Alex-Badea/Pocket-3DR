function X = p3p_grunert( Xw, U )
%P3P_GRUNERT  Three point perspective pose estim. problem - Grunert 1841.
%
%   Xc = P3P_GRUNERT( Xw, u )
%     or
%   Xc = P3P_GRUNERT( [d23 d13 d12], u ) solves calibrated three point 
%     perspective pose estimation problem by direct algorithm of Grunnert
%     [Grunert-1841], as reviewed in [Haralick-IJCV1994].
%
%   Input:
%     Xw .. three 3D points (columns) in any coordinate frame,
%       or
%     [d23 d13 d12] .. the distances between the 3D points, dij = ||Xi-Xj||,
%     
%     u .. the three point projections (image points, columns).
%
%   Output:
%     Xc .. cell matrix, each entry containts the three 3D points in
%     camera coordinate frame (columns). At most four solutions
%
%   Note. For multiple real roots this algorithm does not find all solutions.

% (c) 2007-07-31, Martin Matousek
% Last change: $Date:: 2008-07-21 11:46:23 +0200 #$
%              $Revision: 12 $

X = {};
homog = size( U, 1 ) == 3;

% input preparation
if( numel( Xw ) == 3 )  % [a,b,c]
  a = Xw(1);
  b = Xw(2);
  c = Xw(3);
else  % Xw
  if( size( Xw, 1 ) == 4 )
    homog = true;
    Xw = p2e( Xw );
  end
  a = vlen( Xw(:,2) - Xw(:,3 ) );
  b = vlen( Xw(:,1) - Xw(:,3 ) );
  c = vlen( Xw(:,1) - Xw(:,2 ) );
end

if( any( [a b c] == 0 ) )
  warning( 'VW:grunertnotunique', 'There are no three unique points' );
  return;
end

if( size( U, 1 ) == 2 ), U = e2p( U ); end
% U is now homogeneous

% ray vectors j1, j2, j3 - length is 1
Ur = vnz( U );

% the angles
ca = Ur(:,2)' * Ur(:,3);
cb = Ur(:,1)' * Ur(:,3);
cg = Ur(:,1)' * Ur(:,2);

aa = a^2; bb = b^2; cc = c^2;

% roots of fourth order polynomial, eq. (9)

caca = ca^2; cbcb = cb^2; cgcg = cg^2;

q1 = ( aa - cc ) / bb;
q2 = ( aa + cc ) / bb;
q3 = ( bb - cc ) / bb;
q4 = ( bb - aa ) / bb;

A(5-4) = (q1-1 )^2 - 4*cc*caca/bb;
A(5-3) = 4*( q1*(1-q1)*cb - (1-q2)*ca*cg + 2*cc*caca*cb/bb );
A(5-2) = 2*( q1^2 - 1 + 2*q1^2*cbcb + 2*q3*caca - 4*q2*ca*cb*cg + 2*q4*cgcg );
A(5-1) = 4*( -q1*(1+q1)*cb + 2*aa*cgcg*cb/bb - (1-q2)*ca*cg );
A(5-0) = (1+q1)^2 - 4*aa*cgcg/bb;

v = roots( A );

% chose only real roots
% TODO - numerics
v = real( v( abs( imag( v ) ) < 1e-6 * abs( real( v ) ) ) );

% substitution for u to eq. (8), for s1 to eq. (5) and for s2, s3 to eq. (4)
u = ( (q1-1)*v.^2 - 2*q1*cb*v + 1 + q1 ) ./ ( 2*(cg-v*ca) );
s1 = sqrt( eq5right( aa, bb, cc, ca, cb, cg, u, v ) );

s1 = s1(:,1);


s2 = u .* s1;
s3 = v .* s1;

X ={};
if( homog )
  for i=1:size(s1,1)
    X{i} = ...
        e2p( Ur .* [s1(i) s2(i) s3(i); s1(i) s2(i) s3(i); s1(i) s2(i) s3(i)] );
  end
else
  for i=1:size(s1,1)
    X{i} = Ur .* [s1(i) s2(i) s3(i); s1(i) s2(i) s3(i); s1(i) s2(i) s3(i)];
  end
end

% ==============================================================================

function q = eq5right( aa, bb, cc, ca, cb, cg, u, v )


q = [ aa./(u.^2+v.^2-2*u.*v*ca) ...
      bb./(1+v.^2-2*v*cb) ...
      cc./(1+u.^2-2*u*cg) ];

function x = vnz( x )

x = x ./ repmat( sqrt( sum( x.^2 ) ), [ size( x, 1 ), 1 ] );

function l = vlen( x )

l = sqrt( sum( x.^2 ) );

function y = e2p( x )

y = [ x; ones( 1, size( x, 2 ) ) ];

function y = p2e(x)

s = size( x, 1 );

y = x( 1:end-1, : ) ./ x( ones( s-1,1) * s, : );
