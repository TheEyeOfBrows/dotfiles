#! /bin/bash
HERE="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd )"

check_admin() {
    case $OSTYPE in
        cygwin | msys | win32)
            gitDir="${GIT_DIR:-/c/Program Files/Git}"
            shell=$(cygpath -w "$gitDir/bin/bash.exe")

            net session > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                echo "This script requires administrative privileges. Relaunching with elevated privileges..."
                powershell -Command "Start-Process '$shell' -ArgumentList '$0' -Verb RunAs"
                exit 1
            fi
            ;;
    esac
}

windowsHome() {
    case $OSTYPE in
        cygwin | msys | win32)
            if [ -z "$HOME" ]; then
                export HOME=$(cygpath -u $USERPROFILE)
                setx HOME $(cygpath -w "$HOME")
                echo setx HOME $(cygpath -w "$HOME")
            fi
            ;;
    esac
}

symlinkFile() {
    filename="$HERE/$1"
    destination=$(echo "$HOME/$2/$1" | sed 's|//|/|g')

    mkdir -p "$(dirname "$destination")"

    if [ -L "$destination" ]; then
        echo "[WARN] [$1] already simlinked [$filename]"
        return
    fi

    if [ -e "$destination" ]; then
        echo "[ERROR] [$destination] exists but it's not a symlink"
        exit 1
    fi

    case $OSTYPE in
        cygwin | msys | win32)
            check_admin
            cmd //c mklink "$(cygpath -w "$destination")" "$(cygpath -w "$filename")" 
            ;;
        *)  ln -s "$filename" "$destination" ;;
    esac
    echo "[OK] [$filename] -> [$destination]"
}

sourceFile() {
    filename="$HERE/$1"
    destination=$(echo "$HOME/$2/$1" | sed 's|//|/|g')
    start_tag="# START source $filename"
    end_tag="# END source $filename"
    source_line="source \"$filename\""

    if [ ! -f "$destination" ]; then
        echo "[WARN] Creating destination file: $destination"
        touch "$destination"
    fi

    if ! grep -q "$start_tag" "$destination"; then
        {
            echo ""
            echo "$start_tag"
            echo "$source_line"
            echo "$end_tag"
        } >> "$destination"
        echo "[OK] [$1] source added to [$destination]"
    else
        echo "[WARN] [$1] source already exists in [$destination]"
    fi
}


# deployManifest ManifestFile
deployManifest() {
    for row in $(cat $HERE/$1); do
        if [[ "$row" =~ ^#.* ]]; then
            continue
        fi

        filename="$(echo $row | cut -d \| -f 1)"
        operation="$(echo $row | cut -d \| -f 2)"
        destination="$(echo $row | cut -d \| -f 3)"

        case $operation in
            symlink)
                symlinkFile $filename $destination
                ;;
            source)
                sourceFile $filename $destination
                ;;
            *)
                echo "Unknown operation: $operation"
                ;;
        esac
    done
}

windowsHome
deployManifest MANIFEST