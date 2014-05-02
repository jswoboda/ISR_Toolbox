function varargout = view3Dslice(varargin)
% VIEW3DSLICE MATLAB code for view3Dslice.fig
%      VIEW3DSLICE, by itself, creates a new VIEW3DSLICE or raises the existing
%      singleton*.
%
%      H = VIEW3DSLICE returns the handle to a new VIEW3DSLICE or the handle to
%      the existing singleton*.
%
%      VIEW3DSLICE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEW3DSLICE.M with the given input arguments.
%
%      VIEW3DSLICE('Property','Value',...) creates a new VIEW3DSLICE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before view3Dslice_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to view3Dslice_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help view3Dslice

% Last Modified by GUIDE v2.5 28-Sep-2012 14:37:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @view3Dslice_OpeningFcn, ...
                   'gui_OutputFcn',  @view3Dslice_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


%% Init
function view3Dslice_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for view3Dslice
handles.output = hObject;

% Initalize some counters
handles.flags.dataloaded = 0;
handles.flags.dragging = 0;
handles.xslicenum = 1;
handles.yslicenum = 1;
handles.zslicenum = 1;
handles.scrollax = 1;
handles.amin = 1;
handles.amax = 256;
handles.alphavec = linspace(0,1,256);
if nargin>3
    handles = load_from_command(handles,varargin{:});
end
% Update handles structure
guidata(hObject, handles);

%% Output (unused)
function varargout = view3Dslice_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
%% Load from command line
function handles = load_from_command(handles,varargin)


% check the input to see if its a cell array.
if iscell(varargin{1})
    % take the first matrix of data by default
    handles.Data_Cell = varargin{1};
    matrix = handles.Data_Cell{1};
else
    % same idea as before
    handles.Data_Cell = {varargin{1}};
    matrix = varargin{1};
end
% Store our shiny new data
handles.matrix = matrix;
handles.xsca = varargin{2};
handles.ysca = varargin{3};
handles.zsca = varargin{4};
handles.nxpt = length(handles.xsca);
handles.nypt = length(handles.ysca);
handles.nzpt = length(handles.zsca);
handles.xname = varargin{5};
handles.yname = varargin{6};
handles.zname = varargin{7};

if nargin >8
    names_cell = varargin{8};
    if size(names_cell,2)>size(names_cell,1) 
        names_cell = names_cell';
    end
    handles.Data_Names = names_cell;
else
    N_data = length(handles.Data_Cell);
    names_cell = cell(N_data,1);
    for n = 1:N_data
        names_cell = ['Data ',num2str(n)];
    end
    handles.Data_Names = names_cell;
end

handles.cmin = min(reshape(matrix,1,numel(matrix)));
handles.cmax = max(reshape(matrix,1,numel(matrix)));
handles.flags.dataloaded = 1;

% Set slider steps
set(handles.slider_xy,'SliderStep',[1/handles.nzpt,0.1]);
set(handles.slider_xz,'SliderStep',[1/handles.nypt,0.1]);
set(handles.slider_yz,'SliderStep',[1/handles.nxpt,0.1]);

% Reset flags
handles.flags.dragging = 0;
handles.xslicenum = 1;
handles.yslicenum = 1;
handles.zslicenum = 1;
handles.altslicenum = 1;

% Update plots
cla(handles.axes_3d);
cla(handles.axes_alphamap);
cla(handles.axes_xy_slice);
cla(handles.axes_xz_slice);
cla(handles.axes_yz_slice);
% Update the alphamap
updateAlphaview(handles);
% Make the 3D plot
view(handles.axes_3d,3);
hold(handles.axes_3d,'all');
% Create the first slice down the middle
update3Dview(handles,handles.axes_3d,[round(handles.nxpt/2)],[],[]);
handles.slicesx = [round(handles.nxpt/2)];
handles.slicesz = [];
% And update the 2D plots
update2Dview(handles);

% Data choice
set(handles.datachoicepopupmenu,'string',names_cell);


%% Load Routine
function push_load_Callback(hObject, eventdata, handles)
% Load up a .mat file with pre-defined variable names;
%  matrix = 3D matrix (real values) for plotting.
%  nscale = scale (vector) for axis n.
%  nname = name (string) for axis n.
[FileName,PathName,FilterIndex] = uigetfile('*.mat','SelectFiles','MultiSelect','Off');
% Checks done in this order!!
if ~iscell(FileName) && (length(FileName) == 1) && (FileName == 0) % User canceled
    return;
else
    load([PathName,FileName]);
end
% Store our shiny new data
handles.matrix = matrix;
handles.xsca = xsca;
handles.ysca = ysca;
handles.zsca = zsca;
handles.nxpt = length(xsca);
handles.nypt = length(ysca);
handles.nzpt = length(zsca);
handles.xname = xname;
handles.yname = yname;
handles.zname = zname;
handles.cmin = min(reshape(matrix,1,numel(matrix)));
handles.cmax = max(reshape(matrix,1,numel(matrix)));
handles.flags.dataloaded = 1;

