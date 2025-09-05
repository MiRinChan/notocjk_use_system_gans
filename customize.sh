if [ "$API" -lt 26 ]; then
ui_print "*********************************************************"
ui_print "! Please upgrade your system to Android 8+"
abort    "*********************************************************"
fi
BAKPATH=/data/adb/notocjk_bak/
[ -x `which magisk` ] && {
if magisk --denylist ls &>/dev/null; then
CMDPREFIX="magisk --denylist exec"
elif magisk magiskhide ls &>/dev/null; then
CMDPREFIX="magisk magiskhide exec"
fi
} || unset CMDPREFIX
[ -f $BAKPATH/api_level ] && OLD_API=$(cat $BAKPATH/api_level 2>/dev/null) || OLD_API=$API
ui_print "OLD_API: $OLD_API"
if [ -z $CMDPREFIX ] && [ ! "$API" -eq "$OLD_API" ]; then
rm -rf $BAKPATH
ui_print "*********************************************************"
ui_print "! API level changed"
ui_print "! Please uninstall previous version and reboot, then install this version manually"
abort    "*********************************************************"
fi
MODULE_NAME=$(basename $MODPATH)
ui_print "MODULE_NAME: $MODULE_NAME"
if [ -z $CMDPREFIX ] && [ ! -d $BAKPATH ] && [ -d "/data/adb/modules/$MODULE_NAME/system/etc" ]; then
ui_print "*********************************************************"
ui_print "! Backup missing"
ui_print "! Please uninstall previous version and reboot, then install this version manually"
abort    "*********************************************************"
fi
mkdir -p $BAKPATH
echo "$API" > $BAKPATH/api_level
FILES="fonts.xml fonts_base.xml font_fallback.xml"
FILECUSTOM=fonts_customization.xml
FILEPATHS="/system/etc/ /system_ext/etc/"
for FILE in $FILES
do
for FILEPATH in $FILEPATHS
do
if [ -f $FILEPATH$FILE ]; then
ui_print "- Migrating $FILE"
case "$FILEPATH" in
/system/*) SYSTEMFILEPATH=$FILEPATH ;;
*) SYSTEMFILEPATH=/system$FILEPATH ;;
esac
mkdir -p $MODPATH$SYSTEMFILEPATH
if [ ! -f $BAKPATH$FILEPATH$FILE ]; then
ui_print "- Backup $FILE to $BAKPATH"
mkdir -p $BAKPATH$FILEPATH
$CMDPREFIX cp -af $FILEPATH$FILE $BAKPATH$FILEPATH$FILE
fi
cp -af $BAKPATH$FILEPATH$FILE $MODPATH$SYSTEMFILEPATH$FILE
# Disable MiSans for debugging
# sed -i '/<!-- # MIUI Edit Start -->/,/<!-- # MIUI Edit END -->/d;/<!-- MIUI fonts begin \/-->/,/<!-- MIUI fonts end \/-->/d;' $MODPATH$SYSTEMFILEPATH$FILE 
# Disable OPlusSans for debugging
# sed -i '$!N;/<!-- JiFeng.Tan@ANDROID.UIFramework, 2019-05-13 : Modified for SysSans fonts-->\n    <!--/,/.*--> <!--  #else \/\* OPLUS_FEATURE_FONT_FLIP \*\/-->/{s/<!--.*-->//g;s/<!--//g;s/-->//g};P;D' $MODPATH$SYSTEMFILEPATH$FILE


# Upright Regular → Google Sans Regular
sed -i 's|Roboto-Regular.ttf|GoogleSans-Regular.ttf|g' $MODPATH$SYSTEMFILEPATH$FILE

# Upright Italic → Google Sans Italic
sed -i 's|Roboto-Italic.ttf|GoogleSans-Italic.ttf|g' $MODPATH$SYSTEMFILEPATH$FILE

# Monospace Regular → Google Sans Mono
sed -i 's|RobotoMono-Regular.ttf|GoogleSansMono-Regular.ttf|g' $MODPATH$SYSTEMFILEPATH$FILE

# ==========================
# 变体轴配置 (Upright)
# ==========================
# UL = wght 400 opsz 17 GRAD -50
sed -i '/GoogleSans-Light.ttf/a\
    <axis tag="wght" stylevalue="400"/>\
    <axis tag="opsz" stylevalue="17"/>\
    <axis tag="GRAD" stylevalue="-50"/>' $MODPATH$SYSTEMFILEPATH$FILE

# UR = wght 400 opsz 17 GRAD 0
sed -i '/GoogleSans-Regular.ttf/a\
    <axis tag="wght" stylevalue="400"/>\
    <axis tag="opsz" stylevalue="17"/>\
    <axis tag="GRAD" stylevalue="0"/>' $MODPATH$SYSTEMFILEPATH$FILE

# UM = wght 500 opsz 17 GRAD 0
sed -i '/GoogleSans-Medium.ttf/a\
    <axis tag="wght" stylevalue="500"/>\
    <axis tag="opsz" stylevalue="17"/>\
    <axis tag="GRAD" stylevalue="0"/>' $MODPATH$SYSTEMFILEPATH$FILE

# USB = wght 600 opsz 17 GRAD 0
sed -i '/GoogleSans-SemiBold.ttf/a\
    <axis tag="wght" stylevalue="600"/>\
    <axis tag="opsz" stylevalue="17"/>\
    <axis tag="GRAD" stylevalue="0"/>' $MODPATH$SYSTEMFILEPATH$FILE

# UB = wght 700 opsz 18 GRAD 0
sed -i '/GoogleSans-Bold.ttf/a\
    <axis tag="wght" stylevalue="700"/>\
    <axis tag="opsz" stylevalue="18"/>\
    <axis tag="GRAD" stylevalue="0"/>' $MODPATH$SYSTEMFILEPATH$FILE

# UEB = wght 700 opsz 18 GRAD 100
sed -i '/GoogleSans-ExtraBold.ttf/a\
    <axis tag="wght" stylevalue="700"/>\
    <axis tag="opsz" stylevalue="18"/>\
    <axis tag="GRAD" stylevalue="100"/>' $MODPATH$SYSTEMFILEPATH$FILE

# ==========================
# 变体轴配置 (Monospace)
# ==========================
# MR = wght 400
sed -i '/GoogleSansMono-Regular.ttf/a\
    <axis tag="wght" stylevalue="400"/>' $MODPATH$SYSTEMFILEPATH$FILE

# MM = wght 500
sed -i '/GoogleSansMono-Medium.ttf/a\
    <axis tag="wght" stylevalue="500"/>' $MODPATH$SYSTEMFILEPATH$FILE

# MSB = wght 600
sed -i '/GoogleSansMono-SemiBold.ttf/a\
    <axis tag="wght" stylevalue="600"/>' $MODPATH$SYSTEMFILEPATH$FILE

# MB = wght 700
sed -i '/GoogleSansMono-Bold.ttf/a\
    <axis tag="wght" stylevalue="700"/>' $MODPATH$SYSTEMFILEPATH$FILE

# ==========================
# 布尔/附加设置
# ==========================
# LSC = false → 删除 line spacing axis
sed -i '/<axis tag="LSC"/d' $MODPATH$SYSTEMFILEPATH$FILE

# OTLTAG (空) → 不操作

sed -i 's/<alias name="serif-bold" to="serif" weight="700" \/>/<alias name="serif-thin" to="serif" weight="100" \/>\n<alias name="serif-light" to="serif" weight="300" \/>\n<alias name="serif-medium" to="serif" weight="400" \/>\n<alias name="serif-semi-bold" to="serif" weight="500" \/>\n<alias name="serif-bold" to="serif" weight="700" \/>\n<alias name="serif-black" to="serif" weight="900" \/>/g
' $MODPATH$SYSTEMFILEPATH$FILE
sed -i '
/<family lang=\"zh-Hans\">/,/<\/family>/ {:a;N;/<\/family>/!ba;
s/<family lang=\"zh-Hans\">.*Noto.*CJK.*<\/family>/<family lang="zh-Hans">\n<font weight="100" style="normal" index="2" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="100" \/><\/font>\n<font weight="200" style="normal" index="2" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="200" \/><\/font>\n<font weight="300" style="normal" index="2" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="300" \/><\/font>\n<font weight="400" style="normal" index="2" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="400" \/><\/font>\n<font weight="500" style="normal" index="2" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="500" \/><\/font>\n<font weight="600" style="normal" index="2" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="600" \/><\/font>\n<font weight="700" style="normal" index="2" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="700" \/><\/font>\n<font weight="800" style="normal" index="2" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="800" \/><\/font>\n<font weight="900" style="normal" index="2" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="900" \/><\/font>\n<font weight="200" style="normal" index="2" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="200" \/><\/font>\n<font weight="300" style="normal" index="2" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="300" \/><\/font>\n<font weight="400" style="normal" index="2" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="400" \/><\/font>\n<font weight="500" style="normal" index="2" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="500" \/><\/font>\n<font weight="600" style="normal" index="2" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="600" \/><\/font>\n<font weight="700" style="normal" index="2" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="700" \/><\/font>\n<font weight="800" style="normal" index="2" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="800" \/><\/font>\n<font weight="900" style="normal" index="2" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="900" \/><\/font>\n<\/family>\n<family lang="zh-Hans">\n<font weight="400" style="normal" index="2" postScriptName="NotoSansCJKjp-Regular">NotoSansCJK-Regular.ttc<\/font>\n<font weight="400" style="normal" index="2" fallbackFor="serif" postScriptName="NotoSerifCJKjp-Regular">NotoSerifCJK-Regular.ttc<\/font>\n<\/family>/};
' $MODPATH$SYSTEMFILEPATH$FILE
sed -i '
/<family lang=\"zh-Hant\">/,/<\/family>/ {:a;N;/<\/family>/!ba;
s/<family lang=\"zh-Hant\">.*Noto.*CJK.*<\/family>/<family lang="zh-Hant">\n<font weight="100" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="100" \/><\/font>\n<font weight="200" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="200" \/><\/font>\n<font weight="300" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="300" \/><\/font>\n<font weight="400" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="400" \/><\/font>\n<font weight="500" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="500" \/><\/font>\n<font weight="600" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="600" \/><\/font>\n<font weight="700" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="700" \/><\/font>\n<font weight="800" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="800" \/><\/font>\n<font weight="900" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="900" \/><\/font>\n<font weight="200" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="200" \/><\/font>\n<font weight="300" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="300" \/><\/font>\n<font weight="400" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="400" \/><\/font>\n<font weight="500" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="500" \/><\/font>\n<font weight="600" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="600" \/><\/font>\n<font weight="700" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="700" \/><\/font>\n<font weight="800" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="800" \/><\/font>\n<font weight="900" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="900" \/><\/font>\n<\/family>\n<family lang="zh-Hant">\n<font weight="400" style="normal" index="3" postScriptName="NotoSansCJKjp-Regular">NotoSansCJK-Regular.ttc<\/font>\n<font weight="400" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-Regular">NotoSerifCJK-Regular.ttc<\/font>\n<\/family>/};
' $MODPATH$SYSTEMFILEPATH$FILE
sed -i '
/<family lang=\"zh-Bopo\">/,/<\/family>/ {:a;N;/<\/family>/!ba;
s/<family lang=\"zh-Bopo\">.*Noto.*CJK.*<\/family>/<family lang="zh-Bopo">\n<font weight="100" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="100" \/><\/font>\n<font weight="200" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="200" \/><\/font>\n<font weight="300" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="300" \/><\/font>\n<font weight="400" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="400" \/><\/font>\n<font weight="500" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="500" \/><\/font>\n<font weight="600" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="600" \/><\/font>\n<font weight="700" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="700" \/><\/font>\n<font weight="800" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="800" \/><\/font>\n<font weight="900" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="900" \/><\/font>\n<font weight="200" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="200" \/><\/font>\n<font weight="300" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="300" \/><\/font>\n<font weight="400" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="400" \/><\/font>\n<font weight="500" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="500" \/><\/font>\n<font weight="600" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="600" \/><\/font>\n<font weight="700" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="700" \/><\/font>\n<font weight="800" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="800" \/><\/font>\n<font weight="900" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="900" \/><\/font>\n<\/family>\n<family lang="zh-Bopo">\n<font weight="400" style="normal" index="3" postScriptName="NotoSansCJKjp-Regular">NotoSansCJK-Regular.ttc<\/font>\n<font weight="400" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-Regular">NotoSerifCJK-Regular.ttc<\/font>\n<\/family>/};
' $MODPATH$SYSTEMFILEPATH$FILE
sed -i '
/<family lang=\"zh-Hant zh-Bopo\">/,/<\/family>/ {:a;N;/<\/family>/!ba;
s/<family lang=\"zh-Hant zh-Bopo\">.*Noto.*CJK.*<\/family>/<family lang="zh-Hant zh-Bopo">\n<font weight="100" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="100" \/><\/font>\n<font weight="200" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="200" \/><\/font>\n<font weight="300" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="300" \/><\/font>\n<font weight="400" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="400" \/><\/font>\n<font weight="500" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="500" \/><\/font>\n<font weight="600" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="600" \/><\/font>\n<font weight="700" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="700" \/><\/font>\n<font weight="800" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="800" \/><\/font>\n<font weight="900" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="900" \/><\/font>\n<font weight="200" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="200" \/><\/font>\n<font weight="300" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="300" \/><\/font>\n<font weight="400" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="400" \/><\/font>\n<font weight="500" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="500" \/><\/font>\n<font weight="600" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="600" \/><\/font>\n<font weight="700" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="700" \/><\/font>\n<font weight="800" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="800" \/><\/font>\n<font weight="900" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="900" \/><\/font>\n<\/family>\n<family lang="zh-Hant zh-Bopo">\n<font weight="400" style="normal" index="3" postScriptName="NotoSansCJKjp-Regular">NotoSansCJK-Regular.ttc<\/font>\n<font weight="400" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-Regular">NotoSerifCJK-Regular.ttc<\/font>\n<\/family>/};
' $MODPATH$SYSTEMFILEPATH$FILE
sed -i '
/<family lang=\"zh-Hant,zh-Bopo\">/,/<\/family>/ {:a;N;/<\/family>/!ba;
s/<family lang=\"zh-Hant,zh-Bopo\">.*Noto.*CJK.*<\/family>/<family lang="zh-Hant,zh-Bopo">\n<font weight="100" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="100" \/><\/font>\n<font weight="200" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="200" \/><\/font>\n<font weight="300" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="300" \/><\/font>\n<font weight="400" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="400" \/><\/font>\n<font weight="500" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="500" \/><\/font>\n<font weight="600" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="600" \/><\/font>\n<font weight="700" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="700" \/><\/font>\n<font weight="800" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="800" \/><\/font>\n<font weight="900" style="normal" index="3" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="900" \/><\/font>\n<font weight="200" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="200" \/><\/font>\n<font weight="300" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="300" \/><\/font>\n<font weight="400" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="400" \/><\/font>\n<font weight="500" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="500" \/><\/font>\n<font weight="600" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="600" \/><\/font>\n<font weight="700" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="700" \/><\/font>\n<font weight="800" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="800" \/><\/font>\n<font weight="900" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="900" \/><\/font>\n<\/family>\n<family lang="zh-Hant,zh-Bopo">\n<font weight="400" style="normal" index="3" postScriptName="NotoSansCJKjp-Regular">NotoSansCJK-Regular.ttc<\/font>\n<font weight="400" style="normal" index="3" fallbackFor="serif" postScriptName="NotoSerifCJKjp-Regular">NotoSerifCJK-Regular.ttc<\/font>\n<\/family>/};
' $MODPATH$SYSTEMFILEPATH$FILE
sed -i '
/<family lang=\"ja\">/,/<\/family>/ {:a;N;/<\/family>/!ba;
s/<family lang=\"ja\">.*Noto.*CJK.*<\/family>/<family lang="ja">\n<font weight="100" style="normal" index="0" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="100" \/><\/font>\n<font weight="200" style="normal" index="0" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="200" \/><\/font>\n<font weight="300" style="normal" index="0" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="300" \/><\/font>\n<font weight="400" style="normal" index="0" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="400" \/><\/font>\n<font weight="500" style="normal" index="0" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="500" \/><\/font>\n<font weight="600" style="normal" index="0" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="600" \/><\/font>\n<font weight="700" style="normal" index="0" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="700" \/><\/font>\n<font weight="800" style="normal" index="0" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="800" \/><\/font>\n<font weight="900" style="normal" index="0" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="900" \/><\/font>\n<font weight="200" style="normal" index="0" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="200" \/><\/font>\n<font weight="300" style="normal" index="0" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="300" \/><\/font>\n<font weight="400" style="normal" index="0" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="400" \/><\/font>\n<font weight="500" style="normal" index="0" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="500" \/><\/font>\n<font weight="600" style="normal" index="0" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="600" \/><\/font>\n<font weight="700" style="normal" index="0" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="700" \/><\/font>\n<font weight="800" style="normal" index="0" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="800" \/><\/font>\n<font weight="900" style="normal" index="0" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="900" \/><\/font>\n<\/family>\n<family lang="ja">\n<font weight="400" style="normal" index="0" postScriptName="NotoSansCJKjp-Regular">NotoSansCJK-Regular.ttc<\/font>\n<font weight="400" style="normal" index="0" fallbackFor="serif" postScriptName="NotoSerifCJKjp-Regular">NotoSerifCJK-Regular.ttc<\/font>\n<\/family>/};
' $MODPATH$SYSTEMFILEPATH$FILE
sed -i '
/<family lang=\"ja\">/,/<\/family>/ {:a;N;/<\/family>/!ba;
s/<family lang=\"ja\">.*NotoSerifHentaigana.*<\/family>/<family lang="ja">\n        <font weight="200" style="normal" postScriptName="NotoSerifHentaigana-ExtraLight">\n            NotoSerifHentaigana.ttf\n            <axis tag="wght" stylevalue="200" \/>\n        <\/font>\n        <font weight="300" style="normal" postScriptName="NotoSerifHentaigana-ExtraLight">\n            NotoSerifHentaigana.ttf\n            <axis tag="wght" stylevalue="300" \/>\n        <\/font>\n        <font weight="400" style="normal" postScriptName="NotoSerifHentaigana-ExtraLight">\n            NotoSerifHentaigana.ttf\n            <axis tag="wght" stylevalue="400" \/>\n        <\/font>\n        <font weight="500" style="normal" postScriptName="NotoSerifHentaigana-ExtraLight">\n            NotoSerifHentaigana.ttf\n            <axis tag="wght" stylevalue="500" \/>\n        <\/font>\n        <font weight="600" style="normal" postScriptName="NotoSerifHentaigana-ExtraLight">\n            NotoSerifHentaigana.ttf\n            <axis tag="wght" stylevalue="600" \/>\n        <\/font>\n        <font weight="700" style="normal" postScriptName="NotoSerifHentaigana-ExtraLight">\n            NotoSerifHentaigana.ttf\n            <axis tag="wght" stylevalue="700" \/>\n        <\/font>\n        <font weight="800" style="normal" postScriptName="NotoSerifHentaigana-ExtraLight">\n            NotoSerifHentaigana.ttf\n            <axis tag="wght" stylevalue="800" \/>\n        <\/font>\n        <font weight="900" style="normal" postScriptName="NotoSerifHentaigana-ExtraLight">\n            NotoSerifHentaigana.ttf\n            <axis tag="wght" stylevalue="900" \/>\n        <\/font>\n    <\/family>/};
' $MODPATH$SYSTEMFILEPATH$FILE
sed -i '
/<family lang=\"ko\">/,/<\/family>/ {:a;N;/<\/family>/!ba;
s/<family lang=\"ko\">.*Noto.*CJK.*<\/family>/<family lang="ko">\n<font weight="100" style="normal" index="1" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="100" \/><\/font>\n<font weight="200" style="normal" index="1" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="200" \/><\/font>\n<font weight="300" style="normal" index="1" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="300" \/><\/font>\n<font weight="400" style="normal" index="1" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="400" \/><\/font>\n<font weight="500" style="normal" index="1" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="500" \/><\/font>\n<font weight="600" style="normal" index="1" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="600" \/><\/font>\n<font weight="700" style="normal" index="1" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="700" \/><\/font>\n<font weight="800" style="normal" index="1" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="800" \/><\/font>\n<font weight="900" style="normal" index="1" postScriptName="NotoSansCJKjp-Thin">NotoSansCJK-VF.otf.ttc<axis tag="wght" stylevalue="900" \/><\/font>\n<font weight="200" style="normal" index="1" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="200" \/><\/font>\n<font weight="300" style="normal" index="1" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="300" \/><\/font>\n<font weight="400" style="normal" index="1" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="400" \/><\/font>\n<font weight="500" style="normal" index="1" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="500" \/><\/font>\n<font weight="600" style="normal" index="1" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="600" \/><\/font>\n<font weight="700" style="normal" index="1" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="700" \/><\/font>\n<font weight="800" style="normal" index="1" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="800" \/><\/font>\n<font weight="900" style="normal" index="1" fallbackFor="serif" postScriptName="NotoSerifCJKjp-ExtraLight">NotoSerifCJK-VF.otf.ttc<axis tag="wght" stylevalue="900" \/><\/font>\n<\/family>\n<family lang="ko">\n<font weight="400" style="normal" index="1" postScriptName="NotoSansCJKjp-Regular">NotoSansCJK-Regular.ttc<\/font>\n<font weight="400" style="normal" index="1" fallbackFor="serif" postScriptName="NotoSerifCJKjp-Regular">NotoSerifCJK-Regular.ttc<\/font>\n<\/family>/};
' $MODPATH$SYSTEMFILEPATH$FILE
fi
done
done
FILECUSTOM=fonts_customization.xml
FILECUSTOMPATH=/product/etc/
# magisk mirror compatbility
SYSTEMFILECUSTOMPATH=/system$FILECUSTOMPATH
if [ -f $FILECUSTOMPATH$FILECUSTOM ]; then
ui_print "- Migrating $FILECUSTOM"
if $CMDPREFIX grep -q "google-sans" $FILECUSTOMPATH$FILECUSTOM ; then
# Google Pixel's RRO
mkdir -p $MODPATH$SYSTEMFILECUSTOMPATH
if [ ! -f $BAKPATH$FILECUSTOMPATH$FILECUSTOM ]; then
ui_print "- Backup $FILE to $BAKPATH"
mkdir -p $BAKPATH$FILECUSTOMPATH
$CMDPREFIX cp -af $FILECUSTOMPATH$FILECUSTOM $BAKPATH$FILECUSTOMPATH$FILECUSTOM
fi
cp -af $BAKPATH$FILECUSTOMPATH$FILECUSTOM $MODPATH$SYSTEMFILECUSTOMPATH$FILECUSTOM
sed -i '
/<family customizationType=\"new-named-family\" name=\"google-sans-medium\">/,/<\/family>/ {/<\/family>/! d;
/<\/family>/ s/.*/  <alias name="google-sans-medium" to="google-sans" weight="500" \/>/};
/<family customizationType=\"new-named-family\" name=\"google-sans-bold\">/,/<\/family>/ {/<\/family>/! d;
/<\/family>/ s/.*/  <alias name="google-sans-bold" to="google-sans" weight="700" \/>/};
/<family customizationType=\"new-named-family\" name=\"google-sans-text-medium\">/,/<\/family>/ {/<\/family>/! d;
/<\/family>/ s/.*/  <alias name="google-sans-text-medium" to="google-sans-text" weight="500" \/>/};
/<family customizationType=\"new-named-family\" name=\"google-sans-text-bold\">/,/<\/family>/ {/<\/family>/! d;
/<\/family>/ s/.*/  <alias name="google-sans-text-bold" to="google-sans-text" weight="700" \/>/};
/<family customizationType=\"new-named-family\" name=\"google-sans-text-italic\">/,/<\/family>/ {/<\/family>/! d;
/<\/family>/ s/.*/  <alias name="google-sans-text-italic" to="google-sans-text" weight="400" style="italic" \/>/};
/<family customizationType=\"new-named-family\" name=\"google-sans-text-medium-italic\">/,/<\/family>/ {/<\/family>/! d;
/<\/family>/ s/.*/  <alias name="google-sans-text-medium-italic" to="google-sans-text" weight="500" style="italic" \/>/};
/<family customizationType=\"new-named-family\" name=\"google-sans-text-bold-italic\">/,/<\/family>/ {/<\/family>/! d;
/<\/family>/ s/.*/  <alias name="google-sans-text-bold-italic" to="google-sans-text" weight="700" style="italic" \/>/};
' $MODPATH$SYSTEMFILECUSTOMPATH$FILECUSTOM
# else
# RRO oem fonts customization https://source.android.com/devices/automotive/hmi/car_ui/fonts
# TODO: pattern for general customizationType
# ui_print "================================="
# ui_print "! Please report your $FILECUSTOMPATH$FILECUSTOM."
# ui_print "================================="
fi
fi
ui_print "- Migration done."
rm $MODPATH/LICENSE* 2>/dev/null
