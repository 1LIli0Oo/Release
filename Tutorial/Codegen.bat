pushd GacUI_HelloWorlds
pushd CppXml\UI
call Codegen.bat
popd
pushd MVVM\UI
call Codegen.bat
popd
popd
pushd GacUI_Layout
pushd Alignment\UI
call Codegen.bat
popd
pushd Stack\UI
call Codegen.bat
popd
pushd Table\UI
call Codegen.bat
popd
pushd Flow\UI
call Codegen.bat
popd
pushd RichTextEmbedding\UI
call Codegen.bat
popd
popd
pushd GacUI_Controls
pushd ContainersAndButtons\UI
call Codegen.bat
popd
pushd TextEditor\UI
call Codegen.bat
popd
popd
pushd GacUI_ControlTemplate
pushd BlackSkin\UI
call Codegen.bat
popd
popd