% Set slider steps
set(handles.slider_xy,'SliderStep',[1/handles.nzpt,0.1]);
set(handles.slider_xz,'SliderStep',[1/handles.nypt,0.1]);
set(handles.slider_yz,'SliderStep',[1/handles.nxpt,0.1]);

% Reset flags
handles.flags.dragging = 0;
handles.xslicenum = 1;
handles.yslicenum = 1;
handles.zslicenum = 1;
handles.altslicenum = 1;

% Update plots
cla(handles.axes_3d);
cla(handles.axes_alphamap);
cla(handles.axes_xy_slice);
cla(handles.axes_xz_slice);
cla(handles.axes_yz_slice);
% Update the alphamap
updateAlphaview(handles);
% Make the 3D plot
view(handles.axes_3d,3);
hold(handles.axes_3d,'all');
% Create the first slice down the middle
update3Dview(handles,handles.axes_3d,[round(handles.nxpt/2)],[],[]);
handles.slicesx = [round(handles.nxpt/2)];
handles.slicesz = [];
% And update the 2D plots
update2Dview(handles);

% Update handles structure
guidata(hObject, handles);

%% Update plot functions
%% -- updateAlphaview
function updateAlphaview(handles)
cla(handles.axes_alphamap);
% Remake the alphavec vector
alphavec = zeros(1,256);
slopeind = handles.amin:handles.amax;
alphavec(slopeind) = linspace(0,1,numel(slopeind));
alphavec(handles.amax:end) = 1;
handles.alphavec = alphavec;

% Take the histogram and plot it, overlay the
values = reshape(handles.matrix,1,numel(handles.matrix));
hold(handles.axes_alphamap,'on');
hist(handles.axes_alphamap,values,256);
[hN,hX] = hist(handles.axes_alphamap,values,256);
xplot = linspace(min(values),max(values),256);
plot(handles.axes_alphamap,xplot,handles.alphavec*max(hN),'LineWidth',2);
axis(handles.axes_alphamap,'tight');
% Draw the bars for the low and high cutoffs
[xaxsize] = get(handles.axes_alphamap,'xlim');
[yaxsize] = get(handles.axes_alphamap,'ylim');
plot(handles.axes_alphamap,[1,1]*handles.amin/256*xaxsize(2)+xaxsize(1),yaxsize,'r','LineWidth',2)
plot(handles.axes_alphamap,[1,1]*handles.amax/256*xaxsize(2)+xaxsize(1),yaxsize,'g','LineWidth',2)
% Label everything
xlabel(handles.axes_alphamap,'Intensity');
ylabel(handles.axes_alphamap,'Counts');
title(handles.axes_alphamap,sprintf('Alpha Map (%2.2e : %2.2e)',hX(handles.amin),hX(handles.amax)));

%% -- update3Dview
function update3Dview(handles,h_axes,x_vec,y_vec,z_vec)

useglobalmm = get(handles.check_globalmaxmin,'Value');
augmat = handles.matrix(:);
augmat = augmat(augmat~=-Inf);

min_all = min(augmat);
max_all = max(augmat);
global_lims = [min_all,max_all];

[Xi,Yi,Zi] = meshgrid(handles.xsca,handles.ysca,handles.zsca);
new_x = handles.xsca(x_vec);
new_y = handles.ysca(y_vec);
new_z = handles.zsca(z_vec);

slice_hand = slice(h_axes,Xi,Yi,Zi,handles.matrix,new_x,new_y,new_z);
caxis(global_lims)
if useglobalmm
    caxis([handles.cmin,handles.cmax]);
end
colormap jet;
xlabel(h_axes,handles.xname);
ylabel(h_axes,handles.yname);
zlabel(h_axes,handles.zname);
grid(h_axes,'on');
colorbar('peer',h_axes);

%% -- update2Dview
function update2Dview(handles)
useglobalmm = get(handles.check_globalmaxmin,'Value');
augmat = handles.matrix(:);
augmat = augmat(augmat~=-Inf);

min_all = min(augmat);
max_all = max(augmat);
global_lims = [min_all,max_all];

