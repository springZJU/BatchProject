function res=iircombfilter(data,fo,q,fs)
bw = (fo/(fs/2))/q;
[bb,aa] = iircomb(fs/fo,bw,'notch'); % Note type flag 'notch'
res=filter(bb,aa,data);
end