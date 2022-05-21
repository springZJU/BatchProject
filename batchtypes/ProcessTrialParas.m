function CellParas = ProcessTrialParas(Para)
eval([GetStructStr(Para) '=ReadStructValue(Para);']);
FoldName = {'FilePath','RootPath','RecordingTech','Region','Date','AnimalCode','SitePos','ProtocolName','Channel','FileName'};
%% Todo
label='TrialParas.mat';
CellAll = GetFileStructure('FoldName',FoldName, 'label',label,'StructName','PathFolds','Para',Para);
CellParas = structSelectViaKeyword(CellAll,keyword,'fieldName','ProtocolName');

%% debug
% load('G:\ty data\datasort\problemData.mat');
% problemInd = contains({CellParas.Date},problemData);
% CellParas = CellParas(problemInd);
%% end
% load('G:\ty data\datasort\CellParas.mat');

if ~isempty(CellAll)
    try
        if LoadIndividualData
            OldData = load([CellAll(1).RootPath '\IndividualData.mat']);
        end
    catch
    end
    IndividualData = SelectStructField(CellParas,{'SitePos','Date','AnimalCode','Region','RecordingTech'},'SelectField','Date');
    hh = waitbar(0,'please wait');
%     for cellnum = 1:size(CellParas,1)
for cellnum = 17:22
        str=['Drawing Figures, current: ' num2str(cellnum) , '(' num2str(cellnum) '/' num2str(size(CellParas,1)) ')' ];
        waitbar(cellnum/size(CellParas,1),hh,str)
        %% try to get TrialParas.mat
        datapath = CellParas(cellnum).FilePath;
        Para.datapath = datapath;
        Para.SitePos = CellParas(cellnum).SitePos;
        PlotDataPath = [erase(datapath,'TrialParas.mat') 'ResultFigures\PlotData.mat'];


        if ~exist(datapath,'file')
            disp('Current Path Does Not Exist TrialParas.mat !!!')
            continue
        elseif exist(PlotDataPath,'file') && skipProcessed
            continue
        else
            load(datapath);
            PlotData = [];
        end


        %% set parameters according to different protocol
        Para = GetProtocolPara(TrialParas,CellParas(cellnum).ProtocolName,Para);

        %% main Process Programs
        if reProcess | ~exist(PlotDataPath,'file')
            if toAnalyseLFP % analyse LFP data
                [TrialParas PlotData] =lfpAnalyze(TrialParas,Para,'PlotData',PlotData);
            end

            if toAnalyseSpike % analyse spike data
                [TrialParas PlotData] =spikeAnalyze(TrialParas,Para,'PlotData',PlotData);
            end

            if toAnalyseBehavior % analyse behavior
                [TrialParas PlotData] = behavAnalyze(TrialParas,Para,'PlotData',PlotData);
            end
        end

        %% save IndivudualData
        ProtocolName = CellParas(cellnum).ProtocolName;
        Date = CellParas(cellnum).Date;
        SitePos = CellParas(cellnum).SitePos;
        DateInd = find(contains({IndividualData.Date},Date));
        try
            ProtocolData.TrialParas = SelectStructField(TrialParas,{'StdNum','FreqBase','IntBase','DurBase','PushTime','Diff','CueType','Behav','CorrectWrong','TFCertainRegion','TFCertainVisibility','TFCertainZscore', 'TFRegionSelect'});
        catch
            ProtocolData.TrialParas = SelectStructField(TrialParas,{'StdNum','FreqBase','IntBase','DurBase','PushTime','Diff','CueType','Behav','CorrectWrong'});
        end
        ProtocolData.TrialParasPath = datapath;
        %ProtocolData = plotDataEvalue(ProtocolData,PlotData);
        ProtocolData.PlotDataPath = [erase(datapath,label) 'ResultFigures\PlotData.mat'];
        IndividualData(DateInd).(ProtocolName) = ProtocolData;
        if Fragmentation %分段存储，效率越来越低
            if mod(cellnum,20)==0
                if UpdateIndividualData
                    IndividualData = UpdateStruct(OldData.IndividualData,IndividualData,'Date');
                end
                save([CellAll(1).RootPath '\IndividualData.mat'],'IndividualData');
            elseif cellnum == size(CellParas,1)
                if UpdateIndividualData
                    IndividualData = UpdateStruct(OldData.IndividualData,IndividualData,'Date');
                end
                save([CellAll(1).RootPath '\IndividualData.mat'],'IndividualData');
            end
        end
    end

    if ~Fragmentation %全跑完后存储，一次性存储
        if UpdateIndividualData
            IndividualData = UpdateStruct(OldData.IndividualData,IndividualData,'Date');
        end
        save([CellAll(1).RootPath '\IndividualData.mat'],'IndividualData');
    end


    delete(hh);
end
end
