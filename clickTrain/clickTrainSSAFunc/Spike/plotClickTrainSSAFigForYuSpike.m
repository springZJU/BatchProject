function plotClickTrainSSAFigForYuSpike(batchOpt,varargin)
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
nColumns = 1.5 * numel(stimType);
samePsthPool = [2 * nColumns + (numel(stimType) + 1 : nColumns)  , 4 * nColumns + (numel(stimType) + 1 : nColumns) ; 3 * nColumns + (numel(stimType) + 1 : nColumns)  , 5 * nColumns + (numel(stimType) + 1 : nColumns)];
for typeN = 1:numel(stimType) % if numel(stimType) == n, then the number of columns will be 1.5 * n, n for each type block, 0.5 * n for counts of reg types
    rasterBlockPos{typeN} = [0 1] * nColumns + typeN ; % 3 rows and 1 column
    blockPSTHPos{typeN} = [2 3] * nColumns + typeN; % first, last std, deviant PSTH in a same picture
    block0Pos{typeN} = 4 * nColumns + typeN; % 0-50 ms firing rate
    block1Pos{typeN} = 5 * nColumns + typeN; % 50-200 ms firing rate
    samePSTHPos{typeN} = samePsthPool(:,typeN);
end




blockPopPos0 = 0 * nColumns + (numel(stimType) + 1 : nColumns);
blockPopPos1 = 1 * nColumns + (numel(stimType) + 1 : nColumns);
margins = [0.08; 0.08; 0.15; 0.15 ];
paddings = [0.03; 0; 0.01; 0.01];
%% for block firing rate tuning curves
colors = {[2/3 2/3 2/3],[1 0.65 0];[2/3 2/3 2/3],[1 0.65 0]};
lineStyles = {'-','-';':',':'};

%% To Plot mismatch results for single channel
for ch = sigCh
    Fig = figure;
    maximizeFig(Fig);

