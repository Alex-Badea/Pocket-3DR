function [H1, H2, im1r, im2r] = rectify( F, im1, im2 )
%RECTIFY  Simple epipolar rectification.  
%[H1, H2, im1r, im2r] = rectify( F, im1, im2 )


im_size = size( im1 );

% to the old coordinate system
Fo = F( [2 1 3], [2 1 3] );

[ HH1, HH2 ] = rectprimitive( Fo, im_size, im_size );
[ H1o, H2o ] = rpairalign( HH1, HH2, im_size, im_size, 1 );


[ im1r, im2r ] = rpairproj( im1, im2, H1o, H2o, 1 );

% to the new coordinate system
H2 = H2o( [2 1 3], [2 1 3]);
H1 = H1o( [2 1 3], [2 1 3]);
