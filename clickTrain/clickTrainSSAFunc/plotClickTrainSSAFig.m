function plotClickTrainSSAFig(batchOpt,varargin)
eval([GetStructStr(batchOpt) '=ReadStructValue(batchOpt);']);
eval([GetStructStr(rez) '=ReadStructValue(rez);']);
figRow = 6;

%% comparison of firing rate in [0 50] and [50 200] window
for ii = 1:numel(stimType)
    t0P0Str{ii} = cellfun(@(x) num2str(x),num2cell(roundn(t0P0{ii},-4)),'UniformOutput',false); % [0 50] win
    t0PStr{ii} = cellfun(@(x) num2str(x),num2cell(roundn(t0P{ii},-4)),'UniformOutput',false); % [0 50] win
    tP0Str{ii} = cellfun(@(x) num2str(x),num2cell(roundn(tP0{ii},-4)),'UniformOutput',false); % [50 200] win
    tPStr{ii} = cellfun(@(x) num2str(x),num2cell(roundn(tP{ii},-4)),'UniformOutput',false); % [50 200] win
end


if 0
    Fig = figure;
    maximizeFig(Fig);
    % 0-50ms
    for ii = 1:numel(stimType)
        subplot(numel(stimType),2,ii*2-1)
        errorbar(1:length(asStd(stdEnd).fRateMean0{ii}),asStd(stdEnd).fRateMean0{ii},asStd(stdEnd).fRateSE0{ii},'Color','#AAAAAA','LineStyle','-','linewidth',1,'DisplayName','std'); hold on;
        errorbar(1:length(asStd(1).fRateMean0{ii}),asStd(1).fRateMean0{ii},asStd(1).fRateSE0{ii},'Color','blue','LineStyle','-','linewidth',1,'DisplayName','std'); hold on;
        errorbar(1:length(asDev.fRateMean0{ii}),asDev.fRateMean0{ii},asDev.fRateSE0{ii},'Color','red','LineStyle','-','linewidth',1,'DisplayName','dev'); hold on;
        text((1:length(asStd(stdEnd).fRateMean1{ii}))-0.5,asDev.fRateMean1{ii}+3,t0PStr{ii}); hold on
        xticks(1:length(asStd(stdEnd).fRateMean1{ii}));
        legend;
        %     xticklabels
        title(stimType{ii});
        %     xlabel('Channel Number');
        ylabel('Firing Rate (Hz)')
    end
    % 50-200ms
    for ii = 1:numel(stimType)
        subplot(numel(stimType),2,ii*2)
        errorbar(1:length(asStd(stdEnd).fRateMean1{ii}),asStd(stdEnd).fRateMean1{ii},asStd(stdEnd).fRateSE1{ii},'Color','#AAAAAA','LineStyle','-','linewidth',1,'DisplayName','std'); hold on;
        errorbar(1:length(asStd(1).fRateMean1{ii}),asStd(1).fRateMean1{ii},asStd(1).fRateSE1{ii},'Color','blue','LineStyle','-','linewidth',1,'DisplayName','std'); hold on;
        errorbar(1:length(asDev.fRateMean1{ii}),asDev.fRateMean1{ii},asDev.fRateSE1{ii},'Color','red','LineStyle','-','linewidth',1,'DisplayName','dev'); hold on;
        text((1:length(asStd(stdEnd).fRateMean1{ii}))-0.5,asDev.fRateMean1{ii}+3,tPStr{ii}); hold on
        xticks(1:length(asStd(stdEnd).fRateMean1{ii}));
        legend;
        %     xticklabels
        title(stimType{ii});
        %     xlabel('Channel Number');
        ylabel('Firing Rate (Hz)')
    end
    saveas(Fig,[savePath  '\FiringRate comparison.jpg']);
    close(Fig);
