function [sound_all lfp spike sortdata behavresult] = PEOddBaseSoundAll(path,params,varargin)
%% sound_all params
% 1: sound number in the trial/ 2:num0 in epocs/ 3: not important
% 4: trial number/ 5:std freq/ 6:dev freq/ 7:std int/ 8: dev int/ 
% 9:std dur/ 10:dev dur/ 11: std1 or push time/ 
% 12: freq dev ratio/ 13: int dev ratio/ 14:dur dev ratio/ 
% 15: not important/ 16: freq diff level/ 17: int diff level/ 18: dur diff level
% 19: group names

if nargin>1
    for i = 1:2:length(varargin)
        eval([ varargin{i} '=varargin{i+1};']);
    end
end
eval([GetStructStr(params) '=ReadStructValue(params);']);
load(path);
dat=data;
rawdata=double(data.lfp.data)*10^6;
FsRaw=data.lfp.fs;
buffer=rawdata;

[P,Q] = rat(FsNew/FsRaw);
bufferResample = (resample(buffer',P,Q))';
bufferResample = iircombfilter(bufferResample,50,45,FsNew);
lfp.rawdata=bufferResample;
lfp.fs=FsNew;

lfp.T=(0:1:length(lfp.rawdata)-1)*1000/lfp.fs;
if isfield(data,'spike')
    spike=data.spike;
    if size(spike,2)==1
        spike=spike';
    end
else
    spike=[];
end

if isfield(data,'sortdata')
    sortdata=data.sortdata';
    if size(sortdata,2)==1
        sortdata=sortdata';
    end
else
    sortdata=[];
end

if isfield(dat.epocs,'epocs')
    dat.epocs = dat.epocs.epocs;
end

%%
cue_types={'group1','group2','group3','all'};
errintrpt=[];
if ~isfield(dat.epocs,'push')
    dat.epocs.push.onset=[];
    disp('No pushment!');
else
    if isfield(dat.epocs,'erro')
        for i=1:length(dat.epocs.erro.data)
            err=find(dat.epocs.swee.data==dat.epocs.erro.data(i,1)&dat.epocs.erro.data(i,1)~=0);
            if ~isempty(err)
                if isempty(errintrpt)|isempty(find(err<=errintrpt(end,1)))
                    err1=[err dat.epocs.num0.data(err)];
                    errintrpt=[errintrpt;err1];
                end
                if (max(find(dat.epocs.num0.data(err)==1))-1)>0
                    dat.epocs.num0.data(err(1):err(max(find(dat.epocs.num0.data(err)==1))-1),1)=0;
                else
                    dat.epocs.num0.data(err(1):err(end),1)=0;

                end
            end

        end
    end
end
if dat.epocs.num0.data(end,1)==1
    dat.epocs.num0.data(end,1)=0;
end

%% TODO
dat.epocs.freq.data=dat.epocs.freq.data(dat.epocs.num0.data~=0);
dat.epocs.freq.onset=dat.epocs.freq.onset(dat.epocs.num0.data~=0);
try
    dat.epocs.Durr.data=dat.epocs.Durr.data(dat.epocs.num0.data~=0);
    dat.epocs.Durr.onset=dat.epocs.Durr.onset(dat.epocs.num0.data~=0);
catch
end

freinfo=floor(dat.epocs.freq.data);%把频率变为整数
try
    intinfo=floor(dat.epocs.Durr.data);
catch
    intinfo=ones(length(freinfo))*60;
end
try
    durinfo=floor(dat.epocs.Dura.data);
catch
    durinfo=ones(length(freinfo))*100;
end

%%
dat.epocs.num0.data=dat.epocs.num0.data(dat.epocs.num0.data~=0);
push=dat.epocs.push.onset;

devchu=find(dat.epocs.num0.data==1)-1;
devorder=[devchu(2:end);length(dat.epocs.num0.data)];
stdorder=setdiff((1:1:length(dat.epocs.freq.onset)),devorder)';
std1order=[1;devorder(1:end-1)+1];
sound_all(:,1)=dat.epocs.freq.onset;%1：每个trial的sti的刺激时间；
sound_all(:,2)=1:1:length(sound_all);%2：原序号
sound_all(:,4)=dat.epocs.num0.data;%4:trial num


for i=1:length(devorder)
    if(i==1)
        sound_all(1:devorder(i),5)=freinfo(1,1);
        sound_all(1:devorder(i),6)=freinfo(devorder(i),1);
        sound_all(1:devorder(i),7)=intinfo(1,1);
        sound_all(1:devorder(i),8)=intinfo(devorder(i),1);
        sound_all(1:devorder(i),9)=durinfo(1,1);
        sound_all(1:devorder(i),10)=durinfo(devorder(i),1);
    else
        sound_all(devorder(i-1)+1:devorder(i),5)=freinfo(devorder(i)-1,1);%std freq
        sound_all(devorder(i-1)+1:devorder(i),6)=freinfo(devorder(i),1);%Dev freq
        sound_all(devorder(i-1)+1:devorder(i),7)=intinfo(devorder(i)-1,1);%std int 
        sound_all(devorder(i-1)+1:devorder(i),8)=intinfo(devorder(i),1);%Dev int
        sound_all(devorder(i-1)+1:devorder(i),9)=durinfo(devorder(i)-1,1);%std dur
        sound_all(devorder(i-1)+1:devorder(i),10)=durinfo(devorder(i),1);%Dev dur
    end
end

sound_all(:,11)=sound_all(:,1);
for i=1:length(devorder)
    devpushs=push(push>sound_all(devorder(i),1)+choicewin(1)/1000&push<(sound_all(devorder(i),1)+choicewin(2)/1000)); %单位是S
    if ~isempty(devpushs)
        sound_all(devorder(i),11)= devpushs(1);%仅仅dev的那个时间改了
    end
end

devorder=[find(sound_all(:,4)==1)-1;length(sound_all)];
devorder(1)=[];
std1order=find(sound_all(:,4)==1);
sound_all(:,12)=roundn(sound_all(:,6)./sound_all(:,5),-2); % freq dev ratio
sound_all(:,13)=roundn(sound_all(:,8)./sound_all(:,7),-2); % int dev ratio
sound_all(:,14)=roundn(sound_all(:,10)./sound_all(:,9),-2);% dur dev ratio
fre=unique(sound_all(:,12));
Int=unique(sound_all(:,13));
Dur=unique(sound_all(:,14));
if Int(1)~=1
    Int = sort(Int,'descend');
end

if fre(1)~=1
    fre = sort(fre,'descend');
end

if Dur(1)~=1
    Dur = sort(Dur,'descend');
end
devsti=sound_all(devorder,:);

for k=1:length(devsti)%相当于总共开启了多少次trial
sound_all(std1order(k):devorder(k),3)=k;
end

%% TODO
m=length(fre);
n=length(cue_types);

%%
stiall=zeros(m,n);%每种刺激类型的个数
pushall=zeros(m,n);
rightall=zeros(m,n);
errall=zeros(m,n);

devindex=devorder;
std1index=std1order;
std0index=devindex-1;
for i=1:length(std1index)
    sound_all(devindex(i),15)=0; 
    sound_all(std1index(i):std0index(i),15)=abs(sound_all(std1index(i):std0index(i),4)-sound_all(devindex(i),4));
end


for k=1:length(devsti)%k ：第k个dev sti
    i=find(fre==devsti(k,12));% i：freq dev ratio
    p=find(Int==devsti(k,13));% p：int dev ratio
    q=find(Dur==devsti(k,14));% q：dur dev ratio
    sound_all(std1order(k):devorder(k),16)=i; %freq diff level
    sound_all(std1order(k):devorder(k),17)=p; %int diff level
    sound_all(std1order(k):devorder(k),18)=q; %dur diff level



    if ismember(devsti(k,4)-1,[1 2])
        sound_all(std1order(k):devorder(k),19)=12; %groups
        j=1;
    elseif ismember(devsti(k,4)-1,[3 4])
        sound_all(std1order(k):devorder(k),19)=34; %groups
        j=2;
    elseif ismember(devsti(k,4)-1,[5 6])
        sound_all(std1order(k):devorder(k),19)=56; %groups
        j=3;
    else
        sound_all(std1order(k):devorder(k),19)=789; %groups
        j=4;
    end
   
    stiall(i,j)=stiall(i,j)+1;% total sti num
    kkk=find(push>devsti(k,1)+choicewin(1)/1000&push<(devsti(k,1)+choicewin(2)/1000));
    if fre(i)==fre(1)
        if isempty(kkk) %kkk： push in window
            rightall(i,j)=rightall(i,j)+1;
        else
            pushall(i,j)=pushall(i,j)+1;
            errall(i,j)=errall(i,j)+1;
        end
    else
        if ~isempty(kkk)
            rightall(i,j)=rightall(i,j)+1;
            pushall(i,j)=pushall(i,j)+1;
        else
            errall(i,j)=errall(i,j)+1;
        end
    end

end
try
for cue_type=1:length(cue_types)-1 
    stiall(1,cue_type)=stiall(1,cue_type)+length(find(errintrpt(:,2)==cue_type*2+1));
end
catch
end
behavresult=pushall./stiall;
data.behavresult = behavresult;
save(path,'data');
