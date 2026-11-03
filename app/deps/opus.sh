#!/usr/bin/env bash
set -ex
. $(dirname ${BASH_SOURCE[0]})/_init
process_args "$@"

VERSION=1.5.2
URL="https://downloads.xiph.org/releases/opus/opus-$VERSION.tar.gz"
SHA256SUM=65c1d2f78b9f2fb20082c38cbe47c951ad5839345876e46941612ee87f9a7ce1

PROJECT_DIR="opus-$VERSION"
FILENAME="$PROJECT_DIR.tar.gz"

cd "$SOURCES_DIR"

if [[ -d "$PROJECT_DIR" ]]
then
    echo "$PWD/$PROJECT_DIR" found
else
    get_file "$URL" "$FILENAME" "$SHA256SUM"
    tar xf "$FILENAME"
fi

mkdir -p "$BUILD_DIR/$PROJECT_DIR"
cd "$BUILD_DIR/$PROJECT_DIR"

if [[ -d "$DIRNAME" ]]
then
    echo "'$PWD/$DIRNAME' already exists, not reconfigured"
    cd "$DIRNAME"
else
    mkdir "$DIRNAME"
    cd "$DIRNAME"

    conf=(
        --prefix="$INSTALL_DIR/$DIRNAME"
        --libdir="$INSTALL_DIR/$DIRNAME/lib"
        # Always build opus statically (linked into avcodec)
        --enable-static
        --disable-shared
        --disable-doc
        --disable-extra-programs
        --disable-stack-protector
        --with-pic
    )

    if [[ "$BUILD_TYPE" == cross ]]
    then
        conf+=(--host="$HOST_TRIPLET")
    fi

    CFLAGS="-O2" "$SOURCES_DIR/$PROJECT_DIR/configure" "${conf[@]}"
fi

make -j"$(nproc 2>/dev/null || echo 4)"
make install
