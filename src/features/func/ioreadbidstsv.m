%> @file  ioreadbidstsv.m
%> @brief Reading a Tab-Separate Values (TSV) file where tab characters (\t) separate fields that are in the file.
%> @param tsvfile string referring to the filename of interest
%> @retval f imported table

function f = ioreadbidstsv(tsvfile)

f = readtable(tsvfile,'FileType','text','Delimiter','\t','TreatAsEmpty',{'N/A','n/a'});


end