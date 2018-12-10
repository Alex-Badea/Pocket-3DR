d
im = imread('mer01.jpg');
imshow(im);
Cim = UndistortImages({im},K,d);
imshow(Cim{1})