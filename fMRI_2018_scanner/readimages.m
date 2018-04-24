function[imcell] = readimages;
oldDir = pwd;
cd('images');

iminfo = dir('*.jpg');
imcell = cell(1,numel(iminfo));

for i = 1:numel(iminfo);
    imcell{i} = imread(iminfo(i).name);
end

cd(oldDir);

imcell = reshape(imcell,[2,(length(imcell)/2)])';

end

