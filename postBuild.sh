#Throws warnings for TODO: and FIXME: comments
TAGS="TODO:|FIXME:"
find "${SRCROOT}/Sources" \( -name "*.h" -or -name "*.m" -or -name "*.swift" \) -print0 | xargs -0 egrep -s --with-filename --line-number --only-matching "($TAGS).*\$" | perl -p -e "s/($TAGS)/ warning: \$1/"

#Set podspec values based on xcode project values
if [ -n "$IPHONEOS_DEPLOYMENT_TARGET" ]; then
find "${SRCROOT}/RxSwiftAddons.podspec" -exec sed -i '' -e "s/s\.ios\.deployment_target = .*/s.ios.deployment_target = \'$IPHONEOS_DEPLOYMENT_TARGET\'/g" {} \;
fi

if [ -n "$MACOSX_DEPLOYMENT_TARGET" ]; then
find "${SRCROOT}/RxSwiftAddons.podspec" -exec sed -i '' -e "s/s\.osx\.deployment_target = .*/s.osx.deployment_target = \'$MACOSX_DEPLOYMENT_TARGET\'/g" {} \;
fi

if [ -n "$WATCHOS_DEPLOYMENT_TARGET" ]; then
find "${SRCROOT}/RxSwiftAddons.podspec" -exec sed -i '' -e "s/s\.watchos\.deployment_target = .*/s.watchos.deployment_target = \'$WATCHOS_DEPLOYMENT_TARGET\'/g" {} \;
fi

if [ -n "$TVOS_DEPLOYMENT_TARGET" ]; then
find "${SRCROOT}/RxSwiftAddons.podspec" -exec sed -i '' -e "s/s\.tvos\.deployment_target = .*/s.tvos.deployment_target = \'$TVOS_DEPLOYMENT_TARGET\'/g" {} \;
fi

if [ -n "$VERSION_STRING" ]; then
find "${SRCROOT}/RxSwiftAddons.podspec" -exec sed -i '' -e "s/s.version          = .*/s.version          = \"$VERSION_STRING\"/g" {} \;
fi
