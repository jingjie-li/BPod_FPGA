function [ sound ] = GenerateSineWave( freq,duration,fs )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
t = 0: 1/fs: duration;
sound = sin(2*freq*pi*t);

end

