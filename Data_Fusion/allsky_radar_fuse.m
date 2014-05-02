function outstruct = allsky_radar_fuse(allsky_files,madfile,alt_level,allsky_dim,...
    field_names)


if numel(allsky_dim)==1
    allsky_dim = [allsky_dim,allsky_dim];
end
N_files = numel(allsky_files);
out_opt = zeros(allsky_dim(:),N_files);
time_stamp = zeros(1,N_files);

All_Data = h5read(madfile,'/Data/Table Layout');
% get rid of nans in the range measurement
All_Data = struct_trim(All_Data,~isnan(All_Data.range));
[ut_beg,ia,ic] = unique(All_Data.ut1_unix);
ut_end = unique(All_Data.ut2_unix);


%% Read and interpolate allsky
for k = 1:N_files;


    allsky_file = allsky_files{k};
    [~,allsky_file_name,~] = fileparts(allsky_file);
    
    fprintf('Now processing %s\n\n',allsky_file_name);
    
    time_stamp(k) = fitsfiletimestamp(allsky_file_name);
    time_stamp_unix = datestr2unix(time_stamp(k));
    
    un_loc = find((ut_beg<=time_stamp_unix) & (ut_end>time_stamp_unix)&...
        ~isnan(All_Data.range));
    
    % determine altitude allsky will be interpolated to 630nm will go to
    % 270km and 428 and 558 will go to 140 km
    f_parts = regexp(allsky_file_name,'\_','split');
    lam = f_parts{3};
    
    % Read in an interpolate
    alls_raw = fitsread(allsky_file);

    [X_out,Y_out,d_image_2] = allsky2enu(alls_raw,az_data,...,
        el_data,alt_level,allsky_dim);
    out_opt(:,:,k) = d_image_2;
end

    %% Trim data

    time_stamp_unix = datestr2unix(time_stamp);
    
    
    % Find time period that the image is located
    keep_data = (All_Data.ut1_unix<=time_stamp_unix) & (All_Data.ut2_unix>time_stamp_unix)&...
        ~isnan(All_Data.range);
    Trimed_Data = struct_trim(All_Data,keep_data);
    
    %% Interpolate to ENU grid
    % determine
    cur_time = double(unique(Trimed_Data.ut1_unix));
    cur_time2 = double(unique(Trimed_Data.ut2_unix));
    if cur_time ~= prev_time
        prev_time = cur_time;
        
        % ne
        [X_mat,Y_mat,alt_mat] = meshgrid(X_out,Y_out,alt_level);
        posmesh = [X_mat(:),Y_mat(:),alt_mat(:)];
        Ne = interp3dFlatENU(Trimed_Data.azm,Trimed_Data.elm,Trimed_Data.range*1e3,...
            Trimed_Data.ut1_unix,posmesh,Trimed_Data.nel);
        Ne_image = 10.^(reshape(Ne, size(X_mat)));
        % Ti
        
        [X_mat,Y_mat,alt_mat] = meshgrid(X_out,Y_out,Ti_alt);
        posmesh = [X_mat(:),Y_mat(:),alt_mat(:)];
        Ti = interp3dFlatENU(Trimed_Data.azm,Trimed_Data.elm,Trimed_Data.range*1e3,...
            Trimed_Data.ut1_unix,posmesh,Trimed_Data.ti);
        Ti_image = reshape(Ti, size(X_mat));
        
        timespan_str = [datestr(unixtime2matlab(cur_time),'HH:MM:SS'),...
            ' - ',datestr(unixtime2matlab(cur_time2),'HH:MM:SS')];
    end
    
end