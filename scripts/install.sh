#!/bin/bash

set -e

BINARY_NAME="CleanZipForMac"
INSTALL_PATH="/usr/local/bin/$BINARY_NAME"
SERVICES_DIR="$HOME/Library/Services"
ZIP_WORKFLOW="$SERVICES_DIR/Compress as Clean ZIP.workflow"
TARGZ_WORKFLOW="$SERVICES_DIR/Compress as Clean TAR.GZ.workflow"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

QUICK_ACTIONS_ONLY=false
DOCTOR_MODE=false
UNINSTALL_MODE=false

if [ "$1" = "--quick-actions-only" ]; then
    QUICK_ACTIONS_ONLY=true
elif [ "$1" = "--doctor" ]; then
    DOCTOR_MODE=true
elif [ "$1" = "--uninstall" ]; then
    UNINSTALL_MODE=true
fi

# Function to check if binary exists
check_binary() {
    if [ -x "$INSTALL_PATH" ]; then
        return 0
    else
        return 1
    fi
}

run_uninstall() {
    echo "🗑️ Uninstalling CleanZipForMac..."
    
    if [ -f "$INSTALL_PATH" ]; then
        echo "  • Removing binary: $INSTALL_PATH"
        sudo rm -f "$INSTALL_PATH"
    else
        echo "  • Binary not found: $INSTALL_PATH"
    fi
    
    if [ -d "$ZIP_WORKFLOW" ]; then
        echo "  • Removing workflow: $ZIP_WORKFLOW"
        rm -rf "$ZIP_WORKFLOW"
    else
        echo "  • Workflow not found: $ZIP_WORKFLOW"
    fi
    
    if [ -d "$TARGZ_WORKFLOW" ]; then
        echo "  • Removing workflow: $TARGZ_WORKFLOW"
        rm -rf "$TARGZ_WORKFLOW"
    else
        echo "  • Workflow not found: $TARGZ_WORKFLOW"
    fi
    
    if [ -x "/System/Library/CoreServices/pbs" ]; then
        /System/Library/CoreServices/pbs -flush
    fi
    
    echo "✅ Uninstallation complete!"
    return 0
}

if [ "$UNINSTALL_MODE" = true ]; then
    run_uninstall
    exit $?
fi

