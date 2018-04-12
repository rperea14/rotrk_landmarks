function [ myTable cellTable_out ] = rotrk_2table(TRKS_IN, FA,varargin)
%function [ myTable  cellTable_out] = rotrk_2table(TRKS_IN, varargin)
% Self explanatory, it generates a table based on the values given
% *!! The first hdrs or strs should be longer in size!!

%FIRST, GET THE NECESSARY VALUES FROM TRKS_IN:
[outTable, headerdata_field ] = local_getdemos_from_headerdata(TRKS_IN,'AD23NC23');
%~~END OF TRKS_IN adding to TABLE

%%########################################################################%
%INITIALIZING VARIABLES (e.g. VAR_FIELDS)
%So they have the same SIZE SO WE CAN CONVERT STRUCT TO TABLE
cellTable_out='';%~~~> this will initialize the 2nd output argument that will contain the table in cell form (later...)
num_rows=numel(TRKS_IN);
var_fields.id=headerdata_field.id; %* --> This will be used to convert struct2table (as same index are needed);

%CONCATENATE TRKS_IN INTO VARARGIN:
varargin_w_TRKS_IN=[ {TRKS_IN} varargin ] ;

%ADDING NaNs rows (to take care of values that are not found)
for pp=1:numel(varargin_w_TRKS_IN) %on every TRKS passed
    if isempty(varargin)
        for oo=1:numel(TRKS_IN)
            tmp_init_names{oo}=TRKS_IN{oo}.header.specific_name;
            tmp_init_subjids{oo}=TRKS_IN{oo}.header.id;
        end
        init_subids=unique(tmp_init_subjids);
        init_names=unique(tmp_init_names);
        
        for oo=1:numel(init_names)
            trk_name=cell2char_rdp(init_names(oo));
            trk_name=strrep(trk_name,'-','_');              % will remove the '-' that is invalid for naming purposes
            numstr_varargin_w_TRKS_IN=strcat('numsstr_',trk_name);
            maxlen_varargin_w_TRKS_IN=strcat('maxlen_',trk_name);
            volume_varargin_w_TRKS_IN=strcat('volume_',trk_name);
            var_fields.(numstr_varargin_w_TRKS_IN)=nan(numel(init_subids),1);
            var_fields.(maxlen_varargin_w_TRKS_IN)=nan(numel(init_subids),1);
            var_fields.(volume_varargin_w_TRKS_IN)=nan(numel(init_subids),1);
            
            %On every single mask (add diffmetrics:)
            if isfield(TRKS_IN{1}.header,'scalar_IDs')
                for kk=1:size(TRKS_IN{1}.header.scalar_IDs,2)
                    sc_name=cell2char_rdp(TRKS_IN{1}.header.scalar_IDs(kk));
                    sc_name=strrep(sc_name,'-','_');              % will remove the '-' that is invalid for naming purposes
                    mean_sc_name=strcat('mean',sc_name,'_',trk_name);
                    var_fields.(mean_sc_name)=nan(numel(init_subids),1); %%--> init variable fields
                end
            end
        end
        
    else            %values contained within the first TRKS_IN...
        %initializing the names we'll use for each varargin_w_TRKS_IN
        trk_name=strrep(varargin_w_TRKS_IN{pp}{1}.header.specific_name,'trk_','');
        numstr_varargin_w_TRKS_IN=strcat('numsstr_',trk_name);
        maxlen_varargin_w_TRKS_IN=strcat('maxlen_',trk_name);
        volume_varargin_w_TRKS_IN=strcat('volume_',trk_name);

        %Now on every value that makes up the vararing TRKS (e.g. n=42 for L or
        %45 for R)
        
        %number of streamlines passed:
        var_fields.(numstr_varargin_w_TRKS_IN)=nan(numel(varargin_w_TRKS_IN{pp}),1);
        var_fields.(maxlen_varargin_w_TRKS_IN)=nan(numel(varargin_w_TRKS_IN{pp}),1);
        var_fields.(volume_varargin_w_TRKS_IN)=nan(numel(init_subids),1);
        if isfield(varargin_w_TRKS_IN{pp}{1}.header,'scalar_IDs')
            for kk=1:size(varargin_w_TRKS_IN{pp}{1}.header.scalar_IDs,2)
                sc_name=cell2char_rdp(varargin_w_TRKS_IN{pp}{1}.header.scalar_IDs(kk));
                mean_sc_name=strcat('mean',sc_name,'_',trk_name);
                var_fields.(mean_sc_name)=nan(numel(varargin_w_TRKS_IN{pp}),1); %%--> init variable fields
            end
        end
    end
end
%###################END OF INITIALIZING VAR_FIELDS#######################%%

