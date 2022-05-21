function varargout = lfpAnalyze(TrialParas,Para,varargin)
%% read input arguments
if nargin<2
    disp('Please input datapath information')
    return
else

    for i = 1:2:length(varargin)
        eval([ varargin{i} '=varargin{i+1};']);
    end
    try
        eval([GetStructStr(Para) '=ReadStructValue(Para);']);
    catch
    end
end



savefoldT = erase(datapath,'\TrialParas.mat');
Savepath = check_mkdir_SPR(savefoldT,'ResultFigures');


oldpath=pwd;
cd(Savepath);
buffer = dir('*.*');
subfold = buffer([buffer.isdir] & ~strcmp({buffer.name},'.') & ~strcmp({buffer.name},'..'),:);
subfoldname = {subfold.name};
cd(oldpath);
FsRaw=TrialParas(1).FsRaw;

%% sometimes LFP data do not have same length
if length(TrialParas(1).Lfpdata)~= length(TrialParas(2).Lfpdata)
    TrialParas(1)=[];%delete first trial
elseif length(TrialParas(end).Lfpdata)~= length(TrialParas(end-1).Lfpdata)
    TrialParas(end)=[];%delete last trial
end

%% wavelet analysis
if ~isfield(TrialParas,'Spectrum')
    TrialParas=SpectroAnalyze(TrialParas,FsRaw,Wavelet,FsNew,'Para',Para);
end

%% calculate mean power of selected Time-Frequency Region
if numel(TimeFrequencyRegion)==4
    TrialParas = AverageCertainFieldPower(TrialParas,TimeFrequencyRegion,'Para',Para);
end

%% load PlotData
if exist([Savepath '\PlotData.mat'],'file')
    load([Savepath '\PlotData.mat']);
end

%% plot Population spectro-temporal figures
savefold = 'population several channel result';
if ~skipExisting || ~any(strcmp(subfoldname,savefold))% whether skip analysing for what has been analysed previously
    for Ch1=1:PlotCh:ChAll(end)
        for resstr=1:3 %ResStr={'Align2Std1Onset','Align2DevOnset','Align2Push'};
            for cuetype=1:length(CueTypes) %CueType={'freq','int','all'};
                CueType = CueTypes{cuetype};
                for behav=behavtype %Behav={'Push','Nopush','All'};
                    [ Behav ResStr]=ReadDefStr('Behav',behav,'ResStr',resstr);
                    plotpara=SetPlotPara('PlotType',1,'CueType',CueType,'Behav',Behav,'ResStr',ResStr,...
                        'Chs',[Ch1:1:(Ch1+PlotCh-1)],'ChAll',ChAll,'Diff',Diff,'Cscale','auto_semiequalCLim',...
                        'PlotWin',[-3,3.5],'ylinepos',[0],'savefold',savefold,'ToPlot',1);%,'SetCLim',ones(ChAll,1)*70
                    [~,~,SpecData.DevDiff.(CueType).(ResStr).(Behav)([Ch1:1:(Ch1+PlotCh-1)],:)]=PlotTypes(TrialParas,'plotpara',plotpara,'Savepath',Savepath);
                end
            end
        end
        SpecData.plotpara.DevDiff = plotpara;
    end
end

%% plot SingleTrial spectro-temporal figures
% plotpara=SetPlotPara('PlotType',2,'Chs',[Ch1:1:(Ch1+PlotCh-1)],'ChAll',ChAll,'Cscale','auto','savefold','single trial result');
% h=PlotTypes(TrialParas,plotpara,Savepath);

