#!/bin/sh

#clean
rm -rf ./out
mkdir out
cd bin

#ini
#定义市场列表，以空格分割
markets="channelA channelB channelC"
apk="yourapk.apk"
appname=$(echo $apk | awk -F. '{print $1}')
version=$(aapt dump badging $apk | sed -n "s/.*versionName='\([^']*\).*/\1/p")
pwd="yourpassword"
cp ../key/android.keystore ./

#解包
apktool d $apk

#清理旧签名
rm -rf ./${appname}/original/META-INF/CERT.RSA ./${appname}/original/META-INF/CERT.SF

#循环市场列表，分别传值给各个脚本
for market in $markets
do
    #替换AndroidManifest.xml中Channel值(针对友盟,其他同理)
    #<meta-data android:name="UMENG_CHANNEL" android:value="${channel}" />

    #MAC
    #sed -i '' "s/\(android:name=\"UMENG_CHANNEL\"\)\( android:value=\)\"\(.*\)\"/\1\2\"$market\"/g" ${appname}/AndroidManifest.xml

    #Linux
    sed -i "s/\(android:name=\"UMENG_CHANNEL\"\)\( android:value=\)\"\(.*\)\"/\1\2\"$market\"/g" ${appname}/AndroidManifest.xml

    #打包
    apktool b $appname

    #签名
    jarsigner -sigalg MD5withRSA -digestalg SHA1 -keystore android.keystore -storepass $pwd -signedjar ./${appname}/dist/signed.apk ./${appname}/dist/${apk} android.keystore

    #对齐
    zipalign -v 4 ./${appname}/dist/signed.apk ../out/${appname}_${version}_${market}_Release.apk
done