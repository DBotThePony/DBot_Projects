
--[[
Copyright (C) 2016 DBot


-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

]]

__DPicturePics = {}

local array = {
	'1957-studebaker-golden-hawk.jpg',
	'2015-dodge-challenger-392.jpg',
	'aimp-hi-tech-minimalizm.jpg',
	'amazon-korobka-televizor.jpg',
	'antenna-noch-fon.jpg',
	'arrinera-hussarya-supercar.jpg',
	'audi-a4-stance-audi-a4-sneg-6702.jpg',
	'basf-kasseta-muzyka-makro.jpg',
	'british-thompson-huston-type.jpg',
	'chasy-naruchnye-strelki-4178.jpg',
	'chevrolet-1972-storona.jpg',
	'computers-internet-world.jpg',
	'dj-music-pioneer-266.jpg',
	'dodge-tyuning-2015-ram-1500%20(1).jpg',
	'dodge-tyuning-2015-ram-1500.jpg',
	'fotoapparat-dizayn.jpg',
	'gory-ozero-sneg-derevya.jpg',
	'hi-tech-technology-mikroshema.jpg',
	'honda-accord-acura-tl-stance.jpg',
	'kamera-kniga-fon-7120.jpg',
	'kamera-nikon-koshka.jpg',
	'kompressor-la-la-drp-muz.jpg',
	'macchina-old-power-electric.jpg',
	'maxell-kassety-muzyka-korobka.jpg',
	'mercedes-benz-s63-front.jpg',
	'mikroshema-dorozhki-plata-1876.jpg',
	'nissan-gt-r-r35-blue-177.jpg',
	'observatoriya-teleskop-nebo.jpg',
	'porsche-macan-offroad.jpg',
	'priroda-vektor-dozhd-vetki.jpg',
	'proigryvatel-fon-muzyka-3337.jpg',
	'proigryvatel-plastinka-muzyka-5459.jpg',
	'radio-priemnik-fon-1074.jpg',
	'radio-priemnik-fon-2250.jpg',
	'radio-priemnik-komnata-3986.jpg',
	'robotics-white-design.jpg',
	'seagate-logo-hi-tech-white.jpg',
	'springs_x_by_xxtjxx.jpg',
	'televizory-komnata-fon-1515.jpg',
	'tesla-model-s-elizabeta-larte.jpg',
	'typewriter-abandoned-lost-5823.jpg',
	'typewriter-telefon-fon.jpg',
	'vw-golf-r32-stence-r32-golf-iv.jpg',
	'vyklyuchatel-makro-fon.jpg',
	'wallpaper/1.jpg',
	'wallpaper/10%20(2).jpg',
	'wallpaper/10.jpg',
	'wallpaper/1024x1024_wolfs_trail_by_djcentral.jpg',
	'wallpaper/1024x768_wolfs_trail_by_djcentral.jpg',
	'wallpaper/11%20(2).jpg',
	'wallpaper/11.jpg',
	'wallpaper/1152x864%20(2).jpg',
	'wallpaper/1152x864%20(3).jpg',
	'wallpaper/1152x864%20(4).jpg',
	'wallpaper/1152x864%20(5).jpg',
	'wallpaper/1152x864.jpg',
	'wallpaper/1152x864_wolfs_trail_by_djcentral.jpg',
	'wallpaper/12%20(2).jpg',
	'wallpaper/12.jpg',
	'wallpaper/1200x1024_wolfs_trail_by_djcentral.jpg',
	'wallpaper/1280%20x%201024.JPG',
	'wallpaper/1280.jpg',
	'wallpaper/1280x1024%20(2).jpg',
	'wallpaper/1280x1024%20(3).jpg',
	'wallpaper/1280x1024%20(4).jpg',
	'wallpaper/1280x1024%20(5).jpg',
	'wallpaper/1280x1024.jpg',
	'wallpaper/1280x720.jpg',
	'wallpaper/1280x800%20(c).jpg',
	'wallpaper/1280x800.jpg',
	'wallpaper/1280x800_wolfs_trail_by_djcentral.jpg',
	'wallpaper/1280x900_wolfs_trail_by_djcentral.jpg',
	'wallpaper/13%20(2).jpg',
	'wallpaper/13.jpg',
	'wallpaper/1366x768.jpg',
	'wallpaper/1366x768_Bloodred.png',
	'wallpaper/1366x768_Bluegrey.png',
	'wallpaper/1366x768_Brown.png',
	'wallpaper/1366x768_Caramel.png',
	'wallpaper/1366x768_Darkblue.png',
	'wallpaper/1366x768_Eyebleedingpink.png',
	'wallpaper/1366x768_Green.png',
	'wallpaper/1366x768_Lightblue.png',
	'wallpaper/1366x768_Peach.png',
	'wallpaper/1366x768_Sunny.png',
	'wallpaper/1366x768_wolfs_trail_by_djcentral.jpg',
	'wallpaper/14%20(2).jpg',
	'wallpaper/14.jpg',
	'wallpaper/1440.jpg',
	'wallpaper/1440x900%20(c).jpg',
	'wallpaper/1440x900.jpg',
	'wallpaper/1440x900_wolfs_trail_by_djcentral.jpg',
	'wallpaper/15%20(2).jpg',
	'wallpaper/15.jpg',
	'wallpaper/16.jpg',
	'wallpaper/1600%20x%201200.JPG',
	'wallpaper/1600.jpg',
	'wallpaper/1600x1000.jpg',
	'wallpaper/1600x1200%20(2).jpg',
	'wallpaper/1600x1200%20(3).jpg',
	'wallpaper/1600x1200%20(4).jpg',
	'wallpaper/1600x1200%20(5).jpg',
	'wallpaper/1600x1200.jpg',
	'wallpaper/1600x1200_wolfs_trail_by_djcentral.jpg',
	'wallpaper/1600x900%20(c).jpg',
	'wallpaper/1600x900.jpg',
	'wallpaper/1680%20x%201050.JPG',
	'wallpaper/1680.jpg',
	'wallpaper/1680x1050%20(2).jpg',
	'wallpaper/1680x1050%20(3).jpg',
	'wallpaper/1680x1050%20(4).jpg',
	'wallpaper/1680x1050%20(5).jpg',
	'wallpaper/1680x1050%20(6).jpg',
	'wallpaper/1680x1050.jpg',
	'wallpaper/1680x1050_wolfs_trail_by_djcentral.jpg',
	'wallpaper/16_10/1280x800.jpg',
	'wallpaper/16_10/1440x900.jpg',
	'wallpaper/16_10/1680x1050.jpg',
	'wallpaper/16_10/1920x1200.jpg',
	'wallpaper/17.jpg',
	'wallpaper/18.jpg',
	'wallpaper/1920%20(2).jpg',
	'wallpaper/1920%20x%201200.JPG',
	'wallpaper/1920.jpg',
	'wallpaper/1920x1080%20(c).jpg',
	'wallpaper/1920x1080.jpg',
	'wallpaper/1920x1080.png',
	'wallpaper/1920x1080_wolfs_trail_by_djcentral.jpg',
	'wallpaper/1920x1200.jpg',
	'wallpaper/1920x1200_Bloodred.png',
	'wallpaper/1920x1200_Bluegrey.png',
	'wallpaper/1920x1200_Brown.png',
	'wallpaper/1920x1200_Caramel.png',
	'wallpaper/1920x1200_Darkblue.png',
	'wallpaper/1920x1200_Eyebleedingpink.png',
	'wallpaper/1920x1200_Green.png',
	'wallpaper/1920x1200_Lightblue.png',
	'wallpaper/1920x1200_Peach.png',
	'wallpaper/1920x1200_Sunny.png',
	'wallpaper/1920x1200_wolfs_trail_by_djcentral.jpg',
	'wallpaper/1920x1440.png',
	'wallpaper/2.jpg',
	'wallpaper/2560%20(2).jpg',
	'wallpaper/2560.jpg',
	'wallpaper/2560x1440%20(c).jpg',
	'wallpaper/2560x1440.jpg',
	'wallpaper/2560x1440_wolfs_trail_by_djcentral.jpg',
	'wallpaper/2560x1600%20(c).jpg',
	'wallpaper/2560x1600.jpg',
	'wallpaper/2560x1600_wolfs_trail_by_djcentral.jpg',
	'wallpaper/2880x1800%20(c).jpg',
	'wallpaper/3.jpg',
	'wallpaper/4.jpg',
	'wallpaper/4_3/1024x768.jpg',
	'wallpaper/4_3/1280x960.jpg',
	'wallpaper/4_3/1400x1050.jpg',
	'wallpaper/4_3/1600x1200.jpg',
	'wallpaper/5.jpg',
	'wallpaper/6.jpg',
	'wallpaper/7%20(2).jpg',
	'wallpaper/7.jpg',
	'wallpaper/8%20(2).jpg',
	'wallpaper/8.jpg',
	'wallpaper/9%20(2).jpg',
	'wallpaper/9.jpg',
	'wallpaper/abstract_wind_aqua.jpg',
	'wallpaper/abstract_wind_blue.jpg',
	'wallpaper/abstract_wind_gold.jpg',
	'wallpaper/abstract_wind_green.jpg',
	'wallpaper/abstract_wind_purple.jpg',
	'wallpaper/abstract_wind_red.jpg',
	'wallpaper/Android_Bloodred.png',
	'wallpaper/Android_Bluegrey.png',
	'wallpaper/Android_Brown.png',
	'wallpaper/Android_Caramel.png',
	'wallpaper/Android_Darkblue.png',
	'wallpaper/Android_Eyebleedingpink.png',
	'wallpaper/Android_Green.png',
	'wallpaper/Android_Peach.png',
	'wallpaper/Android_Sunny.png',
	'wallpaper/Another%20Sunset%20Treat%20(2).jpg',
	'wallpaper/Another%20Sunset%20Treat.jpg',
	'wallpaper/Aurora%20Borealis%20(2).jpg',
	'wallpaper/Aurora%20Borealis.jpg',
	'wallpaper/B-river1.jpg',
	'wallpaper/Barbados%20(2).jpg',
	'wallpaper/Barbados.jpg',
	'wallpaper/Boracay%20Beach%20Sunset%20(2).jpg',
	'wallpaper/Boracay%20Beach%20Sunset.jpg',
	'wallpaper/Bright%20moon%20(2).jpg',
	'wallpaper/Bright%20moon.jpg',
	'wallpaper/Caribbean%20Sea%20-%20Mar%20Caribe%20(2).jpg',
	'wallpaper/Caribbean%20Sea%20-%20Mar%20Caribe.jpg',
	'wallpaper/Caribbean%20Sunset%20(2).jpg',
	'wallpaper/Caribbean%20Sunset%202%20(2).jpg',
	'wallpaper/Caribbean%20Sunset%202.jpg',
	'wallpaper/Caribbean%20Sunset.jpg',
	'wallpaper/Color%20Factory%20brownWood.jpg',
	'wallpaper/Color%20Factory%20VintageCamp.jpg',
	'wallpaper/Color%20Factory%20WhiteStudio.jpg',
	'wallpaper/concert1_wide.jpg',
	'wallpaper/concert3_wide.jpg',
	'wallpaper/Cool%20Waters%20(2).jpg',
	'wallpaper/Cool%20Waters.jpg',
	'wallpaper/Cuban%20Sunrise%20II%20(2).jpg',
	'wallpaper/Cuban%20Sunrise%20II.jpg',
	'wallpaper/Deep%20Blue.jpg',
	'wallpaper/Desert%20by%20Monarxy%201280x1024.jpg',
	'wallpaper/Desert%20by%20Monarxy%201280x720.jpg',
	'wallpaper/Desert%20by%20Monarxy%201280x800.jpg',
	'wallpaper/Desert%20by%20Monarxy%201280x960.jpg',
	'wallpaper/Desert%20by%20Monarxy%201400x1050.jpg',
	'wallpaper/Desert%20by%20Monarxy%201440x900.jpg',
	'wallpaper/Desert%20by%20Monarxy%201600x1200.jpg',
	'wallpaper/Desert%20by%20Monarxy%201600x900.jpg',
	'wallpaper/Desert%20by%20Monarxy%201680x1050.jpg',
	'wallpaper/Desert%20by%20Monarxy%201920x1080.jpg',
	'wallpaper/Desert%20by%20Monarxy%201920x1200.jpg',
	'wallpaper/Desert%20by%20Monarxy%202048x1152.jpg',
	'wallpaper/Desert%20by%20Monarxy%202554x1440.jpg',
	'wallpaper/Dripping_v2.png',
	'wallpaper/DSC_0023.jpg',
	'wallpaper/DSC_0030.jpg',
	'wallpaper/DSC_0133.jpg',
	'wallpaper/DSC_0629.jpg',
	'wallpaper/DSC_0709.jpg',
	'wallpaper/DSC_0711.jpg',
	'wallpaper/DSC_0751.jpg',
	'wallpaper/DSC_0806.jpg',
	'wallpaper/DSC_2469-Edit.jpg',
	'wallpaper/DSC_2718.jpg',
	'wallpaper/DSC_4855.jpg',
	'wallpaper/DSC_4861.jpg',
	'wallpaper/DSC_5008.jpg',
	'wallpaper/DSC_5081.jpg',
	'wallpaper/DSC_5129.jpg',
	'wallpaper/DSC_5167.jpg',
	'wallpaper/DSC_5383-3.jpg',
	'wallpaper/DSC_5412.jpg',
	'wallpaper/DSC_5469.jpg',
	'wallpaper/DSC_5554.jpg',
	'wallpaper/DSC_5969.jpg',
	'wallpaper/DSC_6025.jpg',
	'wallpaper/DSC_6112.jpg',
	'wallpaper/DSC_6307.jpg',
	'wallpaper/DSC_6355.jpg',
	'wallpaper/DSC_6377.jpg',
	'wallpaper/DSC_6449.jpg',
	'wallpaper/DSC_6705.jpg',
	'wallpaper/DSC_6720.jpg',
	'wallpaper/DSC_7008.jpg',
	'wallpaper/DSC_7298.jpg',
	'wallpaper/DSC_7331.jpg',
	'wallpaper/DSC_7952.jpg',
	'wallpaper/DSC_8028.jpg',
	'wallpaper/DSC_8101.jpg',
	'wallpaper/DSC_8844-Edit.jpg',
	'wallpaper/DSC_8857-Edit-1.jpg',
	'wallpaper/DSC_9011-Edit.jpg',
	'wallpaper/Entrael%20-1280%20x%201024.JPG',
	'wallpaper/Entrael%20-1440%20x%20900.JPG',
	'wallpaper/Entrael%20-1600%20x%201200.JPG',
	'wallpaper/Entrael%20-1680%20x%201050.JPG',
	'wallpaper/Entrael%20-1920%20x%201200.JPG',
	'wallpaper/Equilibrium_1024%20x%20768.jpg',
	'wallpaper/Equilibrium_1024%20x%20768_%20no%20text.jpg',
	'wallpaper/Equilibrium_1280%20x%20720.jpg',
	'wallpaper/Equilibrium_1280%20x%20720_no%20text.jpg',
	'wallpaper/Equilibrium_1280%20x%20800.jpg',
	'wallpaper/Equilibrium_1280%20x%20800_%20no%20text.jpg',
	'wallpaper/Equilibrium_1400%20x%201050.jpg',
	'wallpaper/Equilibrium_1400%20x%201050_%20no%20text.jpg',
	'wallpaper/Equilibrium_1440%20x%20900.jpg',
	'wallpaper/Equilibrium_1440%20x%20900_%20no%20text.jpg',
	'wallpaper/Equilibrium_1600%20x%201200.jpg',
	'wallpaper/Equilibrium_1600%20x%201200_%20no%20text.jpg',
	'wallpaper/Equilibrium_1680%20x%201050.jpg',
	'wallpaper/Equilibrium_1680%20x%201050_no%20text.jpg',
	'wallpaper/Equilibrium_1920%20x%201080.jpg',
	'wallpaper/Equilibrium_1920%20x%201080_no%20text.jpg',
	'wallpaper/Five%20Past%20Ten_2048x1536.jpg',
	'wallpaper/FPT_1920x1600.jpg',
	'wallpaper/FPT_2560x1440.jpg',
	'wallpaper/FPT_2560x1600.jpg',
	'wallpaper/God%27s%20Mountains%20Original%20Resolution%20(Dark).jpg',
	'wallpaper/God%27s%20Mountains%20Original%20Resolution%20(Green).jpg',
	'wallpaper/God%27s%20Mountains%20Original%20Resolution%20(Light).jpg',
	'wallpaper/Illuminati%20-1280%20x%201024.JPG',
	'wallpaper/Illuminati%20-1440%20x%20900.JPG',
	'wallpaper/Illuminati%20-1600%20x%201200.JPG',
	'wallpaper/Illuminati%20-1680%20x%201050.JPG',
	'wallpaper/Illuminati%20-1920%20x%201200.JPG',
	'wallpaper/IMG_0913.jpg',
	'wallpaper/IMG_1007.jpg',
	'wallpaper/IMG_1129.jpg',
	'wallpaper/IMG_1160.jpg',
	'wallpaper/IMG_1252-Edit-2.jpg',
	'wallpaper/IMG_1590.jpg',
	'wallpaper/infinity_aqua.png',
	'wallpaper/infinity_brown.png',
	'wallpaper/infinity_red.png',
	'wallpaper/infinity_sun.png',
	'wallpaper/iPad_Bloodred.png',
	'wallpaper/iPad_Bluegrey.png',
	'wallpaper/iPad_Brown.png',
	'wallpaper/iPad_Caramel.png',
	'wallpaper/iPad_Darkblue.png',
	'wallpaper/iPad_Eyebleedingpink.png',
	'wallpaper/iPad_Green.png',
	'wallpaper/iPad_Lightblue.png',
	'wallpaper/iPad_Peach.png',
	'wallpaper/iPad_Sunny.png',
	'wallpaper/Isawmylastsunrise.jpg',
	'wallpaper/JCTS2560x1600.jpg',
	'wallpaper/Judgement2560x1600.jpg',
	'wallpaper/JudgementII2560x1600.jpg',
	'wallpaper/JudgementIII2560x1600.jpg',
	'wallpaper/Just%20Endless%20-%201280x1024.png',
	'wallpaper/Just%20Endless%20-%201600x1200.png',
	'wallpaper/Just%20Endless%20-%201920x1200%20-%20BLUE.jpg',
	'wallpaper/Just%20Endless%20-%201920x1200%20-%20BROWN.jpg',
	'wallpaper/Just%20Endless%20-%201920x1200%20-%20CLEAN.jpg',
	'wallpaper/Just%20Endless%20-%201920x1200%20-%20GREEN.jpg',
	'wallpaper/Just%20Endless%20-%201920x1200%20-%20RED.jpg',
	'wallpaper/Just%20Endless%20-%201920x1200%20-%20VIOLETT.jpg',
	'wallpaper/Just%20Endless%20-%201920x1200%20-%20YELLOW.jpg',
	'wallpaper/Just%20Endless%20-%201920x1200.png',
	'wallpaper/minion-a.png',
	'wallpaper/Moonlit%20tropical%20beach%20(2).jpg',
	'wallpaper/Moonlit%20tropical%20beach.jpg',
	'wallpaper/Mountain%20Lion%201920x1080.png',
	'wallpaper/Mountain%20Lion%202560x1600.png',
	'wallpaper/Mountain%20Lion%20wallpaper%201280x800.png',
	'wallpaper/Mountain%20Lion%20wallpaper%201440x900.png',
	'wallpaper/Mountain%20Lion%20wallpaper%201680x1050.png',
	'wallpaper/Mountain%20Lion%20Wallpaper%203200x2000.jpg',
	'wallpaper/Mountain%20Lion%20wallpaper%203840x2400.png',
	'wallpaper/Mountain%20Lion%20wallpaper%20Presentation.png',
	'wallpaper/museo%20wallpaper.jpg',
	'wallpaper/mylastsunrise.jpg',
	'wallpaper/Northern%20reflections%20(2).jpg',
	'wallpaper/Northern%20reflections.jpg',
	'wallpaper/Once%20Upon%20A%20Time_blue%201400x1050.jpg',
	'wallpaper/Once%20Upon%20A%20Time_gray%201400x1050.jpg',
	'wallpaper/Once%20Upon%20A%20Time_green%201400x1050.jpg',
	'wallpaper/Once%20Upon%20A%20Time_pink%201400x1050.jpg',
	'wallpaper/Once%20Upon%20A%20Time_red%201400x1050.jpg',
	'wallpaper/Once%20Upon%20A%20Time_yellow%201400x1050.jpg',
	'wallpaper/Pelican%20Beach%20(2).jpg',
	'wallpaper/Pelican%20Beach.jpg',
	'wallpaper/phone/1024.jpg',
	'wallpaper/phone/1024x640.jpg',
	'wallpaper/phone/1280x720_wolfs_trail_by_djcentral.jpg',
	'wallpaper/phone/240x320_wolfs_trail_by_djcentral.jpg',
	'wallpaper/phone/320%20x%20480%20For%20iPhone%20%26%20Ipod%20Touch.JPG',
	'wallpaper/phone/320x240_wolfs_trail_by_djcentral.jpg',
	'wallpaper/phone/320x480_wolfs_trail_by_djcentral.jpg',
	'wallpaper/phone/360x400_wolfs_trail_by_djcentral.jpg',
	'wallpaper/phone/360x480_wolfs_trail_by_djcentral.jpg',
	'wallpaper/phone/480x320_wolfs_trail_by_djcentral%20(2).jpg',
	'wallpaper/phone/480x320_wolfs_trail_by_djcentral.jpg',
	'wallpaper/phone/480x360_wolfs_trail_by_djcentral.jpg',
	'wallpaper/phone/480x400_wolfs_trail_by_djcentral.jpg',
	'wallpaper/phone/480x432_wolfs_trail_by_djcentral.jpg',
	'wallpaper/phone/640x480_wolfs_trail_by_djcentral.jpg',
	'wallpaper/phone/640x960_wolfs_trail_by_djcentral.jpg',
	'wallpaper/phone/800x600_wolfs_trail_by_djcentral.jpg',
	'wallpaper/phone/960x800_wolfs_trail_by_djcentral.jpg',
	'wallpaper/phone/960x854_wolfs_trail_by_djcentral.jpg',
	'wallpaper/phone/Android_Lightblue.png',
	'wallpaper/phone/concert1_full.jpg',
	'wallpaper/phone/concert2_full.jpg',
	'wallpaper/phone/concert2_wide.jpg',
	'wallpaper/phone/concert3_full.jpg',
	'wallpaper/phone/credit%20me.jpg',
	'wallpaper/phone/Deep%20Blue%201024x768.jpg',
	'wallpaper/phone/Deep%20Blue%202560x1600.jpg',
	'wallpaper/phone/Desert%20by%20Monarxy%20640x960%20iPhone.jpg',
	'wallpaper/phone/Deviantart-Preview.jpg',
	'wallpaper/phone/Entrael%20-Iphone%20%26%20Ipod%20touch%20version.JPG',
	'wallpaper/phone/Five%20Past%20Ten_1024x1024.jpg',
	'wallpaper/phone/Five%20Past%20Ten_1280x1024.jpg',
	'wallpaper/phone/Five%20Past%20Ten_1366x768.jpg',
	'wallpaper/phone/Five%20Past%20Ten_1440x900.jpg',
	'wallpaper/phone/Five%20Past%20Ten_1680x1050.jpg',
	'wallpaper/phone/Five%20Past%20Ten_480x320.jpg',
	'wallpaper/phone/Five%20Past%20Ten_640x960.jpg',
	'wallpaper/phone/God%27s%20Mountains%20(Dark)%201600x1200.jpg',
	'wallpaper/phone/God%27s%20Mountains%20(Dark)%202560X1600.jpg',
	'wallpaper/phone/God%27s%20Mountains%20(Green)%201600x1200.jpg',
	'wallpaper/phone/God%27s%20Mountains%20(Green)%202560X1600.jpg',
	'wallpaper/phone/God%27s%20Mountains%20(Light)%201600x1200.jpg',
	'wallpaper/phone/God%27s%20Mountains%20(Light)%202560X1600.jpg',
	'wallpaper/phone/Illuminati%20-Iphone%20%26%20Ipod%20touch%20version.JPG',
	'wallpaper/phone/infinity_grey.png',
	'wallpaper/phone/iPad.jpg',
	'wallpaper/phone/iPhone%205.jpg',
	'wallpaper/phone/iPhone3.jpg',
	'wallpaper/phone/iPhone4.jpg',
	'wallpaper/phone/iPhone4_Bloodred.png',
	'wallpaper/phone/iPhone4_Bluegrey.png',
	'wallpaper/phone/iPhone4_Brown.png',
	'wallpaper/phone/iPhone4_Caramel.png',
	'wallpaper/phone/iPhone4_Darkblue.png',
	'wallpaper/phone/iPhone4_Eyebleedingpink.png',
	'wallpaper/phone/iPhone4_Green.png',
	'wallpaper/phone/iPhone4_Lightblue.png',
	'wallpaper/phone/iPhone4_Peach.png',
	'wallpaper/phone/iPhone4_Sunny.png',
	'wallpaper/phone/Mobile%201.jpg',
	'wallpaper/phone/Mobile%202.jpg',
	'wallpaper/phone/Procedural%20Jiggle%20Bone%20-Iphone%20%26%20Ipod%20touch%20version.JPG',
	'wallpaper/phone/v01_1280x800.jpg',
	'wallpaper/phone/v01_1440x900.jpg',
	'wallpaper/phone/v01_iPad_1024x1024.jpg',
	'wallpaper/phone/v01_iPhone4_640x960.jpg',
	'wallpaper/phone/v01_iPhone_320x480.jpg',
	'wallpaper/phone/zeka_extra5.jpg',
	'wallpaper/phone/Zunecase%20wallpaper%20320x240px%20Zune%2030-80-120GB%20without%20ribbon.jpg',
	'wallpaper/phone/Zunecase%20wallpaper%20320x240px%20Zune%2030-80-120GB.jpg',
	'wallpaper/phone/Zunecase%20wallpaper%20340x480px%20iPhone%203G%20without%20ribbon.jpg',
	'wallpaper/phone/Zunecase%20wallpaper%20340x480px%20iPhone%203G.jpg',
	'wallpaper/phone/Zunecase%20wallpaper%20480x272px%20Zune%20HD%20without%20ribbon.jpg',
	'wallpaper/phone/Zunecase%20wallpaper%20480x272px%20Zune%20HD.jpg',
	'wallpaper/phone/Zunecase%20wallpaper%20640x960px%20iPhone%204%20without%20ribbon.jpg',
	'wallpaper/phone/Zunecase%20wallpaper%20640x960px%20iPhone%204.jpg',
	'wallpaper/phone/Zunecase%20wallpaper%20800x480px%20Galaxy%20SII%20without%20ribbon.jpg',
	'wallpaper/phone/Zunecase%20wallpaper%20800x480px%20Galaxy%20SII.jpg',
	'wallpaper/phone/____morning%20grass%20(5).jpg',
	'wallpaper/phone/____morning%20grass.jpg',
	'wallpaper/phone/____rocio%20(5).jpg',
	'wallpaper/phone/____sad%20leaf%20(5).jpg',
	'wallpaper/phone/____sad%20leaf.jpg',
	'wallpaper/phone/____stones%20(5).jpg',
	'wallpaper/phone/____stones.jpg',
	'wallpaper/Procedural%20Jiggle%20Bone%20-1280%20x%201024.JPG',
	'wallpaper/Procedural%20Jiggle%20Bone%20-1440%20x%20900.JPG',
	'wallpaper/Procedural%20Jiggle%20Bone%20-1600%20x%201200.JPG',
	'wallpaper/Procedural%20Jiggle%20Bone%20-1680%20x%201050.JPG',
	'wallpaper/Procedural%20Jiggle%20Bone%20-1920%20x%201200.JPG',
	'wallpaper/Racing%20Beach%20(2).jpg',
	'wallpaper/Racing%20Beach.jpg',
	'wallpaper/reeds.jpg',
	'wallpaper/rock%20wall%202.jpg',
	'wallpaper/Sea%20Bright%20(2).jpg',
	'wallpaper/Sea%20Bright.jpg',
	'wallpaper/SpaceScene13W-1.jpg',
	'wallpaper/SpaceScene13W-2.jpg',
	'wallpaper/SpaceScene14W-1.jpg',
	'wallpaper/SpaceScene14W-2.jpg',
	'wallpaper/SpaceScene15W-1.jpg',
	'wallpaper/SpaceScene15W-2.jpg',
	'wallpaper/SpaceScene17W-1.jpg',
	'wallpaper/SpaceScene17W-2.jpg',
	'wallpaper/SpaceScene18W-1.jpg',
	'wallpaper/SpaceScene18W-2.jpg',
	'wallpaper/SpaceScene19W-1.jpg',
	'wallpaper/SpaceScene19W-2.jpg',
	'wallpaper/SpaceScene21W-1.jpg',
	'wallpaper/SpaceScene21W-2.jpg',
	'wallpaper/SpaceSceneSunSetW-1.jpg',
	'wallpaper/SpaceSceneSunSetW-2.jpg',
	'wallpaper/SpaceSceneW02.jpg',
	'wallpaper/sundown.jpg',
	'wallpaper/Sunset%20In%20Circeo%20National%20Park%20(2).jpg',
	'wallpaper/Sunset%20In%20Circeo%20National%20Park.jpg',
	'wallpaper/v01_1600x1200.jpg',
	'wallpaper/v01_1920x1080.jpg',
	'wallpaper/v01_1920x1200.jpg',
	'wallpaper/v01_2560x1400.jpg',
	'wallpaper/v01_2560x1600.jpg',
	'wallpaper/zeka1.jpg',
	'wallpaper/zeka10.jpg',
	'wallpaper/zeka2.jpg',
	'wallpaper/zeka3.jpg',
	'wallpaper/zeka4.jpg',
	'wallpaper/zeka5.jpg',
	'wallpaper/zeka6.jpg',
	'wallpaper/zeka7.jpg',
	'wallpaper/zeka8.jpg',
	'wallpaper/zeka9.jpg',
	'wallpaper/zeka_extra1.jpg',
	'wallpaper/zeka_extra2.jpg',
	'wallpaper/zeka_extra3.jpg',
	'wallpaper/zeka_extra4.jpg',
	'wallpaper/Zunecase%20wallpaper%201024x768px%20iPad%20without%20ribbons.jpg',
	'wallpaper/Zunecase%20wallpaper%201024x768px%20iPad.jpg',
	'wallpaper/Zunecase%20wallpaper%201280x1024px%20without%20ribbons.jpg',
	'wallpaper/Zunecase%20wallpaper%201280x1024px.jpg',
	'wallpaper/Zunecase%20wallpaper%201280x960px%20without%20ribbons.jpg',
	'wallpaper/Zunecase%20wallpaper%201280x960px.jpg',
	'wallpaper/Zunecase%20wallpaper%201440x900px%20without%20ribbons.jpg',
	'wallpaper/Zunecase%20wallpaper%201440x900px.jpg',
	'wallpaper/Zunecase%20wallpaper%201600x1200px%20%20without%20ribbons.jpg',
	'wallpaper/Zunecase%20wallpaper%201600x1200px.jpg',
	'wallpaper/Zunecase%20wallpaper%201620x1050%20with%20ribbon.jpg',
	'wallpaper/Zunecase%20wallpaper%201620x1050%20without%20ribbon.jpg',
	'wallpaper/Zunecase%20wallpaper%202560x1600px%20without%20ribbons.jpg',
	'wallpaper/Zunecase%20wallpaper%202560x1600px.jpg',
	'wallpaper/Zunecase%20wallpaper%20768x1024px%20iPad%20without%20ribbons.jpg',
	'wallpaper/Zunecase%20wallpaper%20768x1024px%20iPad.jpg',
	'wallpaper/_DSC0702.jpg',
	'wallpaper/_DSC0784-Edit.jpg',
	'wallpaper/_DSC1880.jpg',
	'wallpaper/_DSC1951.jpg',
	'wallpaper/_DSC9138-02.jpg',
	'wallpaper/_DSC9187.jpg',
	'wallpaper/_DSC9250-2.jpg',
	'wallpaper/____morning%20grass%20(2).jpg',
	'wallpaper/____morning%20grass%20(3).jpg',
	'wallpaper/____morning%20grass%20(4).jpg',
	'wallpaper/____naturelle2%20preview.jpg',
	'wallpaper/____rocio%20(2).jpg',
	'wallpaper/____rocio%20(3).jpg',
	'wallpaper/____rocio%20(4).jpg',
	'wallpaper/____rocio.jpg',
	'wallpaper/____sad%20LEAF%20(2).jpg',
	'wallpaper/____sad%20LEAF%20(3).jpg',
	'wallpaper/____sad%20LEAf%20(4).jpg',
	'wallpaper/____stones%20(2).jpg',
	'wallpaper/____stones%20(3).jpg',
	'wallpaper/____stones%20(4).jpg',
}

for k, v in pairs(array) do
	table.insert(__DPicturePics, 'https://dbot.serealia.ca/pic/' .. v)
end
