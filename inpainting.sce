function [mini_dist] = compare(patch_1,patch_2,patch_w,patch_h,color_format)
	mini_dist =0
    patch1_null=0
    patch2_null=0
    double(mini_dist)
	pixel_count=0
	for i=1 : patch_h
		for j=1 : patch_w
        if patch_1(i,j,1) == 0 & patch_1(i,j,2) == 0 & patch_1(i,j,3) == 0 then
                   patch1_null=patch1_null+1
        end
        if patch_2(i,j,1) == 0 & patch_2(i,j,2) == 0 & patch_2(i,j,3) == 0 then            patch2_null=patch2_null+1
        end 

        //si les deux pixels contient au moin une valeur
            if ( patch_1(i,j,1) <> 0 | patch_1(i,j,2) <> 0 | patch_1(i,j,3) <> 0 ) & ( patch_2(i,j,1) <> 0 | patch_2(i,j,2) <> 0 | patch_2(i,j,3) <> 0 ) then
                    distance_euclidien=0
                    int32(distance_euclidien)
                    for k=1 : color_format
                        distance_euclidien = distance_euclidien + int32((patch_2(i,j,k) - patch_1(i,j,k)))*int32((patch_2(i,j,k) - patch_1(i,j,k))) 
                    end
                    mini_dist = mini_dist + double(sqrt(double(distance_euclidien))) 
					pixel_count = pixel_count + 1 
			end
		end
	end
     
    if pixel_count == 0 |  patch1_null > 0 then
        mini_dist=255
    else
        mini_dist = (mini_dist / pixel_count) * (patch1_null/(patch_h*patch_h))
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


function [save_pixels] = similarity2(pixels,pixels_w,pixels_h,zone_size,contour_x,contour_y,patch,patch_w,patch_h,color_format,search_facteur)
	save_pixels = []  // MAT W * H
	save_dist = 255 // MAX DISTANCE
    step_h=patch_h/search_facteur
	step_w=patch_w/search_facteur
	frontier_h = contour_y + zone_size // limite h
	frontier_w = contour_x + zone_size // limite w
	debut_x = contour_x - zone_size
	debut_y = contour_y - zone_size
	if debut_x < 1 then
	  	debut_x = 1
	end
	if debut_y < 1 then
	  	debut_y = 1
	end
	if frontier_w > pixels_w then
	  frontier_w = pixels_w
	end
	if frontier_h > pixels_h then
	  frontier_h = pixels_h
	end
	frontier_h = frontier_h - patch_h
	frontier_w = frontier_w - patch_w

	for i=debut_y:step_h:frontier_h
		for j=debut_x:step_w:frontier_w
            
//            printf('Result %d %d %d %d',j,i,frontier_w,frontier_h)        
			tmp_pixels = cut(pixels, j, i, patch_w, patch_h,color_format) 
		    tmp_dist = compare(tmp_pixels,patch,patch_w,patch_h,color_format) 
			if tmp_dist < save_dist then
				save_dist = tmp_dist
				save_pixels = tmp_pixels 
			end
		end
	end				
endfunction


function [x,y,sucess]=selection(pixels,pixels_w,pixels_h,patch_w,patch_h,mask_color)
    sucess=1
    x=-1
    y=-1
    
    for i=1:pixels_h
        for j=1:pixels_w
            if pixels (i,j,1) < mask_color & pixels(i,j,2) < mask_color & pixels(i,j,3) < mask_color then
               x=j-patch_w/2
               y=i-patch_h/2
               return
            end
        end
    end
    if x == -1 & y == -1 then 
        sucess=0    
    end

endfunction

function [x,y,sucess]=selection2(pixels,pixels_w,pixels_h,patch_w,patch_h,mask_color)
    sucess=1
    x=-1
    y=-1
    for i=pixels_h:-1:1
        for j=pixels_w:-1:1
            if pixels (i,j,1) < mask_color & pixels(i,j,2) < mask_color & pixels(i,j,3) < mask_color then
               x=j+patch_w/2
               y=i+patch_h/2
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
            if patch_dest(y+i,x+j,1) < mask_color & patch_dest(y+i,x+j,2) < mask_color & patch_dest(y+i,x+j,3) < mask_color then
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
    


