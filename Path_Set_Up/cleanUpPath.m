function cleanUpPath()
% cleanUpPath.m
% This function will "clean up" the matlab path from the ISR_Tool_Box 

str_remove = 'ISR_Toolbox';
path_str = path;

path_cell = regexp(path_str,pathsep,'split');

remove_log = false(size(path_cell));

for k = 1:numel(path_cell)
    if ~isempty(strfind(path_cell{k},str_remove))
        remove_log(k) = true;
        rmpath(path_cell{k});
    end
end


disp('Folders removed from the path:')
disp(path_cell(remove_log)');

resp = input('Are you sure you want to permanently  modify your path, y/n: ', 's');
if strcmpi(resp, 'y')
    status = savepath();
    if ~status
    	disp('Files permanently removed from path');
    else
    	disp('pathdef.m was not saved, this path will only be temporary, check folder permissions');
    end
end   