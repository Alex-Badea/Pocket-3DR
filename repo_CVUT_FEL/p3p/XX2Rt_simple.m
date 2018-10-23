function [R t] = XX2Rt_simple( X1, X2 )
%XX2RT_SIMPLE  Absolute orientation problem, simple solution.
%   [R t] = XX2Rt_simple( X1, X2 )
%     solves absolute orientation problem using simple method.
%
%   Input:
%     X1, X2 .. 3D points (at least three) in two different 
%     coordinate systems (euclidean or homogeneous, 3xn or 4xn matrix),
%       
%   Output:
%     R .. matrix of rotation (3x3)
%     t .. translation
%
%   X2 = R*X1 + t

% (c) 2007-08-18, Martin Matousek
% Last change: $Date:: 2008-08-11 18:26:29 +0200 #$
%              $Revision: 19 $

if( size( X1, 1 ) == 4 ), X1 = p2e( X1 ); end
if( size( X2, 1 ) == 4 ), X2 = p2e( X2 ); end
% X1, X2 are now euclidean

n = size( X1, 2 );

% points relative to centroids
c1 = mean( X1, 2 );
c2 = mean( X2, 2 );

X1 = X1 - repmat( c1, [1, n ] );
X2 = X2 - repmat( c2, [1, n ] );

% ------------------------------------------------------------------------------
% ROTATION

% normal of triangle plane
n1 = mnz( sqc(X1(:,1))*X1(:,3) );
n2 = mnz( sqc(X2(:,1))*X2(:,3) );

% axis and angle of rotation 1
a = mnz( sqc(n1) * n2 );
c_alpha = n1' * n2;
s_alpha = sqrt(1-c_alpha^2);

% Rodrigues' rotation formula
A = sqc( a );
R1 = eye(3) + A * s_alpha + A^2 * ( 1 - c_alpha );

X1a = R1 * X1;

% rotation 2 - axis (n2) and angle
c_alpha = ( sum( vnz(X2) .* vnz(X1a) ) );
c_alpha = c_alpha(1);
s_alpha = sqrt(1-c_alpha^2);

% Rodrigues' rotation formula
A = sqc( n2 );
R2 = eye(3) + A * s_alpha + A^2 * ( 1 - c_alpha );

% which direction?
e_plus = sum( vlen( X2 - R2 * X1a ) );
e_minus = sum( vlen( X2 - R2' * X1a ) );

if( e_plus < e_minus )
  R = R2 * R1;
else
  R = R2' * R1;
end

% ------------------------------------------------------------------------------
% SHIFT
t = c2 - R*c1;

% ==============================================================================
function A = mnz( A )
A = A / sqrt( sum( A(:).^2 ) );

function S = sqc(x)
S = [0 -x(3) x(2); x(3) 0 -x(1); -x(2) x(1) 0];

function y = p2e(x)

s = size( x, 1 );

y = x( 1:end-1, : ) ./ x( ones( s-1,1) * s, : );

function x = vnz( x )

x = x ./ repmat( sqrt( sum( x.^2 ) ), [ size( x, 1 ), 1 ] );

function l = vlen( x )

l = sqrt( sum( x.^2 ) );
