function [ pc m ] = wbs_match_descriptions( pts1, pts2, cfg )
%WBS_MATCH_DESCRIPTIONS  Between interest points in two images.
%
%   [ pc m ] = wbs_match_descriptions( pts1, pts2, cfg )
%
%   Input:
%     pts1, pts2 .. interest point descriptions for the two images, as
%                   obtained from WBS_DESCRIBE_IMAGE
%     cfg        .. options from e.g. WBS_DEFAULT_CFG
%
%   Output:
%     pc  .. point correspondences, 4xn matrix where n is the number of
%            correspondences found and every column is a single correspondence
%            [x1;y1;x2;y2], where x1,y1 are euclidean coordinates in the
%            first image and x2,y2 are coordinates in the second one.
%
%     m   .. point correspondences as a list of point ids, 2xn matrix; 
%            the first row contains ids of points in pts1 and the second
%            row ids of points in pts2. If the ids are equal to point index
%            (e.g., as obtained from WBS_DESCRIBE_IMAGE), 
%            then for i-th correspondence pc(:,i) equals to 
%
%          [ pts1(m(1,i)).x; pts1(m(1,i)).y; pts2(m(2,i)).x; pts2(m(2,i)).y]

% (c) 2010-10-18, Martin Matousek
% Last change: $Date::                            $
%              $Revision$
   
[m pc] = match( pts1, pts2, cfg );
m = m(1:2, : );
pc = pc( [1 2 4 5], : );