% plot xy
axes(handles.axes_xy_slice);
imagesc(handles.xsca,handles.ysca,...
    squeeze(handles.matrix(:,:,handles.zslicenum))',global_lims);
if useglobalmm
    caxis([handles.cmin,handles.cmax]);
end
set(gca,'Ydir','Normal');

xlabel(handles.axes_xy_slice,handles.xname);
ylabel(handles.axes_xy_slice,handles.yname);
title(handles.axes_xy_slice,sprintf('XY Image (Z = %d, %2.2f)',...
    handles.zslicenum,handles.zsca(handles.zslicenum)));
%plot xz
axes(handles.axes_xz_slice);
imagesc(handles.xsca,handles.zsca,...
    squeeze(handles.matrix(:,handles.yslicenum,:))',global_lims);
if useglobalmm
    caxis([handles.cmin,handles.cmax]);
end
set(gca,'Ydir','Normal');

xlabel(handles.axes_xz_slice,handles.xname);
ylabel(handles.axes_xz_slice,handles.zname);
title(handles.axes_xz_slice,sprintf('XZ Image (Y = %d, %2.2f)',...
    handles.yslicenum,handles.ysca(handles.yslicenum)));
% plot yz
axes(handles.axes_yz_slice);
imagesc(handles.ysca,handles.zsca,...
    squeeze(handles.matrix(handles.xslicenum,:,:))',global_lims);
if useglobalmm
    caxis([handles.cmin,handles.cmax]);
end
set(gca,'Ydir','Normal');
xlabel(handles.axes_yz_slice,handles.yname);
ylabel(handles.axes_yz_slice,handles.zname);
title(handles.axes_yz_slice,sprintf('YZ Image (X = %d, %2.2f)',...
    handles.xslicenum,handles.xsca(handles.xslicenum)));


%% Mouse Scroll
function figure1_WindowScrollWheelFcn(hObject, eventdata, handles)
% Get which axis the click occured in
% And perform the requisite function

%fprintf('%s\n',get(get(hObject,'CurrentAxes'),'Tag'));
switch get(get(hObject,'CurrentAxes'),'Tag')
    otherwise
        % If the tag is empty, check the children
        get(get(get(hObject,'CurrentAxes'),'Children'),'Tag')
        switch get(get(get(hObject,'CurrentAxes'),'Children'),'Tag');
            case 'axes_xy_image'
                fprintf('xy-image wheel\n');
            case 'axes_xz_image'
                fprintf('xy-image wheel\n');
            case 'axes_yz_image'
                fprintf('xy-image wheel\n');
            otherwise
        end
end

%% Mouse Click / Drag
%% --ButtonDown
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
if handles.flags.dataloaded
    switch get(get(hObject,'CurrentAxes'),'Tag')
        case 'axes_alphamap'
            clickpts = get(get(hObject,'CurrentAxes'),'CurrentPoint');
            [xaxsize] = get(handles.axes_alphamap,'xlim');
            cindex = round(256*(clickpts(1,1)-xaxsize(1))/xaxsize(2));
            
            if abs(cindex-handles.amin) < abs(cindex-handles.amax)
                handles.amin = cindex;
                handles.flags.dragging = 1;
            else
                handles.amax = cindex;
                handles.flags.dragging = 2;
            end
            
            % Update handles
            guidata(hObject, handles);
            % And update the plot
            updateAlphaview(handles);
    end
    % Update handles structure
    guidata(hObject, handles);
end

%% --ButtonMotion
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% Drag the active bar around if availble
if handles.flags.dragging ~= 0
    clickpts = get(get(hObject,'CurrentAxes'),'CurrentPoint');
    [xaxsize] = get(handles.axes_alphamap,'xlim');
    cindex = round(256*(clickpts(1,1)-xaxsize(1))/xaxsize(2));
    if handles.flags.dragging == 1
        if handles.amin > 1
            handles.amin = cindex;
        else
            handles.amin = 1;
        end
    elseif handles.flags.dragging == 2
        if handles.amax < 256;
            handles.amax = cindex;
        else
            handles.amax = 256;
        end
    end
    
    % Update handles structure
    guidata(hObject, handles);
    % Update the alphamap
    updateAlphaview(handles);
end

%% -- ButtonUp
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
if handles.flags.dataloaded
    % Discard any flags telling use we're active
    if handles.flags.dragging ~=0
        handles.flags.dragging = 0;
        % and update the 3D view
        update3Dview(handles);
    end
    % Update handles structure
    guidata(hObject, handles);
end

%% Slider Callbacks
%% -- Slider xy
function slider_xy_Callback(hObject, eventdata, handles)
handles.zslicenum = round(get(handles.slider_xy,'value')*handles.nzpt);
% Update handles structure
guidata(hObject, handles);
% Update the 2D plot
update2Dview(handles);

%% -- Slider xz
function slider_xz_Callback(hObject, eventdata, handles)
handles.yslicenum = round(get(handles.slider_xz,'value')*handles.nypt);
% Update handles structure
guidata(hObject, handles);
% Update the 2D plot
update2Dview(handles);

%% -- Slider yz
function slider_yz_Callback(hObject, eventdata, handles)
handles.xslicenum = round(get(handles.slider_yz,'value')*handles.nxpt);
% Update handles structure
guidata(hObject, handles);
% Update the 2D plot
update2Dview(handles);

%% -- Slider Alt
function altsliceslider_Callback(hObject, eventdata, handles)
handles.altslicenum = round(get(handles.altsliceslider,'value')*handles.nzpt);
% Update handles structure
guidata(hObject, handles);

%% 2D Plot Options
%% -- Use Global Max/Min
function check_globalmaxmin_Callback(hObject, eventdata, handles)
% Update handles structure
guidata(hObject, handles);
% Update the 2D plot
update2Dview(handles);

%% -- Analyze Data
function push_analyze_Callback(hObject, eventdata, handles)
% Prototype analyze function goes here
% xyimage = squeeze(handles.matrix(:,:,handles.zslicenum))';
% xzimage = squeeze(handles.matrix(:,handles.zslicenum,:))';
% yzimage = squeeze(handles.matrix(handles.zslicenum,:,:))';
% analyze(xyimage,xzimage,yzimage,handles.xsca,handles.ysca,handles.zsca);


%% Unused Autogenerated Code
function slider_xy_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider_xz_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider_yz_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%% Make fig pushbuttons
%% -- Make Fig 3d
% --- Executes on button press in makefig3dpushbutton.
function makefig3dpushbutton_Callback(hObject, eventdata, handles)
h = figure('Name','3-D Data');
view(gca,3);

update3Dview(handles,gca,handles.slicesx,[],handles.slicesz);
xlabel(handles.xname);
ylabel(handles.yname);
zlabel(handles.zname);
grid on;
colorbar('peer',handles.axes_3d);

%% -- Make Fig XY
% --- Executes on button press in makefigxypushbutton.
function makefigxypushbutton_Callback(hObject, eventdata, handles)
% create an extra figure window for xy
useglobalmm = get(handles.check_globalmaxmin,'Value');
% plot xy
h = figure('Name','XY Slice');
imagesc(handles.xsca,handles.ysca,squeeze(handles.matrix(:,:,handles.zslicenum))');
if useglobalmm
    caxis([handles.cmin,handles.cmax]);
end
set(gca,'Ydir','Normal');
xlabel(handles.xname);
ylabel(handles.yname);
title(sprintf('XY Image (Z = %d, %2.2f)',...
    handles.zslicenum,handles.zsca(handles.zslicenum)));
%% -- Make Fig XZ
% --- Executes on button press in makefigxzpushbutton.
function makefigxzpushbutton_Callback(hObject, eventdata, handles)

useglobalmm = get(handles.check_globalmaxmin,'Value');
h  = figure ('Name','XZ Slice');
%plot xz
imagesc(handles.xsca,handles.zsca,squeeze(handles.matrix(:,handles.yslicenum,:))');
if useglobalmm
    caxis([handles.cmin,handles.cmax]);
end
set(gca,'Ydir','Normal');
xlabel(handles.xname);
ylabel(handles.zname);
title(sprintf('XZ Image (Y = %d, %2.2f)',...
    handles.yslicenum,handles.ysca(handles.yslicenum)));
colorbar

%% -- Make Fig YZ
% --- Executes on button press in makefigyzpushbutton.
function makefigyzpushbutton_Callback(hObject, eventdata, handles)

useglobalmm = get(handles.check_globalmaxmin,'Value');
h  = figure ('Name','YZ Slice');
% plot yz
imagesc(handles.ysca,handles.zsca,squeeze(handles.matrix(handles.xslicenum,:,:))');
if useglobalmm
    caxis([handles.cmin,handles.cmax]);
end
set(gca,'Ydir','Normal');

xlabel(handles.yname);
ylabel(handles.zname);
title(sprintf('YZ Image (X = %d, %2.2f)',...
    handles.xslicenum,handles.xsca(handles.xslicenum)));
colorbar

%% Add Alt Slice

% --- Executes during object creation, after setting all properties.
function altsliceslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to altsliceslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in addslicepushbutton.
function addslicepushbutton_Callback(hObject, eventdata, handles)
alt = handles.altslicenum;
update3Dview(handles,handles.axes_3d,[],[],alt);
handles.slicesz = [handles.slicesz,alt];
% Update handles structure
guidata(hObject, handles);
%% Data choice pop up

% --- Executes on selection change in datachoicepopupmenu.
function datachoicepopupmenu_Callback(hObject, eventdata, handles)
Data_choice = get(handles.datachoicepopupmenu,'Value');
handles.matrix = handles.Data_Cell{Data_choice};
% Reset the 3-D view
cla(handles.axes_3d);
update3Dview(handles,handles.axes_3d,handles.slicesx,[],handles.slicesz);
% And update the 2D plots
update2Dview(handles);
% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function datachoicepopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to datachoicepopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
