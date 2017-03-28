function [distance] = distance_euclidien(pixel_1,pixel_2)
	distance=0.0
	for color=1:3
		distance+=(pixel_2(color)-pixel_1(color))*(pixel_2(color)-pixel_1(color));
	end
	sqrt(distance);
endfunction


function [mini_dist] = compare(patch_1,patch_2,patch_w,patch_h)
	mini_dist=0.0
	pixel_count=0 
	for i=1 : patch_h
		for j=1 : patch_w
        	//si les deux pixels contient au moin une valeur
			if ( patch_1(i,j,1) <> 0 | patch_1(i,j,2) <> 0 | patch_1(i,j,3) <> 0 ) &
			   ( patch_2(i,j,1) <> 0 | patch_2(i,j,2) <> 0 | patch_2(i,j,3) <> 0 ) then
		    		mini_dist += distance_euclidien(patch_1(i,j),patch_2(i,j));
					pixel_count += 1;
			end
		end
	end
	mini_dist/=pixel_count; 
endfunction


function [cut_pixels] cut(pixels, x, y, patch_w, patch_h)
	for i=1:patch_h
		for j=1:patch_w
			cut_pixels(i,j)=pixels(y+i-1,x+j-1);
		end
	end
endfunction


function [save_pixels] = similarity(pixels,pixels_w,pixels_h,patch,patch_w,patch_h)
	save_pixels = []; // MAT W * H
	save_dist = 256 // MAX DISTANCE
	frontier_h = pixels_h - patch_h;// limite h
	frontier_w = pixels_w - patch_w;// limite w
	for i=1:frontier_h
		for j=1:frontier_w
			tmp_pixels = cut(pixels, j, i, patch_w, patch_h);
			tmp_dist = compare(tmp_pixels,patch,patch_w,patch_h);
			if tmp_dist < save_dist then
				save_dist = tmp_dist;	
				save_pixels = tmp_pixels;
			end
		end
	end				
endfunction




