function Psth = calPsth(data,binpara,scaleFactor,varargin)
EDGEMISMATCH = false;
NTRIAL = 1;
for i = 1:2:length(varargin)
    eval([ upper(varargin{i}) '=varargin{i+1};']);
end
binsize = binpara.binsize;
binstep = binpara.binstep;
if ~isempty(data) & max(data)>binsize

if ~(exist('EDGE') == 1) %if WIN is a variable?
    EDGE = [min(data) max(data)];
end
edgeBuffer = EDGE(1):binstep:EDGE(2)-binsize;


%% check if the default edge is exceeds the maximum value of data, and inquiry if it need to be more suitable
if (edgeBuffer(end)+binsize > max(data) | edgeBuffer(1) < min(data)) & EDGEMISMATCH
    % send warning msg to user
    opts.Interpreter = 'tex';
    opts.Default = 'yes';
    quest = {'\fontsize{10} Your psth edge is wider than your data, which will cause sharp inc/dec at the boundary;';...
        '\fontsize{10} Would you like to shorten your psth edge according to data?'};
    questAns = questdlg(quest,'Psth Edge Warning!','yes','no',opts);
switch questAns
    case 'yes'
        EDGE = [min(data) max(data)];
        edgeBuffer = EDGE(1):binstep:EDGE(2)-binsize;
    case 'no'% Nothing to do
        %...
end
end
    
edges(:,1) = edgeBuffer;
edges(:,2) = edges(:,1)+binsize;
edges(:,3) = mean(edges,2);
stepNum = size(edges,1);
count = zeros(stepNum,1);
for stepN = 1:stepNum
    count = histcounts(data,edges(stepN,[1 2]));
    Psth(stepN).y = count/binsize/NTRIAL*scaleFactor;
    Psth(stepN).edges = edges(stepN,:)';
end


else
%     if length(data)<=binsize
%         msgtext = 'The length of input isn''t longer than binsize'
Psth.y = [];
Psth.edges = [];
end


