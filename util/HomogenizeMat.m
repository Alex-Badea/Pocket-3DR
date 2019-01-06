function [A] = HomogenizeMat(A)
%HOMOGENIZEMAT Summary of this function goes here
%   Detailed explanation goes here
if size(A,1) ~= size(A,2)-1
    error('Matrix not homogenizable')
end
A(end+1, end) = 1;
end

