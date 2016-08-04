# Ask for admin passwd
sudo -v

# Get user info
computer_name=' '
user_name=' '
user_email=' '

echo -n "Computer name: "
read computer_name

echo -n 'Username: '
read user_name

echo -n 'Email address: '
read user_email

# Xcode
if ! xcode-select --print-path &> /dev/null; then

    # promtp to install xcode cli tools
    xcode-select --install &> /dev/null
    until xcode-select --print-path &> dev/null; do
        sleep 5
    done

    print_result $? 'Install xcode cli tools'

    sudo xcodebuild -license
    print_result $? 'Agree to xcode cli tools license'

fi


# Homebrew
echo '  » Gaining ownership of /usr/local'
sudo chown -R ${whoami}:admin /usr/local

echo '  » Checking for homebrew'
brew_path='https://raw.githubusercontent.com/Homebrew/install/master/install'
if test ! $(which brew)
then
    echo '  » Installing homebrew'
    ruby -e "$(curl -fsSL ${brew_path})"
fi

echo '  » Updating path for brews'
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bash_profile

echo '  » Updating homebrew'
brew update
brew upgrade

echo '  » Tapping caskroom/versions'
brew tap caskroom/versions

echo '  » Changing default cask install location to ~/Applications'
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

echo '  » Installing brews'
brew install $(cat brews | grep -v "#")

echo '  » Installing casks'
brew cask install $(cat casks | grep -v "#")

echo '  » Cleaning up brews'
brew cleanup

echo '  » Cleaning up casks'
brew cask cleanup


# pip
echo '  » Upgrading pip'
pip install -U pip

# pip3
echo '  » Upgrading pip3'
pip3 install -U pip

echo '  » Installing python packages'
pip install $(cat pips | grep -v "#")


# Setup dotfiles
echo '  » Cloning vundle'
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

echo '  » Creating: ~/programming'
mkdir ~/programming

echo '  » Cloning dotfiles repo'
git clone ~/programming/https://github.com/fairclothjm/dotfiles.git


# Symlink dotfiles
echo '  » Symlinking bash_profile'
ln -s ~/programming/dotfiles/bash_profile ~/.bash_profile

echo '  » Symlinking bashrc'
ln -s ~/programming/dotfiles/bashrc ~/.bashrc

echo '  » Symlinking vimrc'
ln -s ~/programming/dotfiles/vimrc ~/.vimrc

echo '  » Symlinking tmux.conf'
ln -s ~/programming/dotfiles/tmux.conf ~/.tmux.conf

echo '  » Symlinks:'
ls -ld ~/.bash_profile ~/.bashrc ~/.vimrc ~/.tmux.conf

# Set computer name
echo '  » Setting computer name '
sudo scutil --set ComputerName $computer_name
sudo scutil --set HostName $computer_name
sudo scutil --set LocalHostName $computer_name
sys_config_path='/Library/Preferences/SystemConfiguration/com.apple.smb.server' 
sudo defaults write ${sys_config_path} NetBIOSName -string $computer_name

echo '  » Wiping all default apps from dock '
defaults write com.apple.dock persistent-apps -array

echo '  » Auto-hide dock and remove delay '
defaults write com.apple.dock autohide -bool false
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0

# Disable the warning before emptying the Trash
echo '  » Disable warning before emptying the trash '
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Show the ~/Library folder
echo '  » Show the ~/Library folder '
chflags nohidden ~/Library

# Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app
echo '  » Add the keyboard shortcut ⌘ + Enter to send an email '
defaults write com.apple.mail NSUserKeyEquivalents \ 
-dict-add "Send" -string "@\\U21a9"

# Disable prompt when quitting iterm2
echo '  » Disable prompt when quitting iterm2 '
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

# Don’t automatically rearrange Spaces based on most recent use
echo '  » Stop automatically rearranging spaces based on time '
defaults write com.apple.dock mru-spaces -bool false

# expand save prompt
echo '  » Expand save prompt '
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# quit printer app when there are no pending jobs
echo '  » Quit printer app when there are no pending jobs '
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# check for updates daily
echo '  » Check for Apple updates daily '
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# disable smart quotes, auto-correct spelling, and smart dashes
echo '  » Disable smart quotes, auto-correct spelling, and smart dashes '
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# prevent Photos from opening when inserting external media
echo '  » Prevent photos from opening when instering drives '
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

# Disable attachment previews in Mail.app
echo '  » Disable attachment previews in Mail.app'
defaults write com.apple.mail DisableInlineAttachmentViewing -bool yes

# increase Bluetooth sound quality
echo '  » Increase bluetooth sound quality '
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

# disable press-and-hold for special keys
echo '  » Disable special key press-and-hold '
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# increase key repeat rate
echo '  » Increase key repeat rate '
defaults write NSGlobalDomain KeyRepeat -int 0

# disable auto-brightness on keyboard and screen
echo '  » Disable auto-brightness '
light_sensor_path='/Library/Preferences/com.apple.iokit.AmbientLightSensor' 
sudo defaults write ${light_sensor_path} "Automatic Keyboard Enabled" -bool false
sudo defaults write ${light_sensor_path} "Automatic Display Enabled" -bool false

# create folder for screenshots in documents
echo '  » Create folder for screenshots in documents '
ss_path=${HOME}'/Documents/screenshots'
defaults write com.apple.screencapture location -string "${ss_path}"

# enable hidpi mode
echo '  » Enable hidpi '
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

# enable font rendering on non-apple displays
echo '  » Enable font rendering on non-apple displays '
defaults write NSGlobalDomain AppleFontSmoothing -int 2

# show full path in finder
echo '  » Show full path in finder '
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# disable warning when changing file extension
echo '  » Disable warning when changing file extension '
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# disable .DS_Store on network drives
echo '  » Prevent creation of .DS_Store on network drives '
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# enable snap to grid for desktop and icon view
echo '  » Enable snap to grid '
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

# set column view as default
echo '  » Set column view as default in finder '
defaults write com.apple.finder FXPreferredViewStyle Clmv

# set dock icons to 48px
echo '  » Set dock icons to 48px '
defaults write com.apple.dock tilesize -int 48

# reformat copying email addresses
echo '  » Reformat copying email addresses in mail.app '
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

#disable gatekeeper
echo '  » Disable gatekeeper '
sudo spctl --master-disable

# change crash reporter to notification
echo '  » Change crash reporter to notification '
defaults write com.apple.CrashReporter UseUNC 1

# create global .gitignore
echo '  » Create global .gitignore '
# curl -# https://raw.githubusercontent.com/theavish/env-init/master/assets/gitignore.txt > ~/.gitignore

# set git user info and credentials
echo '  » Set git user info and credentials '
git config --global user.name $user_name
git config --global user.email $user_email
git config --global credential.helper osxkeychain
git config --global core.editor 'vim -n -w'
