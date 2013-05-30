function varargout = beam_params(varargin)
% BEAM_PARAMS MATLAB code for beam_params.fig
%      BEAM_PARAMS, by itself, creates a new BEAM_PARAMS or raises the existing
%      singleton*.
%
%      H = BEAM_PARAMS returns the handle to a new BEAM_PARAMS or the handle to
%      the existing singleton*.
%
%      BEAM_PARAMS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BEAM_PARAMS.M with the given input arguments.
%
%      BEAM_PARAMS('Property','Value',...) creates a new BEAM_PARAMS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before beam_params_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to beam_params_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help beam_params

% Last Modified by GUIDE v2.5 30-May-2013 17:29:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @beam_params_OpeningFcn, ...
                   'gui_OutputFcn',  @beam_params_OutputFcn, ...
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


% --- Executes just before beam_params is made visible.
function beam_params_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to beam_params (see VARARGIN)

% Choose default command line output for beam_params
handles.output = hObject;

if nargin>3
    handles = load_input(handles,varargin{:});
    handles = update_image(handles,handles.imageaxis);
end

% Update handles structure
guidata(hObject, handles);


%% call back info
% --- Outputs from this function are returned to the command line.
function varargout = beam_params_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in beamchoicepopup.
function beamchoicepopup_Callback(hObject, eventdata, handles)
% hObject    handle to beamchoicepopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = update_image(handles,handles.imageaxis);
% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function beamchoicepopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to beamchoicepopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in datachoicepopup.
function datachoicepopup_Callback(hObject, eventdata, handles)
% hObject    handle to datachoicepopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = update_image(handles,handles.imageaxis);
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function datachoicepopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to datachoicepopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% Load in Data for function
function handles = load_input(handles,varargin)
% input for function
% beam_params(az,el,range,time,data_name1,data1,data_name2,data2...);
% read in all data
az_all = varargin{1};
el_all = varargin{2};
range_all = varargin{3};
time_all = varargin{4};
% get rid of nans
keep = ~isnan(az_all)&~isnan(el_all)&~isnan(range_all)&~isnan(time_all);
az_all = az_all(keep);
el_all = el_all(keep);

range_all = range_all(keep);
time_all = time_all(keep);
%organize the beams
bco = [az_all,el_all];
% unique command for beams
[u_beams,~,beam_num] = unique(bco,'rows');
n_beams = size(u_beams,1);
%Get the parameters out
n_pre_inputs = 4;% number of previous inputs in varargin
n_params = (nargin-(n_pre_inputs+1))/2;
if logical(mod(n_params,1))
    error('Your parameters do not have matching names');
end
all_params = cell(n_params,2);


for i_inp = 1:n_params
    all_params{i_inp,1} = varargin{2*i_inp-1+n_pre_inputs};
    
    all_params{i_inp,2} = varargin{2*i_inp+n_pre_inputs}(keep);
end
% fill in handle array
handles.u_beams = u_beams;
handles.beam_nums = beam_num;
handles.range_all = range_all;
handles.time_all = time_all;
handles.all_params = all_params;

% Set data popup menu
set(handles.datachoicepopup,'string',all_params(:,1))
set(handles.datachoicepopup,'value',1);

% Set the string for the beam popup menu
names_cell = cell(n_beams,1);
for i_beam = 1:n_beams
    names_cell{i_beam} = sprintf('Az: %g deg El: %g deg',u_beams(i_beam,:));
end
set(handles.beamchoicepopup,'string',names_cell);
set(handles.beamchoicepopup,'value',1);
% UIWAIT makes beam_params wait for user response (see UIRESUME)
% uiwait(handles.figure1);



%% Fill In Everything
function handles = update_image(handles,handle2plot)

temp_struct = struct();
temp_struct.time_all = handles.time_all;
temp_struct.beam_nums = handles.beam_nums;
temp_struct.range_all = handles.range_all;

% get the desired values
data_value = get(handles.datachoicepopup,'value');
beam_value = get(handles.beamchoicepopup,'value');
beam_names = get(handles.beamchoicepopup,'string');
if iscell(beam_names)
    beam_choice_nm = beam_names{data_value};
elseif isstr(beam_names)
    beam_choice_nm = beam_names;
end

% Pull data out of handles struct
data_name = handles.all_params{data_value,1};
temp_struct.data_vec = handles.all_params{data_value,2};

%pull out desired data 
keep = temp_struct.beam_nums ==beam_value;
trimmed_struct = struct_trim(temp_struct,keep);

% Set up data block
[u_range,~,ic_rng] = unique(trimmed_struct.range_all);
[u_time,~,ic_time] = unique(trimmed_struct.time_all);

n_rng = length(u_range);
n_time = length(u_time);

data_block = zeros(n_rng,n_time);

indexes = sub2ind(size(data_block),ic_rng,ic_time);
data_block(indexes) = trimmed_struct.data_vec;

%give consistant limits for image
global_lims = [min(temp_struct.data_vec),max(temp_struct.data_vec)];
matlab_time = unixtime2matlab(double(u_time));
% update axis and do plotting
%axes(handles.imageaxis)
axes(handle2plot)
imagesc(matlab_time,u_range,data_block,global_lims)
datetick('x','HH:MM:SS');
set(gca,'Ydir','Normal');
colorbar('peer',handle2plot);

xlabel('Time UTC');ylabel('Range km');
title(sprintf('%s at %s',data_name,beam_choice_nm));


% --- Executes on button press in makefigpushbutton.
function makefigpushbutton_Callback(hObject, eventdata, handles)

h = figure('Name','data');
haxis = axes();

handles = update_image(handles,haxis);
