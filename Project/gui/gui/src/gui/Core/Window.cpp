#include <pch.h>
#include "GUI/Core/Window.h"

#ifdef TM_PLATFORM_WINDOWS
#include "Platform/Windows/WindowsWindow.h"
#endif

namespace GUI
{

	Scope<Window> Window::Create(const WindowProps& props)
	{
#ifdef TM_PLATFORM_WINDOWS
		return CreateScope<WindowsWindow>(props);
#else
		TM_CORE_ASSERT(false, "Unknown platform!");
		return nullptr;
#endif
	}

}
