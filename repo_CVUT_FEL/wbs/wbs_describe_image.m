function pts = wbs_describe_image( img, cfg )
%WBS_DESCRIBE_IMAGE  Image interest points/regions and their descriptors.
%
%   pts = wbs_describe_image( img, cfg )
%
%   Input:
%     cfg  .. options from e.g. WBS_DEFAULT_CFG
%     img  .. grayscale or RGB image, uint8 
%
%   Output:
%     pts  .. interest points and descriptions
%       pts(i).id .. unique ID, should equal to i
%       pts(i).x, pts(i).y .. euclidean coordinates

% (c) 2010-10-18, Martin Matousek
% (c) 2010-09-01, Michal Perdoch
% Last change: $Date::                            $
%              $Revision$
   
% hessian affine points
pts = kmpts2( img, cfg );
if( ~isempty( pts ) && isfield( pts, 'affpt' ) )
  pts = pts.affpt;
else
  pts = [];
end

% msers + DL rotation
msers = extrema( img, cfg );
msersp = msers{1};
msersm = msers{2};

ptsp = affpatch( img, [ msersp{2,:} ], cfg ); 

if( ~isempty( ptsp ) && isfield( ptsp, 'affpt' ) )
  ptsp = ptsp.affpt;
  for i=1:numel(ptsp), ptsp(i).class=2; end;
else
  ptsp = [];
end

ptsm = affpatch( img, [ msersm{2,:} ], cfg ); 

if( ~isempty( ptsm ) && isfield( ptsm, 'affpt' ) )
  ptsm = ptsm.affpt;
  for i=1:numel(ptsm), ptsm(i).class=3; end;
else
  ptsm = [];
end

pts = [ pts ptsp ptsm ];

% make unique index
for inx=1:length(pts)
  pts(inx).id = inx;
end
