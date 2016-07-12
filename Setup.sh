if ! command -v carthage > /dev/null; then
printf 'Carthage is not installed.\n'
printf 'See https://github.com/Carthage/Carthage for install instructions.\n'
exit 1
fi

carthage update RxSwift &&
carthage update Quick Nimble --platform ios,mac