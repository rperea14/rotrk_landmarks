function sstr_len = rotrk_get_sstrlength(TRKS_IN,opt)
%function sstr_len = rotrk_get_sstrlength(TRKS_IN)
%   (Default unless opt is 'extremes') 
%   This function will take a TRKS_IN struct array and return sstr_len with
%   the length of every single streamline using a point-to-point euclidean
%   distance calculation. 
%   If opt is 'extremes' the euclidean distance will be calculated by from
%   the first [ e.g. XX.sstr.matrix(1,:) ]  and last [ e.g. XX.sstr.matrix(end,:) ] coordinate points sstr.ma

if nargin < 2
    opt='all';
end


for ii=1:size(TRKS_IN.sstr,2)
    sstr_len(ii)=0;
    if strcmp(opt,'extremes')
        sstr_len(ii)=pdist2(TRKS_IN.sstr(ii).matrix(1,:),TRKS_IN.sstr(ii).matrix(end,:));
    else
        
        for jj=1:size(TRKS_IN.sstr(ii).matrix,1)
            if jj~=size(TRKS_IN.sstr(ii).matrix,1)
                sstr_len(ii)=sstr_len(ii)+pdist2(TRKS_IN.sstr(ii).matrix(jj,:),TRKS_IN.sstr(ii).matrix(jj+1,:));
            end
        end
    end
end