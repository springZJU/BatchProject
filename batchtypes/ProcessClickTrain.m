function CellParas = ProcessClickTrain(Para)
eval([GetStructStr(Para) '=ReadStructValue(Para);']);
label='data.mat';
FoldName = {'FilePath','RootPath','RecordingTech','Region','Date','AnimalCode','SitePos','ProtocolName','Channel','FileName'};
CellAll = GetFileStructure('FoldName',FoldName, 'label',label,'StructName','PathFolds','Para',Para);
CellParas = structSelectViaKeyword(CellAll,keyword,'fieldName','FilePath');

if ~isempty(CellAll)
    IndividualData = SelectStructField(CellParas,{'SitePos','Date','AnimalCode','Region','RecordingTech'},'SelectField',{'Date','SitePos'});
    hh = waitbar(0,'please wait');
    for cellnum = 1:size(CellParas,1)
        %% add clickTrain info
        if contains(CellParas(cellnum).ProtocolName,'ClickTrainSSA')
            datapath = CellParas(cellnum).FilePath;
            if ~exist([erase(datapath,'\data.mat') '\clickTrainInfo.mat'],'file')
                display(CellParas(cellnum).FilePath);
                addClickTrainInfo(datapath);
            end
        end
    end



    for cellnum = 1:size(CellParas,1)
        %% IndividualData
        if LoadIndividualData && exist('IndividualData.mat','file')
            OldData = load([CellAll(1).RootPath  '\IndividualData.mat']);
        end

        %% get protocolName
        mProtocolName = CellParas(cellnum).ProtocolName;
        mRecordingTech = CellParas(cellnum).RecordingTech;
        str=['Processing ' mProtocolName ', current: ' num2str(cellnum) , '(' num2str(cellnum) '/' num2str(size(CellParas,1)) ')' ];
        waitbar(cellnum/size(CellParas,1),hh,str)

        datapath = erase(CellParas(cellnum).FilePath,'data.mat');
        cd(datapath);
        %% config basic analyse params
        params = clickTrainConfig(mProtocolName);
        params = AddParameterInPara('Para',params,'protocolName',mProtocolName,'FsNew',300);


        %% check stimParams.mat, or process and generate it

        if ~any(exist('stimParams.mat','file') | exist('batchOpt.mat','file')) || reProcess
            if contains(mProtocolName,'ClickTrainSSA')
                if contains(mRecordingTech,'LinearArrayLfp')
                    clickTrainSSAWinsSpikeFunc(params,CellParas(cellnum).FilePath,'Para',Para);
                elseif contains(mRecordingTech,'ECoG')
                    clickTrainSSAWinsECoGFunc(params,CellParas(cellnum).FilePath,'Para',Para);
                end
            elseif contains(mProtocolName,'ClickTrainToneCF')
                clickTrainCFFunc(params,CellParas(cellnum).FilePath);
            else
                [stimParams.rez stimParams.stimType stimParams.stimPara] = clickTrainAdaptationGenFunc(params,CellParas(cellnum).FilePath,'Para',Para);
            end

        elseif exist('stimParams.mat','file') && ~reProcess && skipProcessed
            continue
        else
            load('stimParams.mat');
        end


        if SaveIndividualData
            % save IndivudualData
            ProtocolName = CellParas(cellnum).ProtocolName;
            Date = CellParas(cellnum).Date;
            SitePos = CellParas(cellnum).SitePos;
            DateInd = find(contains({IndividualData.Date},Date) & contains({IndividualData.SitePos},SitePos));
            if contains(ProtocolName,'ClickTrainSSA')
            stimParams.rez.asStd = rmfield(stimParams.rez.asStd,{'rasterBySound','PSTHBySound'});
            stimParams.rez.asDev = rmfield(stimParams.rez.asDev,{'rasterBySound','PSTHBySound'});
            end
            ProtocolData.rez = stimParams.rez;
            ProtocolData.stimType = stimParams.stimType;
            ProtocolData.rezPath = [datapath '\stimParams.mat'];

            IndividualData(DateInd).(ProtocolName) = ProtocolData;
            if Fragmentation %分段存储，效率越来越低
                if mod(cellnum,20)==0
                    if UpdateIndividualData
                        IndividualData = UpdateStruct(OldData.IndividualData,IndividualData,'Date');
                    end
                    save([CellAll(1).RootPath '\IndividualData.mat'],'IndividualData');
                elseif cellnum == size(CellParas,1)
                    if UpdateIndividualData && exist('OldData','var')
                        IndividualData = UpdateStruct(OldData.IndividualData,IndividualData,'Date');
                    end
                    save([CellAll(1).RootPath '\IndividualData.mat'],'IndividualData');
                end
            end

        end
        if ~Fragmentation %全跑完后存储，一次性存储
            if UpdateIndividualData && exist('OldData','var')
                IndividualData = UpdateStruct(OldData.IndividualData,IndividualData,'Date');
            end
            save([CellAll(1).RootPath '\IndividualData.mat'],'IndividualData');
        end
    end
    delete(hh);
end
end
