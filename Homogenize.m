function [ homX ] = Homogenize( x )
%HOMOGENIZE Summary of this function goes here
%   Detailed explanation goes here
if size(x,1) == 3, error('Already homogenous'), end
homX = [x;ones(1,size(x,2))];
end

