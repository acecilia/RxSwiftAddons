#Throws warnings for TODO: and FIXME: comments
TAGS="TODO:|FIXME:"
ERRORTAG="ERROR:"
find "${SRCROOT}/Sources" \( -name "*.h" -or -name "*.m" -or -name "*.swift" \) -print0 | xargs -0 egrep -s --with-filename --line-number --only-matching "($TAGS).*\$|($ERRORTAG).*\$" | perl -p -e "s/($TAGS)/ warning: \$1/" | perl -p -e "s/($ERRORTAG)/ error: \$1/"

#Set podspec values based on xcode project values
PODSPEC="$SRCROOT/RxSwiftAddons.podspec"
IOS_VERSION="$IPHONEOS_DEPLOYMENT_TARGET"
MACOS_VERSION="$MACOSX_DEPLOYMENT_TARGET"
WHATCHOS_VERSION="$WATCHOS_DEPLOYMENT_TARGET"
TVOS_VERSION="$TVOS_DEPLOYMENT_TARGET"
VERSION="$VERSION_STRING"

if [ -n "$IOS_VERSION" ]; then
MATCHSTRING="s.ios.deployment_target = "
REPLACESTRING="s.ios.deployment_target = \'$IOS_VERSION\'"
sed -i '' -e "s/$MATCHSTRING.*/$REPLACESTRING/g" "$PODSPEC"
fi

if [ -n "$MACOS_VERSION" ]; then
MATCHSTRING="s.osx.deployment_target = "
REPLACESTRING="s.osx.deployment_target = \'$MACOS_VERSION\'"
sed -i '' -e "s/$MATCHSTRING.*/$REPLACESTRING/g" "$PODSPEC"
fi

if [ -n "$WHATCHOS_VERSION" ]; then
MATCHSTRING="s.watchos.deployment_target = "
REPLACESTRING="s.watchos.deployment_target = \'$WHATCHOS_VERSION\'"
sed -i '' -e "s/$MATCHSTRING.*/$REPLACESTRING/g" "$PODSPEC"
fi

if [ -n "$TVOS_VERSION" ]; then
MATCHSTRING="s.tvos.deployment_target = "
REPLACESTRING="s.tvos.deployment_target = \'$TVOS_VERSION\'"
sed -i '' -e "s/$MATCHSTRING.*/$REPLACESTRING/g" "$PODSPEC"
fi

if [ -n "$VERSION" ]; then
MATCHSTRING="s.version          = "
REPLACESTRING="s.version          = \"$VERSION\""
sed -i '' -e "s/$MATCHSTRING.*/$REPLACESTRING/g" "$PODSPEC"
fi

#Remind to reflect project structure changes to disk before committing
if git diff --name-only | grep .xcodeproj > /dev/null; then
printf 'warning: You modified the project structure, make sure to reflect those changes to the disk folder structure. You can do it easily with synx. Find more at: https://github.com/venmo/synx.\n'
exit 0
fi