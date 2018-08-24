function [ kPts ] = EstimateImageKeypoints( im )
%ESTIMATEIMAGEKEYPOINTS Summary of this function goes here
%   Detailed explanation goes here
kPts = wbs_describe_image(im, wbs_default_cfg);
end

