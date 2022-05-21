function TrialParas = deleteNoAttentionTrials(TrialParas,nopushLength)
% nopushLength指的是开始或结束时连续多少trial不按认为是没有干活
        nopushIdx = find([TrialParas.PushTime]' == 0); % 所有不按的trial
        nopushContinuous = judgeContinuous(nopushIdx); % 连续不按的trial
        startNoAttention = nopushContinuous{1}(1) == 1 & length(nopushContinuous{1}) >= nopushLength; % 判断开始是否是没有干活
        endNoAttention = nopushContinuous{end}(end) == length(TrialParas) & length(nopushContinuous{end}) >= nopushLength; % 判断结束是不是没有干活
        if startNoAttention & ~endNoAttention
            TrialParas(nopushContinuous{1}) = [];
        elseif ~startNoAttention & endNoAttention
            TrialParas(nopushContinuous{end}) = [];
        elseif startNoAttention & endNoAttention
            TrialParas([nopushContinuous{1}; nopushContinuous{end}]) = [];
        end
end