function rotrk_statsplot(REF_TRKS,PSTATVOLS,CORRP_VOLS)
%function rotrk_statsplot(REF_TRKS,PSTATVOLS,CORRP_VOLS)


figure();

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
        error(['In iteration: ' num2str(ii)  ' CANT EXECUTE spm_vol(): Maybe--> Invalid filename type. Either implement of check its a char type'])
    end
    
    
    %gzip the file again if needed
    if strcmp(ext_corrp,'.gz') ;  system(['gzip ' VOLScorrp_fn{ii}]); end
    if strcmp(ext_tstat,'gz') ; system(['gzip ' VOLSpstat_fn{ii}]) ; end
    
    
    
    %Plotting starts here:
    
    %Getting idxs:
    ind_corrp{ii}=find(VVOLS_corrp{ii}~=0);
    ind_tstat{ii}=find(VVOLS_tstat{ii}~=0);
    
    %Getting xyz_s
    [ x_corrp{ii} y_corrp{ii} z_corrp{ii} ]  = ind2sub(size(VVOLS_corrp{ii}),ind_corrp{ii});
    [ x_tstat{ii} y_tstat{ii} z_tstat{ii} ]  = ind2sub(size(VVOLS_tstat{ii}),ind_tstat{ii});
    
    %Getting p values = 1-intensity:
    pvals_corrp{ii}=1-VVOLS_corrp{ii}(ind_corrp{ii});
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
    
    %Get corrP into the toplot_vals:
    toplot_vals{ii} = [   REF_TRKS{ii}.sstr.matrix nan(size(REF_TRKS{ii}.sstr.matrix,1),1) nan(size(REF_TRKS{ii}.sstr.matrix,1),1) ]; %Init las columns for p_corrs
    for jj=1:size(REF_TRKS{ii}.sstr.vox_coord(:,1:3),1)
        for kk=1:size(tstat_and_corrp{ii},1)
            %check if x equals:
            if REF_TRKS{ii}.sstr.vox_coord(jj,1) == tstat_and_corrp{ii}(kk,1)
                %check if x equals:
                if REF_TRKS{ii}.sstr.vox_coord(jj,2) == tstat_and_corrp{ii}(kk,2)
                    %check if z equals:
                    if REF_TRKS{ii}.sstr.vox_coord(jj,3) ==tstat_and_corrp{ii}(kk,3)
                        toplot_vals{ii}(jj,4:5) =tstat_and_corrp{ii}(kk,4:5); % Adding the corr_p
                        break
                    end
                end
            end
        end
    end
    
    
    
    %Plotting now...
    scatter3(toplot_vals{ii}(:,1),toplot_vals{ii}(:,2),toplot_vals{ii}(:,3),2000,toplot_vals{ii}(:,4),'filled');
    hold on
    
    %Asterisk if a treshold if found:
    for gg=1:numel(toplot_vals{ii}(:,5))
        if toplot_vals{ii}(gg,5) < 0.05
            scatter3(toplot_vals{ii}(gg,1), toplot_vals{ii}(gg,2), toplot_vals{ii}(gg,3),2000,'r*');
        end
    end
   
    
end

%Properties added:
caxis([0 3.5])
colorbar
view(45,15)
set(gca,'XTick',[]) ; set(gca,'YTick',[]) ; set(gca,'ZTick',[])


hold off