%NOW WORKING ON varargin_w_TRKS_IN
for pp=1:numel(varargin_w_TRKS_IN)               %on every TRKS passed
    for jj=1:numel(varargin_w_TRKS_IN{pp})       %on every SUBJECT within a specific TRKS
        disp([ 'In ' varargin_w_TRKS_IN{pp}{jj}.id ' ' varargin_w_TRKS_IN{pp}{jj}.header.specific_name ]);
        clear id_idx;
        %Getting the index of the id
        id_idx=getnameidx(var_fields.id,varargin_w_TRKS_IN{pp}{jj}.id);
        %Not sure why I keep initializing these guys...
        trk_name=strrep(varargin_w_TRKS_IN{pp}{jj}.header.specific_name,'trk_','');
        trk_name=strrep(trk_name,'-','_');              % will remove the '-' that is invalid for naming purposes
        cur_numstr_name=strcat('numsstr_',trk_name);
        cur_maxlen_name=strcat('maxlen_',trk_name);
        cur_volume_name=strcat('volume_',trk_name);
        if strcmp(varargin_w_TRKS_IN{pp}{jj}.id,var_fields.id{id_idx});
            %GETTING THE NUMBER OF STRLINES PASSED:
            var_fields.(cur_numstr_name)(id_idx,1)=size(varargin_w_TRKS_IN{pp}{jj}.sstr,2);
            clear temp_len
            %Get the streamline length for every streamline:
            %TODEBUG: tic
            temp_len=rotrk_get_sstrlength(varargin_w_TRKS_IN{pp}{jj});
            %TODEBUG: toc
            [  var_fields.(cur_maxlen_name)(id_idx,1), idx_max ] =max(temp_len);
            %Get the unique volume (if available)
            if isfield(varargin_w_TRKS_IN{pp}{jj},'num_uvox')
                var_fields.(cur_volume_name)(id_idx,1) =varargin_w_TRKS_IN{pp}{jj}.num_uvox;
            end
            %DEALING WITH DIFFMETRICS (IF EXIST):
            
            if isfield(varargin_w_TRKS_IN{pp}{1}.header,'scalar_IDs')
                for kk=1:size(varargin_w_TRKS_IN{pp}{jj}.header.scalar_IDs,2)
                    sc_name=cell2char_rdp(varargin_w_TRKS_IN{pp}{jj}.header.scalar_IDs(kk));
                    sc_ref=3+kk;
                    mean_sc_name=strcat('mean',sc_name,'_',trk_name);
                    
                    %varargin_w_TRKS_IN{pp}{jj}.header.id
                    
%                      for gg=1:size(varargin_w_TRKS_IN{pp}{jj}.sstr,2) %on every streamline...
%                          temp_avg(gg)=mean(varargin_w_TRKS_IN{pp}{jj}.sstr(end).vox_coord(:,sc_ref));
%                          %
%                      end
%                    var_fields.(mean_sc_name)(id_idx,1)=mean(temp_avg);
                    if isfield(varargin_w_TRKS_IN{pp}{jj},'unique_voxels')
                        var_fields.(mean_sc_name)(id_idx,1)=mean(varargin_w_TRKS_IN{pp}{jj}.unique_voxels(:,sc_ref));
                    else
                        error([ varargin_w_TRKS_IN{pp}{jj}.id ' in trk: ' varargin_w_TRKS_IN{pp}{jj}.trk_name ' has no .unique_voxels field'])
                    end
                    clear temp_avg
                end                
            end
            
        end
    end
end
try
    varTable=struct2table(var_fields);
catch
    error('This error might be caused because the first TRKs array is shorter than the second? Maybe switch order?')
end
myTable=join(outTable,varTable);
cellTable_out=table2cell(myTable);

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
        
        spec_field.fimbria_volDIL_L(ii,1)=TRKS_IN{unique_IDs_idx(ii)}.header.data.fimbria_volDIL_L;
        spec_field.fimbria_volDIL_R(ii,1)=TRKS_IN{unique_IDs_idx(ii)}.header.data.fimbria_volDIL_R;
        
        spec_field.T1_hippovol_L(ii,1)=TRKS_IN{unique_IDs_idx(ii)}.header.data.T1_hippovol_L;
        spec_field.T1_hippovol_R(ii,1)=TRKS_IN{unique_IDs_idx(ii)}.header.data.T1_hippovol_R;
        
        spec_field.vol_fimbriaDIL_L(ii,1)=TRKS_IN{unique_IDs_idx(ii)}.header.data.fimbria_volDIL_L;
        spec_field.vol_fimbriaDIL_R(ii,1)=TRKS_IN{unique_IDs_idx(ii)}.header.data.fimbria_volDIL_R;
        
        spec_field.trimmed_voltrx_FX_DOTFIM_L(ii,1)=TRKS_IN{unique_IDs_idx(ii)}.header.data.trimmed_voltrx_FX_DOTFIM_L_mm3;
        spec_field.trimmed_voltrx_FX_DOTFIM_R(ii,1)=TRKS_IN{unique_IDs_idx(ii)}.header.data.trimmed_voltrx_FX_DOTFIM_R_mm3;
        
        spec_field.def_voltrx_FX_DOT_L(ii,1)=TRKS_IN{unique_IDs_idx(ii)}.header.data.def_voltrx_FX_DOT_L_mm3;
        spec_field.def_voltrx_FX_DOT_R(ii,1)=TRKS_IN{unique_IDs_idx(ii)}.header.data.def_voltrx_FX_DOT_R_mm3;
        spec_field.def_voltrx_FX_DOT_bil(ii,1)=TRKS_IN{unique_IDs_idx(ii)}.header.data.def_voltrx_FX_DOT_BIL_mm3;
    end
end
%Making specific variables categorical:
spec_field.sex=categorical(spec_field.sex); %(done here so it passes the name when creating the table)
spec_field.dx=categorical(spec_field.dx);
spec_field.dx_pse=categorical(spec_field.dx_pse);

%Making a structure type variable to a table
outTable=struct2table(spec_field);

