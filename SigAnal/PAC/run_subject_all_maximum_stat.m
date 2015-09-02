ddc={'outbound','inbound'};
nperm=100;

for s=1:4
    for dc=1:2
        subj=sprintf('S%i',s+1);
        direction=ddc{dc};

        [data,clist,control,fs,tr]=get_subject_data(subj,5,.5,300,4);
        data=cheby_filter_notch(data,58,62,fs,4);
        data=cheby_filter_notch(data,118,122,fs,4);
        data=cheby_filter_notch(data,178,182,fs,4);
        size(data,1)
        if 1
            elsewhere=1:size(data,2);
            elsewhere(clist)=[];
            control=elsewhere(randi(numel(elsewhere,1)));
            fwa=3:30;
            fwb=40:170;
            ff=fwa'*ones(1,length(fwb))+ones(length(fwa),1)*fwb;ff=ff';

            data=resample(data,1,2);
            fs=fs/2;
            map_all=[];
            maxd_all=[];
            p_all=[];
            ff1_all=[];
            ff2_all=[];
            cs_all=[];
            fprintf('working on subject %i %s\n',s,direction');
            tic;
            for i=1:size(data,2)
                fprintf('working on channel %i\n',i);
                switch direction
                    case 'inbound'
                        [map,maxd,~,p]=compute_bplv_cont(data(:,i),data(:,i)
,data(:,control),fwb,fwa,fs,1,nperm,'GPU');
                    case 'outbound'
                        [map,maxd,~,p]=compute_bplv_cont(data(:,control),dat
a(:,control),data(:,i),fwb,fwa,fs,1,nperm,'GPU');
                end

                map_all{i}=map;
                maxd_all{i}=maxd;
                p_all{i}=p;

                tr=quantile(maxd,.95);
                map2=map;
                map2(ff>55 & ff<65)=0;
                map2(ff>115 & ff<125)=0;
                map2(ff>175 & ff<185)=0;
                [~,l,n]=bwboundaries(map2>tr);

                ff1=zeros(n,1);
                ff2=ff1;
                cs=ff1;
                for u=1:n
                    [ixb,ixa]=ind2sub(size(l),find(l==u));
                    f1=mean(fwb(ixb));
                    f2=mean(fwa(ixa));
                    fprintf('found significant interaction for S%i %s
channel %i f1=%3.0f f2=%3.0f size=%i\n',s,direction,i,f1,f2,length(ixb));
                    ff1(u)=f1;
                    ff2(u)=f2;
                    cs(u)=length(ixb);
                end
                ff1_all{i}=ff1;
                ff2_all{i}=ff2;
                cs_all{i}=cs;
            end
            save(fullfile(subj,sprintf('results_max_%s_random_seed.mat',dire
ction)),'fs','map_all','maxd_all','control','clist','p_all','fwa','fwb','ff1
_all','ff2_all','cs_all');
            t2=toc;
            fprintf('took %4.0f seconds\n',t2);
        end
    end
end
