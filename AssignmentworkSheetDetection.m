%%identify the three shapes we need to find later on the work sheet

%original image size 3968x2240
%picture taken from test sheet so that paper just covers whole image

[s_unscaled,s_data]= iread('smallimage2.jpg');
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








%-----------------------------------------------------------
%% identify the shapes on the worksheet



%original image size 3968x2240
%picture taken so that paper touches the edges of the image

[imunscaled,data]= iread('339test4.png');
%gamma=data.Gamma;
%if (data.Gamma <= 0)
 %   gamma = 2.5; 
%else
 %   gamma = data.Gamma; %Set the value used for gamma correction
%end
gamma=1;

scaleFactor=0.3;
resolutionScaled=data.Height*data.Width*scaleFactor^2;
%minimum blob area covers 0.1%, maximum 5% of test sheet image
minArea=resolutionScaled*0.001;
maxArea=resolutionScaled*0.05;

%rescale
im=imresize(imunscaled,scaleFactor);

imRed=im(:,:,1);
imGreen=im(:,:,2);
imBlue=im(:,:,3);

%normalize
imRedNormal=double(imRed)/255;
imGreenNormal=double(imGreen)/255;
imBlueNormal=double(imBlue)/255;

%gamma correction
imB=imBlueNormal.^gamma;
imG=imGreenNormal.^gamma;
imR=imRedNormal.^gamma;

%clalculate chromaticity
imb=imB./(imR+imG+imB);
imr=imR./(imR+imG+imB);
img=imG./(imR+imG+imB);

%threshold
imbThings=imb>0.4;
imrThings=imr>0.5;
imgThings=img>0.5;

%Morphology Closing
imrThings=iclose(imrThings,ones(7,7));
imgThings=iclose(imgThings,ones(7,7));
imbThings=iclose(imbThings,ones(7,7));



%blue blobs
b = iblobs(imbThings,'area',[minArea,maxArea], 'boundary');

%find biggest blue dot and average of the small ones
bigDot=max(b.area);
smallDot=(sum(b.area)-bigDot)/(numel(b)-1);
%circle threshold is used for the others but they have less area (97%, 60%)
circleThreshold=(bigDot+smallDot)/2;
squareThreshold=circleThreshold*0.9696;
triangleThreshold=circleThreshold*0.5950;

%% image cropping

%Set all the variables to first object size as a reference 
top_left = [b(1).umin, b(1).vc];
top_right = [b(1).umax, b(1).vc];
bottom_left = [b(1).umin, b(1).vc];
bottom_right = [b(1).umax, b(1).vc];

%Find boundry cords of the blue circles 
for i=1:length(b)
    searcherumin = b(i).umin;
    searchervmin = b(i).vmin;
    searcherumax = b(i).umax;
    searchervmax = b(i).vmax;
    
    %Find top_left cords (x,y) = (smallest, smallest)
    if searcherumin < top_left(1)
        top_left(1) = searcherumin;
    end    
    if searchervmin < top_left(2)
        top_left(2) = searchervmin;
    end
    
    %Find top_right cords (x,y) = (largest, smallest)
    if searcherumax > top_right(1)
        top_right(1) = searcherumax;
    end    
    if searchervmin < top_right(2)
        top_right(2) = searchervmin;
    end  
    
    %Find bottom_left cords (x,y) = (smallest, largest)
    if searcherumin < bottom_left(1)
        bottom_left(1) = searcherumin;
    end
    if searchervmax > bottom_left(2)
        bottom_left(2) = searchervmax;
    end
    
    %Find bottom_right cords (x,y) = (largest, largest)
    if searcherumax > bottom_right(1)
        bottom_right(1) = searcherumax;
    end   
    if searchervmax > bottom_right(2)
        bottom_right(2) = searchervmax;
    end    
end

%Crop image around blue circles
Isize = size(imbThings);
crop = poly2mask([top_left(1), top_right(1), bottom_right(1), bottom_left(1)],[top_left(2), top_right(2), bottom_right(2), bottom_left(2)],Isize(1,1),Isize(1,2));
b_crop = bsxfun(@times,imbThings,cast(crop,class(imbThings)));
r_crop = bsxfun(@times,imrThings,cast(crop,class(imrThings)));
g_crop = bsxfun(@times,imgThings,cast(crop,class(imgThings)));

%Sort Blobs, Shows what each blob is GREEN, RED 
g = iblobs(g_crop,'area',[minArea,maxArea], 'boundary');
r = iblobs(r_crop,'area',[minArea,maxArea], 'boundary');

