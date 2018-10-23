function [P] = PnP(X, x)

A = nan(2*size(X,2), 12);
for i = 1:size(X,2)
    A(2*i-1, :) = [[0 0 0 0] -[X(:,i)' 1] x(2,i)*[X(:,i)' 1]];
    A(2*i, :) = [[X(:,i)' 1] [0 0 0 0] -x(1,i)*[X(:,i)' 1]];
end

[~,~,V] = svd(A);
p = V(:,end);
P = reshape(p,4,3)';
R = P(1:3,1:3);
t = P(:,end);
[U,D,V] = svd(R);
R = det(U*V')*U*V';
t = det(U*V')*t/D(1,1);
P = [R t];
end