%% plot Standard Average spectro-temporal figures
PlotWin = [-2 5; -4 3;];
savefold = {'Standard Average Select','Deviant Average Select'};
for Ch1=1:PlotCh:ChAll(end)
    for resstr=1:2 %ResStr={'Align2Std1Onset','Align2DevOnset','Align2Push'};
        for cuetype=1:length(CueTypes) %CueType={'freq','int','all'};

            if ~skipExisting || ~any(strcmp(subfoldname,savefold{resstr})) || ~any(strcmp(subfoldname,'Push-NoPush'))% whether skip analysing for what has been analysed previously
                for behav=behavtype %Behav={'Push','Nopush','All'};
                    CueType = CueTypes{cuetype};
                    [ Behav ResStr]=ReadDefStr('Behav',behav,'ResStr',resstr);
                    plotpara=SetPlotPara('PlotType',3,'Chs',[Ch1:1:(Ch1+PlotCh-1)],'ChAll',ChAll,'Cscale','auto_semiequalCLim','PlotWin',PlotWin(resstr,:),...
                        'CueType',CueType,'Behav',Behav,'ResStr',ResStr,'ylinepos',[0:0.5:3.5],...
                        'Diff',Diff,'savefold',savefold{resstr},'ToPlot',1);%,'SetCLim',ones(ChAll,1)*70
                    [SpectAll{resstr,behav} SpecData.Stdres.(CueType).(ResStr).(Behav)]=PlotTypes(TrialParas,'plotpara',plotpara,'Savepath',Savepath);
                    SpecData.plotpara.Stdres = plotpara;
                   
                end
            
            % Standard Push-Nopush