%{
%Plot Bounding Box for blobs and centroid, in original image
idisp(b_crop);
b.plot_box('g');
b.plot('r*');

%Plot Bounding Box for blobs and centroid, in original image
figure(2);
idisp(g_crop);
g.plot_box('g');
g.plot('r*');

%Plot Bounding Box for blobs and centroid, in original image
figure(3);
idisp(r_crop);
r.plot_box('g');
r.plot('r*');
%}

%% my blob detection


%display
%{
figure(1);
%Blue Blobs
imshow(imbThings);
bB.plot_box('g');
bB.plot('r*');

figure(2);
%Green Blobs
imshow(imgThings);
bG.plot_box('g');
bG.plot('r*');

figure(3);
%Red Blobs
imshow(imrThings);
bR.plot_box('g');
bR.plot('r*');
%}

figure(4)
idisp(im);

figure(3)
allBlobsIm=(b_crop|r_crop|g_crop);
idisp(allBlobsIm);
b.plot_box('b');
g.plot_box('g');
r.plot_box('r');

%% detect shapes

%color: 1=red 2=green 3=blue
%shape: 1=circle 2=square 3=triangle 4=unknown
%size: 1=small 2=big
blobsInfo=[0,0,0,0,0,0,0];
n=0;



%{
%detect circles
figure(3)
i=1;
for x=[r,g,b]
    if (size(x)~=0)
        x_circ=x.circularity;
        x_circ_logical=x_circ>=0.9;
        x_posInVec=find(x_circ_logical);
        for j=x_posInVec
            x(j).plot('ko');
            n=n+1;
            blobsInfo(n,1)=i;
            blobsInfo(n,2)=1;
        end
    end
    i=i+1;
end

%detect squares
i=1;
for x=[r,g,b]
    if (size(x)~=0)
        x_circ=x.circularity;
        x_circ_logical=x_circ>=0.7&x_circ<0.9;
        x_posInVec=find(x_circ_logical);
        for i=x_posInVec
            x(i).plot('ks');
            n=n+1;
            blobsInfo(n,1)=i;
            blobsInfo(n,2)=2;
        end
    end
    i=i+1;
end

%detect triangles
i=1;
for x=[r,g,b]
    if (size(x)~=0)
        x_circ=x.circularity;
        x_circ_logical=x_circ>=0.55&x_circ<0.7;
        x_posInVec=find(x_circ_logical);
        for i=x_posInVec
            x(i).plot('k^');
            n=n+1;
            blobsInfo(n,1)=i;
            blobsInfo(n,2)=3;
        end
    end
    i=i+1;
end

%rest is unknown
i=1;
for x=[r,g,b]
    if (size(x)~=0)
        x_circ=x.circularity;
        x_circ_logical=x_circ<0.55;
        x_posInVec=find(x_circ_logical);
        for i=x_posInVec
            x(i).plot('r*');
            n=n+1;
            blobsInfo(n,1)=i;
            blobsInfo(n,2)=4;
        end
    end
    i=i+1;
end
%}


%{
%detect circles
figure(3)
for x=[r,g,b]
    x_circ=x.circularity;
    x_circ_logical=x_circ>=0.9;
    x_posInVec=find(x_circ_logical);
    for i=x_posInVec
        x(i).plot('ko');
    end
end

%detect squares
for x=[r,g,b]
    x_circ=x.circularity;
    x_circ_logical=x_circ>=0.7&x_circ<0.9;
    x_posInVec=find(x_circ_logical);
    for i=x_posInVec
        x(i).plot('ks');
    end
end

%detect triangles
for x=[r,g,b]
    x_circ=x.circularity;
    x_circ_logical=x_circ>=0.55&x_circ<0.7;
    x_posInVec=find(x_circ_logical);
    for i=x_posInVec
        x(i).plot('k^');
    end
end

%rest is unknown
for x=[r,g,b]
    x_circ=x.circularity;
    x_circ_logical=x_circ<0.55;
    x_posInVec=find(x_circ_logical);
    for i=x_posInVec
        x(i).plot('r*');
    end
end
%}



%cicularity
r_circ=r.circularity;
g_circ=g.circularity;
b_circ=b.circularity;


%find red circles
r_circ_logical=r_circ>=0.9;
r_posInVec=find(r_circ_logical);
for i=r_posInVec
    n=n+1;
    blobsInfo(n,1)=1;
    blobsInfo(n,2)=1;
    blobsInfo(n,4)=r(i).label;
    blobsInfo(n,5)=i;
    if r(i).area>circleThreshold
        blobsInfo(n,3)=2;
        r(i).plot('ko','LineWidth',2);
    else
        blobsInfo(n,3)=1;
        r(i).plot('ko');
    end
end

