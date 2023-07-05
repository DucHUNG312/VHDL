#pragma once

#include "GUI/Core/Layer.h"
#include "GUI/Events/ApplicationEvent.h"
#include "GUI/Events/KeyEvent.h"
#include "GUI/Events/MouseEvent.h"

namespace GUI {

	class ImGuiLayer : public Layer
	{
	public:
		ImGuiLayer();
		~ImGuiLayer() = default;

		virtual void OnAttach() override;
		virtual void OnDetach() override;
		virtual void OnEvent(Event& e) override;

		void Begin();
		void End();

		void SetBlockEvents(bool block) { m_BlockEvents = block; }
		void SetDarkThemeColor();
	private:
		bool m_BlockEvents = true;
	};

}
