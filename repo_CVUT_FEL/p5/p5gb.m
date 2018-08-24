function [Es SOLS] = p5gb( u1, u2 )
%P5GB  Five-point calibrated relative pose problem (Grobner basis).
%   Es = P5( u1, u2 ) computes the esential matrices E according to 
%   Nister-PAMI2004 and Stewenius-PRS2006.
%
%   Input:
%     u1, u2 ..  3x5 matrices, five corresponding points in 
%     HOMOGENEOUS coordinates.
%
%   Output:
%     Es .. 9xn matrix of possible solution. Each column corresponds to one 
%     3x3 essential matrix. Following should be zero for each essential
%     matrix (according to the paper):
%
%          diag( u2' * E * u1 )                          ... eq. (4)
%          det( E )                                      ... eq. (5)
%          E * E' * E - 0.5 * trace( E * E' ) * E        ... eq. (6)

% (c) 2007-05-10, Martin Matousek
% Last change: $Date:: 2008-08-11 18:26:29 +0200 #$
%              $Revision: 19 $

% Linear equations for the essential matrix (eqns 7-9). 

q = [u1(1,:) .* u2(1,:); u1(2,:) .* u2(1,:); u1(3,:) .* u2(1,:);
     u1(1,:) .* u2(2,:); u1(2,:) .* u2(2,:); u1(3,:) .* u2(2,:);
     u1(1,:) .* u2(3,:); u1(2,:) .* u2(3,:); u1(3,:) .* u2(3,:) ]';

% span of null-space
[U,S,V] = svd(q,0);
XYZW = V(:,6:9);

% the matrix 'A'
A = p5_matrixA( XYZW );

p = [1 4 2 3 5 11 7 13 6 12 8 14 17 9 15 18 10 16 19 20];
r = 1:20;
p(p) = r;

A = A(:, p );

if( rcond(A(:,1:10)) < eps || rcond(A(:,11:20)) < eps)
  Es = [];
  return
end

A = A(:,1:10)\A(:,11:20);

M = -A([1 2 3 5 6 8], :);
   
M(7,1) = 1;
M(8,2) = 1;
M(9,4) = 1;
M(10,7) = 1;

[V,D] = eig(M ); %#ok
SOLS =   V(7:9,:)./(ones(3,1)*V(10,:));

Evec = XYZW*[SOLS ; ones(1,10 ) ]; 
Evec = Evec./ ( ones(9,1)*sqrt(sum( Evec.^2)));

I = not(imag( Evec(1,:) ));
Es = Evec(:,I);
