function [sound_all lfp spike sortdata behavresult]=LoadMATData(path,params,varargin)
if nargin>1
    for i = 1:2:length(varargin)
        val([ varargin{i} '=varargin{i+1};']);
    end
end
eval([GetStructStr(params) '=ReadStructValue(params);']);
if  contains(ProtocolName,'PEOddBasic')
    [sound_all lfp spike sortdata behavresult] = PEOddBaseSoundAll(path,params);
elseif contains(ProtocolName,'PEOdd139')
    [sound_all lfp spike sortdata behavresult] = PEOdd139SoundAll(path,params);
elseif contains(ProtocolName,'PEOddLongTerm')
    [sound_all lfp spike sortdata behavresult] = PEOddLongTermSoundAll(path,params);
elseif contains(ProtocolName,'DurOdd')
    [sound_all lfp spike sortdata behavresult] = DurOddSoundAll(path,params);    
elseif contains(ProtocolName,'ms')
    [sound_all lfp spike sortdata ] = RatNoiseSoundAll(path,params);  
else
%     clc;
    disp('Error ProtocolName Input!')
end

