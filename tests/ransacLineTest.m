sigma = 10;
inliersno = 200;
outliersno = 800;
linef = @(x) 0.5*x + 100;

x = linspace(1, 800);
inliers = [linspace(1,800,inliersno);
           linef(linspace(1,800,inliersno))+randn(1,inliersno)*sigma];
outliers = [rand(1,outliersno)*799+1;
            rand(1,outliersno)*599+1];
pts = [inliers outliers];
E = @(p) sum((pts(2,:) - p(1)*pts(1,:) - p(2)).^2);
opt = optimoptions('fminunc', 'Display', 'off');
p = fminunc(E, [0 0], opt);
fitlinef = @(x) p(1)*x + p(2);


[f, inpts, ~, steps] = RANSAC(num2cell(pts,1), @generateLineFcn, 2, ...
    @pointLineDist, 1.96*sigma*(2/sqrt(2)));
steps
inpts = cell2mat(inpts);

% constants chosen as per [H & Z] page 119
figure, hold on  
plot(pts(1,:), pts(2,:), 'ro', 'MarkerSize', 4);
plot(x, linef(x), 'g-', 'LineWidth', 2.5);
plot(x, fitlinef(x), 'c--', 'LineWidth', 1.5);
plot(inpts(1,:), inpts(2,:), 'kx', 'MarkerSize', 3)
axis([1 800 1 600])
daspect([1 1 1])
legend('Fitting point', 'Actual line', 'Naive line', 'RANSAC Inliers', 'RANSAC Line', 'Optimal RANSAC Line')

function Cf = generateLineFcn(Cx)
x1 = Cx{1}; x2 = Cx{2};
x1 = [x1(:); 1]; x2 = [x2(:); 2];
lpar = cross(x1,x2);
a = lpar(1); b = lpar(2); c = lpar(3);
Cf = {@(x) -a/b*x - c/b};
end

function errs = pointLineDist(f, Cpts)
pts = cell2mat(Cpts);
xs = pts(1,:);
ys = pts(2,:);
errs = abs(ys - f(xs));
end