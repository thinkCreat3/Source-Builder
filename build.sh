
# Set variables
ROOT_PATH=/data/user/0/com.gmail.heagoo.apkbuilder/files
CUR_PATH=$(pwd)
OUTPUT_NAME=release

# Check for 'res' and 'src' directories
if [ ! -d "res" ] || [ ! -d "src" ]; then
    echo "Error: 'res' and 'src' directories are required for building the app."
    exit 1
fi

# Generate R.java
${ROOT_PATH}/bin/aapt package -m \
    -J gen \
    -M AndroidManifest.xml \
    -S res \
    -I ${ROOT_PATH}/bin/android.jar

# Compile Java code
/system/bin/dalvikvm -Djava.io.tmpdir=${ROOT_PATH}/tmp -Xmx256m \
    -cp ${ROOT_PATH}/bin/ecj.jar \
    org.eclipse.jdt.internal.compiler.batch.Main \
    -proc:none \
    -7 \
    -cp ${ROOT_PATH}/bin/android.classes.jar \
    -cp gen \
    -d bin/classes \
    -sourcepath src $(find src -type f -name "*.java")

# Convert class files to DEX file
/system/bin/dalvikvm -Xmx256m \
    -cp ${ROOT_PATH}/bin/dx.dex \
    dx.dx.command.Main --dex --output=./bin/classes.dex ./bin/classes

# Package resources and DEX file into APK
${ROOT_PATH}/bin/aapt package -f \
    -I ${ROOT_PATH}/bin/android.jar \
    -S res \
    -M AndroidManifest.xml \
    -A assets \
    -F bin/${OUTPUT_NAME}.apk \
    -c apk \
    --no-version-vectors \
    --min-sdk-version 21 \
    bin/classes.dex

# Sign APK
/system/bin/dalvikvm -cp ${ROOT_PATH}/bin/apksigner.dex net.fornwall.apksigner.Main \
    -p my-release-key.pk8 \
    -k my-release-key.x509.pem \
    bin/${OUTPUT_NAME}.apk

echo "APK file has been built: bin/${OUTPUT_NAME}.apk"

