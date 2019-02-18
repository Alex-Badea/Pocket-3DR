imsDirName = 'ims';
imNamesPattern = 'IMG*';
newName = 'bst';

imsDir = dir([imsDirName '/' imNamesPattern]);
imNames = {imsDir.name};

for i = 1:length(imNames)
    movefile([imsDirName '/' imNames{i}],...
        [imsDirName '/' newName sprintf('%02d',i) '.jpg']);
end