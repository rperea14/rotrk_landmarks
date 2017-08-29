function TRKS_OUT = rotrk_add_uniquevoxels(TRKS_IN, varargin)

AA=1;

for ii=1:numel(TRKS_IN)
    %Init variables:
    TRKS_OUT{ii}.header=TRKS_IN{ii}.header;
    TRKS_OUT{ii}.id=TRKS_IN{ii}.id;
    TRKS_OUT{ii}.sstr=TRKS_IN{ii}.sstr;
    TRKS_OUT{ii}.trk_name = strcat('trk_combinedall' );
    TRKS_OUT{ii}.header.specific_name='trk_combinedall';
    if isfield(TRKS_IN{ii},'all_sstrlen')
        TRKS_OUT{ii}.all_sstrlen=TRKS_IN{ii}.all_sstrlen;
    end
    %
    clear all_vox
    all_vox=TRKS_IN{ii}.unique_voxels;
    
    %loop through all the other ones
    for jj=1:numel(varargin)
        clear ids_jj cur_idx
        %Get idx list:
        for kk=1:numel(varargin{jj})
            ids_jj{kk}=varargin{jj}{kk}.id;
        end
        cur_idx=getnameidx(ids_jj,TRKS_IN{ii}.id);
        %display(['cur_idx for ' TRKS_IN{1}.id ' is: ' num2str(cur_idx)]);
        if cur_idx ~= 0
           %Adding sstr:
            for pp=1:numel(varargin{jj}{cur_idx}.sstr)
                TRKS_OUT{ii}.sstr(end+1).matrix=varargin{jj}{cur_idx}.sstr(pp).matrix;
                TRKS_OUT{ii}.sstr(end).vox_coord=varargin{jj}{cur_idx}.sstr(pp).vox_coord;
                TRKS_OUT{ii}.sstr(end).nPoints=varargin{jj}{cur_idx}.sstr(pp).nPoints;
            end
            %Unique voxels here:
            all_vox=vertcat(all_vox,varargin{jj}{cur_idx}.unique_voxels);
            TRKS_OUT{ii}.header.n_count= TRKS_OUT{ii}.header.n_count + varargin{jj}{cur_idx}.header.n_count;
            
            %Dealing with maxlen:
            if isfield(varargin{jj}{cur_idx},'all_sstrlen')
                TRKS_OUT{ii}.all_sstrlen=vertcat(TRKS_OUT{ii}.all_sstrlen,varargin{jj}{cur_idx}.all_sstrlen);
            end
        end
    end
    
    TRKS_OUT{ii}.maxsstrlen=max(TRKS_OUT{ii}.all_sstrlen);
    TRKS_OUT{ii}.unique_voxels=unique(all_vox,'rows');
    TRKS_OUT{ii}.num_uvox=size(TRKS_OUT{ii}.unique_voxels,1);
end