function [CP] = EstimateAmbiguousPose(E)
W = [0 -1 0;
	1 0 0;
	0 0 1];
[U,~,V] = svd(E);

R = U*W*V';
t = U(:,3);
if det(R) < 0
    R = -R;
    t = -t;
end
CP{1} = [R t];

R = U*W*V';
t = -U(:,3);
if det(R) < 0
    R = -R;
    t = -t;
end
CP{2} = [R t];

R = U*W'*V';
t = U(:,3);
if det(R) < 0
    R = -R;
    t = -t;
end
CP{3} = [R t];

R = U*W'*V';
t = -U(:,3);
if det(R) < 0
    R = -R;
    t = -t;
end
CP{4} = [R t];
