function varargout = p5_matrixA( varargin )%#ok
%P5_MATRIXA  Helper: Five-point relative pose problem: the matrix 'A'.
%   A = P5_MATRIXA( XYZW ) computes the matrix 'A' according to 
%   Nister-PAMI2004.
%
%   Input:
%     XYZW ..  9x4 matrix, each column correspond to 3x3 matrix. These four
%     matrices span the essential matrix, they comes from svd solution of
%          u2' E u1, where essential matrix E is of the form
%     E = x*X + y*Y + z*Z + W.
%
%   Output:
%     A .. the matrix 'A', 10x20, see the paper. Rows correspond to 10 cubic
%     constraints. Columns correspond to indeterminates in order:
%     x^3  y^3  x^2*y  x*y^2  x^2*z  x^2  y^2*z  y^2  x*y*z  x*y
%     x*z^2  x*z  z   y*z^2  y*z  y   z^3  z^2  z  1 
%
%   Mex Implementation.
%   Main part of the c++ code is generated using a Maple script.
%
%   See also P5, P5GB.

% (c) 2007-05-10, Martin Matousek
% Last change: $Date:: 2010-02-22 18:35:05 +0100 #$
%              $Revision: 43 $

error( 'MEX file not found' )
