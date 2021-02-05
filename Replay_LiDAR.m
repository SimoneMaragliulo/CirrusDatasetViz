close all
clear
clc

%% user inputs
datasetNum      = '2';          %shall match the dataset numbering system
LiDARtype       = 'gaussian';   %uniform or gaussian
depthLim        = 50;           %LiDAR plot depth visualization limit (m)
latLim          = 25;           %LiDAR plot lateral visualization limit (m)
altLim          = 20;           %LiDAR plot altitude visualization limit (m)
colorLim        = 30;           %LiDAR plot radial distance colormap limit (m)
bkgdCol         = [0 0 0];      %LiDAR plot background color triplet
clMap           = 'spring';     %Point cloud Colormap name: https://www.mathworks.com/help/matlab/ref/colormap.html 
camVwLatAng     = 87;           %LiDAR plot camera view orizzontal angle: 90 = driver view, 0 = lateral view 
camVwAltAng     = 20;           %LiDAR plot camera view orizzontal angle: 0 = sensor view, 90 = top view 

%% LiDAR files list building and files conversion 
disp('>>> Starting LiDAR files conversion .xyz 2 .txt')

Ldir            = ['dataset',datasetNum,'_', LiDARtype];    %LiDAR files directory
flLst           = dir([Ldir, '\*.xyz']);                    %LiDAR files list
addpath(genpath(Ldir))

% conversion .xyz to .txt to speed up reading
for i = 1:numel(flLst)
    file            = fullfile(Ldir, flLst(i).name);
    [tmpDir, tmpFl] = fileparts(file); 
    status          = copyfile(file, fullfile(tmpDir, [tmpFl, '.txt']));
    delete(file)  
end

flLst           = dir([Ldir, '\*.txt']);                    %LiDAR files list after conversion

disp('>>> Ended LiDAR files conversion .xyz 2 .txt')

%% Camera files list building

imgDir          = ['dataset',datasetNum,'_camera'];         %Camera files directory
imgLst          = dir([imgDir, '\*.jpg']);                  %Camera files list
addpath(genpath(imgDir))

%% data replay
disp('>>> Data replay started')

fig     = figure('units','normalized','outerposition',[0 0 .5 1]);
for i = 1:numel(flLst)
    
    % numeric reference
    disp(['file: ', num2str(i), '/', num2str(numel(flLst)),' ', imgLst(i).name])
    
    % Camera plot
    subplot(3,1,1)
    imr             = imread(imgLst(i).name);
    imshow(imr);
    
    % LiDAR plot
    subplot(3,1,[2 3])
    dt              = importdata(flLst(i).name);
    a               = dt(:,1);                              %LiDAR x data
    b               = dt(:,2);                              %LiDAR y data
    c               = dt(:,3);                              %LiDAR z data
    scatter3(a,b,c,1, sqrt(a.^2 + b.^2 + c.^2))
    set(gca, 'Color', bkgdCol)
    xlim([0 depthLim]), xlabel('x')
    ylim([-latLim latLim]), ylabel('y')
    zlim([-5 altLim]), zlabel('z')
    colormap(clMap)
    c               = colorbar;
    c.Label.String  = 'Radial distance (m)';
    caxis([0, colorLim])
    view(-camVwLatAng, camVwAltAng)

    drawnow
    axis equal

end

disp('>>> Data replay ended')
