function [CFilteredX,CFilteredColors] = psr(CScreenedX,CScreenedColors)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Surface reconstruction from oriented points                      %
%   Radim Tylecek, CMP FEL CVUT Praha, 2010.                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  * Input: *
% X .... set of structured point clouds, one for each stereo pair
% X{p} double [W x H x 3] ... 3d points aligned in image plane W x H
%   each pixel X{p}(i,j,:) either contains a 3d point [x,y,z]
%   or it is empty when the values are set to 'NaN'
%
% The point neighborhood is used for calculation of normals.
% Oriented points are then processed by Poisson Surface Recontruction [1]
% to generate closed a mesh surface.
%
% Executables for PSR for Windows and Linux are included for 32/64 bits.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  * Output: *
% psr.ply ... triangle mesh in 'polygon' file format (vertices+triangle indices)
% output can be viewed, edited and converted to VRML using MeshLab [2]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [1] PSR: http://www.cs.jhu.edu/~misha/Code/PoissonRecon/
% [2] MeshLab: http://meshlab.sourceforge.net/     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parameters
big_tri = 2; % max factor threshold of max to min triangle side length
show = 0;  % plot figures
psr_path = '"repo_CVUT_FEL/psr/PoissonRecon"'; % psr executable, use *64 on 64bit systems
psr_output = 'psr_out.ply';      % output filename
psr_dep = 8;                % psr detail level (max 12)

%% process all pairs
fprintf('Poisson Surface Recontruction %s\n',datestr(now)); tic;
fprintf('Processing %d pairs...\n',length(CScreenedX));

ptsum = 0;
% get depths and points from all pairs

CFilteredX = cell(1,length(CScreenedX));
CFilteredNormals = cell(1,length(CScreenedX));
CFilteredColors = cell(1,length(CScreenedX));

for p = 1:length(CScreenedX)
    
    vis = ~isnan(CScreenedX{p}(:,:,1)); % visibility mask
    fprintf('%d: calculating normals for %d points...',p,sum(vis(:)));
    H = size(CScreenedX{p},1); % height
    W = size(CScreenedX{p},2); % width
    
    %% align points in array
    ptX = zeros(H*W,3);
    Xp = CScreenedX{p}(:,:,1);
    ptX(:,1) = Xp(:);
    Xp = CScreenedX{p}(:,:,2);
    ptX(:,2) = Xp(:);
    Xp = CScreenedX{p}(:,:,3);
    ptX(:,3) = Xp(:);
    
    Colors = zeros(H*W,3);
    ColorsP = CScreenedColors{p}(:,:,1);
    Colors(:,1) = ColorsP(:);
    ColorsP = CScreenedColors{p}(:,:,2);
    Colors(:,2) = ColorsP(:);
    ColorsP = CScreenedColors{p}(:,:,3);
    Colors(:,3) = ColorsP(:);
    %% calculate normals for all possible triangles
    
    ptN = zeros(H*W,3);   % normal accumulator
    Ncnt = zeros(H,W);
    
    % there are four possible triangles around a point
    for m = 1:4
        switch(m)
            case 1
                emask = [0 0 0; 0 1 1; 0 1 0];  % mask for erosion
                tdef = [0 1 H];                 % triangle vertex offsets
            case 2
                emask = [0 1 0; 0 1 1; 0 0 0];
                tdef = [0 -H 1];                % CCW order
            case 3
                emask = [0 1 0; 1 1 0; 0 0 0];
                tdef = [0 -1 -H];
            case 4
                emask = [0 0 0; 1 1 0; 0 1 0];
                tdef = [0 H -1];
        end
        
        cvis = imerode(vis,emask);  % get positions where such triangles can be constructed
        cvis([1 end],:) = 0; cvis(:,[1 end]) = 0;
        vi = find(cvis(:)==1)';     % indices of reference points
        vic = length(vi);
        
        tri = zeros(vic,3);     % triangle vertex indices
        tri(:,1) = vi+tdef(1);
        tri(:,2) = vi+tdef(2);
        tri(:,3) = vi+tdef(3);
        
        ta = [ptX(tri(:,2),1) ptX(tri(:,2),2) ptX(tri(:,2),3)] - [ptX(tri(:,1),1) ptX(tri(:,1),2) ptX(tri(:,1),3)];
        tb = [ptX(tri(:,3),1) ptX(tri(:,3),2) ptX(tri(:,3),3)] - [ptX(tri(:,1),1) ptX(tri(:,1),2) ptX(tri(:,1),3)];
        tc = [ptX(tri(:,3),1) ptX(tri(:,3),2) ptX(tri(:,3),3)] - [ptX(tri(:,2),1) ptX(tri(:,2),2) ptX(tri(:,2),3)];
        td = [sqrt(dot(ta,ta,2)) sqrt(dot(tb,tb,2)) sqrt(dot(tc,tc,2))];
        tdev = max(td,[],2)./min(td,[],2);
        
        %% normal as cross product of triangle sides
        
        tN = cross(ta,tb);
        tN = tN./repmat(sqrt(dot(tN,tN,2)),1,3);
        discont = tdev>big_tri | sum(isnan(tN),2)>0;
        tN(discont,:) = 0;
        ptN(vi,:) = ptN(vi,:) + tN; % normalize
        Ncnt(vi(~discont)) = Ncnt(vi(~discont)) +1;
        
    end
    
    %% get list of points
    vpt = Ncnt(:)>0;
    vX = ptX(vpt,:)';
    vN = ptN(vpt,:)';
    vN = (vN'./repmat(sqrt(dot(vN',vN',2)),1,3))'; % normalize
    fprintf('removed %d lonely and border points\n',sum(vis(:))-sum(vpt(:)));

    CFilteredX{p} = vX;
    CFilteredNormals{p} = vN;
    CFilteredColors{p} = Colors(vpt,:)';
    %% figure
    if show>0
        figure('Name','Points+normals');
        every = 1; %floor(size(vX,2)/1000)+1;
        seli = 1:every:size(vX,2);
        plot3(vX(1,seli),vX(3,seli),vX(2,seli),'b.'); hold on; grid on; axis equal;
        lX = vX(:,seli) + 0.1*vN(:,seli);
        line([vX(1,seli); lX(1,:)],[vX(3,seli); lX(3,:)],[vX(2,seli); lX(2,:)],'color','r');
    end
    ptsum = ptsum + sum(vpt(:));
end

%% open output file for points and normals
npts = 'psr_in.ply';
f = fopen(npts,'w');

fprintf(f,['ply\n'...
    'format ascii 1.0\n'...
    'element vertex ' num2str(size(cell2mat(CFilteredX),2)) '\n'...
    'property float x\n'...
    'property float y\n'...
    'property float z\n'...
    'property float nx\n'...
    'property float ny\n'...
    'property float nz\n'...
    'property uchar red\n'...
    'property uchar green\n'...
    'property uchar blue\n'...
    'end_header\n']);
fprintf(f,'%g %g %g  %g %g %g  %g %g %g\n',...
    [cell2mat(CFilteredX); cell2mat(CFilteredNormals); cell2mat(CFilteredColors)]);

f = fclose(f);
toc;

%% run PSR
fprintf('Running PSR depth=%d on %d total points...\n\n',psr_dep,ptsum); tic;
eval(sprintf(['!%s --verbose --ascii --normals --colors --depth %d '...
    '--in %s --out %s --threads %d'],...
    psr_path,psr_dep,npts,psr_output,feature('numcores')));
toc;

