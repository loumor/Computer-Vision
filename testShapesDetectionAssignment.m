%%identify the three shapes we need to find later on the work sheet

%original image size 3968x2240
%picture taken from test sheet so that paper just covers whole image

[s_unscaled,s_data]= iread('testShapes2.jpg');
%s_gamma=s_data.Gamma;
s_gamma=1;

s_scaleFactor=0.3;
s_resolutionScaled=s_data.Height*s_data.Width*s_scaleFactor^2;
%minimum blob area covers 1%, maximum 50% of test sheet image
s_minArea=s_resolutionScaled*0.01; 
s_maxArea=s_resolutionScaled*0.5; 

%thresholds for size descision
%descision between big or small if circle covers more than 10.6% of image
%etc...
s_circleThreshold=s_resolutionScaled*0.106; 
s_squareThreshold=s_resolutionScaled*0.103;
s_triangleThreshold=s_resolutionScaled*0.063;

%rescale
s_im=imresize(s_unscaled,s_scaleFactor);

s_imRed=s_im(:,:,1);
s_imGreen=s_im(:,:,2);
s_imBlue=s_im(:,:,3);

%normalize
s_imRedNormal=double(s_imRed)/255;
s_imGreenNormal=double(s_imGreen)/255;
s_imBlueNormal=double(s_imBlue)/255;

%gamma correction
s_imB=s_imBlueNormal.^s_gamma;
s_imG=s_imGreenNormal.^s_gamma;
s_imR=s_imRedNormal.^s_gamma;

%chromaticity
s_imb=s_imB./(s_imR+s_imG+s_imB);
s_imr=s_imR./(s_imR+s_imG+s_imB);
s_img=s_imG./(s_imR+s_imG+s_imB);

%threshold
s_imbThings=s_imb>0.5;
s_imrThings=s_imr>0.5;
s_imgThings=s_img>0.5;

%Morphology Closing
s_imrThings=iclose(s_imrThings,ones(7,7));
s_imgThings=iclose(s_imgThings,ones(7,7));
s_imbThings=iclose(s_imbThings,ones(7,7));

%blobs
s_b = iblobs(s_imbThings,'area',[s_minArea, s_maxArea], 'boundary');
s_g = iblobs(s_imgThings,'area',[s_minArea, s_maxArea], 'boundary');
s_r = iblobs(s_imrThings,'area',[s_minArea, s_maxArea], 'boundary');



%display all blobs together
figure(1)
s_allBlobsIm=(s_imbThings|s_imrThings|s_imgThings);
idisp(s_allBlobsIm);


%bounding box and circularity
if (size(s_r)~=0)
    s_r.plot_box('r');
    r_circ=s_r.circularity;
end
if (size(s_g)~=0)
    s_g.plot_box('g');
    g_circ=s_g.circularity;
end
if (size(s_b)~=0)
    s_b.plot_box('b');
    b_circ=s_b.circularity;
end


%%detect shapes
figure(2)
idisp(s_im);
figure(1)

%Info array=[color,shape,size]
%color: 1=red 2=green 3=blue
%shape: 1=circle 2=square 3=triangle 4=unknown
%size: 1=small 2=big
shapesInfo=[0,0,0];
n=0;



%find red circles
if (size(s_r)~=0)
    r_circ_logical=r_circ>=0.9;
    r_posInVec=find(r_circ_logical);
    for i=r_posInVec
        n=n+1;
        shapesInfo(n,1)=1;
        shapesInfo(n,2)=1;
        if s_r(i).area>s_circleThreshold
            shapesInfo(n,3)=2;
            s_r(i).plot('ko','LineWidth',2);
        else
            shapesInfo(n,3)=1;
            s_r(i).plot('ko');
        end
    end
end

%find green circles
if (size(s_g)~=0)
    g_circ_logical=g_circ>=0.9;
    g_posInVec=find(g_circ_logical);
    for i=g_posInVec
        n=n+1;
        shapesInfo(n,1)=2;
        shapesInfo(n,2)=1;
        if s_g(i).area>s_circleThreshold
            shapesInfo(n,3)=2;
            s_g(i).plot('ko','LineWidth',2);
        else
            shapesInfo(n,3)=1;
            s_g(i).plot('ko');
        end
    end
end

%find blue circles
if (size(s_b)~=0)
    b_circ_logical=b_circ>=0.9;
    b_posInVec=find(b_circ_logical);
    for i=b_posInVec
        n=n+1;
        shapesInfo(n,1)=3;
        shapesInfo(n,2)=1;
        if s_b(i).area>s_circleThreshold
            shapesInfo(n,3)=2;
            s_b(i).plot('ko','LineWidth',2);
        else
            shapesInfo(n,3)=1;
            s_b(i).plot('ko');
        end
    end
