function varargout = clickTrainSSAFunc(params,datapath,varargin)
if nargin<2
    disp('Please input datapath information')
    return
else

    for i = 1:2:length(varargin)
        eval([ varargin{i} '=varargin{i+1};']);
    end

    eval([GetStructStr(params) '=ReadStructValue(params);']);
    run('E:\clickTrain\defClickTrainStimStr.m');
    %% generate stimPara
    load(datapath);
    type = unique(data.epocs.type.data);
    stimType = stimStr(SSAPairs);
    stimType = cellfun(@(x) strrep(x,'S1',[num2str(clickICI(1)) 'ms']),stimType,'UniformOutput',false);
    stimType = cellfun(@(x) strrep(x,'S2',[num2str(clickICI(2)) 'ms']),stimType,'UniformOutput',false);
    savePath = erase(datapath,'\data.mat');

    figRow = 5; % first std, last std, dev, psth, responses

    ISI = data.epocs.tril.onset(2) - data.epocs.tril.onset(1);
    trialNum = data.epocs.tril.data;
    if isfield(data.epocs,'erro')
        errorTrial = unique(data.epocs.erro.data);
        errorInfo = data.epocs.erro.data;
    else
        errorTrial = [];
        errorInfo = zeros(length(trialNum),1);
    end

    trialNum(ismember(trialNum,errorTrial)) = 0;
    validIdx = trialNum>0;
    trialNum = trialNum(validIdx);
    if contains(protocolName,'ClickTrainSSA')
        fieldNames = {'trialNum','soundNum','trialOnset','trialOffset','order','clickDur','trainDur'};
        fieldVal = [num2cell(trialNum) num2cell(data.epocs.num0.data(validIdx))  num2cell(data.epocs.tril.onset(validIdx)) num2cell(data.epocs.tril.onset(validIdx) + ISI) num2cell(data.epocs.ordr.data(validIdx))...
        num2cell(ones(length(trialNum),1)) num2cell(TrainDur * ones(length(trialNum),1))];
    end
    % errorTrial = find(data.epocs.erro.data>0);

    stimPara = easyStruct(fieldNames,fieldVal);
    % ISI = stimPara(1).trialOffset - stimPara(1).trialOnset;

    if isinf(stimPara(end).trialOffset)
        stimPara(end).trialOffset = stimPara(end).trialOnset+ISI;
    end
    sound_all = cell2mat((struct2cell(stimPara))');
    soundN = sound_all(:,2);
    std1Idx = find(soundN == 1);
    devIdx = std1Idx - 1;
    devIdx(1) = [];
    devIdx = [devIdx; length(soundN)];
    nToDev = soundN;
    for i = 1:length(devIdx)
        nToDev(std1Idx(i):devIdx(i)) = soundN(devIdx(i)) - soundN(std1Idx(i):devIdx(i));
    end
    stimPara = addFieldToStruct(stimPara,num2cell(nToDev),'nToDev');


    orders = [stimPara.order]';
    orders(devIdx) = orders(devIdx-1);
    stdOrd = orders;
    stimPara = addFieldToStruct(stimPara,num2cell(stdOrd),'stdOrder');

    [lfp,spike,sortdata,chs] = getRawdata(datapath,params);



    for Paranum = 1:length(stimPara)
        lfpBuffer{Paranum,1} = lfp.rawdata(:,lfp.T>stimPara(Paranum).trialOnset*1000&lfp.T<stimPara(Paranum).trialOffset*1000);
        if ~isempty(spike)
            stimPara(Paranum).Spikeraw = cellfun(@(x) x(x>stimPara(Paranum).trialOnset&x<stimPara(Paranum).trialOffset)-stimPara(Paranum).trialOnset,spike,'UniformOutput',false);
            stimPara(Paranum).SpikerawOrder = cellfun(@(x) x(x>stimPara(Paranum).trialOnset&x<stimPara(Paranum).trialOffset)-stimPara(Paranum).trialOnset,spike,'UniformOutput',false);
        end

        if ~isempty(sortdata)
            stimPara(Paranum).Spikesort = cellfun(@(x) x(x>stimPara(Paranum).trialOnset&x<stimPara(Paranum).trialOffset)-stimPara(Paranum).trialOnset,sortdata,'UniformOutput',false);
            stimPara(Paranum).SpikesortOrder = cellfun(@(x) x(x>stimPara(Paranum).trialOnset&x<stimPara(Paranum).trialOffset),sortdata,'UniformOutput',false);
        end
    end


    spikeSort = {stimPara.Spikesort}';

    %% spikeSort To firing rate
    frateWin = [0 stimPara(1).trainDur]/1000;
    for N = 1:length(spikeSort)
        fRate{N} =  cell2mat(cellfun(@(x) length(findWithinInterval(x,frateWin)), spikeSort{N},'UniformOutput',false))/(frateWin(2)-frateWin(1));
    end

    stimPara = addFieldToStruct(stimPara,fRate','fRate');



    %% spikeSort To PSTH
    opt.binsize = 20; % ms
    opt.binstep = 2; % ms

    %% category trials by order and sound number
    [M,N] = size(SSAPairs);

    stdOrder = sort(unique([stimPara.nToDev]));
    stdOrder = stdOrder(stdOrder>0);
    stdEnd = max(stdOrder);
    soundOrder = sort(unique([stimPara.soundNum]));
    for m = 1:M
        for n = 1:N
            for stdN = soundOrder
                asStd(stdN).Idx{m,n} = find([stimPara.stdOrder]' == SSAPairs(m,n) & ismember([stimPara.soundNum]',stdN));
                asStd(stdN).fRate{m,n} = [stimPara(asStd(stdN).Idx{m,n}).fRate];
                for ch = 1:size(asStd(stdN).fRate{m,n},1)
                    spikeBuffer = cellfun(@(x) [x{ch}*1000 ones(length(x{ch}),1)]  ,{stimPara(asStd(stdN).Idx{m,n}).Spikesort}','UniformOutput',false);
                    for nTrial = 1:length(spikeBuffer)
                        spikeBuffer{nTrial}(:,2) = spikeBuffer{nTrial}(:,2) * nTrial;
                    end
                    asStd(stdN).rasterBySound{m,n}{ch,1} = cell2mat(spikeBuffer);
                    rasterBuffer = cell2mat(spikeBuffer);
                    if ~isempty(rasterBuffer)
                        asStd(stdN).PSTHBySound{m,n}{ch,1} = calPsth(rasterBuffer(:,1),opt,1000,'EDGE',[0 ISI]*1000,'nTrial',length(unique(rasterBuffer(:,2))));
                    else
                        asStd(stdN).PSTHBySound{m,n}{ch,1} = calPsth(-1,opt,1000,'EDGE',[0 ISI]*1000,'nTrial',length(unique(rasterBuffer(:,2))));
                    end
                end

                asStd(stdN).psth{m,n}{ch,1} = cell2mat(spikeBuffer);
                asStd(stdN).fRateMean{m,n} = mean(asStd(stdN).fRate{m,n},2);
                asStd(stdN).fRateSE{m,n} = std(asStd(stdN).fRate{m,n},1,2)/sqrt(size(asStd(stdN).fRate{m,n},2));
            end

            asDev.Idx{m,n} = find([stimPara.order]' == SSAPairs(m,n) & ismember([stimPara.nToDev]',0));
            asDev.fRate{m,n} = [stimPara(asDev.Idx{m,n}).fRate];
            for ch = 1:size(asDev.fRate{m,n},1)
                spikeBuffer = cellfun(@(x) [x{ch}*1000 ones(length(x{ch}),1)]  ,{stimPara(asDev.Idx{m,n}).Spikesort}','UniformOutput',false);
                for nTrial = 1:length(spikeBuffer)
                    spikeBuffer{nTrial}(:,2) = spikeBuffer{nTrial}(:,2) * nTrial;
                end
                asDev.rasterBySound{m,n}{ch,1} = cell2mat(spikeBuffer);
                rasterBuffer = cell2mat(spikeBuffer);
                if ~isempty(rasterBuffer)
                    asDev.PSTHBySound{m,n}{ch,1} = calPsth(rasterBuffer(:,1),opt,1000,'EDGE',[0 ISI]*1000,'nTrial',length(unique(rasterBuffer(:,2))));
                else
                    asDev.PSTHBySound{m,n}{ch,1} = calPsth(-1,opt,1000,'EDGE',[0 ISI]*1000,'nTrial',length(unique(rasterBuffer(:,2))));
                end
                [~,tP0{m,n}(ch,1)] =  ttest2(asStd(1).fRate{m,n}(ch,:),asDev.fRate{m,n}(ch,:));
                [~,tP{m,n}(ch,1)] =  ttest2(asStd(stdEnd).fRate{m,n}(ch,:),asDev.fRate{m,n}(ch,:));
            end
            asDev.fRateMean{m,n} = mean(asDev.fRate{m,n},2);
            asDev.fRateSE{m,n} = std(asDev.fRate{m,n},1,2)/sqrt(size(asDev.fRate{m,n},2));
        end
    end


    Fig = figure;
    maximizeFig(Fig);
    for ii = 1:numel(stimType)
        subplot(numel(stimType),1,ii)
        errorbar(1:length(asStd(stdEnd).fRateMean{ii}),asStd(stdEnd).fRateMean{ii},asStd(stdEnd).fRateSE{ii},'Color','#AAAAAA','LineStyle','-','linewidth',1,'DisplayName','std'); hold on;
        errorbar(1:length(asStd(1).fRateMean{ii}),asStd(1).fRateMean{ii},asStd(1).fRateSE{ii},'Color','blue','LineStyle','-','linewidth',1,'DisplayName','std'); hold on;
        errorbar(1:length(asDev.fRateMean{ii}),asDev.fRateMean{ii},asDev.fRateSE{ii},'Color','red','LineStyle','-','linewidth',1,'DisplayName','dev'); hold on;
        tP0Str{ii} = cellfun(@(x) num2str(x),num2cell(roundn(tP0{ii},-4)),'UniformOutput',false);
        tPStr{ii} = cellfun(@(x) num2str(x),num2cell(roundn(tP{ii},-4)),'UniformOutput',false);
        text((1:length(asStd(stdEnd).fRateMean{ii}))-0.5,asDev.fRateMean{ii}+3,tPStr{ii}); hold on
        xticks(1:length(asStd(stdEnd).fRateMean{ii}));
        legend;
        %     xticklabels
        title(stimType{ii});
        %     xlabel('Channel Number');
        ylabel('Firing Rate (Hz)')
    end
    saveas(Fig,[savePath  '\FiringRate comparison.jpg']);
    close(Fig);

    sigCh = chs';

    rez.asStd = asStd;
    rez.asDev = asDev;
    varargout{1} = rez;
    varargout{2} = stimType;
    varargout{3} = stimPara;

    %% To Plot
    for ch = sigCh


        Fig = figure;
        maximizeFig(Fig);
        firstStdRasterPos = [1:numel(stimType)];  lastStdRasterPos = [numel(stimType)+1 : 2*numel(stimType)];  devPosRaster = [2*numel(stimType)+1 : 3*numel(stimType)];
        PSTHPos = [3*numel(stimType)+1 : 4*numel(stimType)];  stdDevPos = 4*numel(stimType) + (1:numel(stimType)/2);  blockPos = 4*numel(stimType) + (numel(stimType)/2 + 1 : numel(stimType));

        for ii = 1:numel(stimType)
            %% first std raster
            mSubplot(Fig,figRow,numel(stimType),firstStdRasterPos(ii));
            scatter(asStd(1).rasterBySound{ii}{ch}(:,1),asStd(1).rasterBySound{ii}{ch}(:,2),20,[2/3 2/3 2/3],'filled');
            if asDev.fRateMean{ii}(ch) > asStd(1).fRateMean{ii}(ch)
                compStr = 'dev > first std';
            else
                compStr = 'dev< first std';
            end
            xlim([0 ISI]*1000);
            title(['Ch' num2str(ch) '  ' stimType{ii} ' ' compStr '  p = ' tP0Str{ii}{ch}]);
            legend('first standard');

            %% last std raster
            mSubplot(Fig,figRow,numel(stimType),lastStdRasterPos(ii));
            scatter(asStd(stdEnd).rasterBySound{ii}{ch}(:,1),asStd(stdEnd).rasterBySound{ii}{ch}(:,2),20,'blue','filled');
            if asDev.fRateMean{ii}(ch) > asStd(stdEnd).fRateMean{ii}(ch)
                compStr = 'dev > last std';
            else
                compStr = 'dev < last std';
            end
            xlim([0 ISI]*1000);
            title(['Ch' num2str(ch) '  ' stimType{ii} ' ' compStr '  p = ' tPStr{ii}{ch}]);
            legend('last standard');

            %% dev raster
            mSubplot(Fig,figRow,numel(stimType),devPosRaster(ii));

            scatter(asDev.rasterBySound{ii}{ch}(:,1),asDev.rasterBySound{ii}{ch}(:,2),20,'red','filled');
            %         xlabel('time to onset (ms)');
            xlim([0 ISI]*1000);
            ylabel('trial number')
            legend('same sound as deviant');


            %% PSTH plot
            mSubplot(Fig,figRow,numel(stimType),PSTHPos(ii)); % dev
            psthData = [asDev.PSTHBySound{ii}{ch,1}.y]';
            psthT = [asDev.PSTHBySound{ii}{ch,1}.edges]';
            if ~isempty(psthT)
                asDev.psth = [psthData psthT(:,3)];
                plot(psthT(:,3),smoothdata(psthData,'gaussian',3),'Color','red','lineStyle','-','LineWidth',3); hold on;
            end

            psthData = [asStd(stdEnd).PSTHBySound{ii}{ch,1}.y]'; %last standard
            psthT = [asStd(stdEnd).PSTHBySound{ii}{ch,1}.edges]';
            if ~isempty(psthT)
                asStd(stdEnd).psth = [psthData psthT(:,3)];
                plot(psthT(:,3),smoothdata(psthData,'gaussian',3),'Color','blue','lineStyle','-','LineWidth',3); hold on;
            end

            psthData = [asStd(1).PSTHBySound{ii}{ch,1}.y]'; %first standard
            psthT = [asStd(1).PSTHBySound{ii}{ch,1}.edges]';
            if ~isempty(psthT)
                asStd(1).psth = [psthData psthT(:,3)];
                plot(psthT(:,3),smoothdata(psthData,'gaussian',3),'Color','#AAAAAA','lineStyle','-','LineWidth',3); hold on;
            end

            title(['Ch' num2str(ch)  ' ' stimType{ii} '  PSTH plot']);
            %         xlabel('time to onset (ms)');
            ylabel('firing rate (Hz)')
        end

        %% std to dev responses
        colors = {[0 0 0],[1 0.65 0];[0 0 0],[1 0.65 0]};
        lineStyles = {'-','-';'--','--'};
        stdDevAx = mSubplot(Fig,figRow,numel(stimType),stdDevPos);
        for ii = 1:numel(stimType)
            gca = stdDevAx;
            devMean = asDev.fRateMean{ii}(ch,1);
            devSE = asDev.fRateSE{ii}(ch,1);
            stdMeanCell = {asStd(stdOrder).fRateMean}';
            stdMean = cell2mat(cellfun(@(x) x{ii}(ch,1),stdMeanCell,'UniformOutput',false));
            stdSECell = {asStd(stdOrder).fRateSE}';
            stdSE = cell2mat(cellfun(@(x) x{ii}(ch,1),stdSECell,'UniformOutput',false));
            meanBuffer = [stdMean;devMean];
            seBuffer = [stdSE;devSE];
            xBuffer = [stdOrder stdOrder(end)+1]';
            errorbar(xBuffer,meanBuffer,seBuffer,'Color',colors{ii},'lineStyle',lineStyles{ii},'LineWidth',3,'DisplayName',stimStr{SSAPairs(ii)}); hold on
            xTickLabelStr = [cellfun(@(x) ['A' num2str(x)],num2cell(stdOrder),'UniformOutput',false) {['A' num2str(stdOrder(end)+1) '|dev']}];
            xlim([xBuffer(1)-1 xBuffer(end)+1]);
            set(stdDevAx,'xTick',xBuffer);
            set(stdDevAx,'xTickLabel',xTickLabelStr);
        end
        yScale = (stdDevAx.YLim(2) - stdDevAx.YLim(1)) * 1.2;
        stdDevAx.YLim = [stdDevAx.YLim(1) stdDevAx.YLim(1) + yScale];
        lgd = legend;
        lgd.NumColumns = numel(stimType);
        title('certain sound compare with itself as Std and Dev');
        %         plot(ones(2,1)*(xBuffer(end)-0.5),stdDevAx.YLim,'Color','k','LineStyle','--','LineWidth',2); hold on

        %% ceitarin block response

        blockAx = mSubplot(Fig,figRow,numel(stimType),blockPos);
        for ii = 1:numel(stimType)
            blockMeanCell = {asStd(soundOrder).fRateMean}';
            blockMean = cell2mat(cellfun(@(x) x{ii}(ch,1),blockMeanCell,'UniformOutput',false));
            blockSECell = {asStd(soundOrder).fRateSE}';
            blockSE = cell2mat(cellfun(@(x) x{ii}(ch,1),blockSECell,'UniformOutput',false));
            errorbar(soundOrder,blockMean,blockSE,'Color',colors{ii},'lineStyle',lineStyles{ii},'LineWidth',3,'DisplayName',stimStr{SSAPairs(ii)}); hold on
            xTickLabelStr = [cellfun(@(x) ['A' num2str(x)],num2cell(stdOrder),'UniformOutput',false) {['B' num2str(stdOrder(end)+1) '|dev']}];
            xlim([soundOrder(1)-1 soundOrder(end)+1]);
            set(blockAx,'xTick',soundOrder);
            set(blockAx,'xTickLabel',xTickLabelStr);
        end
        yScale = (stdDevAx.YLim(2) - stdDevAx.YLim(1)) * 1.2;
        blockAx.YLim = [blockAx.YLim(1) blockAx.YLim(1) + yScale];
        lgd = legend;
        lgd.NumColumns = numel(stimType);
        title('response of all sounds with a certain block');
        %         plot(ones(2,1)*(soundOrder(end)-0.5),blockAx.YLim,'Color','k','LineStyle','--','LineWidth',2); hold on

        saveas(Fig,[savePath  '\Ch' num2str(ch) '.jpg']);
        close(Fig);

    end
end

