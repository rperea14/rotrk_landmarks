function [ outTable ] = rotrk_2tablev3(TRKS_IN, TRKS_ROIS_matfile)%
%function [ outTable ] = rotrk_2tablev3(TRKS_IN, TRKS_ROIS_matfile)
% Self explanatory, it generates a table based on the values given
% *!! The first hdrs or strs should be longer in size!!

%FIRST, GET THE NECESSARY VALUES FROM TRKS_IN:
[xlsTable, headerdata_field ] = local_getdemos_from_headerdata(TRKS_IN,'AD23NC23');
%~~END OF TRKS_IN adding to TABLE


if exist(TRKS_ROIS_matfile) ~=2
    error(['Cannot load matfile: ' TRKS_ROIs_matfile{end} '.Please check and input a *.mat file'])
else
    fprintf(['\n Loading ' TRKS_ROIS_matfile ' ...' ])
    all_VALS=load(TRKS_ROIS_matfile);
    fprintf('done \n')
end

stop=0;

fields_vals=fields(all_VALS);
var_fields.id=xlsTable.id;
for ii=1:numel(fields_vals)
    %Split the string by the character *_* 
    [SPLIT]  = strsplit(fields_vals{ii},'_');
    clear tmp_ROIs
    %Check whether an ROI or TRK is being input...
    if strcmp(SPLIT{1},'ROIS')
        clear tmp_ROIs tmp_fn tmp_varname vol_name ok_idx tmp_ROIS_ids
        %Assigning current ROI of interest cell array
        tmp_ROIs=all_VALS.(fields_vals{ii});
        %Creating the name for the volume_<ROI>:
        [~, tmp_fn, ~ ] =fileparts(tmp_ROIs{1}.filename{end});
        %TODEBUG ~~> display(tmp_fn);
        tmp_varname=strrep(tmp_fn,[ '_' tmp_ROIs{1}.id{end} ],'');
        vol_name=strcat('vol_',tmp_varname);
        %Get IDs for each value:
        for kk=1:numel(tmp_ROIs)
            tmp_ROIS_ids{kk}=tmp_ROIs{kk}.id{end};
        end
        %Looping though all values and assigning them to each id
        for kk=1:numel(var_fields.id)
            ok_idx=getnameidx(tmp_ROIS_ids,var_fields.id{kk});
            %if the id exist on the specific ROI, then do something
            if ok_idx ~= 0
                var_fields.(vol_name){kk} =tmp_ROIs{ok_idx}.num_uvox;
            else
                var_fields.(vol_name){kk} = NaN;
            end
        end
        var_fields.(vol_name)=var_fields.(vol_name)';
        var_fields.(vol_name)=cell2mat(var_fields.(vol_name));
    elseif strcmp(SPLIT{1},'TRKS')
        clear tmp_TRKs trk_prefix vol_trkname maxsstrlen_trkname numsstr_trkname DIFF_name
        %Assigning current trk of interest cell array 
        tmp_TRKs=all_VALS.(fields_vals{ii});
        %Creating the name for the volume_<ROI>:
        trk_prefix=tmp_TRKs{1}.trk_name;
        vol_trkname=strcat('vol',trk_prefix);
        maxsstrlen_trkname=strcat('maxsstrlen',trk_prefix);
        numsstr_trkname=strcat('numsstr',trk_prefix);
        %Init DIFF_name (if exists)
        if isfield(tmp_TRKs{1}.header,'scalar_IDs')
            for pp=1:size(tmp_TRKs{1}.header.scalar_IDs,2)
                DIFF_name{pp} = strcat(tmp_TRKs{1}.header.scalar_IDs(pp),'_',trk_prefix);
            end
        end
        %Get IDs for each value:
        for kk=1:numel(tmp_TRKs)
            tmp_TRKS_ids{kk}=tmp_TRKs{kk}.id;
        end
        %Looping though all values and assigning them to each id
        %TODEBUG ~~>
        display(['iis is: ' num2str(ii) ] ) ; 
        
        for kk=1:numel(var_fields.id)
            ok_idx=getnameidx(tmp_TRKS_ids,var_fields.id{kk});
            %if the id exist on the specific ROI, then do something
            if ok_idx ~= 0
                var_fields.(vol_trkname){kk} =tmp_TRKs{ok_idx}.num_uvox;
                var_fields.(numsstr_trkname){kk} =size(tmp_TRKs{ok_idx}.sstr,2);
                if isfield(tmp_TRKs{ok_idx},'maxsstrlen')
                    %for issues with "single" type instead of "double"
                    %arises when doubels NaNs are added...so we added the
                    %double() function below
                    var_fields.(maxsstrlen_trkname){kk} =double(tmp_TRKs{ok_idx}.maxsstrlen);
                end
                
                %DEALING WITH DIFFUSITIVY METRICS (IF EXISTS):
                if exist('DIFF_name','var')
                    for pp=1:numel(DIFF_name)
                        cur_diff=cell2char(DIFF_name{pp});
                        var_fields.(cur_diff){kk} = mean(tmp_TRKs{ok_idx}.unique_voxels(:,3+pp));
                        clear cur_diff
                    end
                end
            end
            
        end
        %REPLACE EMPTY CELLS SPOTS WITH NaNs:
        idxempty=cellfun('isempty',var_fields.(vol_trkname)) ; var_fields.(vol_trkname)(idxempty) = {NaN} ; 
        idxempty=cellfun('isempty',var_fields.(maxsstrlen_trkname)) ; var_fields.(maxsstrlen_trkname)(idxempty) = {NaN} ; 
        idxempty=cellfun('isempty',var_fields.(numsstr_trkname)) ; var_fields.(numsstr_trkname)(idxempty) = {NaN} ; 
        %Maxxsstrlen:
        if isfield(tmp_TRKs{ok_idx},'maxsstrlen')
            idxempty=cellfun('isempty',var_fields.(maxsstrlen_trkname)) ; var_fields.(maxsstrlen_trkname)(idxempty) = {NaN} ;
        end
        %Diff metrics:
        if exist('DIFF_name','var')
            for pp=1:size(tmp_TRKs{ok_idx}.header.scalar_IDs,2)
                cur_diff=cell2char(DIFF_name{pp});
                idxempty=cellfun('isempty',var_fields.(cur_diff)) ; var_fields.(cur_diff)(idxempty) = {NaN} ;
                clear cur_diff;
            end
        end
        clear idxempty;
        
        %Cell2mat and Transpose all values:
        var_fields.(vol_trkname)=cell2mat(var_fields.(vol_trkname)');
        var_fields.(numsstr_trkname)=cell2mat(var_fields.(numsstr_trkname)');
        if isfield(tmp_TRKs{ok_idx},'maxsstrlen')
            var_fields.(maxsstrlen_trkname) =cell2mat(var_fields.(maxsstrlen_trkname)');
        end
      
        if exist('DIFF_name','var')
            for pp=1:size(tmp_TRKs{ok_idx}.header.scalar_IDs,2)
                cur_diff=cell2char(DIFF_name{pp});
                var_fields.(cur_diff) =cell2mat(var_fields.(cur_diff)');
                clear cur_diff;
            end
        end
        
    else
        warning(['Variable :'  fields_vals{ii} 'is not treated as ROI or TRK'])
    end
end
    



%Joining both tables together....
outTable=join(xlsTable,struct2table(var_fields));

%%~~~~~~~~~~~~~~~~~~~~~~~~END OF IMPLEMENTATION~~~~~~~~~~~~~~~~~~~~~~~~~~%%

%%%%STARTING LOCAL FUNCTION/S%%%%%
function [outTable, spec_field ] = local_getdemos_from_headerdata(TRKS_IN,flag_project)
%EXTRACT variables values
idx=1;
for ii=1:numel(TRKS_IN)
    tmp_IDs{ii}=TRKS_IN{ii}.header.id;
    [unique_IDs unique_IDs_idx ] = unique(tmp_IDs);
end

for ii=1:numel(unique_IDs)
    %char vars:
    spec_field.id{ii,1}=TRKS_IN{unique_IDs_idx(ii)}.header.data.id;
    spec_field.sex{ii,1}=TRKS_IN{unique_IDs_idx(ii)}.header.data.sex;
    spec_field.dx{ii,1}=TRKS_IN{unique_IDs_idx(ii)}.header.data.dx;
    spec_field.dx_pse{ii,1}=TRKS_IN{unique_IDs_idx(ii)}.header.data.dx_pse;
    
    %double type vars:
    spec_field.age(ii,1)=TRKS_IN{unique_IDs_idx(ii)}.header.data.age;
    spec_field.diffmotion(ii,1)=TRKS_IN{unique_IDs_idx(ii)}.header.data.diffmotion;
    spec_field.education(ii,1)=TRKS_IN{unique_IDs_idx(ii)}.header.data.education;
    if strcmp(flag_project,'AD23NC23')
        
        spec_field.agematched_id(ii,1)=TRKS_IN{unique_IDs_idx(ii)}.header.data.agematched;
        spec_field.vol_fimbriaDIL_L(ii,1)=TRKS_IN{unique_IDs_idx(ii)}.header.data.fimbria_volDIL_L;
        spec_field.vol_fimbriaDIL_R(ii,1)=TRKS_IN{unique_IDs_idx(ii)}.header.data.fimbria_volDIL_R;
      
        spec_field.T1_hippovol_L(ii,1)=TRKS_IN{unique_IDs_idx(ii)}.header.data.T1_hippovol_L;
        spec_field.T1_hippovol_R(ii,1)=TRKS_IN{unique_IDs_idx(ii)}.header.data.T1_hippovol_R;
    end
end
%Making specific variables categorical:
spec_field.sex=categorical(spec_field.sex); %(done here so it passes the name when creating the table)
spec_field.dx=categorical(spec_field.dx);
spec_field.dx_pse=categorical(spec_field.dx_pse);

%Making a structure type variable to a table
outTable=struct2table(spec_field);
