function Display3D(Cset, Rset, X, C)
figure, axis equal
if exist('X','var')
pcshow(X',C','MarkerSize',50)
end
for i = 1 : length(Cset)
    hold on
    DisplayCameraPlane(Cset{i}, Rset{i}, 0.5);
end