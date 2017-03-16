function [ myTable cellTable_out ] = rotrk_2table(TRKS_IN, varargin)
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
%START FOR LOOPING AND CREATING/INITING TABLE FIELDS!
for pp=1:numel(varargin_w_TRKS_IN) %on every TRKS passed
    %initializing the names we'll use for each varargin_w_TRKS_IN
    trk_name=strrep(varargin_w_TRKS_IN{pp}{1}.header.specific_name,'trk_','');
    numstr_varargin_w_TRKS_IN=strcat('numsstr_',trk_name);
    maxlen_varargin_w_TRKS_IN=strcat('maxlen_',trk_name);
    %Now on every value that makes up the vararing TRKS (e.g. n=42 for L or
    %45 for R)
    
    %number of streamlines passed:
    var_fields.(numstr_varargin_w_TRKS_IN)=nan(numel(varargin_w_TRKS_IN{pp}),1);
    var_fields.(maxlen_varargin_w_TRKS_IN)=nan(numel(varargin_w_TRKS_IN{pp}),1);
    if isfield(varargin_w_TRKS_IN{pp}{1}.header,'scalar_IDs')
        for kk=1:size(varargin_w_TRKS_IN{pp}{1}.header.scalar_IDs,2)
            sc_name=cell2char(varargin_w_TRKS_IN{pp}{1}.header.scalar_IDs(kk));
            mean_sc_name=strcat('mean',sc_name,'_',trk_name);
            var_fields.(mean_sc_name)=nan(numel(varargin_w_TRKS_IN{pp}),1); %%--> assign variable fields
        end
    end
end
%###################END OF INITIALIZING VAR_FIELDS#######################%%




%NOW WORKING ON varargin_w_TRKS_IN
for ii=1:numel(var_fields.id) % on every SUBJECT
    %NOW WORKING ON varargin_w_TRKS_IN:
    for pp=1:numel(varargin_w_TRKS_IN) %on every TRKS passed
        %if ii==1 ; disp([ 'trk2table--> in ' varargin_w_TRKS_IN{pp}{1}.header.specific_name ' ...' ] ) ; end
        %initializing the names we'll use for each varargin_w_TRKS_IN

        %REPEAT INIT DUE TO MISCHANGED FOR LOOPS TO GO FIRST INTO
        %VAR_FIELDS-->TRKS-->SUBJECTS
        trk_name=strrep(varargin_w_TRKS_IN{pp}{1}.header.specific_name,'trk_','');
        cur_numstr_name=strcat('numsstr_',trk_name);
        cur_maxlen_name=strcat('maxlen_',trk_name);
