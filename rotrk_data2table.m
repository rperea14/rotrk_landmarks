function  newTable  = rotrk_data2table(OBJs,vars)
%function newTable  = rotrk_data2table(OBJs,variables)
% The objective of this function is to generate a table "newTable" with
% data coming from the struct array of objects "OBJs" and requesting the
% variables in "vars".
% e.g. : 
% myTable = rotrk_data2table(obj_HAB, { 'Trkland.fx.data.clineFAHDorff_lh_FA' 'Trkland.fx.data.clineFAHDorff_rh_FA' '...'} )


AA=1;
%Iterate within OBJs:
for ii=1:numel(OBJs)
    
    newS.id{ii} = OBJs{ii}.obj.sessionname;
    %Iterate within vars:
    for jj=1:numel(vars)
        splits=strsplit(vars{jj},'.');
        cur_name=splits{end};
        
        %Check for empty cells:
        if isempty(getfield(OBJs{ii}.obj,splits{:}))
            newS.(cur_name){ii}  = NaN;
        else
            newS.(cur_name){ii} = getfield(OBJs{ii}.obj,splits{:});
        end
    end
end

%Transpose fields
all_fields=fields(newS);
for  ii =1:numel(all_fields)
    newS.(all_fields{ii})=newS.(all_fields{ii})'
end
newTable = struct2table(newS);
AA=1;