function MakePly(filename, points, normals, colors)
header = ['ply\n'...
    'format ascii 1.0\n'...
    'element vertex ' num2str(size(points,2)) '\n'...
    'property float x\n'...
    'property float y\n'...
    'property float z\n'];
format = '%f %f %f';
outArrays = points;
if exist('normals','var') && ~isempty(normals)
    if ~isequal(size(points), size(normals))
        error('Points and normals sizes not matching')
    end
    header = [header 'property float nx\n'...
    'property float ny\n'...
    'property float nz\n'];
    format = [format '  %f %f %f'];
    outArrays = [outArrays; normals];
end
if exist('colors','var') && ~isempty(colors)
    if ~isequal(size(points), size(colors))
        error('Points and colors sizes not matching')
    end
    header = [header 'property uchar red\n'...
    'property uchar green\n'...
    'property uchar blue\n'];
    format = [format '  %d %d %d'];
    outArrays = [outArrays; double(colors)]; 
end
header = [header 'end_header\n'];
format = [format '\n'];

h = fopen(['out/' filename],'w');
fprintf(h,header);
fprintf(h,format,outArrays);
fclose(h);
end