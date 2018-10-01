function H = elemH( varargin )
%ELEMH  Elementary homography (ies).
%   H = elemH( param_1, value_1, ... ) returns a 3x3 homography matrix, composed
%   from elementary homographies ... H_i ... H_1. Each H_i is given by one
%   param-value pair. The order of the pairs determines the order of applying
%   the transformation to a point, i.e, the elementary matrices are multiplied
%   in reverse order. Possible keys:
%     'rot1' or 'rotx' .. projective rotation around the first coordinate,
%     'rot2' or 'roty' .. projective rotation around the second coordinate,
%     'rot3' or 'rotz' .. projective rotation around the third coordinate,
%     'du' .. principal point shift (the first image coordinate),
%     'su' .. scale (the first image coordinate),
%     'dv' .. principal point shift (the second image coordinate),
%     'sv' .. scale (the first image coordinate),
%     's'  .. scale (both image coordinates),
%     'sr' .. scale anisotrophy (ratio su/sv), must be before 's'
%     'q' .. skew.

% (c) 2003-12-21, Martin Matousek
% Last change: $Date:: 2007-01-02 01:00:00 +0100 #$
%              $Revision: 1 $
% Permissions to use: (mm_cmp_research)
%   This software can be used for research and educational purposes
%   by CMP members and CMP students. Other use requires a licence.

if( rem( length( varargin ), 2 ) )
  error 'Even-sized list of param-value pairs expected';
end

H = eye( 3 );
i = 1;
sr = 1;
s_used = 0;
sr_used = 0;

while( i < length( varargin ) )
  type = varargin{i};
  arg = varargin{i+1};
  i = i + 2;
  switch type
    case { 'rot1', 'rotx', 1 }
      ca = cos( arg );  sa = sin( arg );
      H = [ 1 0 0; 0 ca -sa; 0 sa ca ] * H;
    case { 'rot2', 'roty', 2 }
      ca = cos( arg );  sa = sin( arg );
      H = [ ca 0 -sa; 0 1 0; sa 0 ca ] * H;
    case { 'rot3', 'rotz', 3 }
      ca = cos( arg );  sa = sin( arg );
      H = [ ca -sa 0; sa ca 0; 0 0 1 ] * H;
    case { 'du', 4 }
      H = [ 1 0 arg; 0 1 0; 0 0 1 ] * H;
    case 'sr'
     if( s_used ), error 'Scale ratio must be used before scale.'; end
     if( sr == 0 ), error 'Zero scale'; end
     sr = arg;
     sr_used = 1;
    case 's'
      if( any( arg == 0 ) ), error 'Zero scale'; end
      if( length(arg) == 2 )
        if( sr_used ), error 'Ambiguity - both scales and ratio'; end
      else
        arg = [arg arg * sr ];
      end
      H = [ arg(1) 0 0; 0 arg(2) 0; 0 0 1 ] * H;
      s_used = 1;
    case 'su'
      if( arg == 0 ), error 'Zero scale'; end
      H = [ arg 0 0; 0 1 0; 0 0 1 ] * H;
      s_used = 1;
    case 'dv'
      H = [ 1 0 0; 0 1 arg; 0 0 1 ] * H;
    case 'sv'
      if( arg == 0 ), error 'Zero scale'; end
      H = [ 1 0 0; 0 arg 0; 0 0 1 ] * H;
      s_used = 1;
    case 'q'
      H =[ 1 0 0; arg 1 0; 0 0 1 ] * H;
    case 'd'
      H = [ 1 0 arg(1); 0 1 arg(2); 0 0 1 ] * H;
    otherwise
      error( [ 'Unknown param ' type ] );
  end
end