run_doctor() {
    local has_error=0

    echo "🩺 Running Quick Actions diagnostics..."

    if check_binary; then
        echo "✅ Binary found: $INSTALL_PATH"
    else
        echo "❌ Binary not found or not executable: $INSTALL_PATH"
        has_error=1
    fi

    if [ -f "$ZIP_WORKFLOW/Contents/document.wflow" ]; then
        echo "✅ ZIP workflow exists"
        if [ -f "$ZIP_WORKFLOW/Contents/Info.plist" ]; then
            echo "✅ ZIP Info.plist exists"
            if plutil -lint "$ZIP_WORKFLOW/Contents/Info.plist" > /dev/null 2>&1; then
                echo "✅ ZIP Info.plist is valid"
            else
                echo "❌ ZIP Info.plist is invalid"
                has_error=1
            fi
        else
            echo "❌ ZIP Info.plist missing"
            has_error=1
        fi
        if plutil -lint "$ZIP_WORKFLOW/Contents/document.wflow" > /dev/null 2>&1; then
            echo "✅ ZIP workflow plist is valid"
        else
            echo "❌ ZIP workflow plist is invalid"
            has_error=1
        fi
        local zip_input_type
        local zip_accepts_type
        zip_input_type="$(plutil -extract workflowMetaData.serviceInputTypeIdentifier raw "$ZIP_WORKFLOW/Contents/document.wflow" 2>/dev/null || true)"
        zip_accepts_type="$(plutil -extract actions.0.action.AMAccepts.Types.0 raw "$ZIP_WORKFLOW/Contents/document.wflow" 2>/dev/null || true)"
        if [ "$zip_input_type" = "com.apple.Automator.fileSystemObject" ]; then
            echo "✅ ZIP workflow input type is com.apple.Automator.fileSystemObject"
        else
            echo "❌ ZIP workflow input type is invalid: $zip_input_type"
            has_error=1
        fi
        if [ "$zip_accepts_type" = "com.apple.cocoa.path" ]; then
            echo "✅ ZIP workflow AMAccepts type is com.apple.cocoa.path"
        else
            echo "❌ ZIP workflow AMAccepts type is invalid: $zip_accepts_type"
            has_error=1
        fi
        if grep -Fq '"$BINARY" zip "$@"' "$ZIP_WORKFLOW/Contents/document.wflow"; then
            echo "✅ ZIP workflow command matches expected invocation"
        else
            echo "❌ ZIP workflow command does not match expected invocation"
            has_error=1
        fi
    else
        echo "❌ ZIP workflow missing: $ZIP_WORKFLOW/Contents/document.wflow"
        has_error=1
    fi

    if [ -f "$TARGZ_WORKFLOW/Contents/document.wflow" ]; then
        echo "✅ TAR.GZ workflow exists"
        if [ -f "$TARGZ_WORKFLOW/Contents/Info.plist" ]; then
            echo "✅ TAR.GZ Info.plist exists"
            if plutil -lint "$TARGZ_WORKFLOW/Contents/Info.plist" > /dev/null 2>&1; then
                echo "✅ TAR.GZ Info.plist is valid"
            else
                echo "❌ TAR.GZ Info.plist is invalid"
                has_error=1
            fi
        else
            echo "❌ TAR.GZ Info.plist missing"
            has_error=1
        fi
        if plutil -lint "$TARGZ_WORKFLOW/Contents/document.wflow" > /dev/null 2>&1; then
            echo "✅ TAR.GZ workflow plist is valid"
        else
            echo "❌ TAR.GZ workflow plist is invalid"
            has_error=1
        fi
        local targz_input_type
        local targz_accepts_type
        targz_input_type="$(plutil -extract workflowMetaData.serviceInputTypeIdentifier raw "$TARGZ_WORKFLOW/Contents/document.wflow" 2>/dev/null || true)"
        targz_accepts_type="$(plutil -extract actions.0.action.AMAccepts.Types.0 raw "$TARGZ_WORKFLOW/Contents/document.wflow" 2>/dev/null || true)"
        if [ "$targz_input_type" = "com.apple.Automator.fileSystemObject" ]; then
            echo "✅ TAR.GZ workflow input type is com.apple.Automator.fileSystemObject"
        else
            echo "❌ TAR.GZ workflow input type is invalid: $targz_input_type"
            has_error=1
        fi
        if [ "$targz_accepts_type" = "com.apple.cocoa.path" ]; then
            echo "✅ TAR.GZ workflow AMAccepts type is com.apple.cocoa.path"
        else
            echo "❌ TAR.GZ workflow AMAccepts type is invalid: $targz_accepts_type"
            has_error=1
        fi
        if grep -Fq '"$BINARY" targz "$@"' "$TARGZ_WORKFLOW/Contents/document.wflow"; then
            echo "✅ TAR.GZ workflow command matches expected invocation"
        else
            echo "❌ TAR.GZ workflow command does not match expected invocation"
            has_error=1
        fi
    else
        echo "❌ TAR.GZ workflow missing: $TARGZ_WORKFLOW/Contents/document.wflow"
        has_error=1
    fi

    if [ "$has_error" -eq 0 ]; then
        echo "✅ Diagnostics passed"
        return 0
    else
        echo "❌ Diagnostics failed"
        return 1
    fi
}

if [ "$DOCTOR_MODE" = true ]; then
    run_doctor
    exit $?
fi

# Build and install binary if needed
if [ "$QUICK_ACTIONS_ONLY" = true ]; then
    echo "🔧 Quick Actions only mode..."
    if ! check_binary; then
        echo "❌ Error: $BINARY_NAME binary not found."
        echo "   Please install the binary first."
        exit 1
    fi
