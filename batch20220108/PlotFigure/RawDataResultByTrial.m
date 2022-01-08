function RawDataResultByTrial(TrialParas,varargin)
for i = 1:2:length(varargin)
    eval([varargin{i} '=varargin{i+1};']);
end
try
    eval([GetStructStr(Para) '=ReadStructValue(Para);']);
catch
end
try
eval([GetStructStr(plotpara) '=ReadStructValue(plotpara);']);
catch
end
if ToPlot == 1
for ch = 1:ChAll
for Paranum = 1:size(TrialParas,1)
    
    if mod(Paranum-1,60)==0
        h = figure('Visible','off')
        set(gcf,'outerposition',get(0,'screensize'));
    end
    subplot(6,10,Paranum-60*floor((Paranum-1)/60))
    Spect = TrialParas(Paranum).Spectrum;
    hs = imagesc('XData',Spect.XData-(TrialParas(1).Std1Time-TrialParas(1).StdSelect),...
        'YData',Spect.YData,...
        'CData',Spect.CData{ch});hold on;
    colormap('jet');
    set(gca,'YScale','log');
    set(gca,'ytick',[2 5 10]);
    set(gca,'yticklabel',get(gca,'ytick'));
    if mod(Paranum,60)==0 | Paranum==size(TrialParas,1)
        newpath=[savefold '\Ch' num2str(ch)];
        figsavepath=check_mkdir_SPR(Savepath,newpath);
        saveas(h,[figsavepath  '\TFPlot Ch' num2str(ch) ' Trial' num2str(Paranum-59) '-' num2str(Paranum) '.jpg']);
        close
    end
end

for Paranum = 1:size(TrialParas,1)
    if mod(Paranum-1,60)==0
        h=figure('Visible','off')
        set(gcf,'outerposition',get(0,'screensize'));
    end
    subplot(6,10,Paranum-60*floor((Paranum-1)/60))
    buffer = TrialParas(Paranum).Lfpdata(ch,:);
    switch TrialParas(Paranum).IsArtifact
        case 0
        plot((1:length(buffer))/TrialParas(Paranum).FsRaw,buffer,'b-');
        case 1
        plot((1:length(buffer))/TrialParas(Paranum).FsRaw,buffer,'k-');
        case 2 
        plot((1:length(buffer))/TrialParas(Paranum).FsRaw,buffer,'m-'); 
        case 3
        plot((1:length(buffer))/TrialParas(Paranum).FsRaw,buffer,'r-');     
    end
    ylim([-600 600])
    if mod(Paranum,60)==0 | Paranum==size(TrialParas,1)
        newpath=[savefold '\Ch' num2str(ch)];
        figsavepath=check_mkdir_SPR(Savepath,newpath);
        saveas(h,[figsavepath  '\Waveform Ch' num2str(ch) ' Trial' num2str(Paranum-59) '-' num2str(Paranum) '.jpg']);
close
    end
end
end
end