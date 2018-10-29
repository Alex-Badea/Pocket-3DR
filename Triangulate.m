function [ X ] = Triangulate( P1, P2, x1, x2 )
%TRIANGULATE Summary of this function goes here
%   Detailed explanation goes here
X = zeros(3, size(x1,2));
for i = 1:size(x1,2)
    A = [x1(:,i)*P1(3,:) - P1(1:2,:);
        x2(:,i)*P2(3,:) - P2(1:2,:)];
    [~,~,V] = svd(A);
    X(:,i) = V(1:3,end)/V(4,end);
end
end

