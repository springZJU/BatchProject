function FHCGenerateTrialParas(varargin)

%%
if nargin<2
    disp('Please input datapath information')
    return
else

    for i = 1:2:length(varargin)
        eval([ varargin{i} '=varargin{i+1};']);
    end
    eval([GetStructStr(params) '=ReadStructValue(params);']);

    datafold = erase(datapath,'\data.mat');
    savepath=datafold;
    
    %% if savepath exist TrialParas.mat, then load it; otherwise load TDT data
    try
        load([savepath '\TrialParas.mat']);
    catch
        %% There is not TrialParas.mat in savepath, so load TDT data, save sound information into var
        [sound_all lfp spike sortdata behavresult]=LoadMATData(datapath,params);

        %% sound_all to TrialParas
        TrialParas=GenerateTrialPara(params,sound_all,lfp);
        %% split lfp/spike/sort data for each trial
        for Paranum=1:length(TrialParas)
            TrialParas(Paranum).Lfpdata=lfp.rawdata(:,lfp.T>TrialParas(Paranum).StdSelect*1000&lfp.T<TrialParas(Paranum).DevSelect*1000);
            TrialParas(Paranum).Spikeraw=spike(:,spike>TrialParas(Paranum).StdSelect&spike<TrialParas(Paranum).DevSelect);
            TrialParas(Paranum).Spikesort=sortdata(:,sortdata>TrialParas(Paranum).StdSelect&sortdata<TrialParas(Paranum).DevSelect);
        end
        FsRaw=lfp.fs;

        clear lfp Paranum spike sortdata
        %% add string type labels to each trial
        TrialParas=LabelStrTypes(TrialParas,params);
    end

    %% select trials with artifacts
    buffer = strsplit(datapath,Para.ProtocolStr);
    params.datampath = [buffer{1} 'FRA\data.mat'];
    TrialParas = SelectArtifacts(TrialParas,'params',params);
    
    %% select ambiguous trials
    TrialParas = LabelAmbiguous(TrialParas,AmMethod,'params',params);

    %% label prior trial result (correct/wrong)
    TrialParas = LabelPriorRes(TrialParas);


    %% save TrialParas into savepath
    save([savepath '\TrialParas.mat'],'TrialParas');



end
