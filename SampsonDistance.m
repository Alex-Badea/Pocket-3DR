function [ errs ] = SampsonDistance( M, Cx )
%SAMPSONDISTANCE Summary of this function goes here
%   Detailed explanation goes here
x = cell2mat(Cx);
x1 = [x(1:2,:);ones(1,size(x,2))];
x2 = [x(3:4,:);ones(1,size(x,2))];

ntor = dot(x2, M*x1).^2;
Mx1 = M*x1;
MTx2 = M'*x2;
dtor = Mx1(1,:).^2 + Mx1(2,:).^2 + MTx2(1,:).^2 + MTx2(2,:).^2;
errs = ntor./dtor;
end

