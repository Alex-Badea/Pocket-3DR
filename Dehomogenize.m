function [ dehomX ] = Dehomogenize( x )
%DEHOMOGENIZE Summary of this function goes here
%   Detailed explanation goes here
if size(x,1) == 2, error('Already non-homogenous'), end
dehomX = x(1:2,:)./x(3,:);
end

