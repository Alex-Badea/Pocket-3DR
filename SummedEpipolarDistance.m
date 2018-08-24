function [ errs ] = SummedEpipolarDistance( F, Cx )
%SUMMEDEPIPOLARDISTANCE Summary of this function goes here
%   Detailed explanation goes here
x = cell2mat(Cx);
x1 = [x(1:2,:);ones(1,size(x,2))];
x2 = [x(3:4,:);ones(1,size(x,2))];

errs = pointLineDistance(x2, F*x1) + pointLineDistance(x1, F'*x2);
end

function d = pointLineDistance(p, l)
d = zeros(1,size(p,2));
for i = 1:size(p,2)
    a = l(1,i); b = l(2,i); c = l(3,i);
    x0 = p(1,i); y0 = p(2,i);
    d(i) = abs(a*x0+b*y0+c)/sqrt(a^2+b^2);
end
end
