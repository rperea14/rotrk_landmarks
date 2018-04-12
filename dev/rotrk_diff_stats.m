function [ diff_vals ] = rotrk_mean_diff(TRKS_IN)
%~/Dropbox/Martinos/Scripts/matlab_scripts/trk_landmarks/rotrk_mean_dif
%
%Goal: Ouputs the mean diffmetrics of scalars within the
%sstr.vox_coord(:,4...)

AA=1;

%If no scalar is given, then nothing to do...exit!
if ~isfield(TRKS_IN.header,'scalar_IDs')
    error('TRKS_IN.header.scalar_IDs does not exist. Please check!');
else
    for idx_scalars=1:size(TRKS_IN.header.scalar_IDs,2)
        %REPLACED FOR LOOP WITH:
        all_VALS=cat(1,TRKS_IN.sstr.vox_coord);
        diff_vals.name(idx_scalars)=TRKS_IN.header.scalar_IDs(idx_scalars);
        diff_vals.mean_val(idx_scalars)=mean(all_VALS(:,3+idx_scalars));
        diff_vals.mean_uniq_val(idx_scalars)=mean(unique(all_VALS(:,3+idx_scalars)));        
        diff_vals.median_val(idx_scalars)=median(all_VALS(:,3+idx_scalars));
        diff_vals.std_val(idx_scalars)=std(all_VALS(:,3+idx_scalars));
        
        %REPLACED FOR LOOP **(( ))**
        %         %ii denotes each streamline...
        %         for ii=1:size(TRKS_IN.sstr)
        %             mean_added(ii)=mean(TRKS_IN.sstr(ii).vox_coord(:,3+idx_scalars));
        %             median_added(ii)=median(TRKS_IN.sstr(ii).vox_coord(:,3+idx_scalars));
        %             std_added(ii)=std(TRKS_IN.sstr(ii).vox_coord(:,3+idx_scalars));
        %
        %         end
        %         diff_vals.name(idx_scalars)=TRKS_IN.header.scalar_IDs(idx_scalars);
        %         diff_vals.mean(idx_scalars)=mean(mean_added);
        %         diff_vals.median(idx_scalars)=median(median_added);
        %         diff_vals.std(idx_scalars)=mean(std_added);
        
    end
end

AA=1;


