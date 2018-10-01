% convex polugon cropped by horiz line - always two lines crossed
function newc = crop_convex_polygon( c, minu, maxu )
newc = crop_convex_polygon_one( c, maxu );
newc = -crop_convex_polygon_one( -newc, -minu );

function newc = crop_convex_polygon_one( c, maxu )

n = c(1,:) > maxu;

if( all( n == 0 ) ), newc = c; return; end

if( n(1) & n(end) ) % segment of corners crosses end,1 boundary
  n = find( ~n );
  b = n(end) + 1;
  e = n(1) - 1;
else
  n = find( n ) ;
  b = n(1);
  e = n(end);
end

if( b == 1 )
  newb = cross_line( c(:, 1), c(:, end), maxu );
else
  newb = cross_line( c(:, b), c(:, b-1), maxu );
end

if( e == length(c) )
  newe = cross_line( c(:, end), c(:, 1), maxu );
else
  newe = cross_line( c(:, e), c(:, e+1), maxu );
end

if( b <= e )
  newc = [ c( :, 1:b-1 ) newb newe  c(:, e+1:end) ];
else
  newc = [ newe c( :, (e+1):(b-1) ) newb ];
end

% crossing line c1-c2 with horizontal u
function c = cross_line( c1, c2, u )
v = c2(2) + ( c1(2) - c2(2) ) / ( c1(1) - c2(1) ) * ( u - c2(1) );
c = [u;v];