%     try
        for ii = 1:numel(stimType)

            %% raster of one block
            rasterOrder = 0;
            rasterColors = {[0 0 0],[2/3 2/3 2/3],[2/3 2/3 2/3],[2/3 2/3 2/3],[2/3 2/3 2/3],[2/3 2/3 2/3],[2/3 2/3 2/3],[2/3 2/3 2/3],[0 0 1], [1 0 0]};
            rasterTickLabels = cellfun(@(x) ['sound ' num2str(x)], num2cell(fliplr(soundOrder)),'uni',false);
            mSubplot(Fig,figRow,nColumns,rasterBlockPos{ii} , margins, paddings);
            for soundN = fliplr(soundOrder) % from end to first
                scatter(asStd(soundN).rasterBySound{ii}{ch}(:,1),rasterOrder + asStd(soundN).rasterBySound{ii}{ch}(:,2),5,rasterColors{soundN},'filled'); hold on
                ratserTick(soundN) = rasterOrder + 0.5 * max(asStd(soundN).rasterBySound{ii}{ch}(:,2));
                rasterOrder = rasterOrder + max(asStd(soundN).rasterBySound{ii}{ch}(:,2));
                if soundN > 1
                    plot([0 ISI]*1000 , ones(1,2) * rasterOrder + 0.5 ,'k-'); hold on;
                end
            end
            if ii == 1 % the first block type, plotted in the first column
                set(gca,'yTick',sort(ratserTick));
                set(gca,'yTickLabel',rasterTickLabels);
            else
                set(gca,'yTickLabel',[]);
            end

            if soundN == 1
                title(['Ch' num2str(ch)  ' ' stimType{ii} '  raster plot']);
            end
            ylim([0 rasterOrder + 1]);
            xlim([0 ISI]*1000);

            %% PSTH plot first std, last std, last sound in one block
            blockPSTHAx{ii,1} = mSubplot(Fig,figRow,nColumns,blockPSTHPos{ii} , margins , paddings);

            psthData = [asStd(stdEnd).PSTHBySound{ii}{ch,1}.y]'; %last standard
            psthT2 = [asStd(stdEnd).PSTHBySound{ii}{ch,1}.edges]';
            if ~isempty(psthT2)
                asStd(stdEnd).psth = [psthData psthT2(:,3)];
                lastStdPsthToPlot{ii} = smoothdata(psthData,'gaussian',25);
                plot(psthT2(:,3),lastStdPsthToPlot{ii},'Color','blue','lineStyle','-','LineWidth',1.5); hold on;
            end

            psthData = [asStd(1).PSTHBySound{ii}{ch,1}.y]'; %first standard
            psthT3 = [asStd(1).PSTHBySound{ii}{ch,1}.edges]';
            if ~isempty(psthT3)
                asStd(1).psth = [psthData psthT3(:,3)];
                firstStdPsthToPlot{ii} = smoothdata(psthData,'gaussian',25);
                plot(psthT3(:,3),firstStdPsthToPlot{ii},'Color','black','lineStyle','-','LineWidth',1.5); hold on;
            end

            psthData = [asStd(end).PSTHBySound{ii}{ch,1}.y]'; %last sound
            psthT4 = [asStd(end).PSTHBySound{ii}{ch,1}.edges]';
            if ~isempty(psthT4)
                asStd(end).psth = [psthData psthT4(:,3)];
                lastSoundPsthToPlot{ii} = smoothdata(psthData,'gaussian',25);
                plot(psthT4(:,3),lastSoundPsthToPlot{ii},'Color','red','lineStyle','-','LineWidth',1.5); hold on;
            end

            yLims.blockPSTHAx{ii,1} = blockPSTHAx{ii,1}.YLim;

            title(['Ch' num2str(ch)  ' ' stimType{ii} '  PSTH plot']);
            %         xlabel('time to onset (ms)');
            ylabel('firing rate (Hz)')



            %% PSTH plot same sound as first std, last std and dev
            samePSTHAx{ii,1} = mSubplot(Fig,figRow,nColumns,samePSTHPos{ii} , margins , paddings);

            psthData = [asDev.PSTHBySound{ii}{ch,1}.y]'; % dev
            psthT1 = [asDev.PSTHBySound{ii}{ch,1}.edges]';
            if ~isempty(psthT1)
                asDev.psth = [psthData psthT1(:,3)];
                devPsthToPlot{ii} = smoothdata(psthData,'gaussian',25);
                plot(psthT1(:,3),devPsthToPlot{ii},'Color','#FFA500','lineStyle','-','LineWidth',1.5); hold on;
            end

            psthData = [asStd(stdEnd).PSTHBySound{ii}{ch,1}.y]'; %last standard
            psthT2 = [asStd(stdEnd).PSTHBySound{ii}{ch,1}.edges]';
            if ~isempty(psthT2)
                asStd(stdEnd).psth = [psthData psthT2(:,3)];
                lastStdPsthToPlot{ii} = smoothdata(psthData,'gaussian',25);
                plot(psthT2(:,3),lastStdPsthToPlot{ii},'Color','blue','lineStyle','-','LineWidth',1.5); hold on;
            end

            psthData = [asStd(1).PSTHBySound{ii}{ch,1}.y]'; %first standard
            psthT3 = [asStd(1).PSTHBySound{ii}{ch,1}.edges]';
            if ~isempty(psthT3)
                asStd(1).psth = [psthData psthT3(:,3)];
                firstStdPsthToPlot{ii} = smoothdata(psthData,'gaussian',25);
                plot(psthT3(:,3),firstStdPsthToPlot{ii},'Color','black','lineStyle','-','LineWidth',1.5); hold on;
            end
            yLims.samePSTHAx{ii,1} = samePSTHAx{ii,1}.YLim;
        
            [~ , p] = ttest2(asStd(1).fRate{ii}(ch,:),asDev.fRate{ii}(ch,:)); % for first std and deviant
            text(0.45 * sum(samePSTHAx{ii,1}.XLim) , 0.65 * samePSTHAx{ii,1}.YLim(2),[ 'p [std1-dev] =' num2str(roundn(p,-3))]); hold on
            [~ , p] = ttest2(asStd(stdEnd).fRate{ii}(ch,:),asDev.fRate{ii}(ch,:)); % for last std and deviant
            text(0.45 * sum(samePSTHAx{ii,1}.XLim) , 0.75 * samePSTHAx{ii,1}.YLim(2),[ 'p [0-200] = ' num2str(roundn(p,-3))]); hold on
            [~ , p] = ttest2(asStd(stdEnd).fRate0{ii}(ch,:),asDev.fRate0{ii}(ch,:)); % for last std and deviant
            text(0.45 * sum(samePSTHAx{ii,1}.XLim) , 0.85 * samePSTHAx{ii,1}.YLim(2),[ 'p [0-50] = ' num2str(roundn(p,-3))]); hold on
            [~ , p] = ttest2(asStd(stdEnd).fRate1{ii}(ch,:),asDev.fRate1{ii}(ch,:)); % for last std and deviant
            text(0.45 * sum(samePSTHAx{ii,1}.XLim) , 0.95 * samePSTHAx{ii,1}.YLim(2),[ 'p [50-200] = ' num2str(roundn(p,-3))]); hold on

            
            title(['Ch' num2str(ch)  ' ' stimType{ii} '  PSTH plot']);
            %         xlabel('time to onset (ms)');
            ylabel('firing rate (Hz)')



            %% one block response 0-50ms

            blockAx0{ii} = mSubplot(Fig,figRow,nColumns,block0Pos{ii} , margins , paddings);
            blockMeanCell = {asStd(soundOrder).fRateMean0}';
            blockMean = cell2mat(cellfun(@(x) x{ii}(ch,1),blockMeanCell,'UniformOutput',false));
            blockSECell = {asStd(soundOrder).fRateSE0}';
            blockSE = cell2mat(cellfun(@(x) x{ii}(ch,1),blockSECell,'UniformOutput',false));
            errorbar(soundOrder,blockMean,blockSE,'Color',colors{ii},'lineStyle',lineStyles{ii},'LineWidth',3,'DisplayName',stimStr{SSAPairs(ii)}); hold on
            xTickLabelStr = [cellfun(@(x) ['A' num2str(x)],num2cell(stdOrder),'UniformOutput',false) {['B' num2str(stdOrder(end)+1) '|dev']}];
            xlim([soundOrder(1)-1 soundOrder(end)+1]);
            set(blockAx0{ii},'xTick',soundOrder);
            set(blockAx0{ii},'xTickLabel',xTickLabelStr);
            yScale = (blockAx0{ii}.YLim(2) - blockAx0{ii}.YLim(1)) * 1.2;
            blockAx0{ii}.YLim = [blockAx0{ii}.YLim(1) blockAx0{ii}.YLim(1) + yScale];
            yLims.blockAx0{ii} = blockAx0{ii}.YLim;
            [~ , p] = ttest(asStd(stdEnd).fRate0{ii}(ch,:),asStd(end).fRate0{ii}(ch,:)); % paired ttest for last std and last sound
            text(9,0.5 * sum(blockAx0{ii}.YLim),[ 'p=' num2str(roundn(p,-3))]); hold on
            [~ , p] = ttest(asStd(1).fRate0{ii}(ch,:),asStd(stdEnd).fRate0{ii}(ch,:)); % paired ttest for first std and last std
            text(0.5,0.5 * sum(blockAx0{ii}.YLim),[ 'p=' num2str(roundn(p,-3))]); hold on

            title('response of all sounds with a certain block [0 50] ms');
            ylabel('firing rate (Hz)')

            %% one block response 50-200ms

            blockAx1{ii} = mSubplot(Fig,figRow,nColumns,block1Pos{ii} , margins , paddings);
            blockMeanCell = {asStd(soundOrder).fRateMean1}';
            blockMean = cell2mat(cellfun(@(x) x{ii}(ch,1),blockMeanCell,'UniformOutput',false));
            blockSECell = {asStd(soundOrder).fRateSE1}';
            blockSE = cell2mat(cellfun(@(x) x{ii}(ch,1),blockSECell,'UniformOutput',false));
            errorbar(soundOrder,blockMean,blockSE,'Color',colors{ii},'lineStyle',lineStyles{ii},'LineWidth',3,'DisplayName',stimStr{SSAPairs(ii)}); hold on
            xTickLabelStr = [cellfun(@(x) ['A' num2str(x)],num2cell(stdOrder),'UniformOutput',false) {['B' num2str(stdOrder(end)+1) '|dev']}];
            xlim([soundOrder(1)-1 soundOrder(end)+1]);
            set(blockAx1{ii},'xTick',soundOrder);
            set(blockAx1{ii},'xTickLabel',xTickLabelStr);
            yScale = (blockAx1{ii}.YLim(2) - blockAx1{ii}.YLim(1)) * 1.2;
            blockAx1{ii}.YLim = [blockAx1{ii}.YLim(1) blockAx1{ii}.YLim(1) + yScale];
            yLims.blockAx1{ii} = blockAx1{ii}.YLim;
            [~ , p] = ttest(asStd(stdEnd).fRate1{ii}(ch,:),asStd(end).fRate1{ii}(ch,:)); % paired ttest for last std and last sound
            text(9,0.5 * sum(blockAx1{ii}.YLim),[ 'p=' num2str(roundn(p,-3))]); hold on
            [~ , p] = ttest(asStd(1).fRate1{ii}(ch,:),asStd(stdEnd).fRate1{ii}(ch,:)); % paired ttest for first std and last std
            text(0.5,0.5 * sum(blockAx1{ii}.YLim),[ 'p=' num2str(roundn(p,-3))]); hold on

            %             lgd = legend;
            %             lgd.NumColumns = numel(stimType);
            %             legend('boxoff');
            title('response of all sounds with a certain block [50 200] ms');
            ylabel('firing rate (Hz)')


        end

        %% ceitarin block response 0-50ms

        blockPopAx1 = mSubplot(Fig,figRow,nColumns,blockPopPos0 , margins , paddings);
        for ii = 1:numel(stimType)
            blockMeanCell = {asStd(soundOrder).fRateMean0}';
            blockMean = cell2mat(cellfun(@(x) x{ii}(ch,1),blockMeanCell,'UniformOutput',false));
            blockSECell = {asStd(soundOrder).fRateSE0}';
            blockSE = cell2mat(cellfun(@(x) x{ii}(ch,1),blockSECell,'UniformOutput',false));
            errorbar(soundOrder,blockMean,blockSE,'Color',colors{ii},'lineStyle',lineStyles{ii},'LineWidth',3,'DisplayName',stimStr{SSAPairs(ii)}); hold on
            xTickLabelStr = [cellfun(@(x) ['A' num2str(x)],num2cell(stdOrder),'UniformOutput',false) {['B' num2str(stdOrder(end)+1) '|dev']}];
            xlim([soundOrder(1)-1 soundOrder(end)+1]);
            set(blockPopAx1,'xTick',soundOrder);
            set(blockPopAx1,'xTickLabel',xTickLabelStr);
        end
        yScale = (blockPopAx1.YLim(2) - blockPopAx1.YLim(1)) * 1.2;
        blockPopAx1.YLim = [blockPopAx1.YLim(1) blockPopAx1.YLim(1) + yScale];

        ylabel('firing rate (Hz)')
        title('response of all sounds with a certain block [0 50] ms');




        %% ceitarin block response 50-200ms

        blockPopAx2 = mSubplot(Fig,figRow,nColumns,blockPopPos1 , margins , paddings);
        for ii = 1:numel(stimType)
            blockMeanCell = {asStd(soundOrder).fRateMean1}';
            blockMean = cell2mat(cellfun(@(x) x{ii}(ch,1),blockMeanCell,'UniformOutput',false));
            blockSECell = {asStd(soundOrder).fRateSE1}';
            blockSE = cell2mat(cellfun(@(x) x{ii}(ch,1),blockSECell,'UniformOutput',false));
            errorbar(soundOrder,blockMean,blockSE,'Color',colors{ii},'lineStyle',lineStyles{ii},'LineWidth',3,'DisplayName',stimStr{SSAPairs(ii)}); hold on
            xTickLabelStr = [cellfun(@(x) ['A' num2str(x)],num2cell(stdOrder),'UniformOutput',false) {['B' num2str(stdOrder(end)+1) '|dev']}];
            xlim([soundOrder(1)-1 soundOrder(end)+1]);
            set(blockPopAx2,'xTick',soundOrder);
            set(blockPopAx2,'xTickLabel',xTickLabelStr);
        end
        yScale = (blockPopAx2.YLim(2) - blockPopAx2.YLim(1)) * 1.2;
        blockPopAx2.YLim = [blockPopAx2.YLim(1) blockPopAx2.YLim(1) + yScale];
        lgd = legend;
        lgd.NumColumns = numel(stimType);
        legend('boxoff');
        title('response of all sounds with a certain block [50 200] ms');
        ylabel('firing rate (Hz)')
        %% reset scale
        psthAxYlim = [min([cellfun(@min,yLims.blockPSTHAx) ; cellfun(@min,yLims.samePSTHAx)] ) max([cellfun(@max,yLims.blockPSTHAx) ; cellfun(@max,yLims.samePSTHAx)])];
        fRate0AxYlim = [min(cellfun(@min,yLims.blockAx0)) max(cellfun(@max,yLims.blockAx0))];
        fRate1AxYlim = [min(cellfun(@min,yLims.blockAx1) ) max(cellfun(@max,yLims.blockAx1))];
        for ii = 1:numel(stimType)
            samePSTHAx{ii}.YLim = psthAxYlim;
            blockPSTHAx{ii}.YLim = psthAxYlim;
            blockAx0{ii}.YLim = fRate0AxYlim;
            blockAx1{ii}.YLim = fRate1AxYlim;
        end




%     catch
%     end
    %% save figures
    savePathNew = check_mkdir_SPR(savePath, 'newFigures');
    saveas(Fig,[savePathNew  '\newCh' num2str(ch) '.jpg']);
    close(Fig);

end
end