%             bufferSubFold = GetDirInPath([Savepath '\' savefold{resstr}]);
                if strcmp(AP,'Active')
                    plotpara=SetPlotPara('CueType',CueType,'Behav',Behav,'ResStr',ResStr,'ylinepos',[0:0.5:3.5],...
                        'Chs',[Ch1:1:(Ch1+PlotCh-1)],'ChAll',ChAll,'Diff',1,'Cscale','auto_equalCLim','ToPlot',1,'savefold',[savefold{resstr} '\Push-NoPush']);
                    SpecData.P_NPStd.(CueType).(ResStr) = Push_NopushSpect(SpectAll(resstr,:),plotpara,Savepath);
                    SpecData.plotpara.P_NPStd = plotpara;
                end
            end


            % %Standard ANOVA
            %             plotpara=SetPlotPara('PlotType',4,'CueType',CueType,'ResStr',ResStr,'SigBase',0.05,...
            %                 'Chs',[Ch1:1:(Ch1+PlotCh-1)],'behavind',[1 2],'Cscale',[0 2],'ylinepos',[0:0.5:3.5],'ToPlot',1,...
            %                 'linepos',[2 5 10],'savefold','Standard Average Select','ROI',[0 3.5;2 10]);
            %             if Ch1==1
            %                 h=0;
            %             end
            %             h=CalSigBeTweenPushNopush_anova(SpectAll,plotpara,Savepath,h);
            %             end
        end
    end
end
clear SpectAll
%% plot Population MMN figures
for resstr=2 %ResStr={'Align2Std1Onset','Align2DevOnset','Align2Push'};
    for cuetype=1:length(CueTypes) %CueType={'freq','int','all'};
        for Ch1=1:PlotCh:ChAll(end)
            for behav=behavtype %Behav={'Push','Nopush','All'};
                CueType = CueTypes{cuetype};
                savefold = 'MMN result';
                if ~skipExisting || ~any(strcmp(subfoldname,savefold)) % whether skip analysing for what has been analysed previously
                    [ Behav ResStr]=ReadDefStr('Behav',behav,'ResStr',resstr);
                    plotpara=SetPlotPara('PlotType',4,'CueType',CueType,'Behav',Behav,'ResStr',ResStr,...
                        'Chs',[Ch1:1:(Ch1+PlotCh-1)],'ChAll',ChAll,'Diff',Diff,'ylinepos',[0],'PlotWin',[-0.2,0.5],'Cscale','auto_equalCLim','ISI',0.5,'MMN',1,...
                        'linepos',[2 10 30],'Coneinf',0,'savefold',savefold,'ToPlot',1);
                    [SpectAll{behav} IndN SpecData.MMN.(CueType).(Behav)]=PlotTypes(TrialParas,'plotpara',plotpara,'Savepath',Savepath);
                    SpecData.plotpara.MMN=plotpara;
                end
            end

            % %MMN Push-Nopush
            %             savefold = 'MMN Push-NoPush';
            %                 if isempty(find(strcmp(subfoldname,savefold)))
            %             plotpara=SetPlotPara('PlotType',4,'CueType',CueType,'Behav',Behav,'ResStr',ResStr,...
            %                 'Chs',[Ch1:1:(Ch1+PlotCh-1)],'Diff',[1:5],'Cscale','auto_equalCLim','ylinepos',[0],'ToPlot',1,'savefold',savefold);
            %             Push_NopushSpect(SpectAll,plotpara,Savepath);
            %                 end
            %
            % %MMN ANOVA
            %             plotpara=SetPlotPara('PlotType',4,'CueType',CueType,'Behav','Push','ResStr',ResStr,'SigBase',0.05,...
            %                 'Chs',[Ch1:1:(Ch1+PlotCh-1)],'Diff',[3:5],'Cscale',[0 2],'ylinepos',[0],'ToPlot',1,...
            %                 'linepos',[2 10 30],'savefold','MMN result','ROI',[0 0.3;10 50]);
            %             if Ch1==1
            %                 h=0;
            %             end
            %             h=CalSigBeTweenDiff_anova(SpectAll,plotpara,Savepath,h);
            %             clear SpectAll

        end
    end
end
clear SpectAll

%% plot TFCertainField distribution
% savefold = 'TFCertainRegionDistribution';
% if ~skipExisting || ~any(strcmp(subfoldname,savefold))% whether skip analysing for what has been analysed previously
%     plotpara=SetPlotPara('PlotType',5,'Chs',[Ch1:1:(Ch1+PlotCh-1)],'ChAll',ChAll,'savefold',savefold,'ToPlot',1);
%     PlotData.TFcertainZDistribution = PlotTypes(TrialParas,'Para',Para,'plotpara',plotpara,'Savepath',Savepath);
% end

%% plot RawDataResultByTrial
savefold = 'RawDataResultByTrial';
if ~skipExisting || ~any(strcmp(subfoldname,savefold)) % whether skip analysing for what has been analysed previously
    plotpara=SetPlotPara('PlotType',6,'Chs',[Ch1:1:(Ch1+PlotCh-1)],'ChAll',ChAll,'savefold',savefold,'ToPlot',1);
%     PlotTypes(TrialParas,'Para',Para,'plotpara',plotpara,'Savepath',Savepath);
end

%% plot waveform of Standard
PlotWin = [-2 3.5; -3.5 5];
savefold = {'Standard Wave Average Select','Deviant Wave Average Select'};
for Ch1=1:PlotCh:ChAll(end)
    for resstr=1:2 %ResStr={'Align2Std1Onset','Align2DevOnset','Align2Push'};
        for cuetype=1:length(CueTypes) %CueType={'freq','int','all'};
            if ~skipExisting || ~any(strcmp(subfoldname,savefold{resstr})) % whether skip analysing for what has been analysed previously
                for behav=behavtype %Behav={'Push','Nopush','All'};
                    CueType = CueTypes{cuetype};
                    [ Behav ResStr]=ReadDefStr('Behav',behav,'ResStr',resstr);
                    plotpara=SetPlotPara('PlotType',13,'Chs',[Ch1:1:(Ch1+PlotCh-1)],'ChAll',ChAll,'PlotWin',PlotWin(resstr,:),...
                        'CueType',CueType,'Behav',Behav,'ResStr',ResStr,'ylinepos',[0:0.5:3.5],...
                        'Diff',Diff,'savefold',savefold{resstr},'ToPlot',1);
                    [WaveAll{resstr,behav} WaveData.Stdres.(CueType).(ResStr).(Behav)]=PlotTypes(TrialParas,'plotpara',plotpara,'Savepath',Savepath);
                    WaveData.plotpara.Stdres = plotpara; 
                end
            end
        end
    end
end
clear SpectAll


if exist('WaveData','var')
PlotData.WaveData = WaveData;
end
if exist('SpectData','var')
PlotData.SpectData = SpecData;
end
save([Savepath '\PlotData.mat'], 'PlotData');
if ChAll~=1
    TrialParas = rmfield(TrialParas,'Spectrum');
end
save([savefoldT '\TrialParas.mat'],'TrialParas');
varargout{1} = TrialParas;
varargout{2} = PlotData;
% end
cd(oldpath);
end