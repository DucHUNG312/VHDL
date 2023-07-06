#pragma once

#include "gui/Core/Base.h"
#include "gui/Core/KeyCodes.h"
#include "gui/Core/MouseCodes.h"
#include <glm/glm.hpp>

namespace GUI {

	class Input
	{
	public:
		static bool IsKeyPressed(KeyCode keycode);

		static bool IsMouseButtonPressed(MouseCode button);
		static glm::vec2 GetMousePosition();
		static float GetMouseX();
		static float GetMouseY();
	};

}