end
sigCh = chs';
%% set subplot positions
nColumns = 4 * numel(stimType);
for typeN = 1:numel(stimType) % if numel(stimType) == n, then the number of columns will be 2*n
    rasterBlockPos{typeN} = 0 * nColumns + (4 * typeN - 3 : 4 * typeN);
    firstStdRasterPos{typeN} = 1 * nColumns + (4 * typeN - 3 : 4 * typeN - 2);
    lastStdRasterPos{typeN} = 2 * nColumns + (4 * typeN - 3 : 4 * typeN - 2);
    devPosRaster{typeN} = 3 * nColumns + (4 * typeN - 3 : 4 * typeN - 2);
    PSTHPos{typeN} = 4 * nColumns + (4 * typeN - 3 : 4 * typeN - 2);
    onsetPos{typeN} = 1 * nColumns + (4 * typeN - 1 : 4 * typeN);
    laterAccPos{typeN} = 2 * nColumns + (4 * typeN - 1 : 4 * typeN);
    offsetPos{typeN} = 3 * nColumns + (4 * typeN - 1 : 4 * typeN);
    lastStdDevPsthPos{typeN} = 4 * nColumns + (4 * typeN - 1 : 4 * typeN);
end

stdDevPos0 = 5 * nColumns + (1 : nColumns / 4);
stdDevPos1= 5 * nColumns + (nColumns / 4 + 1 : nColumns / 2);
blockPos0 = 5 * nColumns + (nColumns / 2 + 1 : 3 * nColumns / 4);
blockPos1 = 5 * nColumns + (3 * nColumns / 4 + 1 : nColumns );
margins = [0.08; 0.08; 0.3; 0.3 ];
paddings = [0.03; 0.03; 0; 0.05];
%% To Plot mismatch results for single channel
for ch = sigCh
    Fig = figure;
    maximizeFig(Fig);
    
    

    try
    for ii = 1:numel(stimType)
        rasterYLim{ii} = [];
        %% first std raster
        mSubplot(Fig,figRow,nColumns,firstStdRasterPos{ii},margins, paddings);
        scatter(asStd(1).rasterBySound{ii}{ch}(:,1),asStd(1).rasterBySound{ii}{ch}(:,2),5,[2/3 2/3 2/3],'filled');
        if asDev.fRateMean1{ii}(ch) > asStd(1).fRateMean1{ii}(ch)
            compStr = 'dev > first std';
        else
            compStr = 'dev< first std';
        end

        xlim([0 ISI]*1000);
        ylim([0 max(max(cellfun(@length,asDev.Idx)))]);
        %         title(['Ch' num2str(ch) '  ' stimType{ii} ' ' compStr '  p[0 50] = ' t0P0Str{ii}{ch} '  |  p[50 200] = ' tP0Str{ii}{ch}]);
        title(['Ch' num2str(ch) ' p[0 50] = ' t0P0Str{ii}{ch} '  |  p[50 200] = ' tP0Str{ii}{ch}]);

        %         legend('first standard');

        %% last std raster
        mSubplot(Fig,figRow,nColumns,lastStdRasterPos{ii} , margins, paddings);
        scatter(asStd(stdEnd).rasterBySound{ii}{ch}(:,1),asStd(stdEnd).rasterBySound{ii}{ch}(:,2),5,'blue','filled');
        if asDev.fRateMean1{ii}(ch) > asStd(stdEnd).fRateMean1{ii}(ch)
            compStr = 'dev > last std';
        else
            compStr = 'dev < last std';
        end
        xlim([0 ISI]*1000);
        ylim([0 max(max(cellfun(@length,asDev.Idx)))]);
        %         title(['Ch' num2str(ch) '  ' stimType{ii} ' ' compStr '  p[0 50] = ' t0PStr{ii}{ch} '  |  p[50 200] = ' tPStr{ii}{ch}]);
        title(['Ch' num2str(ch) ' p[0 50] = ' t0PStr{ii}{ch} '  |  p[50 200] = ' tPStr{ii}{ch}]);
        %         legend('last standard');

        %% dev raster
        mSubplot(Fig,figRow,nColumns,devPosRaster{ii} , margins, paddings);

        scatter(asDev.rasterBySound{ii}{ch}(:,1),asDev.rasterBySound{ii}{ch}(:,2),5,'red','filled');
        %         xlabel('time to onset (ms)');
        xlim([0 ISI]*1000);
        ylim([0 max(max(cellfun(@length,asDev.Idx)))]);
        ylabel('trial number')
        %         legend('same sound as deviant');



        %% raster for a single block
        mSubplot(Fig,figRow,nColumns,rasterBlockPos{ii} , margins, paddings);
        spikeSortOrder = {stimPara.SpikesortOrder}';
        firstSoundIdx{ii} = num2cell([asStd(1).Idx{ii} asStd(end).Idx{ii}],2); % stimType{ii} Idx
        bufferBlock = [cellfun(@(x) spikeSortOrder(x(1):x(2)),firstSoundIdx{ii},'UniformOutput',false) firstSoundIdx{ii} num2cell((1:length(firstSoundIdx{ii}))')];
        for trialN = 1:length(bufferBlock)
            rasterByBlock{ii}{trialN,ch} = cell2mat(cellfun(@(x) [1000*(x{ch} - stimPara(bufferBlock{trialN,2}(1)).trialOnset) ones(length(x{ch}),1)*bufferBlock{trialN,3}], bufferBlock{trialN,1},'UniformOutput',false));
        end
        rasterByBlockPlot{ii}{ch,1} = cell2mat(rasterByBlock{ii}(:,ch));
        scatter(rasterByBlockPlot{ii}{ch,1}(:,1),rasterByBlockPlot{ii}{ch,1}(:,2),2,'black','filled'); hold on;

        %% mark sound time
        soundTimeToOnset = (soundOrder-1)*ISI*1000; % ms
        for soundN = 1 : length(soundTimeToOnset)
            plot(ones(1,2) * soundTimeToOnset(soundN), [0 max(rasterByBlockPlot{ii}{ch,1}(:,2))], 'Color','red','LineStyle','-','LineWidth',1); hold on
        end
        ylim([0 max(max(cellfun(@length,asDev.Idx)))]);
        title(['Ch' num2str(ch)  ' ' stimType{ii} '  raster by block']);



        %% PSTH plot first std, last std, deviant
        psthAx{ii,1} = mSubplot(Fig,figRow,nColumns,PSTHPos{ii} , margins, paddings);
        psthData = [asDev.PSTHBySound{ii}{ch,1}.y]'; % dev
        psthT1 = [asDev.PSTHBySound{ii}{ch,1}.edges]';
        if ~isempty(psthT1)
            asDev.psth = [psthData psthT1(:,3)];
            devPsthToPlot{ii} = smoothdata(psthData,'gaussian',3);
            plot(psthT1(:,3),devPsthToPlot{ii},'Color','red','lineStyle','-','LineWidth',1.5); hold on;
        end

        psthData = [asStd(stdEnd).PSTHBySound{ii}{ch,1}.y]'; %last standard
        psthT2 = [asStd(stdEnd).PSTHBySound{ii}{ch,1}.edges]';
        if ~isempty(psthT2)
            asStd(stdEnd).psth = [psthData psthT2(:,3)];
            lastStdPsthToPlot{ii} = smoothdata(psthData,'gaussian',3);
            plot(psthT2(:,3),lastStdPsthToPlot{ii},'Color','blue','lineStyle','-','LineWidth',1.5); hold on;
        end

        psthData = [asStd(1).PSTHBySound{ii}{ch,1}.y]'; %first standard
        psthT3 = [asStd(1).PSTHBySound{ii}{ch,1}.edges]';
        if ~isempty(psthT3)
            asStd(1).psth = [psthData psthT3(:,3)];
            firstStdPsthToPlot{ii} = smoothdata(psthData,'gaussian',3);
            plot(psthT3(:,3),firstStdPsthToPlot{ii},'Color','#AAAAAA','lineStyle','-','LineWidth',1.5); hold on;
        end

        psthData = [asStd(end).PSTHBySound{ii}{ch,1}.y]'; %last sound
        psthT4 = [asStd(end).PSTHBySound{ii}{ch,1}.edges]';
        if ~isempty(psthT4)
            asStd(end).psth = [psthData psthT4(:,3)];
            lastSoundPsthToPlot{ii} = smoothdata(psthData,'gaussian',3);
            plot(psthT4(:,3),lastSoundPsthToPlot{ii},'Color','#FFA500','lineStyle','-','LineWidth',1.5); hold on;
        end

        yLims.psthAx{ii,1} = psthAx{ii,1}.YLim;

        title(['Ch' num2str(ch)  ' ' stimType{ii} '  PSTH plot']);
        %         xlabel('time to onset (ms)');
        ylabel('firing rate (Hz)')


        %% PSTH 0-50ms response
        onsetAxis = mSubplot(Fig,figRow,nColumns,onsetPos{ii} , margins, paddings);
        [tBuffer , win0Idx] = findWithinInterval(psthT4(:,3),frateWin0*1000);
        psthWin0 = tBuffer;
        firstStdPsth = interp1(tBuffer,firstStdPsthToPlot{ii}(win0Idx),psthWin0);
        plot(psthWin0,firstStdPsth,'Color','#AAAAAA','lineStyle','-','LineWidth',2); hold on;
        lastStdPsth = interp1(tBuffer,lastStdPsthToPlot{ii}(win0Idx),psthWin0);
        plot(psthWin0,lastStdPsth,'Color','blue','lineStyle','-','LineWidth',2); hold on;
        devPsth = interp1(tBuffer,devPsthToPlot{ii}(win0Idx),psthWin0);
        plot(psthWin0,devPsth,'Color','red','lineStyle','-','LineWidth',2); hold on;
        lastSoundPsth = interp1(tBuffer,lastSoundPsthToPlot{ii}(win0Idx),psthWin0);
        plot(psthWin0,lastSoundPsth,'Color','#FFA500','lineStyle','-','LineWidth',2); hold on;

        firstStdPeak = psthWin0(firstStdPsth == max(firstStdPsth));
        plot(ones(1,2) * firstStdPeak(1), onsetAxis.YLim,'Color','#AAAAAA','lineStyle','--','LineWidth',1); hold on;
        lastStdPeak = psthWin0(lastStdPsth == max(lastStdPsth));
        plot(ones(1,2) * lastStdPeak(1), onsetAxis.YLim,'Color','blue','lineStyle','--','LineWidth',1); hold on;
        devPeak = psthWin0(devPsth == max(devPsth));
        plot(ones(1,2) * devPeak(1), onsetAxis.YLim,'Color','red','lineStyle','--','LineWidth',1); hold on;
        lastSoundPeak = psthWin0(lastSoundPsth == max(lastSoundPsth));
        plot(ones(1,2) * lastSoundPeak(1), onsetAxis.YLim,'Color','#FFA500','lineStyle','--','LineWidth',1); hold on;
        title('0-50 ms PSTH');

        

%% PSTH 50-200ms accumulation
        laterAccAxis = mSubplot(Fig,figRow,nColumns,laterAccPos{ii} , margins, paddings);
        [tBuffer , win0Idx] = findWithinInterval(psthT4(:,3),frateWin1*1000);
        psthWin0 = tBuffer;
        % 50-200ms psth
        firstStdPsth = interp1(tBuffer,firstStdPsthToPlot{ii}(win0Idx),psthWin0);
        lastStdPsth = interp1(tBuffer,lastStdPsthToPlot{ii}(win0Idx),psthWin0);
        devPsth = interp1(tBuffer,devPsthToPlot{ii}(win0Idx),psthWin0);
        lastSoundPsth = interp1(tBuffer,lastSoundPsthToPlot{ii}(win0Idx),psthWin0);
        % 
        firstStdRatio = cumtrapz(firstStdPsth)./trapz(firstStdPsth);
        plot(psthWin0,asStd(1).fRateMean1{ii}(ch) * firstStdRatio,'Color','#AAAAAA','lineStyle','-','LineWidth',2); hold on;
        lastStdRatio = cumtrapz(lastStdPsth)./trapz(lastStdPsth);
        plot(psthWin0,asStd(stdEnd).fRateMean1{ii}(ch) * lastStdRatio,'Color','blue','lineStyle','-','LineWidth',2); hold on;
        devRatio = cumtrapz(devPsth)./trapz(devPsth);
        plot(psthWin0,asDev.fRateMean1{ii}(ch) * devRatio,'Color','red','lineStyle','-','LineWidth',2); hold on;
        lastSoundRatio = cumtrapz(lastSoundPsth)./trapz(lastSoundPsth);
        plot(psthWin0,asStd(end).fRateMean1{ii}(ch) * lastSoundRatio,'Color','#FFA500','lineStyle','-','LineWidth',2); hold on;

        % half time 
        [~,minIdx] = min(abs(firstStdRatio - 0.5));
        firstStdHalfT = psthWin0(minIdx);
        plot(ones(1,2) * firstStdHalfT(1), laterAccAxis.YLim,'Color','#AAAAAA','lineStyle','--','LineWidth',1); hold on;
        [~,minIdx] = min(abs(lastStdRatio - 0.5));
        lastStdHalfT = psthWin0(minIdx);
        plot(ones(1,2) * lastStdHalfT(1), laterAccAxis.YLim,'Color','blue','lineStyle','--','LineWidth',1); hold on;
        [~,minIdx] = min(abs(devRatio - 0.5));
        devHalfT = psthWin0(minIdx);
        plot(ones(1,2) * devHalfT(1), laterAccAxis.YLim,'Color','red','lineStyle','--','LineWidth',1); hold on;
        [~,minIdx] = min(abs(lastSoundRatio - 0.5));
        lastSoundHalfT = psthWin0(minIdx);
        plot(ones(1,2) * lastSoundHalfT(1), laterAccAxis.YLim,'Color','#FFA500','lineStyle','--','LineWidth',1); hold on;

        
         title('50-200 ms accumulative curve');
        


%% PSTH 200-250 ms offset response
        offsetAxis = mSubplot(Fig,figRow,nColumns,offsetPos{ii} , margins, paddings);
        frateWin2 = frateWin0 + stimPara(1).trainDur/1000;
        [tBuffer , win0Idx] = findWithinInterval(psthT4(:,3),frateWin2*1000);
        psthWin0 = tBuffer;
        firstStdPsth = interp1(tBuffer,firstStdPsthToPlot{ii}(win0Idx),psthWin0);
        plot(psthWin0,firstStdPsth,'Color','#AAAAAA','lineStyle','-','LineWidth',2); hold on;
        lastStdPsth = interp1(tBuffer,lastStdPsthToPlot{ii}(win0Idx),psthWin0);
        plot(psthWin0,lastStdPsth,'Color','blue','lineStyle','-','LineWidth',2); hold on;
        devPsth = interp1(tBuffer,devPsthToPlot{ii}(win0Idx),psthWin0);
        plot(psthWin0,devPsth,'Color','red','lineStyle','-','LineWidth',2); hold on;
        lastSoundPsth = interp1(tBuffer,lastSoundPsthToPlot{ii}(win0Idx),psthWin0);
        plot(psthWin0,lastSoundPsth,'Color','#FFA500','lineStyle','-','LineWidth',2); hold on;

        firstStdPeak = psthWin0(firstStdPsth == max(firstStdPsth));
        plot(ones(1,2) * firstStdPeak(1), onsetAxis.YLim,'Color','#AAAAAA','lineStyle','--','LineWidth',1); hold on;
        lastStdPeak = psthWin0(lastStdPsth == max(lastStdPsth));
        plot(ones(1,2) * lastStdPeak(1), onsetAxis.YLim,'Color','blue','lineStyle','--','LineWidth',1); hold on;
        devPeak = psthWin0(devPsth == max(devPsth));
        plot(ones(1,2) * devPeak(1), onsetAxis.YLim,'Color','red','lineStyle','--','LineWidth',1); hold on;
        lastSoundPeak = psthWin0(lastSoundPsth == max(lastSoundPsth));
        plot(ones(1,2) * lastSoundPeak(1), onsetAxis.YLim,'Color','#FFA500','lineStyle','--','LineWidth',1); hold on;
        xlim(frateWin2*1000)
        title('200-250 ms PSTH');


        %% PSTH difference between last std and dev
        lastStdDevPsthDiff{ii}.raw = lastSoundPsthToPlot{ii} - lastStdPsthToPlot{ii};
        lastStdDevPsthDiff{ii}.abs = abs(lastStdDevPsthDiff{ii}.raw);
        psthDiffAx{ii,1} = mSubplot(Fig,figRow,nColumns,lastStdDevPsthPos{ii} , margins, paddings);
        if ~isempty(psthT1) && ~isempty(psthT2)
            plot(psthT2(:,3),lastStdDevPsthDiff{ii}.raw,'Color','black','lineStyle','-','LineWidth',2); hold on;
            plot(psthT2(:,3),lastStdDevPsthDiff{ii}.abs,'Color','red','lineStyle','-','LineWidth',2); hold on;
            plot(psthT2(:,3),ones(length(psthT2(:,3)),1),'Color','#AAAAAA','LineStyle','--','LineWidth',1); hold on
        end
        yLims.psthDiffAx{ii} = psthDiffAx{ii,1}.YLim;
        % paired ttest
        % 50 ms
        [~ , pairP0(ii)] = ttest(asStd(stdEnd).fRate0{ii}(ch,:),asStd(end).fRate0{ii}(ch,:));
        % 50-200 ms
        [~ , pairP1(ii)] = ttest(asStd(stdEnd).fRate1{ii}(ch,:),asStd(end).fRate1{ii}(ch,:));
        title(['p[0 50] = ' num2str(roundn(pairP0(ii),-4)) ', p[50 200] = ' num2str(roundn(pairP1(ii),-4))]);

        
       




        %         %% PSTH plot for all std
        %         stdColors = generateColorGrad(stdEnd,'rgb','blue',1:)
        %         for stdN = 1:stdEnd
        %         psthData = [asStd(stdEnd).PSTHBySound{ii}{ch,1}.y]'; %last standard
        %             psthT = [asStd(stdEnd).PSTHBySound{ii}{ch,1}.edges]';
        %             if ~isempty(psthT)
        %                 asStd(stdEnd).psth = [psthData psthT(:,3)];
        %                 plot(psthT(:,3),smoothdata(psthData,'gaussian',3),'Color','blue','lineStyle','-','LineWidth',3); hold on;
        %             end
        %         end



    end

    %% std to dev responses 0-50ms
    colors = {[0 0 0],[1 0.65 0];[0 0 0],[1 0.65 0]};
    lineStyles = {'-','-';'--','--'};
    stdDevAx1 = mSubplot(Fig,figRow,nColumns,stdDevPos0 , margins, paddings);
    for ii = 1:numel(stimType)

        devMean = asDev.fRateMean0{ii}(ch,1);
        devSE = asDev.fRateSE0{ii}(ch,1);
        stdMeanCell = {asStd(stdOrder).fRateMean0}';
        stdMean = cell2mat(cellfun(@(x) x{ii}(ch,1),stdMeanCell,'UniformOutput',false));
        stdSECell = {asStd(stdOrder).fRateSE1}';
        stdSE = cell2mat(cellfun(@(x) x{ii}(ch,1),stdSECell,'UniformOutput',false));
        meanBuffer = [stdMean;devMean];
        seBuffer = [stdSE;devSE];
        xBuffer = [stdOrder stdOrder(end)+1]';
        errorbar(xBuffer,meanBuffer,seBuffer,'Color',colors{ii},'lineStyle',lineStyles{ii},'LineWidth',3,'DisplayName',stimStr{SSAPairs(ii)}); hold on
        xTickLabelStr = [cellfun(@(x) ['A' num2str(x)],num2cell(stdOrder),'UniformOutput',false) {['A' num2str(stdOrder(end)+1) '|dev']}];
        xlim([xBuffer(1)-1 xBuffer(end)+1]);
        set(stdDevAx1,'xTick',xBuffer);
        set(stdDevAx1,'xTickLabel',xTickLabelStr);
    end
    yScale = (stdDevAx1.YLim(2) - stdDevAx1.YLim(1)) * 1.2;
    stdDevAx1.YLim = [stdDevAx1.YLim(1) stdDevAx1.YLim(1) + yScale];
    %     lgd = legend;
    %     lgd.NumColumns = numel(stimType);
    title('certain sound compare with itself as Std and Dev [0 50] ms');
    %         plot(ones(2,1)*(xBuffer(end)-0.5),stdDevAx.YLim,'Color','k','LineStyle','--','LineWidth',2); hold on

    %% ceitarin block response 0-50ms

    blockAx1 = mSubplot(Fig,figRow,nColumns,blockPos0 , margins, paddings);
    for ii = 1:numel(stimType)
        blockMeanCell = {asStd(soundOrder).fRateMean0}';
        blockMean = cell2mat(cellfun(@(x) x{ii}(ch,1),blockMeanCell,'UniformOutput',false));
        blockSECell = {asStd(soundOrder).fRateSE0}';
        blockSE = cell2mat(cellfun(@(x) x{ii}(ch,1),blockSECell,'UniformOutput',false));
        errorbar(soundOrder,blockMean,blockSE,'Color',colors{ii},'lineStyle',lineStyles{ii},'LineWidth',3,'DisplayName',stimStr{SSAPairs(ii)}); hold on
        xTickLabelStr = [cellfun(@(x) ['A' num2str(x)],num2cell(stdOrder),'UniformOutput',false) {['B' num2str(stdOrder(end)+1) '|dev']}];
        xlim([soundOrder(1)-1 soundOrder(end)+1]);
        set(blockAx1,'xTick',soundOrder);
        set(blockAx1,'xTickLabel',xTickLabelStr);
    end
    yScale = (blockAx1.YLim(2) - blockAx1.YLim(1)) * 1.2;
    blockAx1.YLim = [blockAx1.YLim(1) blockAx1.YLim(1) + yScale];
    %     lgd = legend;
    %     lgd.NumColumns = numel(stimType);
    title('response of all sounds with a certain block [0 50] ms');
    %         plot(ones(2,1)*(soundOrder(end)-0.5),blockAx.YLim,'Color','k','LineStyle','--','LineWidth',2); hold on

    %         saveas(Fig,[savePath  '\Ch' num2str(ch) '.jpg']);
    %         close(Fig);

    %% std to dev responses 50-200ms
    colors = {[0 0 0],[1 0.65 0];[0 0 0],[1 0.65 0]};
    lineStyles = {'-','-';'--','--'};
    stdDevAx2 = mSubplot(Fig,figRow,nColumns,stdDevPos1 , margins, paddings);
    for ii = 1:numel(stimType)

        devMean = asDev.fRateMean1{ii}(ch,1);
        devSE = asDev.fRateSE1{ii}(ch,1);
        stdMeanCell = {asStd(stdOrder).fRateMean1}';
        stdMean = cell2mat(cellfun(@(x) x{ii}(ch,1),stdMeanCell,'UniformOutput',false));
        stdSECell = {asStd(stdOrder).fRateSE1}';
        stdSE = cell2mat(cellfun(@(x) x{ii}(ch,1),stdSECell,'UniformOutput',false));
        meanBuffer = [stdMean;devMean];
        seBuffer = [stdSE;devSE];
        xBuffer = [stdOrder stdOrder(end)+1]';
        errorbar(xBuffer,meanBuffer,seBuffer,'Color',colors{ii},'lineStyle',lineStyles{ii},'LineWidth',3,'DisplayName',stimStr{SSAPairs(ii)}); hold on
        xTickLabelStr = [cellfun(@(x) ['A' num2str(x)],num2cell(stdOrder),'UniformOutput',false) {['A' num2str(stdOrder(end)+1) '|dev']}];
        xlim([xBuffer(1)-1 xBuffer(end)+1]);
        set(stdDevAx2,'xTick',xBuffer);
        set(stdDevAx2,'xTickLabel',xTickLabelStr);
    end
    yScale = (stdDevAx2.YLim(2) - stdDevAx2.YLim(1)) * 1.2;
    stdDevAx2.YLim = [stdDevAx2.YLim(1) stdDevAx2.YLim(1) + yScale];
    %     lgd = legend;
    %     lgd.NumColumns = numel(stimType);
    title('certain sound compare with itself as Std and Dev [50 200] ms');
    %         plot(ones(2,1)*(xBuffer(end)-0.5),stdDevAx.YLim,'Color','k','LineStyle','--','LineWidth',2); hold on



    %% ceitarin block response 50-200ms

    blockAx2 = mSubplot(Fig,figRow,nColumns,blockPos1 , margins, paddings);
    for ii = 1:numel(stimType)
        blockMeanCell = {asStd(soundOrder).fRateMean1}';
        blockMean = cell2mat(cellfun(@(x) x{ii}(ch,1),blockMeanCell,'UniformOutput',false));
        blockSECell = {asStd(soundOrder).fRateSE1}';
        blockSE = cell2mat(cellfun(@(x) x{ii}(ch,1),blockSECell,'UniformOutput',false));
        errorbar(soundOrder,blockMean,blockSE,'Color',colors{ii},'lineStyle',lineStyles{ii},'LineWidth',3,'DisplayName',stimStr{SSAPairs(ii)}); hold on
        xTickLabelStr = [cellfun(@(x) ['A' num2str(x)],num2cell(stdOrder),'UniformOutput',false) {['B' num2str(stdOrder(end)+1) '|dev']}];
        xlim([soundOrder(1)-1 soundOrder(end)+1]);
        set(blockAx2,'xTick',soundOrder);
        set(blockAx2,'xTickLabel',xTickLabelStr);
    end
    yScale = (blockAx2.YLim(2) - blockAx2.YLim(1)) * 1.2;
    blockAx2.YLim = [blockAx2.YLim(1) blockAx2.YLim(1) + yScale];
    lgd = legend;
    lgd.NumColumns = numel(stimType);
    title('response of all sounds with a certain block [50 200] ms');
    %         plot(ones(2,1)*(soundOrder(end)-0.5),blockAx.YLim,'Color','k','LineStyle','--','LineWidth',2); hold on

    %% reset scale
    psthAxYlim = [min(cellfun(@min,yLims.psthAx)) max(cellfun(@max,yLims.psthAx))];
    psthDiffAxYlim = [min(cellfun(@min,yLims.psthDiffAx)) max(cellfun(@max,yLims.psthDiffAx))];
    for ii = 1:numel(stimType)
        psthDiffAx{ii}.YLim = psthDiffAxYlim;
        psthAx{ii}.YLim = psthAxYlim;
    end

    stdDevAx1.YLim = [min([stdDevAx1.YLim blockAx1.YLim]) max([stdDevAx1.YLim blockAx1.YLim])];
    stdDevAx2.YLim = [min([stdDevAx2.YLim blockAx2.YLim]) max([stdDevAx2.YLim blockAx2.YLim])];
    blockAx1.YLim = [min([stdDevAx1.YLim blockAx1.YLim]) max([stdDevAx1.YLim blockAx1.YLim])];
    blockAx2.YLim = [min([stdDevAx2.YLim blockAx2.YLim]) max([stdDevAx2.YLim blockAx2.YLim])];


    %% replot PSTH diff figure , short reg v.s. irreg
    % 4ms regular
    plot(psthDiffAx{1,1},psthT2(:,3),lastStdDevPsthDiff{2}.raw,'Color','#AAAAAA','lineStyle',':','LineWidth',2); hold on;
    plot(psthDiffAx{1,1},psthT2(:,3),lastStdDevPsthDiff{2}.abs,'Color','#FFA500','lineStyle',':','LineWidth',2); hold on;
    % 4ms irregular
    plot(psthDiffAx{2,1},psthT2(:,3),lastStdDevPsthDiff{1}.raw,'Color','#AAAAAA','lineStyle',':','LineWidth',2); hold on;
    plot(psthDiffAx{2,1},psthT2(:,3),lastStdDevPsthDiff{1}.abs,'Color','#FFA500','lineStyle',':','LineWidth',2); hold on;

    % 7ms regular
    plot(psthDiffAx{3,1},psthT2(:,3),lastStdDevPsthDiff{4}.raw,'Color','#AAAAAA','lineStyle',':','LineWidth',2); hold on;
    plot(psthDiffAx{3,1},psthT2(:,3),lastStdDevPsthDiff{4}.abs,'Color','#FFA500','lineStyle',':','LineWidth',2); hold on;
    % 7ms irregular
    plot(psthDiffAx{4,1},psthT2(:,3),lastStdDevPsthDiff{3}.raw,'Color','#AAAAAA','lineStyle',':','LineWidth',2); hold on;
    plot(psthDiffAx{4,1},psthT2(:,3),lastStdDevPsthDiff{3}.abs,'Color','#FFA500','lineStyle',':','LineWidth',2); hold on;

    catch
    end
    %% save figures
    savePathNew = check_mkdir_SPR(savePath, 'Figures');
    saveas(Fig,[savePathNew  '\Ch' num2str(ch) '.jpg']);
    close(Fig);

end
end
