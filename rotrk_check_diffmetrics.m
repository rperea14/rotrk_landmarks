function [flag_ok, diff_bad ]  = rotrk_check_diffmetrics(varargin)
%function [flag_ok, diff_bad ]  = rotrk_check_diffmetrics( varargin)
flag_ok=0;
diff_bad=0;
AA=varargin{1};

for ii=2:size(AA,2) %change every TRKS
    for jj=1:size(AA,1) %change every diffmetric
        if ~strcmp(AA{1,ii}.id,AA{jj,ii}.id)
            flag_ok=ii;
            error( [ AA{ii,jj}.id.identifier ': ' cell2char(AA{1,ii}.id) ...
                ' and ' cell2char(AA{jj,ii}.id) ' differ!' ])
            diff_bad=jj;
        end
    end
end