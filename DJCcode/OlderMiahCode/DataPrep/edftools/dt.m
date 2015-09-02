function datatyp=dt(x)
k=1;
EDF.GDFTYP(1)=x;
if EDF.GDFTYP(k)==0
        datatyp=('uchar');
elseif EDF.GDFTYP(k)==1
        datatyp=('int8');
elseif EDF.GDFTYP(k)==2
        datatyp=('uint8');
elseif EDF.GDFTYP(k)==3
        datatyp=('int16');
elseif EDF.GDFTYP(k)==4
        datatyp=('uint16');
elseif EDF.GDFTYP(k)==5
        datatyp=('int32');
elseif EDF.GDFTYP(k)==6
        datatyp=('uint32');
elseif EDF.GDFTYP(k)==7
        datatyp=('int64');
elseif 0; EDF.GDFTYP(k)==8
        datatyp=('uint64');
elseif EDF.GDFTYP(k)==16
        datatyp=('float32');
elseif EDF.GDFTYP(k)==17
        datatyp=('float64');
elseif 0;EDF.GDFTYP(k)>255 & EDF.GDFTYP(k)< 256+64
        datatyp=(['bit' int2str(EDF.GDFTYP(k))]);
elseif 0;EDF.GDFTYP(k)>511 & EDF.GDFTYP(k)< 511+64
        datatyp=(['ubit' int2str(EDF.GDFTYP(k))]);
elseif EDF.GDFTYP(k)==256
        datatyp=('bit1');
elseif EDF.GDFTYP(k)==512
        datatyp=('ubit1');
elseif EDF.GDFTYP(k)==255+12
        datatyp=('bit12');
elseif EDF.GDFTYP(k)==511+12
        datatyp=('ubit12');
elseif EDF.GDFTYP(k)==255+22
        datatyp=('bit22');
elseif EDF.GDFTYP(k)==511+22
        datatyp=('ubit22');
elseif EDF.GDFTYP(k)==255+24
        datatyp=('bit24');
elseif EDF.GDFTYP(k)==511+24
        datatyp=('ubit24');
else 
        fprintf(2,'Error GDFREAD: Invalid GDF channel type\n');
        datatyp='';
end;