function show_patch(path, patch, zone,facteur, mask_x, mask_y, mask_w, mask_h)
pixels=imread(path) 
[pixels_h,pixels_w,color_format]=size(pixels) 
patch_w=patch
patch_h=patch
stop=1
while stop <> 0
//randomNumber=uint8(modulo(rand(1)*100,2))
//printf('Random  %d',randomNumber)
[x,y,z]=selection(pixels,pixels_w,pixels_h,patch_w,patch_h,12)
stop=z
if z == 0 then
    break
end    
patch_1=cut(pixels, x, y,patch_w,patch_h) 

matched=similarity2(pixels,pixels_w,pixels_h, zone, x, y,patch_1,patch_w,patch_h,color_format,facteur)
pixels=coloring(matched,pixels,x, y,patch_w,patch_h,color_format,12);
patch_after=cut(pixels, x, y,patch_w,patch_h) 
imshow([patch_1,matched,patch_after]) 
end
endfunction




function repaint(path,save_path, patch, zone,facteur, mask_x, mask_y, mask_w, mask_h)
pixels=imread(path) 
[pixels_h,pixels_w,color_format]=size(pixels) 
patch_w=patch
patch_h=patch
stop=1
while stop <> 0
//randomNumber=uint8(modulo(rand(1)*100,2))
//printf('Random  %d',randomNumber)
[x,y,z]=selection(pixels,pixels_w,pixels_h,patch_w,patch_h,12)
stop=z
//printf('Result %d %d %d',x,y,z)
if z == 0 then
    break
end    
patch_1=cut(pixels, x, y,patch_w,patch_h) 

matched=similarity2(pixels,pixels_w,pixels_h, zone, x, y,patch_1,patch_w,patch_h,color_format,facteur)
pixels=coloring(matched,pixels,x, y,patch_w,patch_h,color_format,12);
imshow(pixels)
end

