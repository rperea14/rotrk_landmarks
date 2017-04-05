function sstr_len = rotrk_get_sstrlength(TRKS_IN)
%function sstr_len = rotrk_get_sstrlength(TRKS_IN)
%   This function will take a TRKS_IN struct array and return sstr_len with
%   the length of every single streamline using a point-to-point euclidean
%   distance calculation. 


for ii=1:size(TRKS_IN.sstr,2)
    sstr_len(ii)=0;
    for jj=1:size(TRKS_IN.sstr(ii).matrix,1)
        if jj~=size(TRKS_IN.sstr(ii).matrix,1)
            sstr_len(ii)=sstr_len(ii)+pdist2(TRKS_IN.sstr(ii).matrix(jj,:),TRKS_IN.sstr(ii).matrix(jj+1,:));
        end
    end
end