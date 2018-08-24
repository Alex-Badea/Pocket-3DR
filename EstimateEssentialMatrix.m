function [ CE ] = EstimateEssentialMatrix( Cx )
%ESTIMATEESSENTIALMATRIX Summary of this function goes here
%   Detailed explanation goes here
if length(Cx) ~= 5
    error('Exactly 5 points required for Fundamental Matrix estimation')
end
x = cell2mat(Cx);
x1 = x(1:2,:);
x2 = x(3:4,:);

Es = p5gb(Homogenize(x1), Homogenize(x2));
CE = cell(1, size(Es,2));
for i = 1:size(Es,2)
    crtE = reshape(Es(:,i), 3, 3)';
    CE{i} = crtE;
end
end

