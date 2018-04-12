function [flag_ok, diff_bad ]  = rotrk_check_diffmetrics(varargin)
%function [flag_ok, diff_bad ]  = rotrk_check_diffmetrics( varargin)
%   Checks whether all the DIFFMETRICS have the same SUBJECT ID name.
%   Returns 0 if ok, all of them are equal OR
%   Stops, display an error if not equal!

flag_ok=0;
diff_bad=0;
AA=varargin{1};

for ii=2:size(AA,2) %change every TRKS
    for jj=1:size(AA,1) %change every diffmetric
        if ~strcmp(AA{1,ii}.id,AA{jj,ii}.id)
            flag_ok=ii;
            error( [ 'Mismatch found in: DIFFMETRICS{1,' num2str(ii) '}  and '...
                'DIFFMETRICS{' num2str(jj) ',' num2str(ii) '} : ' cell2char_rdp(AA{1,ii}.id) ...
                ' and ' cell2char_rdp(AA{jj,ii}.id) ' differ!' ])
            diff_bad=jj;
        end
    end
end