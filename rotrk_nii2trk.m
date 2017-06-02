% function TRKS_OUT = rotrk_nii2trk(nii_vol, trk_ref)
%
% ALL THESE HAS NOT BEEN IMPLEMENTED SINCE TRKS CANNOT FOLLOW A SPECIFIC
% PATH (UNLESS WE TREAT THEM ALL AS A SINGLE STREAMLINE). INSTEAD, PLEASE
% USE rotrk_ROIxyz!

disp( 'ALL THESE HAS NOT BEEN IMPLEMENTED SINCE TRKS CANNOT FOLLOW A SPECIFIC' ...
 ' PATH (UNLESS WE TREAT THEM ALL AS A SINGLE STREAMLINE). INSTEAD, PLEASE ' ...
 'USE rotrk_ROIxyz!');
% 
% %function TRKS = rotrk_nii2trk(nii_vol, trk_ref)
% %   Compulsory input arguments:
% %       nii_vol:      volume input in .nii.gz or .nii format (e.g. temp.nii.gz)
% %       trk_ref:      reference trk struct/cell to get similar coord. space
% %                     properties.
% %   Output:
% %       TRKS_OUT:     TRK structure similar to TrackVis or DsiStudio format
% 
% 
% 
% if nargin <2
%     error('Not enough arguments. Please input a nii_volume and a trk_reference')
% end
% 
% 
% 
% 
% 
% %IS vol_input IT GZIPPED??
% if ischar(nii_vol)
%     [ nii_dirpath, nii_filename, nii_ext ] = fileparts(nii_vol);
%     if strcmp(nii_ext,'.gz')
%         disp(['Gunzipping...' vol_input ]);
%         system([ 'gunzip ' vol_input ] );
%         VOL_IN = [ ronii_dirpath filesep ronii_filename ];
%     else
%         VOL_IN = vol_input;
%     end
% else
%     error('nii_vol should be a char type. If not, please finish implementing. RDP20@01-06-2017');
% end
% 
% 
% %Dealing with struct vs. cell TRK_ref
% if  iscell(trk_ref)
%     TRKS_IN=trl_ref{end};
% elseif isstruct(trk_ref)
%     TRKS_IN=trk_ref;
% else
%     error('trk_ref should be a struct or cell/ If not, please finish implementing. RDP20@01-06-02017')
% end
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% %GZIP ISSUES:
% if strcmp(nii_ext,'.gz') %for output ROI_NAME
%     system(['gzip -f ' vol_input ] )
% end
% 
% 
% 
% 
% %   Created by Rodrigo Perea --> rpereacamargo@mgh.harvard.edu