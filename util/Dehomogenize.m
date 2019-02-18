function [ dehomX ] = Dehomogenize( x )
%DEHOMOGENIZE Summary of this function goes here
%   Detailed explanation goes here
if size(x,1) < 3, error('Already non-homogenous'), end
if size(x,1) == 3
dehomX = [x(1,:)./x(3,:); x(2,:)./x(3,:)];
elseif size(x,1) == 4
dehomX = [x(1,:)./x(4,:); x(2,:)./x(4,:); x(3,:)./x(4,:)];
end
end

