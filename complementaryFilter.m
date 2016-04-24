close all; clear; clc;

% Choose the file that you would like to analyze - it must be an Excel file
[name,path] = uigetfile('*.xlsx');
% Concatenate the file path and the file name of the file you chose so that
% we can open it in the next line of code
filename = [path,name];
% Open the Excel file that you chose. Each sheet in the Excel spreadsheet
% is saved as a different matrix.
[numBackBone,txtBackBone,rawBackBone] = xlsread(filename,1);
% [numRightThigh,txtRightThigh,rawRightThigh] = xlsread(filename,2);
% [numLeftThigh,txtLeftThigh,rawLeftThigh] = xlsread(filename,3);
% [numRightCalf,txtRightCalf,rawRightCalf] = xlsread(filename,4);
% [numLeftCalf,txtLeftCalf,rawLeftCalf] = xlsread(filename,5);

updateRate = 60;    % Hz
dt = 1/updateRate;  % s
hpf = 0.98;
lpf = 0.02;

% packet | sampleTime | acc_x | acc_y | acc_z | gyr_x | gyr_y | gyr_z
acc_x = numBackBone(:,3);
acc_y = numBackBone(:,4);
acc_z = numBackBone(:,5);
thetaX_acc = lpf*atan2(acc_z,acc_y);
thetaY_acc = lpf*atan2(acc_x,acc_z);
thetaZ_acc = lpf*atan2(acc_y,acc_x);
% theta_acc = sqrt(thetaX_acc.^2 + thetaY_acc.^2 + thetaZ_acc.^2);

gyr_x = numBackBone(:,6);
gyr_y = numBackBone(:,7);
gyr_z = numBackBone(:,8);
thetaX = zeros(size(gyr_x));
thetaY = thetaX;
thetaZ = thetaY;
for a = 1:length(gyr_x)
    if a == 1
        thetaX(a) = hpf*thetaX(a)*dt + lpf*thetaX_acc(a);
        thetaY(a) = hpf*thetaY(a)*dt + lpf*thetaY_acc(a);
        thetaZ(a) = hpf*thetaZ(a)*dt + lpf*thetaZ_acc(a);
    else
        thetaX(a) = hpf*(thetaX(a-1) + gyr_x(a)*dt) + lpf*thetaX_acc(a);
        thetaY(a) = hpf*(thetaY(a-1) + gyr_y(a)*dt) + lpf*thetaY_acc(a);
        thetaZ(a) = hpf*(thetaZ(a-1) + gyr_z(a)*dt) + lpf*thetaZ_acc(a);
    end
end
% theta_gyr = sqrt(thetaX_gyr.^2 + thetaY_gyr.^2 + thetaZ_gyr.^2);

plot(thetaX)
hold on
plot(thetaY)
plot(thetaZ)
legend('X','Y','Z')