elif check_binary; then
    echo "✅ $BINARY_NAME already installed, skipping build..."
else
    echo "🔨 Building $BINARY_NAME..."
    cd "$PROJECT_DIR"
    cargo build --release

    echo "📦 Installing binary to $INSTALL_PATH..."
    sudo cp target/release/$BINARY_NAME "$INSTALL_PATH"
    sudo chmod +x "$INSTALL_PATH"
fi

echo "🔧 Creating Quick Actions..."

# Create Services directory if it doesn't exist
mkdir -p "$SERVICES_DIR"

# Create ZIP Quick Action
mkdir -p "$ZIP_WORKFLOW/Contents"
cat > "$ZIP_WORKFLOW/Contents/document.wflow" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>AMApplicationBuild</key>
    <string>510</string>
    <key>AMApplicationVersion</key>
    <string>2.8</string>
    <key>actions</key>
    <array>
        <dict>
            <key>action</key>
            <dict>
                <key>AMAccepts</key>
                <dict>
                    <key>Container</key>
                    <string>List</string>
                    <key>Optional</key>
                    <true/>
                    <key>Types</key>
                    <array>
                        <string>com.apple.cocoa.path</string>
                    </array>
                </dict>
                <key>AMActionVersion</key>
                <string>2.0.3</string>
                <key>AMApplication</key>
                <array>
                    <string>Automator</string>
                </array>
                <key>AMCategory</key>
                <string>AMCategoryUtilities</string>
                <key>AMIconName</key>
                <string>Run Shell Script</string>
                <key>AMName</key>
                <string>Run Shell Script</string>
                <key>AMParameterProperties</key>
                <dict>
                    <key>COMMAND_STRING</key>
                    <dict/>
                    <key>CheckedForUserDefaultShell</key>
                    <dict/>
                    <key>inputMethod</key>
                    <dict/>
                    <key>shell</key>
                    <dict/>
                    <key>source</key>
                    <dict/>
                </dict>
                <key>AMProvides</key>
                <dict>
                    <key>Container</key>
                    <string>List</string>
                    <key>Types</key>
                    <array>
                        <string>com.apple.cocoa.path</string>
                    </array>
                </dict>
                <key>ActionBundlePath</key>
                <string>/System/Library/Automator/Run Shell Script.action</string>
                <key>ActionName</key>
                <string>Run Shell Script</string>
                <key>ActionParameters</key>
                <dict>
                    <key>COMMAND_STRING</key>
                    <string>BINARY="/usr/local/bin/CleanZipForMac"
if [ ! -x "$BINARY" ]; then
    osascript -e 'display alert "CleanZipForMac not found" message "Please reinstall the application." as critical'
    exit 1
fi

"$BINARY" zip "$@"
RESULT=$?

