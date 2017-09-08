call "%VS140COMNTOOLS%..\..\VC\vcvarsall.bat"

set MAYA_VERSION=2016
set MAYA_LIB_DIR=%cd%\External\Maya2016\lib
set MAYA_INCLUDE_DIR=%cd%\External\Maya2016\include
msbuild MeshSyncClientMaya.vcxproj /t:Build /p:Configuration=Master /p:Platform=x64 /m /nologo
mkdir "UnityMeshSync for Maya\Maya2016\plug-ins"
copy _out\x64_Master\MeshSyncClientMaya2016\MeshSyncClientMaya.mll "UnityMeshSync for Maya\Maya2016\plug-ins"

set MAYA_VERSION=2016.5
set MAYA_LIB_DIR=%cd%\External\Maya2016.5\lib
set MAYA_INCLUDE_DIR=%cd%\External\Maya2016.5\include
msbuild MeshSyncClientMaya.vcxproj /t:Build /p:Configuration=Master /p:Platform=x64 /m /nologo
mkdir "UnityMeshSync for Maya\Maya2016.5\plug-ins"
copy _out\x64_Master\MeshSyncClientMaya2016.5\MeshSyncClientMaya.mll "UnityMeshSync for Maya\Maya2016.5\plug-ins"

set MAYA_VERSION=2017
set MAYA_LIB_DIR=%cd%\External\Maya2017\lib
set MAYA_INCLUDE_DIR=%cd%\External\Maya2017\include
msbuild MeshSyncClientMaya.vcxproj /t:Build /p:Configuration=Master /p:Platform=x64 /m /nologo
mkdir "UnityMeshSync for Maya\Maya2017\plug-ins"
copy _out\x64_Master\MeshSyncClientMaya2017\MeshSyncClientMaya.mll "UnityMeshSync for Maya\Maya2017\plug-ins"

mkdir "UnityMeshSync for Maya\scripts"
copy MeshSyncClientMaya\MEL\*.mel "UnityMeshSync for Maya\scripts"
copy MeshSyncClientMaya\MEL\*.mod "UnityMeshSync for Maya"

del "UnityMeshSync for Maya.zip"
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::CreateFromDirectory('UnityMeshSync for Maya', 'UnityMeshSync for Maya.zip'); }"
