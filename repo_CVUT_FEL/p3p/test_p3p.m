% Verify p3p and absolute orientation problem.

% note that p3p_grunert and XX2Rt_simple accept homogeneous as well as
% euclidean coordinates

n = 10; % number of generated trials


fprintf( 'Generating %i samples....\n', n );
for i=1:n
  % Generate a random triplet of 3D and 2D points:
  Xw = -100 + 200*rand( 3, 3 );
  u  = -100 + 200*rand( 2, 3 );
    
  % p3p solution
  res = p3p_grunert( Xw, u );

  fprintf( '%i: %i solution(s)\n', i, numel( res ) );

  
  % for each solution solve absolute orientation and verify
  for r = res
    Xc = r{1};
    [R t] = XX2Rt_simple( Xw, Xc );
    
    % now Xc should be R * Xw + t for each column
    Xc1 = R * Xw + repmat( t, [1 3] );
    
    % and u should be projection of Xc
    u1 = Xc1( [1 2], : ) ./ Xc1( [3 3], : );
    
    % euclidean err in 3D (note: values of coordinates are in range of hundreds)
    err1 = sqrt( sum( (Xc - Xc1).^2 ) );
    
    % reprojection err in image (in pixels)
    err2 = sqrt( sum( (u1 - u).^2 ) );
    
    fprintf( '  3D err: %8.3g   reprojection err: %8.3g\n', ...
             max( err1 ), max( err2 ) );
  end
end
