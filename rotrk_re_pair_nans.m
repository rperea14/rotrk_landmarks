function [ pair_nan_Table ] = rotrk_re_pair_nans(unclean_Table,agematched_id, start_after)

fields_table=fields(unclean_Table);

if nargin < 3 ; start_after=2 ; end

pair_nan_Table=unclean_Table;

%NaNing the values where no agematched_ids are found
for ii=1:size(unclean_Table.(agematched_id),1)
    tmp_size=find(unclean_Table.(agematched_id)==unclean_Table.(agematched_id)(ii));
    
    if size(tmp_size,1) ~=2
        pair_nan_Table(ii,start_after:end)={nan};
    end
    clear tmp_size
end



%NaNing the values that it's age matched pair is a Nana
for ii=start_after:size(fields_table,1)-1
    %disp(['in ii: ' num2str(ii) ' ' fields_table(ii)])
    [idx_nan , ~ ] = find (isnan(unclean_Table.(cell2char(fields_table(ii)))));
    pair_matched=zeros(size(idx_nan,1),1);
    for jj=1:size(pair_matched,1)
        pair_matched(jj)=unclean_Table.(agematched_id)(idx_nan(jj));
        [idx_allnan, ~ ] = find (unclean_Table.(agematched_id)==pair_matched(jj));
        pair_nan_Table(idx_allnan',ii)={nan};
    end
    clear pair_matched idx_allnan;
end
