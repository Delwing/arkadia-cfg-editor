hdiutil attach $1/editor.dmg
if [ -d "/Applications/arkadia-cfg-editor.app/" ]
then
  rm -R /Applications/arkadia-cfg-editor.app/
fi
cp -pPR "/Volumes/arkadia-cfg-editor $2/arkadia-cfg-editor.app/" /Applications/arkadia-cfg-editor.app
hdiutil detach /Volumes/arkadia-cfg-editor\ $2/