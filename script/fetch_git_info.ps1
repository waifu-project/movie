$FILE = "lib/git_info.dart"

$COMMIT = git rev-parse --short HEAD
$DESCRIBE = git describe --tags --always

# copy by ChatGPT

# copy by https://gist.github.com/ericbmerritt/f52f1c48b86150704270
# https://gist.github.com/rponte/fdc0724dd984088606b0

# increment the build number (ie 115 to 116)
$VERSION = ($DESCRIBE -split '-')[0]
$BUILD = ($DESCRIBE -split '-')[1]
$PATCH = ($DESCRIBE -split '-')[2]

if ($DESCRIBE -match '^[A-Fa-f0-9]+$') {
    $VERSION = "0.0.0"
    $BUILD = $(git rev-list HEAD --count)
    $PATCH = $DESCRIBE
}

if (-not $BUILD) {
    $BUILD = '0'
}

if (-not $PATCH) {
    $PATCH = $DESCRIBE
}

$REAL_VERSION = "$BUILD.$PATCH"
Set-Content -Path $FILE -Value "const gitCommit = '$COMMIT';`nconst gitTag = '$REAL_VERSION';"
