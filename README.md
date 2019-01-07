# 3DReconstruction
A MATLAB implementation of a full 3D Reconstruction pipeline using the functions provided by the Czech Technical University in Prague, Faculty of Electrical Engineering.
- Tips:
  - It is highly recommended that you calibrate for the distorsion parameters as well when dealing with high-depth background images, else reconstruction might fail;
  - The reconstruction fails for [non-Lambertian objects](https://en.wikipedia.org/wiki/Lambertian_reflectance) (see image set "car") due to inconsistency of features between scenes;
  - If the script fails with "Transitivity 0", rerun the program. You might have stumbled upon an unfortunate Essential Matrix estimation. If it fails again, the camera might have been badly calibrated.
- Check out some samples below (full image sets in repo):

#### cpl: 47 images
  
<img src="https://i.ibb.co/DbTk8sS/cpl01.jpg" height="250"> <img src="https://i.ibb.co/R661gv7/cpl.gif" height="250">
<img src="https://i.ibb.co/qNnKgQ4/cpl.jpg" width="602">

#### mer: 51 images
  
<img src="https://i.ibb.co/QY63ZmV/csk01.jpg" height="250"> <img src="https://i.ibb.co/S6NmZwY/csk.gif" height="250">
<img src="https://i.ibb.co/mCX9b9s/csk.jpg" width="602">

#### csk: 41 images
  
<img src="https://i.ibb.co/5hdjbBS/mer01.jpg" height="250"> <img src="https://i.ibb.co/dtRPDxV/mer.gif" height="250">
<img src="https://i.ibb.co/ys26mnk/mer.jpg" width="602">

#### car: 43 images

<img src="https://i.ibb.co/NjTXcbj/car01.jpg" height="250"> <img src="https://i.ibb.co/1MzvQKd/car.gif" height="250">
<img src="https://i.ibb.co/bmMHHcr/car.jpg" width="602">

```diff
+ Dense reconstruction from 2 images
+ High disparity background filtering
+ Dense reconstruction from n>2 images
+ Background cropping for Dense Reconstruction
+ Recoloring
- Documentation (Romanian)
- Documentation (English)
- Parallel (Multi-core)
- Retexturing
- Background filtering with adaptive bin size (since absolute scale is in relation with translation magnitude)
- Stepwise consistency check (if something goes wrong either let the user fix it or rerun the same block again)
```
