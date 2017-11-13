function  rotrk_rand_plot(REF_TRK, T_STATS_FNAME, CORRP_STATS_FNAME, STATS_DIRNAME)
%function  rotrk_rand_plot(REF_TRKS, STATS_DIRNAME)
%Goal: To plot voxel-by-voxel the statistically significant results coming
%out of randomise using the <REF_TRK> as the reference tract which should
%be the same used for masking the in randomise in the directory
%<STATS_DIRNAME>
%   IN:     REF_TRK             Reference tract/tracts to be plotted
%           STATS_DIRNAME       Directory name of the voxels of interest
%   OUT:                        THE PLOT ITSELF
%   *Make sure if more than one  filename is input, that they are orderly
%   passed. 
%Created by Rodrigo Perea Nov 2017
%
%UNNECESSARY --> METRICS = [ {'FA'}  {'AxD'}   {'MD'}  {'RD'} {'NQA0'} ];
PCORR_fns=dir_wfp('coord_2_REF/GFA/bil_tbss_results/*_corrp*');
PSTAT_fns=dir_wfp('coord_2_REF/GFA/bil_tbss_results/*NC_tstat*');
%Reference trks to extracr x,y,z coordinates:
REF_TRK = [ {MYTRKS.FA.L_CLINE{16}} {MYTRKS.FA.R_CLINE{18}} ];


if numel(PCORR_fns) ~= numel(PSTAT_fns)
    error('PCORR_fns and PSTAT_fns are not the same size.Please check!')
end



%If even, then a left and right exist!
if mod(numel(PCORR_fns),2) == 0
    for ii=1:numel(PCORR_fns)-1
        %PCORR VALS:
        [~, fn_tfce1, ~ ] = fileparts(PCORR_fns{ii});
        prex_fn_tfce1=strsplit(fn_tfce1,'_');
        [~, fn_tfce2, ~ ] = fileparts(PCORR_fns{ii+1});
        prex_fn_tfce2=strsplit(fn_tfce2,'_');
        
        %PSTAT VALS:
        [~, fn_pstat1, ~ ] = fileparts(PSTAT_fns{ii});
        prex_fn_pstat1=strsplit(fn_pstat1,'_');
        [~, fn_pstat2, ~ ] = fileparts(PSTAT_fns{ii+1});
        prex_fn_pstat2=strsplit(fn_pstat2,'_');
        
        
        if strcmp(prex_fn_tfce1(1),prex_fn_tfce2(1))  && strcmp(prex_fn_pstat1(1),prex_fn_pstat2(1)) ...
                && strcmp(prex_fn_tfce1(1),prex_fn_pstat1(1))
            fprintf([ PCORR_fns{ii}  ' AND \n' PCORR_fns{ii+1} '\n\n'])
            rotrk_statsplot(REF_TRK,[ {PSTAT_fns{ii}}  {PSTAT_fns{ii+1}}], [{PCORR_fns{ii}} {PCORR_fns{ii+1}}]);
        end
    end
else
    warning('PCORR_fns is not even, so no bilateralise and not implemented. Nothing to do...')
end
