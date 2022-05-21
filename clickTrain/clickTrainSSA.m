function varargout = clickTrainSSA(stimPara,params,varargin)
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
eval([GetStructStr(params) '=ReadStructValue(params);']);

%%  classify based on ICI and process data
soundNum = [stimPara.soundNum]';



varargout{1} = rez;
varargout{2} = stimType;
varargout{3} = stimPara;
end