%find green circles
g_circ_logical=g_circ>=0.9;
g_posInVec=find(g_circ_logical);
for i=g_posInVec
    n=n+1;
    blobsInfo(n,1)=2;
    blobsInfo(n,2)=1;
    blobsInfo(n,4)=g(i).label;
    blobsInfo(n,5)=i;
    if g(i).area>circleThreshold
        blobsInfo(n,3)=2;
        g(i).plot('ko','LineWidth',2);
    else
        blobsInfo(n,3)=1;
        g(i).plot('ko');
    end
end

%find blue circles
b_circ_logical=b_circ>=0.9;
b_posInVec=find(b_circ_logical);
for i=b_posInVec
    n=n+1;
    blobsInfo(n,1)=3;
    blobsInfo(n,2)=1;
    blobsInfo(n,4)=b(i).label;
    blobsInfo(n,5)=i;
    if b(i).area>circleThreshold
        blobsInfo(n,3)=2;
        b(i).plot('ko','LineWidth',2);
    else
        blobsInfo(n,3)=1;
        b(i).plot('ko');
    end
end



%find red squares
r_circ_logical=r_circ>=0.7&r_circ<0.9;
r_posInVec=find(r_circ_logical);
for i=r_posInVec
    n=n+1;
    blobsInfo(n,1)=1;
    blobsInfo(n,2)=2;
    blobsInfo(n,4)=r(i).label;
    blobsInfo(n,5)=i;
    if r(i).area>squareThreshold
        blobsInfo(n,3)=2;
        r(i).plot('ks','LineWidth',2);
    else
        blobsInfo(n,3)=1;
        r(i).plot('ks');
    end
end

%find green squares
g_circ_logical=g_circ>=0.7&g_circ<0.9;
g_posInVec=find(g_circ_logical);
for i=g_posInVec
    n=n+1;
    blobsInfo(n,1)=2;
    blobsInfo(n,2)=2;
    blobsInfo(n,4)=g(i).label;
    blobsInfo(n,5)=i;
    if g(i).area>squareThreshold
        blobsInfo(n,3)=2;
        g(i).plot('ks','LineWidth',2);
    else
        blobsInfo(n,3)=1;
        g(i).plot('ks');
    end
end

%find blue squares
b_circ_logical=b_circ>=0.7&b_circ<0.9;
b_posInVec=find(b_circ_logical);
for i=b_posInVec
    n=n+1;
    blobsInfo(n,1)=3;
    blobsInfo(n,2)=2;
    blobsInfo(n,4)=b(i).label;
    blobsInfo(n,5)=i;
    if b(i).area>squareThreshold
        blobsInfo(n,3)=2;
        b(i).plot('ks','LineWidth',2);
    else
        blobsInfo(n,3)=1;
        b(i).plot('ks');
    end
end



%find red triangles
r_circ_logical=r_circ>=0.55&r_circ<0.7;
r_posInVec=find(r_circ_logical);
for i=r_posInVec
    n=n+1;
    blobsInfo(n,1)=1;
    blobsInfo(n,2)=3;
    blobsInfo(n,4)=r(i).label;
    blobsInfo(n,5)=i;
    if r(i).area>triangleThreshold
        blobsInfo(n,3)=2;
        r(i).plot('k^','LineWidth',2);
    else
        blobsInfo(n,3)=1;
        r(i).plot('k^');
    end
end

%find green triangles
g_circ_logical=g_circ>=0.55&g_circ<0.7;
g_posInVec=find(g_circ_logical);
for i=g_posInVec
    n=n+1;
    blobsInfo(n,1)=2;
    blobsInfo(n,2)=3;
    blobsInfo(n,4)=g(i).label;
    blobsInfo(n,5)=i;
    if g(i).area>triangleThreshold
        blobsInfo(n,3)=2;
        g(i).plot('k^','LineWidth',2);
    else
        blobsInfo(n,3)=1;
        g(i).plot('k^');
    end
end

%find blue triangles
b_circ_logical=b_circ>=0.55&b_circ<0.7;
b_posInVec=find(b_circ_logical);
for i=b_posInVec
    n=n+1;
    blobsInfo(n,1)=3;
    blobsInfo(n,2)=3;
    blobsInfo(n,4)=b(i).label;
    blobsInfo(n,5)=i;
    if b(i).area>triangleThreshold
        blobsInfo(n,3)=2;
        b(i).plot('k^','LineWidth',2);
    else
        blobsInfo(n,3)=1;
        b(i).plot('k^');
    end
end


%find red unknown
r_circ_logical=r_circ<0.55;
r_posInVec=find(r_circ_logical);
for i=r_posInVec
    r(i).plot('k*');
    n=n+1;
    blobsInfo(n,1)=1;
    blobsInfo(n,2)=4;
    blobsInfo(n,4)=r(i).label;
    blobsInfo(n,5)=i;
