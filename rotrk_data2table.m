function  newTable  = rotrk_data2table(OBJs,vars,b_id)
%function newTable  = rotrk_data2table(OBJs,variables)
% The objective of this function is to generate a table "newTable" with
% data coming from the struct array of objects "OBJs" and requesting the
% variables in "vars".
% e.g. : 
% myTable = rotrk_data2table(obj_HAB, { 'Trkland.fx.data.clineFAHDorff_lh_FA' 'Trkland.fx.data.clineFAHDorff_rh_FA' '...'} )
%
% *Make sure  'ALL FIELDS' assigned exist on every obj_HAB iteration! 

if nargin <3
    b_id = false;
end
    AA=1;
%Iterate within OBJs:
for ii=1:numel(OBJs)
    if b_id 
        ID_NAME='MRI_Session_ID';
        dctl_cmd = [ 'SELECT MRI_Session_ID FROM Sessions.MRI  WHERE ' ' MRI_Session_Name = ''' OBJs{ii}.obj.sessionname '''' ];
        cur_DC_ID = DataCentral(dctl_cmd);
        newS.(ID_NAME){ii} = cur_DC_ID.MRI_Session_ID;
    else
        ID_NAME='Id';
        newS.(ID_NAME){ii} = OBJs{ii}.obj.sessionname;
    end
    display(['In ' OBJs{ii}.obj.sessionname ]);
    %Iterate within vars:
    for jj=1:numel(vars)
        splits=strsplit(vars{jj},'.');
        cur_name=splits{end};
        
        %Check for empty cells:
        if isempty(getfield(OBJs{ii}.obj,splits{:}))
            newS.(cur_name){ii}  = '\N';
        else
            newS.(cur_name){ii} = getfield(OBJs{ii}.obj,splits{:});
        end
    end
end

%Transpose fields
all_fields=fields(newS);
for  ii =1:numel(all_fields)
    newS.(all_fields{ii})=newS.(all_fields{ii})';
end
newTable = struct2table(newS);
AA=1;