function Z=normalize_plv(plv_data,plv_ref)
m_ref1=mean(plv_ref,2);
s_ref1=std(plv_ref')';
Z=(plv_data-m_ref1*ones(1,size(plv_data,2)))./(s_ref1*ones(1,size(plv_data,2)));