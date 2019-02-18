function [ X ] = Triangulate( P1, P2, corrs )
%TRIANGULATE Summary of this function goes here
%   Detailed explanation goes here
X = zeros(3, size(corrs,2));
x1 = corrs(1:2,:);
x2 = corrs(3:4,:);
for i = 1:size(x1,2)
    A = [x1(:,i)*P1(3,:) - P1(1:2,:);
        x2(:,i)*P2(3,:) - P2(1:2,:)];
    [~,~,V] = svd(A,0);
    X(:,i) = V(1:3,end)/V(4,end);
end
end

