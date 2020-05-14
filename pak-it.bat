rmdir /s/q ..\PakTemp
mkdir ..\PakTemp
CScript zip.vbs . ..\PakTemp\2eArmorDamage.zip
ren ..\PakTemp\2eArmorDamage.zip 2eArmorDamage.ext
xcopy /s/y ..\PakTemp\2eArmorDamage.ext "C:\Users\drplo\AppData\Roaming\Fantasy Grounds\extensions\"
xcopy /s/y ..\PakTemp\2eArmorDamage.ext "C:\Users\drplo\AppData\Roaming\SmiteWorks\Fantasy Grounds\extensions\"
pause

