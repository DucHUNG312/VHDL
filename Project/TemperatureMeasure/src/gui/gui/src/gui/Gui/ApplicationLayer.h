#pragma once

#include "GUI/Core/Layer.h"
#include "GUI/Events/Event.h"
#include "GUI/Events/KeyEvent.h"
#include "GUI/Events/MouseEvent.h"
#include "GUI/Core/Base.h"

#include <boost/asio.hpp>

namespace GUI
{
	class ApplicationLayer : public Layer
	{
	public:
		ApplicationLayer();
		virtual ~ApplicationLayer() = default;

		virtual void OnAttach() override;
		virtual void OnDetach() override;
		virtual void OnUpdate(Timestep ts) override;
		virtual void OnImGuiRender() override;
		virtual void OnEvent(Event& event) override;
	private:
		bool OnKeyPressed(KeyPressedEvent& e);
		bool OnMouseButtonPressed(MouseButtonEvent& e);

		void CreatePortSettingOption(const char** options, int itemCount, int& currentItemIndex, const char* comboId);
	};
}
