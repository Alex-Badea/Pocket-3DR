CX(1) = RectifyAndDenseTriangulate({Cim{1},Cim{2}}, {K'\CE{1}/K}, {K*CP{1},K*CP{2}});
CX(2) = RectifyAndDenseTriangulate({Cim{16},Cim{17}}, {K'\CE{16}/K}, ...
    {K*CP{16},K*CP{17}});
figure,pcshow([CX{1} CX{2}]')

CX(1) = RectifyAndDenseTriangulate({Cim{1},Cim{2}}, {K'\CE{1}/K}, {K*CP_{1},K*CP_{2}});
CX(2) = RectifyAndDenseTriangulate({Cim{16},Cim{17}}, {K'\CE{16}/K}, ...
    {K*CP_{16},K*CP_{17}});
figure,pcshow([CX{1} CX{2}]')

