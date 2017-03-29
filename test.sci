function [mini_dist] = compare(patch_1,patch_2,patch_w,patch_h,color_format)
	mini_dist =0
    patch1_null=0
    patch2_null=0
    double(mini_dist)
	pixel_count=0
	for i=1 : patch_h
		for j=1 : patch_w
        if patch_1(i,j,1) < 10 & patch_1(i,j,2) < 10 & patch_1(i,j,3) < 10 then
            patch1_null=patch1_null+1
        end
        if patch_2(i,j,1) < 10 & patch_2(i,j,2) < 10 & patch_2(i,j,3) < 10 then            patch2_null=patch2_null+1
        end 

        //si les deux pixels contient au moin une valeur
            if ( patch_1(i,j,1) <> 0 | patch_1(i,j,2) <> 0 | patch_1(i,j,3) <> 0 ) & ( patch_2(i,j,1) <> 0 | patch_2(i,j,2) <> 0 | patch_2(i,j,3) <> 0 ) then
                    distance_euclidien=0
                    int32(distance_euclidien)
                    for k=1 : color_format
                        distance_euclidien = distance_euclidien+int32((patch_2(i,j,k) - patch_1(i,j,k)))*int32((patch_2(i,j,k) - patch_1(i,j,k))) 
                    end
                    mini_dist = mini_dist + double(sqrt(double(distance_euclidien))) 
					pixel_count = pixel_count + 1 
			end
		end
	end
     
    if pixel_count == 0 | patch1_null > patch2_null then
        mini_dist=255
    else
        mini_dist=mini_dist / pixel_count 
    end
endfunction


function [cut_pixels] = cut(pixels, x, y, patch_w, patch_h,color_format)
	for i=1:patch_h
		for j=1:patch_w
            for k=1:color_format
                cut_pixels(i,j,k)=pixels(y+i-1,x+j-1,k) 
            end
		end
	end
endfunction


function [save_pixels] = similarity(pixels,pixels_w,pixels_h,patch,patch_w,patch_h,color_format,search_facteur)
	save_pixels = []  // MAT W * H
	save_dist = 255 // MAX DISTANCE
    step_h=patch_h/search_facteur
	step_w=patch_w/search_facteur
	frontier_h = pixels_h - patch_h // limite h
	frontier_w = pixels_w - patch_w // limite w
	for i=1:step_h:frontier_h
		for j=1:step_w:frontier_w
			tmp_pixels = cut(pixels, j, i, patch_w, patch_h,color_format) 
			tmp_dist = compare(tmp_pixels,patch,patch_w,patch_h,color_format) 
			if tmp_dist < save_dist then
				save_dist = tmp_dist
				save_pixels = tmp_pixels 
			end
		end
	end				
endfunction

function [x,y,sucess]=selection(pixels,pixels_w,pixels_h,mask_color)
    sucess=1
    x=-1
    y=-1
    for i=1:pixels_h
        for j=1:pixels_w
//            if pixels (i,j,1) == 0 & pixels(i,j,2) == 0 & pixels(i,j,3) == 0 then
           if pixels (i,j,1) <= mask_color & pixels(i,j,2) <= mask_color & pixels(i,j,3) <= mask_color then           
               x=j
               y=i
               return
            end
        end
    end
    if x == -1 & y == -1 then 
        sucess=0    
    end

endfunction

function [patch_dest]=coloring(patch_source,patch_dest,x,y,patch_w,patch_h,color_format,mask_color)
    for i=1:patch_h
        for j=1:patch_w
            if patch_dest(y+i,x+j,1) <= mask_color & patch_dest(y+i,x+j,2) <= mask_color & patch_dest(y+i,x+j,3) <= mask_color then
                for k=1:color_format
                   patch_dest(y+i,x+j,k)=patch_source(i,j,k)         
                end
            end
        end
    end
endfunction


function [pixels]=masking(pixels,x,y,mask_w,mask_h,color_format)
    //masked=pixels
    for i=1:mask_h
        for j=1:mask_w
     //       if y+i < pixels_h & x+j < pixels_w   then
                for k=1:color_format
                   pixels(y+i,x+j,k)=0        
                end
  //          end
        end
    end
    
    
    
endfunction


function [pixels]=aplatir(pixels,pixels_h,pixels_w)
    //masked=pixels
    for i=1:pixels_h
        for j=1:pixels_w
               if ( pixels(i,j,1) <> 0 | pixels(i,j,2) <> 0 | pixels(i,j,3) <> 0 ) & ( pixels (i,j,1) < 10 & pixels(i,j,2) < 10 & pixels(i,j,3) < 10) then                     pixels(i,j,1)=0        
                   pixels(i,j,2)=0        
                   pixels(i,j,3)=0        
                end
        end
    end
    
    
    