imwrite(pixels,save_path) 
endfunction
function remplisage(path, mask_x, mask_y, mask_w, mask_h)
pixels=imread(path) 
[pixels_h,pixels_w,color_format]=size(pixels) 
pixels_mask=masking(pixels,mask_x,mask_y,mask_w,mask_h,color_format)
imshow([pixels,pixels_mask])
imwrite(pixels_mask,"/home/hbxxx/Downloads/pivert-jmp_mask.jpg") 
endfunction
function []=fenetre_graphique(h)
    X=25
    Y=-35
    L=60
    titre = uicontrol(h, "style", "text", ...
        "string", " Projet : Inpainting", ...
        "fontweight", "bold", ...
        "fontsize", 20, ...
        "position", [50+X 420+Y 400+L 40]);
    intro = uicontrol(h, "style", "text", ...
        "string", " Auteur : Hobean BAE", ...
        "fontsize", 14, ...
        "position", [50+X 390+Y 400+L 30]);
    intro2 = uicontrol(h, "style", "text", ...
        "string", " Masking : Remplir le zone à supprimer par le pixel vide", ...
        "fontsize", 14, ...
        "position", [50+X 360+Y 400+L 30]);
    intro3 = uicontrol(h, "style", "text", ...
        "string", " Repainting : Reconstuire des pixels vides", ...
        "fontsize", 14, ...
        "position", [50+X 330+Y 400+L 30]);
    intro2 = uicontrol(h, "style", "text", ...
        "string", " Debuging : Montrer le zone de reconstruction", ...
        "fontsize", 14, ...
        "position", [50+X 300+Y 400+L 30]);
    // consignes
    texte_b1 = uicontrol(h, "style", "text", ...
        "string", " Img path : ", ...
        "fontsize", 14, ...
        "position", [50+X 120+Y 400+L 30]);
    N1 = uicontrol(h, "style", "edit", ...
        "string", "./pivert-jmp_mask.jpg",...
        "fontsize", 14, ...
        "position", [130+X 120+Y 320 30]);
    texte_b5 = uicontrol(h, "style", "text", ...
        "string", " Result path : ", ...
        "fontsize", 14, ...
        "position", [50+X 90+Y 400+L 30]);
    N9 = uicontrol(h, "style", "edit", ...
        "string",   "./result.jpg",...
        "fontsize", 14, ...
        "position", [150+X 90+Y 320 30]);
    param = uicontrol(h, "style", "text", ...
        "string", " Parametres ", ...
        "fontweight", "bold", ...
        "fontsize", 14, ...
        "position", [50+X 270+Y 400+L 30])
    texte_b2 = uicontrol(h, "style", "text", ...
        "string", " Patch size :", ...
        "fontsize", 14, ...
        "position", [50+X 240+Y 400+L 30]);
    N2 = uicontrol(h, "style", "edit", ...
        "string", "10", ...
        "fontsize", 14, ...
        "position", [140+X 240+Y 40 30]);
    texte_b3 = uicontrol(h, "style", "text", ...
        "string", " Zone recherche :", ...
        "fontsize", 14, ...
        "position", [50+X 210+Y 400+L 30]);
    N3 = uicontrol(h, "style", "edit", ...
        "string", "30", ...
        "fontsize", 14, ...
        "position", [170+X 210+Y 40 30]);
    texte_b4 = uicontrol(h, "style", "text", ...
        "string", " Mask zone :   X              Y              W             H", ...
        "fontsize", 14, ...
        "position", [50+X 150+Y 400+L 30]);
    N4 = uicontrol(h, "style", "edit", ...
        "string", "230", ...
        "fontsize", 14, ...
        "position", [160+X 150+Y 40 30]);
    N5 = uicontrol(h, "style", "edit", ...
        "string", "60", ...
        "fontsize", 14, ...
        "position", [225+X 150+Y 40 30]);
    N6 = uicontrol(h, "style", "edit", ...
        "string", "30", ...
        "fontsize", 14, ...
        "position", [295+X 150+Y 40 30]);
    N7 = uicontrol(h, "style", "edit", ...
        "string", "30", ...
        "fontsize", 14, ...
        "position", [360+X 150+Y 40 30]);
    texte_b3 = uicontrol(h, "style", "text", ...
        "string", " Facteur recherche :", ...
        "fontsize", 14, ...
        "position", [50+X 180+Y 400+L 30]);
    N8 = uicontrol(h, "style", "edit", ...
        "string", "1", ...
        "fontsize", 14, ...
        "position", [190+X 180+Y 40 30]);
    bouton = uicontrol(h, "string", "Repainting",...
        "position", [130+X 60+Y 80 30], ...
        "userdata", [N1, N2, N3, N4, N5, N6, N7, N8, N9], ...
        "callback", "path = gcbo.userdata(1).string;"+ ...
                    "save = gcbo.userdata(9).string;"+ ...
                    "patch = eval(gcbo.userdata(2).string);" + ...
                    "zone = eval(gcbo.userdata(3).string);"+ ...
                    "X = eval(gcbo.userdata(4).string);" + ...
                    "Y = eval(gcbo.userdata(5).string);"+ ...
                    "W = eval(gcbo.userdata(6).string);" + ...
                    "H = eval(gcbo.userdata(7).string);"+ ...
                    "facteur = eval(gcbo.userdata(8).string);" + ...
                    "repaint(path,save,patch, zone,facteur,X,Y,W,H);");
   bouton2 = uicontrol(h, "string", "Masking",...
        "position", [50+X 60+Y 80 30], ...
        "userdata", [N1, N2, N3, N4, N5, N6, N7], ...
        "callback", "path = gcbo.userdata(1).string;"+ ...
                    "patch = eval(gcbo.userdata(2).string);" + ...
                    "zone = eval(gcbo.userdata(3).string);"+ ...
                    "X = eval(gcbo.userdata(4).string);" + ...
                    "Y = eval(gcbo.userdata(5).string);"+ ...
                    "W = eval(gcbo.userdata(6).string);" + ...
                    "H = eval(gcbo.userdata(7).string);"+ ...
                    "remplisage(path,X,Y,W,H);");
  
    bouton3 = uicontrol(h, "string", "Debuging",...
        "position", [210+X 60+Y 80 30], ...
        "userdata", [N1, N2, N3, N4, N5, N6, N7,N8], ...
        "callback", "path = gcbo.userdata(1).string;"+ ...
                    "patch = eval(gcbo.userdata(2).string);" + ...
                    "zone = eval(gcbo.userdata(3).string);"+ ...
                    "X = eval(gcbo.userdata(4).string);" + ...
                    "Y = eval(gcbo.userdata(5).string);"+ ...
                    "W = eval(gcbo.userdata(6).string);" + ...
                    "H = eval(gcbo.userdata(7).string);"+ ...
                    "facteur = eval(gcbo.userdata(8).string);" + ...
                    "show_patch(path,patch, zone,facteur,X,Y,W,H);");
endfunction

// ***** Programme principal *****

fig = figure(0); // création de la fenêre
clf;
fenetre_graphique(fig);
