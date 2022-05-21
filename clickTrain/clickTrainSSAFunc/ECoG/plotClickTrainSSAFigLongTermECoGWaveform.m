function plotClickTrainSSAFigLongTermECoGWaveform(batchOpt,varargin)
eval([GetStructStr(batchOpt) '=ReadStructValue(batchOpt);']);
eval([GetStructStr(rez) '=ReadStructValue(rez);']);
sigCh = chs';
TrainDur = batchOpt.stimPara(1).trainDur;
region = {'AC','PFC'};
regionCh = {[1:64],[65:128]};
%% set subplot positions
sigCh = 1:size(batchOpt.stimPara(1).lfpData);

%% set subplot positions
% define column and row numbers
switch length(sigCh)
    case 128
        nColumns = 8;
        nRows = 8;
        regionN = 2; % AC and PFC
    case 64
        nColumns = 8;
        nRows = 8;
        regionN = 1; % AC or PFC
    case 32
        nColumns = 8;
        nRows = 4;
        regionN = 1; % AC or MGB or IC, for linear array
    case 16
        nColumns = 4;
        nRows = 4;
        regionN = 1; % AC or MGB or IC, for linear array
end
siteInFigure = length(sigCh)/regionN;

% set subplot index of channels
for siteN = 1 : length(sigCh)
    if regionN == 1
        sitePos{siteN} = siteN;
    elseif regionN == 2
        if siteN > 64
            sitePos{siteN} = siteN - 64;
        else
            sitePos{siteN} = siteN;
        end
    end
end



margins = [0.05; 0.05; 0.06; 0.06 ];
paddings = [0.03; 0.03; 0.03; 0.03];
%% for block firing rate tuning curves
colors = {[2/3 2/3 2/3],[1 0.65 0];[2/3 2/3 2/3],[1 0.65 0]};
lineStyles = {'-','-';':',':'};

%% To Plot LFP Waveform , each stimType one figure
for ii = 1:numel(stimType)
    figN = 0;
    for ch = sigCh
        if mod(ch,siteInFigure) == 1 % generate figure for the first channel
            figN = figN + 1;
            Fig{ii,figN} = figure;
            maximizeFig(Fig{ii,figN});
            margins = [0;0;0;0 ];

            if figN == 1 % AC
                layout = imread('C:\Users\Yulab2\Pictures\Camera Roll\AC_sulcus.jpg');
            elseif figN == 2 % PFC
                layout = imread('C:\Users\Yulab2\Pictures\Camera Roll\PFC_sulcus.jpg');
            end
            mSubplot(Fig{ii,figN},1,1,1,margins , paddings);
            image(layout); hold on;
            set(gca,'XTickLabel',[]);
            set(gca,'YTickLabel',[]);
            set(gca,'Box','off');
            set(gca,'visible','off');
        end


        %% lfp waveform
        margins = [0.05; 0.05; 0.06; 0.06 ];
        siteNAx{ii,ch} = mSubplot(Fig{ii,figN},nRows,nColumns,sitePos{ch} , margins , paddings);
        lfpMeanBuffer{ii}{mod(ch,200)} = mean(asStd(stdEnd).lfpData{ii}{mod(ch,200)});
        lfpT = (0 : 1 : size(lfpMeanBuffer{ii}{mod(ch,200)},2) - 1) *1000 /stimPara(1).lfpFs; % ms
%         for trialN = 1 : size(asStd(stdEnd).lfpData{ii}{mod(ch,200)},1)
%             plot(lfpT,asStd(stdEnd).lfpData{ii}{mod(ch,200)}(trialN,:),'Color','#AAAAAA','LineStyle','-','LineWidth',1); hold on;
% 
%         end
        chSE = std((asStd(stdEnd).lfpData{ii}{mod(ch,200)}),[],1);
        y1 = lfpMeanBuffer{ii}{mod(ch,200)} + chSE;
        y2 = lfpMeanBuffer{ii}{mod(ch,200)} - chSE;
        fill([lfpT fliplr(lfpT)], [y1 fliplr(y2)], [0, 0, 0], 'edgealpha', '0', 'facealpha', '0.3', 'DisplayName', 'Error bar');
        hold on;
        plot(lfpT,lfpMeanBuffer{ii}{mod(ch,200)},'Color','red','LineStyle','-','LineWidth',2); hold on;

        plot([S1Duration(ii) S1Duration(ii)], siteNAx{ii,ch}.YLim,'k--'); hold on;

        yLims.LFPAx{ii,ch} = siteNAx{ii,ch}.YLim;
        xlim([0 TrainDur]);
        set(gca,'color','none');
        if ~(ceil(sitePos{ch}/nColumns) == nRows)
            set(gca,'XTickLabel',[]);
        end
        title([region{figN} ' Ch' num2str(sitePos{ch})  ' ' stimType{ii}]);

        drawnow
    end
end

%% reset scale
for n = 1 : 2
    lfpAxYlim{n} = [min(reshape(cellfun(@min,yLims.LFPAx(:,regionCh{n})),1,[])) max(reshape(cellfun(@max,yLims.LFPAx(:,regionCh{n})),1,[]))];
end

for ii = 1:numel(stimType)
    for ch =  sigCh
        if ismember(ch,regionCh{1})
%             siteNAx{ii,ch}.YLim = lfpAxYlim{1};
           siteNAx{ii,ch}.YLim = [-100 100];
        elseif ismember(ch,regionCh{2})
%             siteNAx{ii,ch}.YLim = lfpAxYlim{2};
            siteNAx{ii,ch}.YLim = [-100 100];
        end
        drawnow
    end

    %% save figures
    for figNum = 1 : figN
        savePathNew = check_mkdir_SPR(savePath, 'newFigures\Waveform');
        saveas(Fig{ii,figNum},[savePathNew   '\' region{figNum}  '_' stimType{ii}  '_Waveform.jpg']);
        close(Fig{ii,figNum});
    end
end






