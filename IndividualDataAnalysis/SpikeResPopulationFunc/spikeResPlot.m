function spkPlot = spikeResPlot(popRes,varargin)
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
eval([GetStructStr(params) '=ReadStructValue(params);']);
popResFields = fields(popRes);
colors = {'#AAAAAA','b','m','r'};
plotWin = [200 600; -400 400];
% eval([GetStructStr(popRes.(popResFields{1})) '=ReadStructValue(popRes.(popResFields{1}));']);
for popResNum = 1:length(popResFields)
    analyseType = fields(popRes.(popResFields{popResNum}));
    for aNum = 1:length(analyseType)
        cuetype = fields(popRes.(popResFields{popResNum}).(analyseType{aNum}));
        for cueNum = 1:length(cuetype)
            buffer = popRes.(popResFields{popResNum}).(analyseType{aNum}).(cuetype{cueNum});
            analyseName = analyseType{aNum};
            switch analyseName

                case 'SpikePsth'
                    h = figure;
                    set(gcf,'outerposition',get(0,'screensize'));
                    alignType = fields(buffer);
                    for alignNum = 1:length(alignType)
                        subplotPanel(length(alignType),alignNum,'position');
                        plotBuffer = buffer.(alignType{alignNum}){1};
                        for devDiff = 2:length(buffer.(alignType{alignNum}))-1
                            plotBuffer = [plotBuffer; mean(buffer.(alignType{alignNum}){devDiff+1})];
                            plot(plotBuffer(1,:),plotBuffer(devDiff,:),'Color',colors{devDiff-1}); hold on
                        end
                        xlim([plotWin(alignNum,:)]);
                        spkPlot.(cuetype{cueNum}).SpikePsth.(alignType{alignNum}) = plotBuffer;
                        title(['Alignment ' alignType{alignNum}]);
                    end
                        
                case 'DPCurve'
                    h = figure;
                    set(gcf,'outerposition',get(0,'screensize'));
                    spkPlot.(cuetype{cueNum}).DPCurve.All = cell2mat(buffer);
                    spkPlot.(cuetype{cueNum}).DPCurve.Mean = mean(spkPlot.(cuetype{cueNum}).DPCurve.All);
                    %plot DP Curve
                    plotBuffer = spkPlot.(cuetype{cueNum}).DPCurve;
                    plot([50:50:950]+50,plotBuffer.All,'Color','#AAAAAA','LineStyle','-'); hold on
                    plot([50:50:950]+50,plotBuffer.Mean,'r-','LineWidth',2); hold on
                    title('DP Curve')

                case 'DPWin'
                    h = figure;
                    set(gcf,'outerposition',get(0,'screensize'));
                    subplotNum = length(buffer); 
                    for winNum = 1:length(buffer)
                        subplotPanel(subplotNum,winNum,'position');
                        winType = ['win' num2strcell(buffer{winNum}(1).win)];
                        winType = [winType{1:2} '_' winType{end}];
                        DPwinBuffer = [[buffer{winNum}.value]; [buffer{winNum}.p]];
                        %plot histogram of DP value and correspond p value
                        sigBuffer = DPwinBuffer(:,DPwinBuffer(2,:)<0.05);
                        nosigBuffer = DPwinBuffer(:,DPwinBuffer(2,:)>0.05);
                        DPEdge = [0:0.1:1];
                        spkPlot.(cuetype{cueNum}).DPwin.(winType).sig = histcInd(sigBuffer(1,:),DPEdge);
                        spkPlot.(cuetype{cueNum}).DPwin.(winType).nosig = histcInd(nosigBuffer(1,:),DPEdge);
                        plotBuffer = spkPlot.(cuetype{cueNum}).DPwin.(winType);
                        b = bar(plotBuffer.sig(2,:),[plotBuffer.sig(1,:);plotBuffer.nosig(1,:)]','stacked');
                        b(1).FaceColor = 'k';
                        b(2).FaceColor = 'w';
                        legend('p<0.05','p>0.05');
                        title(['DP in ' winType ]);
                    end
                   
                case 'frTuningCurve'
                    winType = fields(buffer.Correct);
                    cwType = fields(buffer) % correct/wrong/all
                    h = figure;
                    set(gcf,'outerposition',get(0,'screensize'));
                    subplotNum = length(cwType)*length(winType);
                    for cwNum = 1:length(cwType)
                        for winNum = 1:length(winType) % different windows
                            
                            frBuffer = [];
                            for devDiff = 1:size(buffer.(cwType{cwNum}),2)
                                frBuffer = [frBuffer;buffer.(cwType{cwNum})(devDiff).(winType{winNum})(1,:)];
                            end
                            frBuffer(:,frBuffer(1,:)==0) = [];
                            spkPlot.(cuetype{cueNum}).frTuningCurve.(cwType{cwNum}).raw.(winType{winNum}) = frBuffer;
                            spkPlot.(cuetype{cueNum}).frTuningCurve.(cwType{cwNum}).plot.(winType{winNum}) = [mean(frBuffer,2) std(frBuffer,1,2)/sqrt(size(frBuffer,2))];
                        end
                    end
                    %plot frTuningCurve
                    for cwNum = 1:length(cwType)
                    for winNum = 1:length(winType) % different windows
                        subplotPanel(subplotNum,(cwNum-1)*length(winType)+winNum,'position');
                        plotBuffer = spkPlot.(cuetype{cueNum}).frTuningCurve.(cwType{cwNum}).raw.(winType{winNum}); hold on
                        plot(1:5,plotBuffer(:,:),'Color','#AAAAAA'); hold on;
                        plotBuffer = spkPlot.(cuetype{cueNum}).frTuningCurve.(cwType{cwNum}).plot.(winType{winNum});
                        errorbar(1:5,plotBuffer(:,1),plotBuffer(:,2),'r-','LineWidth',3); hold on
                        title([cwType{cwNum} ' firing rate, win [' winType{winNum} ']'  ]);
                        if cwNum<length(cwType)
                            set(gca,'XTickLabel',' ');
                        end
                    end
                    end

                case 'timeLag'
                    h = figure;
                    set(gcf,'outerposition',get(0,'screensize'));
                    tlType = fields(buffer); % timeLag types
                    for tlNum = 1:length(tlType)
                        for devDiff = 1:size(buffer,2)
                            tlBuffer = buffer(devDiff).(tlType{tlNum});
                            spkPlot.(cuetype{cueNum}).timeLag.(tlType{tlNum})(devDiff) = mean(tlBuffer(tlBuffer>0));
                            spkPlot.(cuetype{cueNum}).timeLagRaw.(tlType{tlNum}){devDiff} = tlBuffer(tlBuffer>0);
                        end
                    end
                    %plot timelag raster
                    subplotPanel(length(tlType)*2,1,'position'); % timelag raster
                    plotBuffer = spkPlot.(cuetype{cueNum}).timeLagRaw;
                    for  devDiff = 2:size(buffer,2)
                        s = scatter(plotBuffer.neuralRes{devDiff},plotBuffer.behavRes{devDiff},'filled'); hold on
                        s.MarkerFaceColor = colors{devDiff-1};
                    end
                   
                case 'behavioralThr'
                    spkPlot.(cuetype{cueNum}).behavioralThr = histcInd(buffer,[1:0.25:3]);

                case 'neuronalThr'
                    winType = fields(buffer);
                    h = figure;
                    set(gcf,'outerposition',get(0,'screensize'));
                    subplotNum = 2*length(winType);
                    subplotPanel(subplotNum,1,'position');
                    plotBuffer = spkPlot.(cuetype{cueNum}).behavioralThr;
                    b = bar(plotBuffer(2,:),plotBuffer(1,:));
                    b.FaceColor = 'k';
                    set(gca,'XTickLabel','');
                    title('behavioral threshold');
                    for winNum = 1:length(winType)
                        spkPlot.(cuetype{cueNum}).neuronalThr = histcInd(buffer.(winType{winNum}),[1:0.25:3]);
                        subplotPanel(subplotNum,subplotNum/2+winNum,'position');
                        plotBuffer = spkPlot.(cuetype{cueNum}).neuronalThr;
                        b = bar(plotBuffer(2,:),plotBuffer(1,:));
                        b.FaceColor = 'k';
                        title(['neuronal threshold win [' winType{winNum} ']']);
                    end
                end

        end
    end
end
%%


