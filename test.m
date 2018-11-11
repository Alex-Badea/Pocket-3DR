CX(1) = RectifyAndDenseTriangulate({Cim{1},Cim{2}}, {K'\CE{1}/K}, {K*CP{1},K*CP{2}});
CX(2) = RectifyAndDenseTriangulate({Cim{8},Cim{9}}, {K'\CE{8}/K}, {K*CP{8},K*CP{9}});
CX(3) = RectifyAndDenseTriangulate({Cim{20},Cim{21}}, {K'\CE{20}/K},...
    {K*CP{20},K*CP{21}});

pcshow([CX{1} CX{2} CX{3}]')