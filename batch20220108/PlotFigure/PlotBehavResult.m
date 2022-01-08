function PlotBehavResult(varargin)
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
eval([GetStructStr(Para) '=ReadStructValue(Para);']);
eval([GetStructStr(params) '=ReadStructValue(params);']);
eval([GetStructStr(plotpara) '=ReadStructValue(plotpara);']);
hh = waitbar(0,'please wait');
for cellnum = 1:size(BufferData,1)
    % for cellnum = 62
    str=['Running PlotTFRegionInf, current: ' num2str(cellnum) , '(' num2str(cellnum) '/' num2str(size(BufferData,1)) ')' ];
    waitbar(cellnum/size(BufferData,1),hh,str)
    h = figure
    set(gcf,'outerposition',get(0,'screensize'));
    ProtocolName = BufferField(ProtocolLogic&StructLogic(cellnum,:));
    ActiveProtocolTypes = ProtocolName(contains(ProtocolName,'Active'));
    PassiveProtocolTypes = strrep(ActiveProtocolTypes,'Active','Passive');
    HeightSpect = 0.86/length(ActiveProtocolTypes)/2; HeightHistogram = HeightSpect-0.02; HeightScatter = HeightSpect; HeightSpike = HeightSpect;
    SitePos = BufferData(cellnum).SitePos;
    Date = BufferData(cellnum).Date;
    Region = BufferData(cellnum).Region;

    for ch = Chs
        params.ProtocolName = ProtocolName; params.ActiveProtocolTypes = ActiveProtocolTypes; params.PassiveProtocolTypes = PassiveProtocolTypes;
        params.HeightSpect = HeightSpect; params.HeightHistogram = HeightHistogram; params.HeightScatter = HeightScatter;  params.HeightSpike = HeightSpike;
        params.cellnum = cellnum; params.ch = ch;
        for protypes = 1:length(ActiveProtocolTypes)
            Path = strrep(BufferData(cellnum).(ActiveProtocolTypes{protypes}).PlotDataPath,'F:\',RootDisk);
            load(Path);
            TrialParasPath = strrep(BufferData(cellnum).(ActiveProtocolTypes{protypes}).TrialParasPath,'F:\',RootDisk);
            load(TrialParasPath);
            
            %% prior experience analysis
            PreCorrectIndex = find(strcmp({TrialParas.CorrectWrong},'Correct'))+1;
            PreWrongIndex = find(strcmp({TrialParas.CorrectWrong},'Wrong'))+1;
            PreCorrectIndex(PreCorrectIndex>size(TrialParas,1))=[];
            PreWrongIndex(PreWrongIndex>size(TrialParas,1))=[];
            PreCorrectTrial = TrialParas(PreCorrectIndex);
            PreWrongTrial = TrialParas(PreWrongIndex);
            Diff = unique([TrialParas.Diff]);
            for dev_diff = 1:length(Diff)
                PCBehav(dev_diff,2) = length(find(strcmp({PreCorrectTrial.Behav},'Push') & [PreCorrectTrial.Diff]==dev_diff));
                PCBehav(dev_diff,3) = length(find([PreCorrectTrial.Diff]'==dev_diff));
                PWBehav(dev_diff,2) = length(find(strcmp({PreWrongTrial.Behav},'Push') & [PreWrongTrial.Diff]==dev_diff));
                PWBehav(dev_diff,3) = length(find([PreWrongTrial.Diff]'==dev_diff));
            end
            PCBehav(:,1) = PCBehav(:,2)./PCBehav(:,3);
            PWBehav(:,1) = PWBehav(:,2)./PWBehav(:,3);
            PWBehav(PWBehav(:,3)==0,1)=0;
            PlotData.Behav.PreCorrect = PCBehav;
            PlotData.Behav.PreWrong = PWBehav;
        
        diffColor = {'#AAAAAA','k','b','m','r'};
        figure
        subplot 231 
        for dev_diff = 1:5
            if PWBehav(dev_diff,3)==0
                continue
            else
                plot(PCBehav(dev_diff,1),PWBehav(dev_diff,1),'o','color',diffColor{dev_diff},'MarkerFaceColor',diffColor{dev_diff},'markersize',5); hold on;
            end
        end
        plot([0 1], [0 1],'k--');
        legend('control','diff1','diff2','diff3','diff4','diagonal','Location','southeast','NumColumns',2);
        legend('boxoff');
        subplot 232
        plot(Diff,PWBehav(:,1),'bo-','linewidth',2,'MarkerFaceColor','b'); hold on;
        plot(Diff,PCBehav(:,1),'ro-','LineWidth',2,'MarkerFaceColor','r'); hold on;
        plot(Diff,PlotData.behavresult,'ko-','LineWidth',2,'MarkerFaceColor','k'); hold on;
        legend('PreWrong','PreCorrect','Location','southeast');legend('boxoff');

        %% process of block
       
        EarlyTrial = TrialParas(1:floor(end/2));
        LateTrial = TrialParas(floor(end/2)+1:end);
        Diff = unique([TrialParas.Diff]);
            for dev_diff = 1:length(Diff)
                EarlyBehav(dev_diff,2) = length(find(strcmp({EarlyTrial.Behav},'Push') & [EarlyTrial.Diff]==dev_diff));
                EarlyBehav(dev_diff,3) = length(find([EarlyTrial.Diff]'==dev_diff));
                LateBehav(dev_diff,2) = length(find(strcmp({LateTrial.Behav},'Push') & [LateTrial.Diff]==dev_diff));
                LateBehav(dev_diff,3) = length(find([LateTrial.Diff]'==dev_diff));
            end
            EarlyBehav(:,1) = EarlyBehav(:,2)./EarlyBehav(:,3);
            LateBehav(:,1) = LateBehav(:,2)./LateBehav(:,3);
            LateBehav(LateBehav(:,3)==0,1)=0;
            PlotData.Behav.Early = EarlyBehav;
            PlotData.Behav.Late = LateBehav;
        
        diffColor = {'#AAAAAA','k','b','m','r'};
        
        subplot 234 
        for dev_diff = 1:5
            if LateBehav(dev_diff,3)==0
                continue
            else
                plot(EarlyBehav(dev_diff,1),LateBehav(dev_diff,1),'o','color',diffColor{dev_diff},'MarkerFaceColor',diffColor{dev_diff},'markersize',5); hold on;
            end
        end
        plot([0 1], [0 1],'k--');
        legend('control','diff1','diff2','diff3','diff4','diagonal','Location','southeast','NumColumns',2);
        legend('boxoff');
        subplot 235
        plot(Diff,LateBehav(:,1),'bo-','linewidth',2,'MarkerFaceColor','b'); hold on;
        plot(Diff,EarlyBehav(:,1),'ro-','LineWidth',2,'MarkerFaceColor','r'); hold on;
        plot(Diff,PlotData.behavresult,'ko-','LineWidth',2,'MarkerFaceColor','k'); hold on;
        legend('Early','Late','Location','southeast');legend('boxoff');



        %% Stumuli distribution
        Diffnum = zeros(length(Diff),1);
        DynamicDiffnum = [];
        for Paranum = 1:size(TrialParas,1)
            ind = find(Diff == TrialParas(Paranum).Diff);
            Diffnum(ind) = Diffnum(ind)+1;
            DynamicDiffnum = [DynamicDiffnum Diffnum];
        end
        subplot 233
        for dev_diff = 1:length(Diff)
            plot(1:size(DynamicDiffnum,2),DynamicDiffnum(dev_diff,:)/DynamicDiffnum(dev_diff,end),'Color',diffColor{dev_diff},'LineStyle','-'); hold on;
        end


    end
end
    delete(hh)
