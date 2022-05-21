function plotClickTrainSSAFigLongTermECoGTimeFrequency(batchOpt,varargin)
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

%% To Plot LFP Time-Frequency result, each stimType one figure

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

        end


        %% lfp waveform
        margins = [0.05; 0.05; 0.06; 0.06 ];
        siteNAx{ii,ch} = mSubplot(Fig{ii,figN},nRows,nColumns,sitePos{ch} , margins , paddings);
        lfpMeanSpect{ii}{mod(ch,200)} = clickTrainSpectroAnalyze(asStd(stdEnd).lfpData{ii}{mod(ch,200)},stimPara(1).lfpFs,'morlet',300);
        
        % plot time-frequency grams
        Spect = lfpMeanSpect{ii}{mod(ch,200)};
        imagesc('XData',Spect.Timescale*1000,'YData',Spect.FsScale,'CData',Spect.CDataMean);hold on;
        alpha(.8);
        plot(Spect.Timescale*1000,Spect.Coi,'w--','LineWidth',1); hold on;
        alpha(.8);
        plot([S1Duration(ii) S1Duration(ii)], siteNAx{ii,ch}.YLim,'k--'); hold on;
        alpha(.8);
        colormap('jet');
        set(gca,'color','none');
        
        cLims.LFPAx{ii,ch} = siteNAx{ii,ch}.CLim;
        xlim([0 TrainDur]);
        set(gca,'yscale','log');
        title([region{figN} ' Ch' num2str(sitePos{ch})  ' ' stimType{ii}]);
        if ~(ceil(sitePos{ch}/nColumns) == nRows)
            set(gca,'XTickLabel',[]);
        end
        drawnow;
        if mod(ch,siteInFigure) == 0
            colorbar('position',[1 - paddings(2),   0.1 , 0.5 * paddings(2), 0.8]);
        end
    end

end

%% reset scale
for n = 1 : 2
    lfpAxClim{n} = [min(reshape(cellfun(@min,cLims.LFPAx(:,regionCh{n})),1,[])) max(reshape(cellfun(@max,cLims.LFPAx(:,regionCh{n})),1,[]))];
end

for ii = 1:numel(stimType)
    for ch =  sigCh
        if ismember(ch,regionCh{1})
            set(siteNAx{ii,ch},'CLim',lfpAxClim{1});
        elseif ismember(ch,regionCh{2})
            set(siteNAx{ii,ch},'CLim',lfpAxClim{2});
        end
        
        drawnow
    end

    %% save figures
    for figNum = 1 : figN
        savePathNew = check_mkdir_SPR(savePath, 'newFigures\TimeFrequency');
        saveas(Fig{ii,figNum},[savePathNew  '\' region{figNum}  '_' stimType{ii}  '_TimeFrequency.jpg']);
        close(Fig{ii,figNum});
    end
end




