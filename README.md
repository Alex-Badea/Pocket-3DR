# 3DReconstruction
A MATLAB implementation of a full 3D Reconstruction pipeline using the functions provided by the Czech Technical University in Prague, Faculty of Electrical Engineering
- At the moment, it can do Dense Multiple Reconstruction from only up to 6 images due to inappropriate initialization of the Bundle Adjustment algorithm.

<img src="https://image.ibb.co/jt6JZK/car04.jpg" width="135"> <img src="https://image.ibb.co/cT4STe/car05.jpg" width="135"> <img src="https://image.ibb.co/nFGwMz/car06.jpg" width="135"> <img src="https://image.ibb.co/eAvZ8e/car07.jpg" width="135"> <img src="https://image.ibb.co/hFPmoe/car08.jpg" width="135"> <img src="https://image.ibb.co/dnte8e/car09.jpg" width="135"> 
![](https://image.ibb.co/nFRXTe/untitled.jpg)
Also, in general, 3D Reconstruction Algorithms handle non-lambertian objects pretty badly, so, in this case, a polarizing filter would have helped greatly.

```diff
+ Dense reconstruction from 2 images
+ High disparity background filtering
- Dense reconstruction from n>2 images
```
