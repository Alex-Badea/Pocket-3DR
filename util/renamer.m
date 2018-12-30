imsDirName = 'haha';
imNamesPattern = 'car*';
newName = 'car';

imsDir = dir([imsDirName '/' imNamesPattern]);
imNames = {imsDir.name};

for i = 1:length(imNames)
    movefile([imsDirName '/' imNames{i}],...
        [imsDirName '/' newName sprintf('%02d',i) '.jpg']);
end