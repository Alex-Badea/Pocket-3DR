# Pocket 3DR
This is a MATLAB library containing the necessary functions in order to implement a fully functional 3D Reconstruction pipeline. The pipeline runs inside the <strong>main.m</strong> script file. 

The SfM stage of this pipeline is noticeably faster than that of other Photogrammetry programs currently on the market, as it combines background filtering with translation baseline adjustment, which means that, even if it's an incremental SfM pipeline, it doesn't resection the camera every time a new view is added, it just adjusts the global translation within a camera triplet. There is also no need for this process to run within a RANSAC framework, as the background filtering removes many of the outliers still present after correspondence filtering. A small caveat of this library is that the object immortalized needs to be non-Lambertian (the Multi View Stereo stage will fail otherwise), thus the application targets those who want a quick and efficient way to create 3D meshes of small household objects in order to import them in a graphics engine to create video games or CGI.

### Installation:
There are no executables available yet. You will need MATLAB in order to run this pipeline.

### Usage:
Insert the images of the object to be reconstructed inside the <strong>ims</strong> folder which will be processed in alphabetical order and provide a calibration file of your camera inside the <strong>calib_mats</strong> folder. The calibration file needs to have a 3-by-3 matrix <strong>K</strong> representing the Calibration Matrix and, optionally, a 2-vector <strong>d</strong> representing the distortion parameters. MATLAB provides a tool that can calibrate the camera for you given some images of a checkerboard pattern as input.
The program arguments are the following:

<strong>dataset</strong>: a common beginning pattern that the images of the object share, e.g. if your images are called <em>mystuff1.jpg</em>, <em>mything2.jpg</em> and <em>myobject3.jpg</em>, the dataset is <strong>my</strong>;

<strong>calib</strong>: name of the calibration file;

<strong>drp</strong>: image pairs used for dense reconstruction, as Multiple View Stereo is a very heavy process and it doesn't need to use all image pairs to provide a dense reconstruction;

<strong>threads</strong>: if different than 1, will summon that number of MATLAB workers to parallelize all for loops that can run non-deterministically.

These program arguments can be found in the "Program arguments" section of the <strong>main.m</strong> script. Technically, this is the only section you should adjust to suit your needs, the rest is implementation detail.If you had to modify some parameters other than those in the "Program arguments" section in order for the reconstruction to work, please <strong>open an issue</strong>!

#### cpl: 47 images
  
<img src="https://i.ibb.co/DbTk8sS/cpl01.jpg" height="250"> <img src="https://i.ibb.co/R661gv7/cpl.gif" height="250">
<img src="https://i.ibb.co/qNnKgQ4/cpl.jpg" width="602">

#### csk: 41 images
  
<img src="https://i.ibb.co/QY63ZmV/csk01.jpg" height="250"> <img src="https://i.ibb.co/S6NmZwY/csk.gif" height="250">
<img src="https://i.ibb.co/mCX9b9s/csk.jpg" width="602">

#### mer: 51 images
  
<img src="https://i.ibb.co/5hdjbBS/mer01.jpg" height="250"> <img src="https://i.ibb.co/dtRPDxV/mer.gif" height="250">
<img src="https://i.ibb.co/ys26mnk/mer.jpg" width="602">

#### car: 43 images (FAIL)

<img src="https://i.ibb.co/NjTXcbj/car01.jpg" height="250"> <img src="https://i.ibb.co/1MzvQKd/car.gif" height="250">
<img src="https://i.ibb.co/bmMHHcr/car.jpg" width="602">

```diff
+ Dense reconstruction from 2 images
+ High disparity background filtering
+ Dense reconstruction from n>2 images
+ Background cropping for Dense Reconstruction
+ Recoloring
+ Parallel (Multi-core)
- Documentation (Romanian)
- Documentation (English)
- Retexturing
- Background filtering with adaptive bin size (since absolute scale is in relation with translation magnitude)
- Stepwise consistency check (if something goes wrong either let the user fix it or rerun the same block again)
- Parallelize SfM as well
```
