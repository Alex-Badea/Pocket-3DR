function [ err ] = ReprojectionError( P, CXx )
%REPROJECTIONERROR Summary of this function goes here
%   Detailed explanation goes here
Xx = cell2mat(CXx);
X = Xx(1:3,:);
x = Xx(4:5,:);
err = vec2Norm(x-Dehomogenize(P*Homogenize(X)));
end

function n = vec2Norm(v)
v = [v(1,:).^2;
    v(2,:).^2];
n = sqrt(sum(v));
end