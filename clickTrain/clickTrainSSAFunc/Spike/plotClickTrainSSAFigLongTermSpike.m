function plotClickTrainSSAFigLongTermSpike(batchOpt,varargin)
eval([GetStructStr(batchOpt) '=ReadStructValue(batchOpt);']);
eval([GetStructStr(rez) '=ReadStructValue(rez);']);
figRow = 5;
sigCh = chs';
TrainDur = batchOpt.stimPara(1).trainDur;

%% set subplot positions
nColumns = numel(stimType);
for typeN = 1:numel(stimType) % if numel(stimType) == n, then the number of columns will be 1.5 * n, n for each type block, 0.5 * n for counts of reg types
    rasterBlockPos{typeN} = [0 ] * nColumns + typeN ; % 3 rows and 1 column
    blockPSTHPos{typeN} = [1] * nColumns + typeN; % first, last std, deviant PSTH in a same pictur

    rasterBlockPosZoom{typeN} = [2 ] * nColumns + typeN ; % 3 rows and 1 column
    blockPSTHPosZoom{typeN} = [3] * nColumns + typeN; % first, last std, deviant PSTH in a same pictur
    LFPPos{typeN} = [4] * nColumns + typeN; % for lfp plot
end

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
                scatter(asStd(soundN).rasterBySound{ii}{ch}(:,1),rasterOrder + asStd(soundN).rasterBySound{ii}{ch}(:,2),3,rasterColors{soundN},'filled'); hold on
                ratserTick(soundN) = rasterOrder + 0.5 * max(asStd(soundN).rasterBySound{ii}{ch}(:,2));
                rasterOrder = rasterOrder + max(asStd(soundN).rasterBySound{ii}{ch}(:,2));
                if soundN > 1
                    plot([0 ISI]*1000 , ones(1,2) * rasterOrder + 0.5 ,'k-'); hold on;
                end
                
            end
            plot([S1Duration(ii) S1Duration(ii)], [0 rasterOrder],'r-'); hold on;
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
            xlim([0 TrainDur]);

            %% PSTH plot first std, last std, last sound in one block
            blockPSTHAx{ii,1} = mSubplot(Fig,figRow,nColumns,blockPSTHPos{ii} , margins , paddings);

            psthData = [asStd(stdEnd).PSTHBySound{ii}{ch,1}.y]'; %last standard
            psthT2 = [asStd(stdEnd).PSTHBySound{ii}{ch,1}.edges]';
            if ~isempty(psthT2)
                asStd(stdEnd).psth = [psthData psthT2(:,3)];
                lastStdPsthToPlot{ii} = smoothdata(psthData,'gaussian',5);
                plot(psthT2(:,3),lastStdPsthToPlot{ii},'Color','black','lineStyle','-','LineWidth',1.5); hold on;
            end


            yLims.blockPSTHAx{ii,1} = blockPSTHAx{ii,1}.YLim;

            title(['Ch' num2str(ch)  ' ' stimType{ii} '  PSTH plot']);
            %         xlabel('time to onset (ms)');
            ylabel('firing rate (Hz)')
            xlim([0 TrainDur]);
            plot([S1Duration(ii) S1Duration(ii)], blockPSTHAx{ii,1}.YLim,'r-'); hold on;

            %% raster of one block, zoomed
            rasterOrder = 0;
            rasterColors = {[0 0 0],[2/3 2/3 2/3],[2/3 2/3 2/3],[2/3 2/3 2/3],[2/3 2/3 2/3],[2/3 2/3 2/3],[2/3 2/3 2/3],[2/3 2/3 2/3],[0 0 1], [1 0 0]};
            rasterTickLabels = cellfun(@(x) ['sound ' num2str(x)], num2cell(fliplr(soundOrder)),'uni',false);
            mSubplot(Fig,figRow,nColumns,rasterBlockPosZoom{ii} , margins, paddings);
            for soundN = fliplr(soundOrder) % from end to first
                scatter(asStd(soundN).rasterBySound{ii}{ch}(:,1),rasterOrder + asStd(soundN).rasterBySound{ii}{ch}(:,2),3,rasterColors{soundN},'filled'); hold on
                ratserTick(soundN) = rasterOrder + 0.5 * max(asStd(soundN).rasterBySound{ii}{ch}(:,2));
                rasterOrder = rasterOrder + max(asStd(soundN).rasterBySound{ii}{ch}(:,2));
                if soundN > 1
                    plot([0 ISI]*1000 , ones(1,2) * rasterOrder + 0.5 ,'k-'); hold on;
                end
                
            end
            plot([S1Duration(ii) S1Duration(ii)], [0 rasterOrder],'r-'); hold on;
            if ii == 1 % the first block type, plotted in the first column
                set(gca,'yTick',sort(ratserTick));
                set(gca,'yTickLabel',rasterTickLabels);
            else
                set(gca,'yTickLabel',[]);
            end

            if soundN == 1
                title(['Ch' num2str(ch)  ' ' stimType{ii} ' zoomed-in raster plot']);
            end
            ylim([0 rasterOrder + 1]);
            xlim([-500 500] + S1Duration(ii));

            %% PSTH plot first std, last std, last sound in one block, zoomed
            blockPSTHAxZoom{ii,1} = mSubplot(Fig,figRow,nColumns,blockPSTHPosZoom{ii} , margins , paddings);

            psthData = [asStd(stdEnd).PSTHBySound{ii}{ch,1}.y]'; %last standard
            psthT2 = [asStd(stdEnd).PSTHBySound{ii}{ch,1}.edges]';
            if ~isempty(psthT2)
                asStd(stdEnd).psth = [psthData psthT2(:,3)];
                lastStdPsthToPlot{ii} = smoothdata(psthData,'gaussian',5);
                plot(psthT2(:,3),lastStdPsthToPlot{ii},'Color','black','lineStyle','-','LineWidth',1.5); hold on;
            end


            yLims.blockPSTHAx{ii,1} = blockPSTHAx{ii,1}.YLim;

            title(['Ch' num2str(ch)  ' ' stimType{ii} '  zoomed-in PSTH plot']);
            %         xlabel('time to onset (ms)');
            ylabel('firing rate (Hz)')
            xlim([-500 500] + S1Duration(ii));
            yZoomMax(ii) = max(lastStdPsthToPlot{ii}(psthT2(:,3)> S1Duration(ii)-500 & psthT2(:,3)< S1Duration(ii)+500));
