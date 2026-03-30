function varargout = Brain_Tumor_Detector(varargin)
% BRAIN_TUMOR_DETECTOR MATLAB code for Brain_Tumor_Detector.fig
% GUI for Brain Tumor Detection with Tumor Size Display

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Brain_Tumor_Detector_OpeningFcn, ...
                   'gui_OutputFcn',  @Brain_Tumor_Detector_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


% --- Executes just before Brain_Tumor_Detector is made visible.
function Brain_Tumor_Detector_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

% Set background and title
set(hObject, 'Color', get(0,'defaultUicontrolBackgroundColor'));
set(handles.select_mage, 'ForegroundColor', [1 0 0]);
set(handles.meadian_filtering, 'ForegroundColor', [1 0 0]);
set(handles.edge_detection, 'ForegroundColor', [1 0 0]);
set(handles.tumor_detection, 'ForegroundColor', [1 0 0]);

guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = Brain_Tumor_Detector_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes on button press: Upload MRI image
function select_mage_Callback(hObject, eventdata, handles)
global img1 img2
[path, nofile] = imgetfile();
if nofile
    msgbox(sprintf('Image not found!!!'), 'Error', 'warn');
    return
end
img1 = imread(path);
img1 = im2double(img1);
img2 = img1;

axes(handles.axes1);
imshow(img1);
title('\fontsize{18}\color[rgb]{0 0.5 1}Original MRI Image');


% --- Executes on button press: Apply median filter
function meadian_filtering_Callback(hObject, eventdata, handles)
global img1
axes(handles.axes2)
if size(img1,3) == 3
    img1 = rgb2gray(img1);
end
K = medfilt2(img1);
imshow(K);
title('\fontsize{18}\color[rgb]{0 0.5 1}Median Filter Applied');


% --- Executes on button press: Perform edge detection
function edge_detection_Callback(hObject, eventdata, handles)
global img1
axes(handles.axes3);
if size(img1,3) == 3
    img1 = rgb2gray(img1);
end
K = medfilt2(img1);
C = double(K);
B = zeros(size(C));

for i = 1:size(C,1)-2
    for j = 1:size(C,2)-2
        Gx = ((2*C(i+2,j+1)+ C(i+2,j)+C(i+2,j+2))-(2*C(i,j+1)+C(i,j)+C(i,j+2)));
        Gy = ((2*C(i+1,j+2)+ C(i,j+2)+C(i+2,j+2))-(2*C(i+1,j)+C(i,j)+C(i+2,j)));
        B(i,j) = sqrt(Gx.^2 + Gy.^2);
    end
end
imshow(B);
title('\fontsize{18}\color[rgb]{0 0.5 1}Edge Detection');


% --- Executes on button press: Tumor detection and size calculation
function tumor_detection_Callback(hObject, eventdata, handles)
global img1
axes(handles.axes4);
K = medfilt2(img1);
bw = imbinarize(K, 0.7);
label = bwlabel(bw);
stats = regionprops(label,'Solidity','Area');

density = [stats.Solidity];
area = [stats.Area];
high_density = density > 0.5;

if any(high_density)
    max_area = max(area(high_density));
    tumor_label = find(area == max_area);
    tumor = ismember(label, tumor_label);

    se = strel('square', 5);
    tumor = imdilate(tumor, se);
    boundaries = bwboundaries(tumor, 'noholes');

    imshow(K);
    hold on
    for i = 1:length(boundaries)
        plot(boundaries{i}(:,2), boundaries{i}(:,1), 'y', 'LineWidth', 2);
    end

    % Tumor size calculation and display
    tumor_pixels = sum(tumor(:));
    tumor_text = sprintf('Tumor Size: %d pixels', tumor_pixels);
    text(10, 20, tumor_text, 'Color', 'cyan', 'FontSize', 12, 'FontWeight', 'bold');

    title('\fontsize{18}\color[rgb]{1 0 0}Tumor Detected!');
    hold off
else
    msgbox('No significant tumor detected.', 'Result', 'warn');
end
