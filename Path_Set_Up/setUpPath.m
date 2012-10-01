function setUpPath(varargin)
% setUpPath.m
% by John Swoboda
% This function will set up the path for the ISR toolbox and make the path
% selection perminent if the user so desires.  
% Example use
% setUpPath()
% setUpPath(setup_type)
% setUpPath(setup_type,save_location)
% Inputs
% setup_type - (Optional) This determines whether or user wants to
% perminetly add the changes to the pathdef.m file.  The choices are 'temp'
% or 'perminent'.  The default is temp.
% save_location - (Optional) This determines the location of the pathdef.m
% file is the user chooses to save the file.

%% Deal with inputs
if nargin ==0
    setup_type = 'temp';
elseif nargin ==1
    setup_type = varargin{1};
    save_location = [];
elseif nargin ==2
    setup_type = varargin{1};
    save_location = varargin{2};
end
%% Do path set up
% get the current path of this file
tmp = mfilename('fullpath');
[cur_file_path,~,~] = fileparts(tmp);

file_sep_loc = strfind(cur_file_path,filesep); 

code_path = cur_file_path(1:file_sep_loc(end));

all_folders = genpath(code_path);

all_paths_cell = regexp(all_folders,pathsep,'split');
% check for hidden folders and get rid of them because they won't be on the
% path and they clutter everything
path_log = true(size(all_paths_cell));
first_entry = true;
for k = 1:length(all_paths_cell)
    
    if isempty(strfind(all_paths_cell{k},[filesep,'.']))
        if first_entry
            big_path_string = all_paths_cell{k};
            first_entry = false;
        else
            big_path_string = [big_path_string,pathsep,all_paths_cell{k}];
        end
    else
        path_log(k) = false;
    end
    % Some times this adds empty strings to the path
    if isempty(all_paths_cell{k})
        path_log(k) = false;
    end
end

all_paths_cell = all_paths_cell(path_log);
addpath(all_paths_cell{:},'-end');
disp('Folders added to the path:')
disp(all_paths_cell')
%% Make path perminent or not
if strcmpi(setup_type,'permanent')
    resp = input('Are you sure you want to perminetly modify your path, y/n', 's');
    if strcmpi(resp, 'y')&&exist(save_location,'dir')
        status = savepath(fullfile(save_location,'pathdef.m'));
        if ~status
            disp(['New pathdef.m file saved to directory: ',save_location]);
        else
            disp('pathdef.m was not saved, this path will only be temporary, check folder permissions');
        end
    elseif strcmpi(resp,'y')&& isempty(save_location)
        status = savepath;
        if ~status
            disp('New pathdef.m file saved to directory to root directory');
        else
            disp('pathdef.m was not saved, this path will only be temporary, check folder permissions');
        end
    elseif strcmpi(resp, 'y')&&~exist(save_location,'dir')
        disp('Folder does not exist, run this function again with a folder that exists');
    end
end

    end