%             
            plot([S1Duration(ii) S1Duration(ii)], blockPSTHAx{ii,1}.YLim,'r-'); hold on;
            

            %% lfp waveform
            LFPPosAx{ii,1} = mSubplot(Fig,figRow,nColumns,LFPPos{ii} , margins , paddings);
            lfpMeanBuffer{ii}{mod(ch,200)} = mean(asStd(stdEnd).lfpData{ii}{mod(ch,200)});
            lfpT = (0 : 1 : size(lfpMeanBuffer{ii}{mod(ch,200)},2) - 1) *1000 /stimPara(1).lfpFs; % ms
            
            for trialN = 1 : size(asStd(stdEnd).lfpData{ii}{mod(ch,200)},1)
                plot(lfpT,asStd(stdEnd).lfpData{ii}{mod(ch,200)}(trialN,:),'Color','#AAAAAA','LineStyle','-','LineWidth',1); hold on;
            end
            plot(lfpT,lfpMeanBuffer{ii}{mod(ch,200)},'Color','red','LineStyle','-','LineWidth',2); hold on;
            plot([S1Duration(ii) S1Duration(ii)], LFPPosAx{ii,1}.YLim,'r-'); hold on;
            yLims.LFPAx{ii,1} = LFPPosAx{ii,1}.YLim;
            xlim([0 TrainDur]);
            title(['Ch' num2str(ch)  ' ' stimType{ii} '  lfp raw waveform plot']);
            
        end

        %% reset scale
        psthAxYlim = [min(cellfun(@min,yLims.blockPSTHAx)  ) max(cellfun(@max,yLims.blockPSTHAx) )];
        lfpAxYlim = [min(cellfun(@min,yLims.LFPAx)  ) max(cellfun(@max,yLims.LFPAx) )];
        for ii = 1:numel(stimType)
            LFPPosAx{ii}.YLim = lfpAxYlim;
            blockPSTHAx{ii}.YLim = psthAxYlim;
            blockPSTHAxZoom{ii}.YLim = [0 max(yZoomMax)];
        end



        


%     catch
%     end
    %% save figures
    savePathNew = check_mkdir_SPR(savePath, 'newFigures');
    saveas(Fig,[savePathNew  '\newCh' num2str(ch) '.jpg']);
    close(Fig);

end
end




