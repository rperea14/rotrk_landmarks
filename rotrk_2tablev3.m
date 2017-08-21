function [ myTable cellTable_out ] = rotrk_2table(TRKS_IN, TRKS_ROIS_matfile)
%function [ myTable cellTable_out ] = rotrk_2table(TRKS_IN, TRKS_ROIs_matfile)
% Self explanatory, it generates a table based on the values given
% *!! The first hdrs or strs should be longer in size!!

%FIRST, GET THE NECESSARY VALUES FROM TRKS_IN:
[outTable, headerdata_field ] = local_getdemos_from_headerdata(TRKS_IN,'AD23NC23');
%~~END OF TRKS_IN adding to TABLE


if exist(TRKS_ROIS_matfile) ~=2
    error(['Cannot load matfile: ' TRKS_ROIs_matfile{end} '.Please check and input a *.mat file'])
else
    all_VALS=load(TRKS_ROIS_matfile);
end


fields_vals=fields(all_VALS);
var_fields.id=outTable.id;
for ii=1:numel(fields_vals)
    %Split the string by the character *_* 
    [SPLIT]  = strsplit(fields_vals{ii},'_');
    clear tmp_ROIs
    %Check whether an ROI or TRK is being input...
    if strcmp(SPLIT{1},'ROIS')
        clear tmp_ROIs tmp_fn tmp_varname var_name ok_idx tmp_ROIS_ids
        tmp_ROIs=all_VALS.(fields_vals{ii});
        %Creating the name for the volume_<ROI>:
        [~, tmp_fn, ~ ] =fileparts(tmp_ROIs{1}.filename{end}); 
        display(tmp_fn);
        tmp_varname=strrep(tmp_fn,[ '_' tmp_ROIs{1}.id{end} ],'');
        var_name=strcat('vol_',tmp_varname);
        %Get IDs for each value:
        for kk=1:numel(tmp_ROIs)
            tmp_ROIS_ids{kk}=tmp_ROIs{kk}.id{end};
        end
        %Looping though all values and assigning them to each id
        for kk=1:numel(var_fields.id)
            ok_idx=getnameidx(tmp_ROIS_ids,var_fields.id{kk});
            %if the id exist on the specific ROI, then do something
            if ok_idx ~= 0
                var_fields.(var_name){kk} =tmp_ROIs{ok_idx}.num_uvox;
            end
        end
        
    elseif strcmp(SPLIT{1},'TRKS')
    else
    end
end
    



%Joining both tables together....
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
