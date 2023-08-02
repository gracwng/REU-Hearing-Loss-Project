clc; clear all;

initdir

% point to where the source data is stored
bidsdir = '/home/sorenaf/datasets/bids/ds-eeg-nhhi';

% point to where the derived data is stored
sdir    = '/mrhome/sorenaf/datasets/derived/ds-eeg-nhhi/paper/';


r01f01(sdir,bidsdir)
r01f02(bidsdir)
r01f03
r01f04(sdir,bidsdir)
r01f05(bidsdir)
r01f06(bidsdir)
r01f07(sdir,bidsdir)
r01f08(sdir,bidsdir)