endfunction
function test1()
img=imread("/home/hbxxx/Downloads/lena.png") 
patch_w=5 
patch_h=5 
patch_1=cut(img, 250, 250,patch_w,patch_h) 
patch_2=cut(img, 1, 1,patch_w,patch_h) 
patch_3=cut(img, 200, 200,patch_w,patch_h) 
x=compare(patch_1,patch_2,patch_w,patch_h) 
y=compare(patch_1,patch_3,patch_w,patch_h) 
printf('Result %f %f',x,y)        
endfunction

function test2()
pixels=imread("/home/hbxxx/Downloads/pivert-jmp2.jpg") 
[pixels_h,pixels_w,color_format]=size(pixels) 
patch_w=5 
patch_h=5 
patch_1=cut(pixels, 100, 100,patch_w,patch_h) 
matched=similarity(pixels,100,100,patch_1,patch_w,patch_h,color_format,1)
imshow([patch_1,matched]) 
endfunction


function test3()
pixels=imread("/home/hbxxx/Downloads/pivert-jmp3.jpg") 
[pixels_h,pixels_w,color_format]=size(pixels) 
[x,y,z]=selection(pixels,pixels_w,pixels_h)
printf('Result %d %d %d',x,y,z)        
patch_w=10 
patch_h=10 
patch_1=cut(pixels, x-patch_w, y-patch_h/3,patch_w,patch_h) 
matched=similarity(pixels,100,100,patch_1,patch_w,patch_h,color_format,1)
imshow([patch_1,matched]) 
patch_1=cut(pixels, 1,1 ,patch_w,patch_h) 
matched=similarity(pixels,100,100,patch_1,patch_w,patch_h,color_format,1)
imshow([patch_1,matched]) 
patch_1=cut(pixels, 50,50 ,patch_w,patch_h) 
matched=similarity(pixels,100,100,patch_1,patch_w,patch_h,color_format,1)
imshow([patch_1,matched]) 

endfunction

function test4()
pixels=imread("/home/hbxxx/Downloads/pivert-jmp5.jpg") 
[pixels_h,pixels_w,color_format]=size(pixels) 
printf('Result %d %d %d',x,y,z)        
patch_w=15 
patch_h=15
stop=1
while stop <> 0
[x,y,z]=selection(pixels,pixels_w,pixels_h,10)
stop=z
//printf('Result %d %d %d',x,y,z)        
patch_1=cut(pixels, x-patch_w/2, y-patch_h/2,patch_w,patch_h) 
matched=similarity(pixels,100,100,patch_1,patch_w,patch_h,color_format,1)
pixels=coloring(matched,pixels,x-patch_w/2, y-patch_h/2,patch_w,patch_h,color_format,10);
//imshow([patch_1,matched]) 
imshow(pixels)
end


endfunction

function test5()
pixels=imread("/home/hbxxx/Downloads/pivert-jmp2.jpg") 
[pixels_h,pixels_w,color_format]=size(pixels) 
masked=masking(pixels,30,30,20,20,color_format)
imshow(masked) 

endfunction

function test6()
pixels=imread("/home/hbxxx/Downloads/pivert-jmp3.jpg") 
[pixels_h,pixels_w,color_format]=size(pixels) 
masked=aplatir(pixels,pixels_h,pixels_w)
imshow(masked) 
imwrite(masked,"/home/hbxxx/Downloads/pivert-jmp4.jpg") 

endfunction



function test7()
//  rectangle selection
clf();  // erase/create window
a=gca();a.data_bounds=[0 0;100 100];//set user coordinates
xtitle(" drawing a rectangle ") //add a title

show_window(); //put the window on the top


[b,xc,yc]=xclick(); //get a point
xrect(xc,yc,0,0) //draw a rectangle entity
r=gce();// the handle of the rectangle
rep=[xc,yc,-1];first=%f;



while rep(3)==-1 do // mouse just moving ...
  rep=xgetmouse();
  xc1=rep(1);yc1=rep(2);
  ox=min(xc,xc1);
  oy=max(yc,yc1);
  w=abs(xc-xc1);h=abs(yc-yc1);
  r.data=[ox,oy,w,h]; //change the rectangle origin, width a height
  first=%f;
end
endfunction
