%> @file  parcreaterandstream.m
%> @brief Setup  global random number state to the specific stream and substream using combined recursive generator.
%> @param ns number of independent streams
%> @param si substream index

function parcreaterandstream(ns, si)

s = RandStream.create('mrg32k3a', 'NumStreams', ns,'StreamIndices', ns);

s.Substream = si;

RandStream.setGlobalStream(s);
end