end



%find red squares
if (size(s_r)~=0)
    r_circ_logical=r_circ>=0.7&r_circ<0.9;
    r_posInVec=find(r_circ_logical);
    for i=r_posInVec
        n=n+1;
        shapesInfo(n,1)=1;
        shapesInfo(n,2)=2;
        if s_r(i).area>s_squareThreshold
            shapesInfo(n,3)=2;
            s_r(i).plot('ks','LineWidth',2);
        else
            shapesInfo(n,3)=1;
            s_r(i).plot('ks');
        end
    end
end

%find green squares
if (size(s_g)~=0)
    g_circ_logical=g_circ>=0.7&g_circ<0.9;
    g_posInVec=find(g_circ_logical);
    for i=g_posInVec
        n=n+1;
        shapesInfo(n,1)=2;
        shapesInfo(n,2)=2;
        if s_g(i).area>s_squareThreshold
            shapesInfo(n,3)=2;
            s_g(i).plot('ks','LineWidth',2);
        else
            shapesInfo(n,3)=1;
            s_g(i).plot('ks');
        end
    end
end

%find blue squares
if (size(s_b)~=0)
    b_circ_logical=b_circ>=0.7&b_circ<0.9;
    b_posInVec=find(b_circ_logical);
    for i=b_posInVec
        n=n+1;
        shapesInfo(n,1)=3;
        shapesInfo(n,2)=2;
        if s_b(i).area>s_squareThreshold
            shapesInfo(n,3)=2;
            s_b(i).plot('ks','LineWidth',2);
        else
            shapesInfo(n,3)=1;
            s_b(i).plot('ks');
        end
    end
end



%find red triangles
if (size(s_r)~=0)
    r_circ_logical=r_circ>=0.55&r_circ<0.7;
    r_posInVec=find(r_circ_logical);
    for i=r_posInVec
        n=n+1;
        shapesInfo(n,1)=1;
        shapesInfo(n,2)=3;
        if s_r(i).area>s_triangleThreshold
            shapesInfo(n,3)=2;
            s_r(i).plot('k^','LineWidth',2);
        else
            shapesInfo(n,3)=1;
            s_r(i).plot('k^');
        end
    end
end

%find green triangles
if (size(s_g)~=0)
    g_circ_logical=g_circ>=0.55&g_circ<0.7;
    g_posInVec=find(g_circ_logical);
    for i=g_posInVec
        n=n+1;
        shapesInfo(n,1)=2;
        shapesInfo(n,2)=3;
        if s_g(i).area>s_triangleThreshold
            shapesInfo(n,3)=2;
            s_g(i).plot('k^','LineWidth',2);
        else
            shapesInfo(n,3)=1;
            s_g(i).plot('k^');
        end
    end
end

%find blue triangles
if (size(s_b)~=0)
    b_circ_logical=b_circ>=0.55&b_circ<0.7;
    b_posInVec=find(b_circ_logical);
    for i=b_posInVec
        n=n+1;
        shapesInfo(n,1)=3;
        shapesInfo(n,2)=3;
        if s_b(i).area>s_triangleThreshold
            shapesInfo(n,3)=2;
            s_b(i).plot('k^','LineWidth',2);
        else
            shapesInfo(n,3)=1;
            s_b(i).plot('k^');
        end
    end
end


%find red unknown
if (size(s_r)~=0)
    r_circ_logical=r_circ<0.55;
    r_posInVec=find(r_circ_logical);
    for i=r_posInVec
        s_r(i).plot('k*');
        n=n+1;
        shapesInfo(n,1)=1;
        shapesInfo(n,2)=4;
    end
end

%find green unknown
if (size(s_g)~=0)
    g_circ_logical=g_circ<0.55;
    g_posInVec=find(g_circ_logical);
    for i=g_posInVec
        s_g(i).plot('k*');
        n=n+1;
        shapesInfo(n,1)=2;
        shapesInfo(n,2)=4;
    end
end

%find blue unknown
if (size(s_b)~=0)
    b_circ_logical=b_circ<0.55;
    b_posInVec=find(b_circ_logical);
    for i=b_posInVec
        s_b(i).plot('k*');
        n=n+1;
        shapesInfo(n,1)=3;
        shapesInfo(n,2)=4;
    end
end

disp(shapesInfo)