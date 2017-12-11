function  rotrk_rand_plot(REF_TRKS,PSTATVOLS,CORRP_VOLS, plot_params)
%function  rotrk_rand_plot(REF_TRKS,PSTATVOLS,CORRP_VOLS, plot_params)
%Goal: To plot voxel-by-voxel the statistically significant results coming
%out of randomise using the <REF_TRK> as the reference tract which should
%be the same used for masking the in randomise in the directory
%<STATS_DIRNAME>
%   IN:     REF_TRKS            Reference tract/tracts to be plotted
%           PSTATSVOLS          Tstat niftii file (e.g. tbss_<NAME>_tstat1.nii.gz )
%           CORRPVOLS           Corrected tstat niftii file (e.g. tbss_<NAME>_tfce_corrp_tstat1.nii.gz )
%           plot_params         (optional) parameters to plot:
%                               plot_params.title (default nothing --> '') 
%                               plot_params.asterisk (default 'r*')
%                               plot_params.markersize (default 2000)
%                               plot_params.corr_pvalue (default 0.05)
%                               plot_params.xyz_ticks (default don't show xyz labels)
%                               plot_params.trkname (name of the trk)
%   OUT:                        THE PLOT ITSELF
%Created by Rodrigo Perea Nov 2017
%

if nargin < 4
    plot_params='';
end

if numel(CORRP_VOLS) ~= numel(REF_TRKS)
    error(['REF_TRKS passed (n=' num2str(numel(REF_TRKS)) ') is not equal to corrp vols passed (n=' num2str(numel(CORRP_VOLS)) ')' ]);
end


if numel(PSTATVOLS) ~= numel(REF_TRKS)
    error(['REF_TRKS passed (n=' num2str(numel(REF_TRKS)) ') is not equal tstat  vols passed (n=' num2str(numel(PSTATVOLS)) ')' ]);
end

for ii=1:numel(CORRP_VOLS)
    %Is it gzipped?
    %CORRP VOLS:
    [ ~, ~, ext_corrp ] = fileparts(CORRP_VOLS{ii});
    if strcmp(ext_corrp,'.gz')
        system(['gunzip ' CORRP_VOLS{ii}]);
        VOLScorrp_fn{ii} = strrep(CORRP_VOLS{ii},'.gz','');
    else
        VOLScorrp_fn{ii}=CORRP_VOLS{ii};
    end
    
    %PSTATVOLS:
    [ ~, ~, ext_tstat ] = fileparts(PSTATVOLS{ii});
    if strcmp(ext_tstat,'.gz')
        system(['gunzip ' PSTATVOLS{ii}]);
        VOLSpstat_fn{ii} = strrep(PSTATVOLS{ii},'.gz','');
    else
        VOLSpstat_fn{ii}=PSTATVOLS{ii};
    end
    
    
    %Trying to execute spm_vol():
    try
        %Corrp:
        VOLS_corrp{ii} = spm_vol(VOLScorrp_fn{ii});
        VVOLS_corrp{ii}= spm_read_vols(VOLS_corrp{ii});
        %Tstat:
        VOLS_tstat{ii} = spm_vol(VOLSpstat_fn{ii});
        VVOLS_tstat{ii}= spm_read_vols(VOLS_tstat{ii});
        
    catch
        if strcmp(ext_corrp,'gz') ; system(['gzip ' VOLScorrp_fn{ii}]) ; end
        if strcmp(ext_tstat,'gz') ; system(['gzip ' VOLSpstat_fn{ii}]) ; end
        error(['In iteration: ' num2str(ii)  ' CANT EXECUTE spm_vol(): Maybe--> Invalid filename type. Either implement of check its a char type \n' ...
            'filename is:' ])
    end
    
    
    %gzip the file again if needed
    if strcmp(ext_corrp,'.gz') ;  system(['gzip ' VOLScorrp_fn{ii}]); end
    if strcmp(ext_tstat,'.gz') ; system(['gzip ' VOLSpstat_fn{ii}]) ; end
    
    
    
    %Plotting starts here:
    
    %Getting idxs:
    ind_corrp{ii}=find(VVOLS_corrp{ii}~=0);
    ind_tstat{ii}=find(VVOLS_tstat{ii}~=0);
    
    %Getting xyz_s
    [ x_corrp{ii} y_corrp{ii} z_corrp{ii} ]  = ind2sub(size(VVOLS_corrp{ii}),ind_corrp{ii});
    [ x_tstat{ii} y_tstat{ii} z_tstat{ii} ]  = ind2sub(size(VVOLS_tstat{ii}),ind_tstat{ii});
    
    %Getting p values = 1-intensity:
    pvals_corrp{ii}=VVOLS_corrp{ii}(ind_corrp{ii});
    pvals_tstat{ii}=VVOLS_tstat{ii}(ind_tstat{ii});
    
    %Removing -1 for indexing issues that happened before...
    all_corr{ii} = [ x_corrp{ii}-1 y_corrp{ii}-1 z_corrp{ii}-1 pvals_corrp{ii} ] ;
    all_tstat{ii} = [ x_tstat{ii}-1 y_tstat{ii}-1 z_tstat{ii}-1 pvals_tstat{ii} ] ;
    
    
    
    
    %Get corrP into the t-stat values:
    tstat_and_corrp{ii} = [ all_tstat{ii}  nan(size(all_tstat{ii},1),1) ]; %Init las columns for p_corrs
    for jj=1:size(all_tstat{ii},1)
        for kk=1:size(all_corr{ii},1)
            %check if x equals:
            if all_tstat{ii}(jj,1) == all_corr{ii}(kk,1)
                %check if x equals:
                if all_tstat{ii}(jj,2) == all_corr{ii}(kk,2)
                    %check if z equals:
                    if all_tstat{ii}(jj,3) == all_corr{ii}(kk,3)
                        tstat_and_corrp{ii}(jj,5) = all_corr{ii}(kk,4); % Adding the corr_p
                        break
                    end
                end
            end
        end
    end
    
    %Check file format of REF_TRKS{ii}
    %if ischar(class(REF_TRKS{ii}))
    if ~isstruct(REF_TRKS{ii})
        REF_TRKS_fname{ii}=REF_TRKS{ii};
        REF_TRKS{ii}=rotrk_read(REF_TRKS_fname{ii},'REF_TRK',PSTATVOLS{ii});
    end
    
    %DOES THE REF_TRK CONTAINtr A SINGLE STREAMLINE OR A COMBINATION OF MANY?
    if size(REF_TRKS{ii}.sstr,2) ~= 1
        %if many, then vercat the vox_coord and matrix
        singleREF_TRKS{ii}.sstr.matrix=REF_TRKS{ii}.sstr(1).matrix;
        singleREF_TRKS{ii}.sstr.vox_coord=REF_TRKS{ii}.sstr(1).vox_coord;       %initializing vox_coord
        for kk=2:size(REF_TRKS{ii}.sstr,2)
            singleREF_TRKS{ii}.sstr.matrix=vertcat(singleREF_TRKS{ii}.sstr.matrix,REF_TRKS{ii}.sstr(kk).matrix);
            singleREF_TRKS{ii}.sstr.vox_coord=vertcat(singleREF_TRKS{ii}.sstr.vox_coord,REF_TRKS{ii}.sstr(kk).vox_coord);
        end
    else
        singleREF_TRKS{ii}.sstr=REF_TRKS{ii}.sstr;
    end
    
    
    %Get corrP into the toplot_vals:
    toplot_vals{ii} = [   singleREF_TRKS{ii}.sstr.matrix(:,1:3) nan(size(singleREF_TRKS{ii}.sstr.matrix,1),1) nan(size(singleREF_TRKS{ii}.sstr.matrix,1),1) ]; %Init last columns for p_corrs
    for jj=1:size(singleREF_TRKS{ii}.sstr.vox_coord(:,1:3),1)
        for kk=1:size(tstat_and_corrp{ii},1)
            %check if x equals:
            if singleREF_TRKS{ii}.sstr.vox_coord(jj,1) == tstat_and_corrp{ii}(kk,1)
                %check if y equals:
                if singleREF_TRKS{ii}.sstr.vox_coord(jj,2) == tstat_and_corrp{ii}(kk,2)
                    %check if z equals:
                    if singleREF_TRKS{ii}.sstr.vox_coord(jj,3) ==tstat_and_corrp{ii}(kk,3)
                        toplot_vals{ii}(jj,4:5) =tstat_and_corrp{ii}(kk,4:5); % Adding the corr_p
                        break
                    end
                end
            end
        end
    end
    
        
    %PLOT PARAMTERS CHECK:
    %Change markersize:
    if isfield(plot_params,'markersize')
        plot_markersize=plot_params.markersize;
    else
        plot_markersize=2000;
    end
    
    %Change asterisk:
    if isfield(plot_params,'asterisk')
        plot_asterisk=plot_params.asterisk;
    else
        plot_asterisk='r*';
    end
    
    %Change p-value for asterisk:
    if isfield(plot_params,'corr_pvalue')
        plot_corr_pvalue=plot_params.corr_pvalue;
    else
        plot_corr_pvalue=0.05;
    end
    
   
    
    %PLOTTING NOW:
    figure();
    hold on
    %Check if there are no tstats coordinates:
    if any(isnan(toplot_vals{ii}(:,4)))
        for gg=1:numel(toplot_vals{ii}(:,4))
            if ~isnan(toplot_vals{ii}(gg,4))
                scatter3(toplot_vals{ii}(gg,1),toplot_vals{ii}(gg,2),toplot_vals{ii}(gg,3),plot_markersize,toplot_vals{ii}(gg,4),'filled');
            else
                scatter3(toplot_vals{ii}(gg,1),toplot_vals{ii}(gg,2),toplot_vals{ii}(gg,3),plot_markersize,toplot_vals{ii}(gg,4),'b');
            end
        end
    else
        %If all tstats exist, do a simple (faster plot)
        scatter3(toplot_vals{ii}(:,1),toplot_vals{ii}(:,2),toplot_vals{ii}(:,3),plot_markersize,toplot_vals{ii}(:,4),'filled');
    end
    
    
  
    for gg=1:numel(toplot_vals{ii}(:,5))
        if 1-toplot_vals{ii}(gg,5) < plot_corr_pvalue
            scatter3(toplot_vals{ii}(gg,1), toplot_vals{ii}(gg,2), toplot_vals{ii}(gg,3),plot_markersize,plot_asterisk,'filled');
        end
    end
   
    

%Properties added:
if isfield(plot_params,'caxis')
    caxis(plot_params.caxis);
else
    caxis([-3 3])
end

%caxis([0 3.5])
colorbar
if isfield(plot_params,'view')
    view(plot_params.view(1),plot_params.view(2))
else
    %view(45,15)
    view(-81,17)
end
if isfield(plot_params,'xyz_ticks')
     do_nothing=1;
else
    set(gca,'XTick',[]) ; set(gca,'YTick',[]) ; set(gca,'ZTick',[])
end
 %Add title is plot_params are passed:
 if isfield(plot_params,'title')
     title(plot_params.title)
 end

    
end
hold off


