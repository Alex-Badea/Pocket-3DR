function MakePly(filename, vertices, colors)
if ~isequal(size(vertices), size(colors))
    error('Vertices and colors sizes not matching')
end
n = size(vertices,2);
h = fopen(filename,'w');
fprintf(h,['ply\nformat ascii 1.0\nelement vertex ' num2str(n) ...
    '\nproperty float x\nproperty float y\nproperty float z' ...
    '\nproperty uchar red\nproperty uchar green\nproperty uchar blue' ...
    '\nend_header\n']);
fprintf(h,'%f %f %f %d %d %d\n',[vertices; colors]);
end