function [yaw, pitch, roll] = euler_angles(rot_mat)
    pitch = asin(rot_mat(3,1)) * (180.0/pi);
    yaw   = atan2(rot_mat(2,1), rot_mat(1,1)) * (180.0/pi);
    roll  = atan2(rot_mat(3,2), rot_mat(3,3))* (180.0/pi);
end