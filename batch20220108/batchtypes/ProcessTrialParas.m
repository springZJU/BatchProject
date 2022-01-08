function CellParas = ProcessTrialParas(Para)
eval([GetStructStr(Para) '=ReadStructValue(Para);']);
FoldName = {'FilePath','RootPath','RecordingTech','Region','Date','AnimalCode','SitePos','ProtocolName','Channel','FileName'};
%% Todo
label='TrialParas.mat';

CellAll = GetFileStructure('FoldName',FoldName, 'label',label,'StructName','PathFolds','Para',Para);
eval(EvalStructureSelect);

if ~isempty(CellAll)
    try
        if LoadIndividualData
            OldData = load([CellAll(1).RootPath '\IndividualData.mat']);
        end

    catch
    end
    IndividualData = SelectStructField(CellParas,'CopyField',{'SitePos','Date','AnimalCode','Region','RecordingTech'},'SelectField','Date');
    hh = waitbar(0,'please wait');
    for cellnum = 1:size(CellParas,1)
        try
            %         for cellnum = 1
            str=['Drawing Figures, current: ' num2str(cellnum) , '(' num2str(cellnum) '/' num2str(size(CellParas,1)) ')' ];
            waitbar(cellnum/size(CellParas,1),hh,str)
            %% try to get TrialParas.mat
            datapath = CellParas(cellnum).FilePath;
            Para.datapath = datapath;
            Para.SitePos = CellParas(cellnum).SitePos;
            PlotDataPath = [erase(datapath,'TrialParas.mat') 'ResultFigures\PlotData.mat'];
            try
                load(PlotDataPath);
            catch
                PlotData = [];
            end
            try
                load(datapath);
                %             load([erase(datapath,'\TrialParas.mat') '\ResultFigures\PlotData.mat']);
            catch
                disp('Current Path Does Not Exist TrialParas.mat !!!')
                continue
            end

            %%
            Para = GetProtocolPara(TrialParas,CellParas(cellnum).ProtocolName,Para);
            try
                buffer=TrialParas(Paranum).Lfpdata;
                meanbase = mean(lfp.rawdata(:,lfp.T>(TrialParas(Paranum).StdTime+MinusBaseline(1))*1000&lfp.T<(TrialParas(Paranum).StdTime+MinusBaseline(2))*1000),2);
                for chs=1:size(meanbase,1)
                    buffer2(chs,:) = buffer(chs,:)-meanbase(chs);
                end
                TrialParas(Paranum).Lfpdata = buffer2;
            catch
            end

            %         [TrialParas PlotData] =lfpAnalyze('TrialParas',TrialParas,'Para',Para);

        catch

            close
            continue
        end

        ProtocolName = CellParas(cellnum).ProtocolName;
        Date = CellParas(cellnum).Date;
        SitePos = CellParas(cellnum).SitePos;
        DateInd = find(contains({IndividualData.Date},Date));
        %         ProtocolData.TrialParas = rmfield(TrialParas,{'StrType','Lfpdata','Spikeraw','Spikesort','Spectrum','SpecYlength'});
        try
            ProtocolData.TrialParas = SelectStructField(TrialParas,'CopyField',{'StdNum','FreqBase','IntBase','DurBase','PushTime','Diff','CueType','Behav','CorrectWrong','TFCertainRegion','TFCertainVisibility','TFCertainZscore', 'TFRegionSelect','IsArtifact'});
        catch
            ProtocolData.TrialParas = SelectStructField(TrialParas,'CopyField',{'StdNum','FreqBase','IntBase','DurBase','PushTime','Diff','CueType','Behav','CorrectWrong','IsArtifact'});
        end
        ProtocolData.TrialParasPath = datapath;
        if ~isempty(PlotData)
            ProtocolData.PlotData = rmfield(PlotData,'SpectData');
            ProtocolData.PlotDataPath = [erase(datapath,label) 'ResultFigures\PlotData.mat'];
        end
        IndividualData(DateInd).(ProtocolName) = ProtocolData;

        %         if mod(cellnum,10)==0
        %             try
        %                 if UpdateIndividualData
        %                     IndividualData = UpdateStruct(OldData.IndividualData,IndividualData,'Date');
        %                 end
        %             catch
        %             end
        %             save([CellAll(1).RootPath '\IndividualData.mat'],'IndividualData');
        %         end

    end

    save([CellAll(1).RootPath '\IndividualData.mat'],'IndividualData');
    delete(hh);
end
end
