function [Onsets] = getOnsetfromMidi(file, sampleRate, pad)
%getOnsetfromMidi Returns time onset at the right sampling rate
    nmat = readmidi(file);
    Onsets = zeros(1, round(pad*sampleRate+nmat(end, 6)*sampleRate+2000));
    Onsets(floor(pad*sampleRate+1.2*nmat(:,6)*sampleRate+1)) = 1;
end

