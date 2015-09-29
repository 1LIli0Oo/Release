#include "UI/Source/Demo.h"
#include <Windows.h>

using namespace vl::collections;
using namespace vl::stream;

int CALLBACK WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int CmdShow)
{
	return SetupWindowsDirect2DRenderer();
}

void GuiMain()
{
	{
		List<WString> errors;
		FileStream fileStream(L"../UIRes/Flow.bin", FileStream::ReadOnly);
		auto resource = GuiResource::LoadPrecompiledBinary(fileStream, errors);
		GetInstanceLoaderManager()->SetResource(L"Resource", resource);
	}
	demo::MainWindow window;
	window.MoveToScreenCenter();
	GetApplication()->Run(&window);
}