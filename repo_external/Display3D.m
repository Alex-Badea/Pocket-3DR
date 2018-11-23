function Display3D(Cset, Rset, X)
figure, axis equal
pcshow(X','MarkerSize',50)
for i = 1 : length(Cset)
    hold on
    DisplayCameraPlane(Cset{i}, Rset{i}, 0.5);
end

