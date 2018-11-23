function matches = match2viewSIFT(im1, im2)

% SFMedu: Structrue From Motion for Education Purpose
% Written by Jianxiong Xiao (MIT License)

%% load two images and depths
image_i=im1;
image_j=im2;

%% compute SIFT keypoints
  
edge_thresh = 2.5;
[SIFTloc_i,SIFTdes_i] = vl_sift(single(rgb2gray(image_i)), 'edgethresh', edge_thresh) ;
SIFTloc_i = SIFTloc_i([2,1],:);
[SIFTloc_j,SIFTdes_j] = vl_sift(single(rgb2gray(image_j)), 'edgethresh', edge_thresh) ;
SIFTloc_j = SIFTloc_j([2,1],:);

%% SIFT matching
 
%[matchPointsID_i, matchPointsID_j] = matchSIFTdesImages(SIFTdes_i, SIFTdes_j);
[matchPointsID_i, matchPointsID_j] = matchSIFTdesImagesBidirectional(SIFTdes_i, SIFTdes_j, 0.75^2);

SIFTloc_i = SIFTloc_i([2 1],matchPointsID_i);
SIFTloc_j = SIFTloc_j([2 1],matchPointsID_j);





matches = [SIFTloc_i;SIFTloc_j];