if [ $RESULT -eq 0 ]; then
    if [ $# -eq 1 ]; then
        NAME=$(basename "$1")
        # Escape double quotes for AppleScript
        NAME=${NAME//\"/\\\"}
        MSG="Created ZIP archive for ${NAME}"
    else
        MSG="Created ZIP archive for $# items"
    fi
    osascript -e "display notification \"${MSG}\" with title \"Clean Zip\""
else
    osascript -e "display alert \"Failed to create ZIP archive\" as critical"
fi</string>
                    <key>CheckedForUserDefaultShell</key>
                    <true/>
                    <key>inputMethod</key>
                    <integer>1</integer>
                    <key>shell</key>
                    <string>/bin/zsh</string>
                    <key>source</key>
                    <string></string>
                </dict>
                <key>BundleIdentifier</key>
                <string>com.apple.RunShellScript</string>
                <key>CFBundleVersion</key>
                <string>2.0.3</string>
                <key>CanShowSelectedItemsWhenRun</key>
                <false/>
                <key>CanShowWhenRun</key>
                <true/>
                <key>InputUUID</key>
                <string>UUID-1</string>
                <key>Keywords</key>
                <array>
                    <string>Shell</string>
                    <string>Script</string>
                    <string>Command</string>
                    <string>Run</string>
                    <string>Unix</string>
                </array>
                <key>OutputUUID</key>
                <string>UUID-2</string>
                <key>UUID</key>
                <string>UUID-3</string>
                <key>UnlocalizedApplications</key>
                <array>
                    <string>Automator</string>
                </array>
            </dict>
        </dict>
    </array>
    <key>connectors</key>
    <dict/>
    <key>workflowMetaData</key>
    <dict>
        <key>serviceApplicationBundleID</key>
        <string>com.apple.finder</string>
        <key>serviceInputTypeIdentifier</key>
        <string>com.apple.Automator.fileSystemObject</string>
        <key>serviceOutputTypeIdentifier</key>
        <string>com.apple.Automator.nothing</string>
        <key>serviceProcessesInput</key>
        <integer>0</integer>
        <key>workflowTypeIdentifier</key>
        <string>com.apple.Automator.servicesMenu</string>
    </dict>
</dict>
</plist>
EOF

cat > "$ZIP_WORKFLOW/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>English</string>
    <key>CFBundleGetInfoString</key>
    <string>Compress as Clean ZIP</string>
    <key>CFBundleIdentifier</key>
    <string>com.cleanzip.workflow.zip</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Compress as Clean ZIP</string>
    <key>CFBundlePackageType</key>
    <string>BNDL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>NSPrincipalClass</key>
    <string>AMWorkflowServiceApplication</string>
    <key>NSServices</key>
    <array>
        <dict>
            <key>NSMenuItem</key>
            <dict>
                <key>default</key>
                <string>Compress as Clean ZIP</string>
            </dict>
            <key>NSMessage</key>
            <string>runWorkflowAsService</string>
            <key>NSRequiredContext</key>
            <dict>
                <key>NSApplicationIdentifier</key>
                <string>com.apple.finder</string>
            </dict>
            <key>NSSendFileTypes</key>
            <array>
                <string>public.item</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
EOF

# Create TAR.GZ Quick Action
mkdir -p "$TARGZ_WORKFLOW/Contents"
cat > "$TARGZ_WORKFLOW/Contents/document.wflow" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>AMApplicationBuild</key>
    <string>510</string>
    <key>AMApplicationVersion</key>
    <string>2.8</string>
    <key>actions</key>
    <array>
        <dict>
            <key>action</key>
            <dict>
                <key>AMAccepts</key>
                <dict>
                    <key>Container</key>
                    <string>List</string>
                    <key>Optional</key>
                    <true/>
                    <key>Types</key>
                    <array>
                        <string>com.apple.cocoa.path</string>
                    </array>
                </dict>
                <key>AMActionVersion</key>
                <string>2.0.3</string>
                <key>AMApplication</key>
                <array>
                    <string>Automator</string>
                </array>
                <key>AMCategory</key>
                <string>AMCategoryUtilities</string>
                <key>AMIconName</key>
                <string>Run Shell Script</string>
                <key>AMName</key>
                <string>Run Shell Script</string>
                <key>AMParameterProperties</key>
                <dict>
                    <key>COMMAND_STRING</key>
                    <dict/>
                    <key>CheckedForUserDefaultShell</key>
                    <dict/>
                    <key>inputMethod</key>
                    <dict/>
                    <key>shell</key>
                    <dict/>
                    <key>source</key>
                    <dict/>
                </dict>
                <key>AMProvides</key>
                <dict>
                    <key>Container</key>
                    <string>List</string>
                    <key>Types</key>
                    <array>
                        <string>com.apple.cocoa.path</string>
                    </array>
                </dict>
                <key>ActionBundlePath</key>
                <string>/System/Library/Automator/Run Shell Script.action</string>
                <key>ActionName</key>
                <string>Run Shell Script</string>
                <key>ActionParameters</key>
                <dict>
                    <key>COMMAND_STRING</key>
                    <string>BINARY="/usr/local/bin/CleanZipForMac"
if [ ! -x "$BINARY" ]; then
    osascript -e 'display alert "CleanZipForMac not found" message "Please reinstall the application." as critical'
    exit 1
fi

"$BINARY" targz "$@"
RESULT=$?

if [ $RESULT -eq 0 ]; then
    if [ $# -eq 1 ]; then
        NAME=$(basename "$1")
        # Escape double quotes for AppleScript
        NAME=${NAME//\"/\\\"}
        MSG="Created TAR.GZ archive for ${NAME}"
    else
        MSG="Created TAR.GZ archive for $# items"
    fi
    osascript -e "display notification \"${MSG}\" with title \"Clean Zip\""
else
    osascript -e "display alert \"Failed to create TAR.GZ archive\" as critical"
fi</string>
                    <key>CheckedForUserDefaultShell</key>
                    <true/>
                    <key>inputMethod</key>
                    <integer>1</integer>
                    <key>shell</key>
                    <string>/bin/zsh</string>
                    <key>source</key>
                    <string></string>
                </dict>
                <key>BundleIdentifier</key>
                <string>com.apple.RunShellScript</string>
                <key>CFBundleVersion</key>
                <string>2.0.3</string>
                <key>CanShowSelectedItemsWhenRun</key>
                <false/>
                <key>CanShowWhenRun</key>
                <true/>
                <key>InputUUID</key>
                <string>UUID-4</string>
                <key>Keywords</key>
                <array>
                    <string>Shell</string>
                    <string>Script</string>
                    <string>Command</string>
                    <string>Run</string>
                    <string>Unix</string>
                </array>
                <key>OutputUUID</key>
                <string>UUID-5</string>
                <key>UUID</key>
                <string>UUID-6</string>
                <key>UnlocalizedApplications</key>
                <array>
                    <string>Automator</string>
                </array>
            </dict>
        </dict>
    </array>
    <key>connectors</key>
    <dict/>
    <key>workflowMetaData</key>
    <dict>
        <key>serviceApplicationBundleID</key>
        <string>com.apple.finder</string>
        <key>serviceInputTypeIdentifier</key>
        <string>com.apple.Automator.fileSystemObject</string>
        <key>serviceOutputTypeIdentifier</key>
        <string>com.apple.Automator.nothing</string>
        <key>serviceProcessesInput</key>
        <integer>0</integer>
        <key>workflowTypeIdentifier</key>
        <string>com.apple.Automator.servicesMenu</string>
    </dict>
</dict>
</plist>
EOF

cat > "$TARGZ_WORKFLOW/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>English</string>
    <key>CFBundleGetInfoString</key>
    <string>Compress as Clean TAR.GZ</string>
    <key>CFBundleIdentifier</key>
    <string>com.cleanzip.workflow.targz</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Compress as Clean TAR.GZ</string>
    <key>CFBundlePackageType</key>
    <string>BNDL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>NSPrincipalClass</key>
    <string>AMWorkflowServiceApplication</string>
    <key>NSServices</key>
    <array>
        <dict>
            <key>NSMenuItem</key>
            <dict>
                <key>default</key>
                <string>Compress as Clean TAR.GZ</string>
            </dict>
            <key>NSMessage</key>
            <string>runWorkflowAsService</string>
            <key>NSRequiredContext</key>
            <dict>
                <key>NSApplicationIdentifier</key>
                <string>com.apple.finder</string>
            </dict>
            <key>NSSendFileTypes</key>
            <array>
                <string>public.item</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
EOF

echo "✅ Installation complete!"
echo ""
echo "Two Quick Actions have been created:"
echo "  • Compress as Clean ZIP"
echo "  • Compress as Clean TAR.GZ"
echo ""
echo "To use: Right-click any file/folder in Finder → Quick Actions → select the desired format"
echo ""
echo "Note: You may need to log out and back in for the Quick Actions to appear in the context menu."

if [ -x "/System/Library/CoreServices/pbs" ]; then
    /System/Library/CoreServices/pbs -flush
fi

killall Finder > /dev/null 2>&1 || true
