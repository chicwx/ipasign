# 脚本功能
### 将ipa进行拆包，修改部分内容，进行二次签名，可用于渠道包的快速批量生产
# Usage
1. 将ipa放在input文件夹
2. 将签名文件embedded.mobileprovision放在与脚本同级目录
3. 打开脚本，填写EXPANDED_CODE_SIGN_IDENTITY（打包用的证书）
4. 执行脚本 sh appsign.sh
5. 打包成功后的ipa在output目录