end

%find green unknown
g_circ_logical=g_circ<0.55;
g_posInVec=find(g_circ_logical);
for i=g_posInVec
    g(i).plot('k*');
    n=n+1;
    blobsInfo(n,1)=2;
    blobsInfo(n,2)=4;
    blobsInfo(n,4)=g(i).label;
    blobsInfo(n,5)=i;
end

%find blue unknown
b_circ_logical=b_circ<0.55;
b_posInVec=find(b_circ_logical);
for i=b_posInVec
    b(i).plot('k*');
    n=n+1;
    blobsInfo(n,1)=3;
    blobsInfo(n,2)=4;
    blobsInfo(n,4)=b(i).label;
    blobsInfo(n,5)=i;
end




%HOMOGRAPHY

%Real world locations in mm
Q = [20 380; 200 380; 380 380; 20 200; 200 200; 200 20; 20 20; 380 200; 380 20];

for i=1:length(b)
   Pb(1,i) = b(i).uc;
   Pb(2,i) = b(i).vc;
end


%Transpose the blue dot array, then sort y locations ascending
smallesttolargest = sortrows(Pb',2);

%Store in top 3 array
for i=1:3
   Pb1(i,1) = smallesttolargest(i,1);
   Pb1(i,2) = smallesttolargest(i,2);
end
%Store top 3, x locations ascending
Pb1_sortted = sortrows(Pb1,1);

%Store in second 3 array
for i=1:3
   Pb2(i,1) = smallesttolargest(i+3,1);
   Pb2(i,2) = smallesttolargest(i+3,2);
end
%Store second 3, x locations ascending
Pb2_sortted = sortrows(Pb2,1);

%Store in thrid 3 array
for i=1:3
   Pb3(i,1) = smallesttolargest(i+6,1);
   Pb3(i,2) = smallesttolargest(i+6,2);
end
%Store third 3, x locations ascending
Pb3_sortted = sortrows(Pb3,1);

%Transponse back to original 
Pb_final = [Pb1_sortted', Pb2_sortted', Pb3_sortted'];

%Find homography array 
H = homography(Pb_final, Q');

 %Find real-world coordinates of red shapes
for i=1:length(r)
   pr = [r(i).uc r(i).vc];
   qr = homtrans(H,pr');
   for j=1:n
       
       if blobsInfo(j,1) == 1 && blobsInfo(j,5) == i
           blobsInfo(j, 6) = int64(qr(1));
           blobsInfo(j, 7) = int64(qr(2));
       end
   end
   fprintf('Red shape ID %d is at %dmm %dmm\n', i, qr(1), qr(2));
end

 %Find real-world coordinates of green shapes
for i=1:length(g)
   pg = [g(i).uc g(i).vc];
   qg = homtrans(H,pg');
   for j=1:n
       
       if blobsInfo(j,1) == 2 && blobsInfo(j,5) == i
           blobsInfo(j, 6) = int64(qg(1));
           blobsInfo(j, 7) = int64(qg(2));
       end
   end
   
   
   fprintf('Green shape ID %d is at %dmm %dmm\n', i, qg(1), qg(2));
end

disp(blobsInfo)


%% matching

labelr=ilabel(r_crop);
labelg=ilabel(g_crop);

%the array colorAndPos stores the infos of the matching blobs to draw 
%the boxes later when we created the image with only these blobs

for i=1:3
    for j=1:n
        if shapesInfo(i,1)==blobsInfo(j,1)&&shapesInfo(i,2)==blobsInfo(j,2)&&shapesInfo(i,3)==blobsInfo(j,3)
            if shapesInfo(i,1)==1
                colorAndPos(i,1)=1;
                colorAndPos(i,2)=blobsInfo(j,5);
                label(:,:,i)=(labelr==blobsInfo(j,4));
            end
            if shapesInfo(i,1)==2
                colorAndPos(i,1)=2;
                colorAndPos(i,2)=blobsInfo(j,5);
                label(:,:,i)=(labelg==blobsInfo(j,4));
            end
        end
    end
end
        
labelAll=label(:,:,1)|label(:,:,2)|label(:,:,3);
figure(5)
idisp(labelAll);

%draw boxes and centroids
for i=1:3
    if colorAndPos(i,1)==1
        r(colorAndPos(i,2)).plot_box('y');
        r(colorAndPos(i,2)).plot('y*');
    end
    if colorAndPos(i,1)==2
        g(colorAndPos(i,2)).plot_box('y');
        g(colorAndPos(i,2)).plot('y*');
    end
end