function [A] = DehomogenizeMat(A)
%DEHOMOGENIZEMAT Summary of this function goes here
%   Detailed explanation goes here
if all(A(end, 1:end-1) ~= 0) || A(end,end) ~= 1
    error('Matrix not dehomogenizable')
end
A = A(1:end-1,:);
end

