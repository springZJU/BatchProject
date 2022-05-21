function  varargout = clickTrianSpikeInICI(trialBuffer,varargin)
% 'rater' save raster time  and trialNum
% 'frate' save mean & SE of frate and individual frate for each trial
% 'psth' save psth and bin params
% 'RS' save mean & SE of RS and p-value with 13.8 and individual RS for each trial
% 'percentAdapt' save percentAdapt  and click-frate array
% 'RRTF' save TTRF and rawdata

% 'RS', 'percentAdapt' and 'RRTF' only for clickTrain sounds
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
eval([GetStructStr(params) '=ReadStructValue(params);']);

%% if sorted, use sorted data
if isfield(trialBuffer,'Spikesort')
    spikeField = 'Spikesort';
else
    spikeField = 'Spikeraw';
end
chAll = size(trialBuffer(1).Lfpdata,1);
repeatTime = ceil(TrainDur/curICI);


for ch = 1:chAll
    %% raster to plot
    rasterBuffer = [];
    for trialN = 1:length(trialBuffer) % calculate single trial res and then integrate
        trialNum = trialBuffer(trialN).trialNum;
        soundN = trialBuffer(trialN).soundNum;
        buffer = trialBuffer(trialN).(spikeField);
        % for raster plot
        buffer{ch} = findWithinInterval(buffer{ch},[0 ISI]);
        rasterBuffer = [rasterBuffer ; buffer{ch}*1000 ones(length(buffer{ch}),1)*soundN ones(length(buffer{ch}),1)*trialNum ];
        trialBuffer(trialN).raster(ch,:) = {[buffer{ch}*1000 ones(length(buffer{ch}),1)*soundN  ones(length(buffer{ch}),1)*trialNum ]};
        % for frate
        frateBuffer(trialN) = length(findWithinInterval(buffer{ch}*1000,analyseWin))*1000/(analyseWin(2) - analyseWin(1));
        trialBuffer(trialN).frate(ch,:) =  frateBuffer(trialN);
        % for click
        clickOnset =  0:curICI:(repeatTime-1)*curICI;
        if curICI<= analyseWin(2)
            clickOffset = clickOnset + curICI;
        else
            clickOffset = clickOnset + analyseWin(2)-TrainDur;
        end
        clickWin = [clickOnset; clickOffset]';
        for clickN = 1:size(clickWin,1)
            win = clickWin(clickN,:);
            clickFrate(trialN,clickN) = length(findWithinInterval(buffer{ch}*1000,win))*1000/(analyseWin(2) - TrainDur);
        end
        trialBuffer(trialN).clickFrate(ch,:) = clickFrate(trialN,:);

        if contains(protocolName,'ClickTrain')
            % for reyleigh
            RSbuffer(trialN,1) = RayleighStatistic(buffer{ch}*1000,curICI);
            trialBuffer(trialN).RSbuffer(ch,:) = RSbuffer(trialN,1);
            % for percent adaptation A% and RRTF
            trialBuffer(trialN).percentAdapt(ch,:)= 100*(1-clickFrate(trialN,:)./clickFrate(trialN,1));
            trialBuffer(trialN).RRTF(ch,:) = mean(clickFrate(trialN,end-4:end))./clickFrate(trialN,1);
        end
    end


    for num = unique([trialBuffer.soundNum]) % split trials into different groups accoring to soundNum
        idx = find([trialBuffer.soundNum] == num);
        rasterIdx = ismember(rasterBuffer(:,2),idx);
        raster{ch,num} = rasterBuffer(rasterIdx,:);
        %% calculate firing rate
        frate{ch,num} = {[mean(frateBuffer(idx)) std(frateBuffer(idx))/sqrt(length(idx))], frateBuffer(idx)};

        %% calculate PSTH
        psth{ch,num} = calPsth(rasterBuffer(rasterIdx,1),optPSTH,1000,'edge',analyseWin,'Ntrial',length(idx));
        
        %% calculate click firing rate
        clickFrateVector = reshape(clickFrate(idx,:),[numel(clickFrate(idx,:)),1]);
        click{ch,num} = {[mean(clickFrateVector) std(clickFrateVector)/sqrt(length(clickFrateVector))] , [(mean(clickFrate(idx,:)))' std(clickFrate(idx,:))'/sqrt(length(idx))] , clickFrate(idx,:)};

        if contains(protocolName,'ClickTrain')
            %% calculate rayleigh statistic
            [h,p] = ttest2(RSbuffer(idx),ones(length(RSbuffer(idx)),1)*13.8);
            if mean(RSbuffer(idx)) < 13.8
                p = p*-1;
            end
            RS{ch,num} = {[mean(RSbuffer(idx)) std(RSbuffer(idx))/sqrt(length(idx))], p ,RSbuffer(idx)};

            %% calculate percent adaptation A%
            percentAdapt{ch,num} = {100*(1-clickFrate(idx,:)./clickFrate(idx,1)), clickFrate(idx,:)}; % save percentAdapt  and click-frate array
            %   percentAdapt{ch,num}(percentAdapt(RRTF{ch,num}{1}) | isinf(percentAdapt{ch,num}{1})) = 0; % convert inf or nan to 0

            %% calculate RRTF
            RRTF{ch,num} = {mean(clickFrate(idx,end-4:end),2)./clickFrate(idx,1), clickFrate(idx,:)} ; % return n*1 mean array
            %   RRTF{ch,1}(isnan(RRTF{ch,1}) | isinf(RRTF{ch,1})) = 0; % convert inf or nan to 0
        end
    end
end

%% set output
varargout{1} = trialBuffer;
varargout{2} = mergeCellToOneCol(frate);
varargout{3} = mergeCellToOneCol(raster);
varargout{4} = mergeCellToOneCol(psth);
varargout{5} = mergeCellToOneCol(click);
if contains(protocolName,'ClickTrain')
    varargout{6} = mergeCellToOneCol(RS);
    varargout{7} = mergeCellToOneCol(percentAdapt);
    varargout{8} = mergeCellToOneCol(RRTF);
end

end