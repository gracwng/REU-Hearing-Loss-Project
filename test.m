	files = dir('C:\Users\student\Documents\snhl-master\src\features\func\modules\eeg');  % lists all files in the specified directory
for i = 1:numel(files)
    disp(files(i).name)  % displays the names of the files
end


