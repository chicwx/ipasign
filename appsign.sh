# 准备文件
# 1.将ipa放在input文件夹
# 2.将签名文件embedded.mobileprovision放在与脚本同级目录

# 输出
# 生成的新ipa在output目录
PRODUCT_PATH="output"
# 修改bundleid，吃参数改为${1}
PRODUCT_BUNDLE_IDENTIFIER="com.test.bundleId"
# 证书名称，换成你的证书
EXPANDED_CODE_SIGN_IDENTITY=""

#用来放置ipa包
crackPath="input"
#获取越狱版本Ipa路径
oldIpaPath="${crackPath}/*.ipa"
# 创建一个临时文件夹，用来放置解压的Ipa文件
tempPath="input/temp"

#首先先清空temp文件夹
rm -rf "$tempPath"
#创建临时文件夹目录
mkdir -p "$tempPath"

# 解压IPA
unzip -oqq "$oldIpaPath" -d "$tempPath"
# 拿到解压的临时的APP的路径
targetAppPath=$(set -- "$tempPath/Payload/"*.app;echo "$1")

# 获取二进制文件名称
nowPath=`pwd`
exectName=`/usr/bin/defaults read $nowPath/$targetAppPath/Info.plist CFBundleExecutable`
echo "exectName = $exectName"

# 打印app路径
echo "app路径 = $targetAppPath"

# 删除extension和WatchAPP.个人证书没法签名Extention
rm -rf "$targetAppPath/PlugIns"
rm -rf "$targetAppPath/Watch"

# 4. 更新info.plist文件 CFBundleIdentifier,PlistBuddy是更改plist文件的可执行文件
#  设置:"Set : KEY Value" "目标文件路径"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $PRODUCT_BUNDLE_IDENTIFIER" "$targetAppPath/Info.plist"

#frameWork签名
tagetAppFramworkPath="$targetAppPath/Frameworks"
if [ -d "$tagetAppFramworkPath" ];
then
for frameWork in "$tagetAppFramworkPath/"*
do

/usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" "$frameWork"
done
fi

# 替换证书配置文件
cp embedded.mobileprovision $targetAppPath

# 读取embedded.mobileprovision中的权限信息，生成entitlements.plist
/usr/bin/security cms -D -i embedded.mobileprovision > entitlements_full.plist
# 只需要entitlements_full.plist中的Entitlements字段
/usr/libexec/PlistBuddy -x -c 'Print:Entitlements'  entitlements_full.plist > entitlements.plist

# 添加权限
/bin/chmod 755 "$targetAppPath/$exectName"
# 对二进制文件签名
/usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" --entitlements entitlements.plist "$targetAppPath/$exectName"
# 校验签名
/usr/bin/codesign -v "$targetAppPath"


# 将app文件拷到output
mkdir "$PRODUCT_PATH/Payload" 
mv $targetAppPath "$PRODUCT_PATH/Payload/$exectName.app"
cd $PRODUCT_PATH
# 压缩生成ipa
echo "正在生成ipa:$PRODUCT_PATH/$exectName.ipa"
/usr/bin/zip -qry "$exectName.ipa" .
cd ../

# 删除临时文件
rm -rf "$tempPath"
rm -rf "output/Payload"
rm -rf entitlements_full.plist
rm -rf entitlements.plist





