function [mini_dist] = compare(patch_1,patch_2,patch_w,patch_h,color_format)
	mini_dist =0
    double(mini_dist)
	pixel_count=0
	for i=1 : patch_h
		for j=1 : patch_w
        //si les deux pixels contient au moin une valeur
			if ( patch_1(i,j,1) <> 0 | patch_1(i,j,2) <> 0 | patch_1(i,j,3) <> 0 ) & ( patch_2(i,j,1) <> 0 | patch_2(i,j,2) <> 0 | patch_2(i,j,3) <> 0 ) then
                    distance_euclidien=0
                    int32(distance_euclidien)
                    for col=1 : color_format
                        distance_euclidien = distance_euclidien+int32((patch_2(i,j,col) - patch_1(i,j,col)))*int32((patch_2(i,j,col) - patch_1(i,j,col))) 
                    end
                    mini_dist = mini_dist + double(sqrt(double(distance_euclidien))) 
					pixel_count = pixel_count + 1 
			end
		end
	end
	mini_dist=mini_dist / pixel_count  
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
	save_dist = 256 // MAX DISTANCE
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
pixels=imread("/home/hbxxx/Downloads/lena.png") 
[pixels_h,pixels_w,color_format]=size(pixels) 
patch_w=10 
patch_h=10 
patch_1=cut(pixels, 100, 100,patch_w,patch_h) 
imshow([patch_1,similarity(pixels,100,100,patch_1,patch_w,patch_h,color_format,1)]) 
endfunction
