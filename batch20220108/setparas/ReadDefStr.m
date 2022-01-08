function varargout=ReadDefStr(varargin)
ResStr={'Align2Std1Onset','Align2DevOnset','Align2Push'};
% CueType={'freq','int','all'};
Behav={'Push','NoPush','All'};

for i = 1:2:length(varargin)
    eval(['varargout{(i+1)/2}=' varargin{i} '{varargin{i+1}};']);
end
end