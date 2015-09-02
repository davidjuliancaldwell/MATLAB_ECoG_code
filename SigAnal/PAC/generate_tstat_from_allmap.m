function
tstat=generate_tstat_from_allmap(map,inn,out,fxa,fxb,use_measure,xx)

yi=xx(1:end-1);
yo=yi;
yis=yi;
yos=yi;
ni=yi;
no=yi;

[map_inn,dst_in]=select_interaction_map(inn,map,[]);
[map_out,dst_out]=select_interaction_map(out,map,[]);
val_inn=sample_map_region(map_inn,fxa,fxb,use_measure);
val_out=sample_map_region(map_out,fxa,fxb,use_measure);
for i=1:length(xx)-1;
    yi(i)=mean(val_inn(dst_in>=xx(i) & dst_in<xx(i+1)));
    yo(i)=mean(val_out(dst_out>=xx(i) & dst_out<xx(i+1)));

    yis(i)=var(val_inn(dst_in>=xx(i) & dst_in<xx(i+1)));
    yos(i)=var(val_out(dst_out>=xx(i) & dst_out<xx(i+1)));

    ni(i)=sum(dst_in>=xx(i) & dst_in<xx(i+1));
    no(i)=sum(dst_out>=xx(i) & dst_out<xx(i+1));
end

tstat=(yi-yo)./sqrt(yis./ni+yos./no);
