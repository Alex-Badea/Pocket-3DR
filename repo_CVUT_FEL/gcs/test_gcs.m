%demo for GCS matching (stereo matching via growing correspondence seeds)

Il = imread('Rotunda_0.png');
Ir = imread('Rotunda_1.png');
 
D = gcs(Il,Ir,[]);

figure(1)
clf
imagesc(D); axis image; colormap(jet); set(gca,'clim',[-100,100]);
title 'Disparity map';
