function zRange = ExtractZRange(P1, P2, corrs)
%EXTRACTZRANGE Summary of this function goes here
%   Detailed explanation goes here
X = Triangulate(P1,P2,corrs);
z = X(3,:);
zRange = [z(z==min(z)) z(z==max(z))];
end

