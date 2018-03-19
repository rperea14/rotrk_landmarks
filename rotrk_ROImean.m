function [ roi_mean_xyz ] = rotrk_ROImean(roi_input)
%function [ roi_mean_xyz ] = rotrk_ROImean(roi_input,whatplane)
%
%   IN ->
%           roi_input     : roi niftii file with the needed information
%           (either in rotrk format or just the filename)
%   OUTPUT:
%               roixyz                   : output the mean 3xn xyz coordinates in
%                                          trk space


%THIS CODE SHOULD BE SUFFICIENT BUT ISSUES WITH FXn46....not sure why!
if isfield(roi_input,'filename')
    in_roi = roi_input.filename;
else
    in_roi = roi_input;
end


%Check the class of it:
if iscell(in_roi)
    %then make it a char:
    in_roi=in_roi{end};
end


ROI_read = rotrk_ROIxyz(in_roi);
roi_mean_xyz = mean(ROI_read.approx_trk_coord);
end






% THIS WORKED BEFORE CHANGES WERE MADE IN TRKLAND CHANGES AFTER THE SCRIPTS
% HERE WERE RAN! 
% if isstruct(roi_input)
%     roi_filename=roi_input.filename;
% elseif iscell(roi_input)
%     roi_filename=roi_input;
% else
%     roi_filename= {roi_input};
% end
% 
% 
% 
% 
% %Is it gzip?
% [ roi_dir , roi_name , roi_ext ] = fileparts(roi_filename{end});
% %check if roi_dir is ~ ...
% if strcmp(roi_dir,'~')
%     roi_dir=getenv('HOME');
% end
% if strcmp(roi_ext,'.gz')
%     system(['gunzip -f ' roi_filename{end}]);
%     if isempty(roi_dir)
%         roi_filename = {[ '.' filesep filesep roi_name ]}; 
%     else
%         roi_filename = {[ roi_dir filesep roi_name ]};
%     end
% end
% %Read the volume:
% H_vol = spm_vol(roi_filename{end});
% mat2=H_vol.mat;
% 
% %Check if the matfile is 
% AA=1;
% 
% V_vol=spm_read_vols(H_vol);
% 
% 
% 
% %was it gzipped?
% if strcmp(roi_ext,'.gz');
%     system(['gzip -f ' roi_filename{end} ]);
%     if isempty(roi_dir)
%         roi_filename = {[ '.' filesep filesep roi_name roi_ext ]};
%     else
%         roi_filename = {[ roi_dir filesep roi_name roi_ext ]};
%     end
% end
% 
% try
%     ind=find(V_vol>0);
%     [ x y z ]  = ind2sub(size(V_vol),ind);
%     tmp_xyz = [ x-1 y-1 z-1 ones(numel(x),1) ] ;
%     if nargin > 1
%         switch whatplane
%             case 'x'
%                 roi_mean_xyz= mean(abs(tmp_xyz*mat2));
%                 roi_mean_xyz=roi_mean_xyz(1:3);
%             case 'y'
%                 roi_mean_xyz= mean(abs(tmp_xyz*mat2));
%                 roi_mean_xyz=roi_mean_xyz(1:3);
%             case 'z'
%                 roi_mean_xyz= mean(abs(tmp_xyz*mat2));
%                 roi_mean_xyz=roi_mean_xyz(1:3);
%             otherwise
%                 error('incorrect use of 2nd argument (use only ''x'' or ''y'' or ''z'' ')
%         end
%     else
%         roi_mean_xyz= mean(abs(tmp_xyz*mat2));
%         roi_mean_xyz=roi_mean_xyz(1:3);
%     end
% catch
%     error(['rotrk_ROImean: Error must be when you invoked' roi_filename 'to get the mean values?. ' ] )
% end







