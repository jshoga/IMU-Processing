% sources:
% http://www.pieter-jan.com/node/11
% http://www.starlino.com/imu_guide.html

function IMU_GUI
    h = figure('Position',[50,100,1800,900]);
    uicontrol(...
        'Style','pushbutton',...
        'String','Select File to Analyze',...
        'Position',[10,850,200,25],...
        'Callback',@GetFile_Callback);
    uicontrol(...
        'Style','pushbutton',...
        'String','Analyze!',...
        'Position',[10,700,200,25],...
        'Callback',@Analyze);
    uicontrol(...
        'Style','text',...
        'String','High Pass Filter Constant:',...
        'Position',[10,815,200,25],...
        'HorizontalAlignment','Center');
    hHPF = uicontrol(...
        'Style','edit',...
        'String','0.98',...
        'Position',[10,800,200,25]);
    uicontrol(...
        'Style','text',...
        'String','Low Pass Filter Constant:',...
        'Position',[10,765,200,25],...
        'HorizontalAlignment','Center');
    hLPF = uicontrol(...
        'Style','edit',...
        'String','0.02',...
        'Position',[10,750,200,25]);
    
    % GUI Output
    htheta1 = axes(...
        'Units','Pixels',...
        'Position',[270,630,400,250]);
    htheta2 = axes(...
        'Units','Pixels',...
        'Position',[270,330,400,250]);
    htheta3 = axes(...
        'Units','Pixels',...
        'Position',[850,330,400,250]);
    htheta4 = axes(...
        'Units','Pixels',...
        'Position',[270,30,400,250]);
    htheta5 = axes(...
        'Units','Pixels',...
        'Position',[850,30,400,250]);
    
    function GetFile_Callback(~,~)
        % Choose the file that you would like to analyze - it must be an 
        % Excel file
        [name,path] = uigetfile('*.xlsx');
        % Concatenate the file path and the file name of the file you chose
        % so that we can open it in the next line of code
        filename = [path,name];
        setappdata(h,'filename',filename);
    end
    function Analyze(~,~)
        filename = getappdata(h,'filename');
        [~,sheetNames] = xlsfinfo(filename);
        numSheets = length(sheetNames);
        sheet = cell(numSheets,1);
        for s = 1:numSheets
            [sheet{s},~,~] = xlsread(filename,s);
            updateRate = 60;    % Hz
            dt = 1/updateRate;  % s
            currentHPFVal = str2double(get(hHPF,'string'));
            currentLPFVal = str2double(get(hLPF,'string'));
            
            thisSheet = sheet{s};
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
            
            acc_x{s} = thisSheet(:,3);
            acc_y{s} = thisSheet(:,4);
            acc_z{s} = thisSheet(:,5);
            thetaX_acc{s} = currentLPFVal*atan2(acc_z{s},acc_y{s});
            thetaY_acc{s} = currentLPFVal*atan2(acc_x{s},acc_z{s});
            thetaZ_acc{s} = currentLPFVal*atan2(acc_y{s},acc_x{s});
            
            gyr_x{s} = thisSheet(:,6);
            gyr_y{s} = thisSheet(:,7);
            gyr_z{s} = thisSheet(:,8);
            thetaX{s} = zeros(size(gyr_x{s}));
            thetaY{s} = thetaX{s};
            thetaZ{s} = thetaY{s};
            for a = 1:length(gyr_x{s})
                if a == 1
                    thetaX{s}(a) = currentHPFVal*thetaX{s}(a)*dt + thetaX_acc{s}(a);
                    thetaY{s}(a) = currentHPFVal*thetaY{s}(a)*dt + thetaY_acc{s}(a);
                    thetaZ{s}(a) = currentHPFVal*thetaZ{s}(a)*dt + thetaZ_acc{s}(a);
                else
                    thetaX{s}(a) = currentHPFVal*(thetaX{s}(a-1) + gyr_x{s}(a)*dt) + thetaX_acc{s}(a);
                    thetaY{s}(a) = currentHPFVal*(thetaY{s}(a-1) + gyr_y{s}(a)*dt) + thetaY_acc{s}(a);
                    thetaZ{s}(a) = currentHPFVal*(thetaZ{s}(a-1) + gyr_z{s}(a)*dt) + thetaZ_acc{s}(a);
                end
            end
            switch s
                case 1
                    set(h,'CurrentAxes',htheta1)
                case 2
                    set(h,'CurrentAxes',htheta2)
                case 3
                    set(h,'CurrentAxes',htheta3)
                case 4
                    set(h,'CurrentAxes',htheta4)
                case 5
                    set(h,'CurrentAxes',htheta5)
            end
            x = plot(thetaX{s});
            hold on
            [pksX,plocX] = findpeaks(thetaX{s});
            [valX,vlocX] = findpeaks(-thetaX{s});
            plot(plocX,pksX,'x')
            plot(vlocX,-valX,'o')
            y = plot(thetaY{s});
            [pksY,plocY] = findpeaks(thetaY{s});
            [valY,vlocY] = findpeaks(-thetaY{s});
            plot(plocY,pksY,'x')
            plot(vlocY,-valY,'o')
            z = plot(thetaZ{s});
            [pksZ,plocZ] = findpeaks(thetaZ{s});
            [valZ,vlocZ] = findpeaks(-thetaZ{s});
            plot(plocZ,pksZ,'x')
            plot(vlocZ,-valZ,'o')
            title(sheetNames{s})
            xlabel('Time (s)')
            ylabel('Angle (radians)')
            legend([x,y,z],{'X','Y','Z'},'Location','southoutside',...
                'Orientation','horizontal')
            hold off
            dataname = sprintf('Sheet_%u_',s);
            setappdata(h,[dataname,'thetaX'],thetaX);
            setappdata(h,[dataname,'thetaX_peaks'],[pksX,plocX]);
            setappdata(h,[dataname,'thetaX_valleys'],[valX,vlocX]);
            setappdata(h,[dataname,'thetaY'],thetaY);
            setappdata(h,[dataname,'thetaY_peaks'],[pksY,plocY]);
            setappdata(h,[dataname,'thetaY_valleys'],[valY,vlocY]);
            setappdata(h,[dataname,'thetaZ'],thetaZ);
            setappdata(h,[dataname,'thetaZ_peaks'],[pksZ,plocZ]);
            setappdata(h,[dataname,'thetaZ_valleys'],[valZ,vlocZ]);
        end
    end
end