%         %Now on every value that makes up the vararing TRKS (e.g. n=42 for L or
        %45 for R)
        for jj=1:numel(varargin_w_TRKS_IN{pp}) %on every SUBJECT within a specific TRKS
            %id from TRKS_in (initialize in var_fields.id to compare and
            %execute:
            if strcmp(var_fields.id{ii},varargin_w_TRKS_IN{pp}{jj}.id);
                %GETTING THE NUMBER OF STRLINES PASSED:
                var_fields.(cur_numstr_name)(ii,1)=size(varargin_w_TRKS_IN{pp}{jj}.sstr,2);
                for idx_str=1:size(varargin_w_TRKS_IN{pp}{jj}.sstr,2)
                    temp_maxlen(idx_str)=varargin_w_TRKS_IN{pp}{jj}.sstr(idx_str).nPoints;
                end
                var_fields.(cur_maxlen_name)(ii,1)=max(temp_maxlen);
                clear temp_maxlen
                %DEALING WITH DIFFMETRICS (IF EXIST):
                if isfield(varargin_w_TRKS_IN{pp}{1}.header,'scalar_IDs')
                    for kk=1:size(varargin_w_TRKS_IN{pp}{jj}.header.scalar_IDs,2)
                        sc_name=cell2char(varargin_w_TRKS_IN{pp}{jj}.header.scalar_IDs(kk));
                        sc_ref=3+kk;
                        mean_sc_name=strcat('mean',sc_name,'_',trk_name);
                        for gg=1:size(varargin_w_TRKS_IN{pp}{jj}.sstr,2) %on every streamline...
                            temp_avg(gg)=mean(varargin_w_TRKS_IN{pp}{jj}.sstr(end).vox_coord(:,sc_ref));
                            %        
                        end
                        var_fields.(mean_sc_name)(ii,1)=mean(temp_avg);
                        clear temp_avg 
                    end
                end
            end
        end
    end
end
varTable=struct2table(var_fields);
myTable=join(outTable,varTable);
cellTable_out=table2cell(myTable);

%%~~~~~~~~~~~~~~~~~~~~~~~~END OF IMPLEMENTATION~~~~~~~~~~~~~~~~~~~~~~~~~~%%

%%%%STARTING LOCAL FUNCTION/S%%%%%
function [outTable, spec_field ] = local_getdemos_from_headerdata(TRKS_IN,flag_project)
%EXTRACT variables values
for ii=1:numel(TRKS_IN)
    %char vars:
    spec_field.id{ii,1}=TRKS_IN{ii}.header.data.id;
    spec_field.sex{ii,1}=TRKS_IN{ii}.header.data.sex;
    spec_field.dx{ii,1}=TRKS_IN{ii}.header.data.dx;
    spec_field.dx_pse{ii,1}=TRKS_IN{ii}.header.data.dx_pse;
    
    %double type vars:
    spec_field.age(ii,1)=TRKS_IN{ii}.header.data.age;
    spec_field.diffmotion(ii,1)=TRKS_IN{ii}.header.data.diffmotion;
    spec_field.education(ii,1)=TRKS_IN{ii}.header.data.education;
    if strcmp(flag_project,'AD23NC23')
        
        spec_field.agematched_id(ii,1)=TRKS_IN{ii}.header.data.agematched;
        
        spec_field.fimbria_volDIL_L(ii,1)=TRKS_IN{ii}.header.data.fimbria_volDIL_L;
        spec_field.fimbria_volDIL_R(ii,1)=TRKS_IN{ii}.header.data.fimbria_volDIL_R;
                
        spec_field.T1_hippovol_L(ii,1)=TRKS_IN{ii}.header.data.T1_hippovol_L;
        spec_field.T1_hippovol_R(ii,1)=TRKS_IN{ii}.header.data.T1_hippovol_R;
        
        spec_field.vol_fimbriaDIL_L(ii,1)=TRKS_IN{ii}.header.data.fimbria_volDIL_L;
        spec_field.vol_fimbriaDIL_R(ii,1)=TRKS_IN{ii}.header.data.fimbria_volDIL_R;
        
        spec_field.trimmed_voltrx_FX_DOTFIM_L(ii,1)=TRKS_IN{ii}.header.data.trimmed_voltrx_FX_DOTFIM_L_mm3;
        spec_field.trimmed_voltrx_FX_DOTFIM_R(ii,1)=TRKS_IN{ii}.header.data.trimmed_voltrx_FX_DOTFIM_R_mm3;
        
        spec_field.def_voltrx_FX_DOT_L(ii,1)=TRKS_IN{ii}.header.data.def_voltrx_FX_DOT_L_mm3;
        spec_field.def_voltrx_FX_DOT_R(ii,1)=TRKS_IN{ii}.header.data.def_voltrx_FX_DOT_R_mm3;
        spec_field.def_voltrx_FX_DOT_bil(ii,1)=TRKS_IN{ii}.header.data.def_voltrx_FX_DOT_BIL_mm3;
    end
    %number of strlines
    name_TRKS_IN=TRKS_IN{1}.header.specific_name;
    numstr=strcat('numsstr_',name_TRKS_IN);
end

%Making specific variables categorical:
spec_field.sex=nominal(spec_field.sex); %(done here so it passes the name when creating the table)
spec_field.dx=nominal(spec_field.dx);
spec_field.dx_pse=nominal(spec_field.dx_pse);
    
%Making a structure type variable to a table
outTable=struct2table(spec_field);

