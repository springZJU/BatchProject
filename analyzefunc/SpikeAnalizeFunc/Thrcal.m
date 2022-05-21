function [Res,ThrRes] = Thrcal(data,opt,varargin)
% opt.lanmuda
% opt.xThr : the maximum of x obtained from fit curve
% opt.yThr
% opt.thrMethod
% opt.plotYN
% varargin: fitMethod:
%           fitRes: if fitted previous, use this function as:
%           Thrcal(data,opt,'fitRes',fitRes);
plotYN = false;
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end

defopt = defConfig(data,opt);
eval([GetStructStr(defopt) '=ReadStructValue(defopt);']);

%% fit curve according to input (lanmuda & data)


if ~exist('fitRes','var')
norx = lanmuda;
nory = data;
[Res.R2,Res.yFit,Res.fitRes,Res.Threshold,Res.norx] = psychometricFit(nory,plotYN,defopt); 
end
ThrRes = Res.Threshold.(defopt.fitMethod);
end




function defOpt = defConfig(Data,Opt)
if ~isfield(Opt,'lanmuda')
    defOpt.lanmuda = 1:size(Data,1);
else
    defOpt.lanmuda = Opt.lanmuda;
end
if ~isfield(Opt,'yThr')
    defOpt.yThr = 0.8;
else
    defOpt.yThr = Opt.yThr;
end
if ~isfield(Opt,'xThr')
    defOpt.xThr = 2.9;
else
    defOpt.xThr = Opt.xThr;
end
if ~isfield(Opt,'thrMethod')
    defOpt.thrMethod = 'Y';
else
    defOpt.thrMethod = Opt.thrMethod;
end
if ~isfield(Opt,'fitMethod')
    defOpt.fitMethod = {'sigmoid','logistic','weibull','gaussint'};
else
    defOpt.fitMethod = Opt.fitMethod;
end
if ~isfield(Opt,'dataType')
    defOpt.dataType = 'neural';
else
    defOpt.dataType = Opt.dataType;
end
if ~isfield(Opt,'plotYN')
    defOpt.plotYN = false;
else
    defOpt.plotYN = Opt.plotYN;
end
end