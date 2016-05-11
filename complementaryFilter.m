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

[~,sheetNames] = xlsfinfo(filename);
numSheets = length(sheetNames);
sheet = cell(numSheets,1);

acc_x = cell(size(sheet));
acc_y = acc_x;
acc_z = acc_x;
thetaX_acc = acc_x;
thetaY_acc = acc_x;
thetaZ_acc = acc_x;
gyr_x = acc_x;
gyr_y = acc_x;
gyr_z = acc_x;
thetaX = acc_x;
thetaY = acc_x;
thetaZ = acc_x;
for s = 1:numSheets
    [sheet{s},~,~] = xlsread(filename,s);
    updateRate = 60;    % Hz
    dt = 1/updateRate;  % s

    thisSheet = sheet{s};

    acc_x{s} = thisSheet(:,3);
    acc_y{s} = thisSheet(:,4);
    acc_z{s} = thisSheet(:,5);
    thetaX_acc{s} = lpf*atan2(acc_z{s},acc_y{s});
    thetaY_acc{s} = lpf*atan2(acc_x{s},acc_z{s});
    thetaZ_acc{s} = lpf*atan2(acc_y{s},acc_x{s});

    gyr_x{s} = thisSheet(:,6);
    gyr_y{s} = thisSheet(:,7);
    gyr_z{s} = thisSheet(:,8);
    thetaX{s} = zeros(size(gyr_x{s}));
    thetaY{s} = thetaX{s};
    thetaZ{s} = thetaY{s};
    for a = 1:length(gyr_x{s})
        if a == 1
            thetaX{s}(a) = hpf*thetaX{s}(a)*dt + thetaX_acc{s}(a);
            thetaY{s}(a) = hpf*thetaY{s}(a)*dt + thetaY_acc{s}(a);
            thetaZ{s}(a) = hpf*thetaZ{s}(a)*dt + thetaZ_acc{s}(a);
        else
            thetaX{s}(a) = hpf*(thetaX{s}(a-1) + gyr_x{s}(a)*dt) + thetaX_acc{s}(a);
            thetaY{s}(a) = hpf*(thetaY{s}(a-1) + gyr_y{s}(a)*dt) + thetaY_acc{s}(a);
            thetaZ{s}(a) = hpf*(thetaZ{s}(a-1) + gyr_z{s}(a)*dt) + thetaZ_acc{s}(a);
        end
    end
    figure
    plot(thetaX{s})
    hold on
    plot(thetaY{s})
    plot(thetaZ{s})
    legend('X','Y','Z')
end