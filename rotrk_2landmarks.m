function [ TRKS_trimmed_interp, TRKS_centerline, TRKS_trimmed_nointerp ] = rotrk_2landmarks(TRKS_IN, first_roi, second_roi,number_coordinates, method, diffmetric, selected_diffmetric)
%function [ TRKS_trimmed_interp, TRKS_centerline, TRKS_trimmed_nointerp ] = rotrk_2landmarks(TRKS_IN, first_roi, second_roi,number_coordinates, method, diffmetric, selected_diffmetric)
%                                                                                           
%   INPUT (*optional) -->
%               TRKS_IN:   
%                      TRKS_IN.header -->                 header structure file (or cell list)
%                      TRKS_IN.sstr   -->                 streamlines struct file  (or cell list)
%               firt_roi:               ROI (or ROI list) where trim will happened above
%               second_roi:             ROI (or ROI list) where trim will happened below
%               *number_coordinates:     # of values for centerline interpolation (Default: 60)
%               *method:                'mean' or 'high_sc' (Default: high_sc)
%                                       method for centerline to be used.
%                                       *if high_sc is choosen make sure
%                                       you add the diffmetric as the 7th
%                                       argument!
%               *diffmetric             volumes passed to be used
%               selected_diffmetric     selects the diffmetric to be used
%                                       for the highest centerline (def. GFA)       
%
%   OUTPUT -->
%               TRK_trimmed:            trimmed header & str structure file (or cell list)
%               TRK_centerline:         centerline header & str structure file (or cell list)
%
%   *Make sure you are inputing a list of struct inputs as output
%   The first_roi will be used for flipping the initial coordinates.
%   The first_roi input will be trimmed "above" (e.g. dotfornix) the specific roi and
%   The second_roi (2nd argument roi) will be trimmed below (e.g. fimbria)
%Mean center the tract for ROI masking...


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for args_mgmt1=1:1
    if nargin < 4
        number_coordinates=40 ;
        method='mean'
        diffmetric=''
    end
    if nargin < 5
        method='mean'
        diffmetric=''
    end
    if nargin < 6
        diffmetric=''
    end
    if nargin < 7
        diffmetric='GFA'
    end
    
    %If one structure is passed only, then convert it to cell so it can act as
    %a list
    if numel(TRKS_IN) < 2
        if ~iscell(TRKS_IN)
            TRKS_IN={TRKS_IN};
        end
        if ischar(first_roi)
            first_roi=rotrk_list(first_roi,'','',1);
        end
        if ischar(second_roi)
            second_roi=rotrk_list(second_roi,'','',1);
        end
        if ischar(diffmetric)
            diffmetric=rotrk_list(diffmetric,'','',1,'GFA');
        end
        if strcmp('noID',first_roi{1}.id)
            first_roi{1}.id=TRKS_IN{1}.header.id;
        end
        if strcmp('noID',second_roi{1}.id)
            second_roi{1}.id=TRKS_IN{1}.header.id;
        end
        if strcmp('noID',diffmetric{1}.id)
            diffmetric{1}.id=TRKS_IN{1}.header.id;
        end
    end
end


%LOOPING THROUGH ALL THE IMAGES...
for ii=1:numel(TRKS_IN)
    disp([ 'In subject' char(39) 's' TRKS_IN{ii}.header.id ' ...' ] );
    %TRIMMING THE STREAMLINES...
    for kk=1:numel(first_roi) 
        %"for loop" for the first_roi and compare IDs w/ trks...
        if strcmp(TRKS_IN{ii}.header.id,first_roi{kk}.id)
            disp([ 'Flipping to origin next to the first_roi'])
            TRKS_IN{ii}=rotrk_flip(TRKS_IN{ii},[ rotrk_ROImean(first_roi{kk}.filename) ] );
            disp([ 'Trimming first_roi'])
            disp([ TRKS_IN{ii}.header.id ' and 1stROI: ' first_roi{kk}.id ])
            TRKS_trimmed{ii} = rotrk_trimmedbyROI(TRKS_IN{ii},first_roi{kk} , 'above');
        end
    end
    for kk=1:numel(second_roi)
        %"for loop" for the second_roi and compare IDs w/ trks...
        if strcmp(TRKS_IN{ii}.header.id,second_roi{kk}.id)
            disp([ 'Trimming second_roi'])
            disp([ TRKS_IN{ii}.header.id ' and 2ndROI: ' second_roi{kk}.id ])
            TRKS_trimmed_nointerp{ii}  = rotrk_trimmedbyROI(TRKS_trimmed{ii},second_roi{kk} , 'below');
        end
    end
        
    %INTERPOLATING THE TRIMMED TRKS...
    TRKS_trimmed_interp{ii} = rotrk_interp(TRKS_trimmed_nointerp{ii},number_coordinates);
  
    %ADDING THE SCALARS TO THE TRIMMED INTERP TRKS...
    for pp=1:size(diffmetric,2)
        if strcmp(cell2char(diffmetric{1,pp}.id), TRKS_trimmed_interp{ii}.header.id)
            TRKS_trimmed_interp{ii} = rotrk_add_sc(TRKS_trimmed_interp{ii}, diffmetric(:,pp));
        end
    end
    
    %NOW WORKING ON SELECTING A SPECIFIC CENTERLINE...
    TRKS_centerline{ii} = rotrk_centerline(TRKS_trimmed_interp{ii}, method, selected_diffmetric);
    
    %%##############################
    %SCALAR SHOULDN"T BE ADDED AS THEIR ARE NEEDED FOR PICKING THE
    %CENTERLINE!!
    %%##############################
%     %FINALLY ADDING SCALARS TO CENTERLIENS
%      for pp=1:size(diffmetric,2)
%         if strcmp(cell2char(diffmetric{1,pp}.id), TRKS_centerline{ii}.header.id)
%             TRKS_centerline{ii} = rotrk_add_sc(TRKS_centerline{ii}, diffmetric(:,pp));
%         end
%     end
end


