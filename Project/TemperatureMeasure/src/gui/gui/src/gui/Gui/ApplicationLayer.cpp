#include "pch.h"
#include "ApplicationLayer.h"
#include "gui/Renderer/RenderCommand.h"

#include <imgui.h>

namespace GUI
{
	ApplicationLayer::ApplicationLayer()
		: Layer("GUI Layer")
	{
	}

	void ApplicationLayer::OnAttach()
	{
	}

	void ApplicationLayer::OnDetach()
	{
	}

	void ApplicationLayer::OnUpdate(Timestep ts)
	{
		RenderCommand::SetClearColor({ 0.1f, 0.1f, 0.1f, 1.0f });
		RenderCommand::Clear();
	}

	void ApplicationLayer::OnImGuiRender()
	{
		static bool dockspaceOpen = true;
		static bool show_demo_window = true;
		static bool opt_fullscreen_persistant = true;
		bool opt_fullscreen = opt_fullscreen_persistant;
		static ImGuiDockNodeFlags dockspace_flags = ImGuiDockNodeFlags_None;

		// We are using the ImGuiWindowFlags_NoDocking flag to make the parent window not dockable into,
		// because it would be confusing to have two docking targets within each others.
		ImGuiWindowFlags window_flags = ImGuiWindowFlags_MenuBar | ImGuiWindowFlags_NoDocking;
		if (opt_fullscreen)
		{
			const ImGuiViewport* viewport = ImGui::GetMainViewport();
			ImGui::SetNextWindowPos(viewport->WorkPos);
			ImGui::SetNextWindowSize(viewport->WorkSize);
			ImGui::SetNextWindowViewport(viewport->ID);
			ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, 0.0f);
			ImGui::PushStyleVar(ImGuiStyleVar_WindowBorderSize, 0.0f);
			window_flags |= ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove;
			window_flags |= ImGuiWindowFlags_NoBringToFrontOnFocus | ImGuiWindowFlags_NoNavFocus;
		}

		// When using ImGuiDockNodeFlags_PassthruCentralNode, DockSpace() will render our background
		// and handle the pass-thru hole, so we ask Begin() to not render a background.
		if (dockspace_flags & ImGuiDockNodeFlags_PassthruCentralNode)
			window_flags |= ImGuiWindowFlags_NoBackground;

		// Important: note that we proceed even if Begin() returns false (aka window is collapsed).
		// This is because we want to keep our DockSpace() active. If a DockSpace() is inactive,
		// all active windows docked into it will lose their parent and become undocked.
		// We cannot preserve the docking relationship between an active window and an inactive docking, otherwise
		// any change of dockspace/settings would lead to windows being stuck in limbo and never being visible.
		ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(0.0f, 0.0f));
		ImGui::Begin("DockSpace Demo", &dockspaceOpen, window_flags);
		ImGui::PopStyleVar();

		if (opt_fullscreen)
			ImGui::PopStyleVar(2);

		// Submit the DockSpace
		ImGuiIO& io = ImGui::GetIO();
		ImGuiStyle& style = ImGui::GetStyle();
		float minWinSizeX = style.WindowMinSize.x;
		float minWinSizeY = style.WindowMinSize.y;
		style.WindowMinSize.x = 250.0f;
		style.WindowMinSize.y = 160.0f;
		if (io.ConfigFlags & ImGuiConfigFlags_DockingEnable)
		{
			ImGuiID dockspace_id = ImGui::GetID("MyDockSpace");
			ImGui::DockSpace(dockspace_id, ImVec2(0.0f, 0.0f), dockspace_flags);
		}
		style.WindowMinSize.x = minWinSizeX;
		style.WindowMinSize.y = minWinSizeY;

		// Setting window
		ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2{ 0, 0 });
		ImGui::ShowDemoWindow(&show_demo_window);
		// Setting window
		ImGui::Begin("Port Settings", nullptr, ImGuiWindowFlags_NoScrollbar);
		{
			ImGui::PushItemWidth(80);
			{
				ImGui::Text("Port Name");
				ImGui::SameLine(170);
				const char* portNameOptions[] = { "AAAA", "BBBB", "CCCC", "DDDD", "EEEE", "FFFF", "GGGG", "HHHH", "IIII", "JJJJ", "KKKK", "LLLLLLL", "MMMM", "OOOOOOO" };
				static int item_current_idx_1 = 0; // Here we store our selection data as an index.
				CreatePortSettingOption(portNameOptions, IM_ARRAYSIZE(portNameOptions), item_current_idx_1, "##combo_id_1");
			}

			{
				ImGui::Text("Baud Rate");
				ImGui::SameLine(170);
				const char* baudRateOptions[] = { "4800", "9600", "14400", "19200", "38400", "57600", "115200", "128000", "256000" };
				static int item_current_idx_2 = 0; // Here we store our selection data as an index.
				CreatePortSettingOption(baudRateOptions, IM_ARRAYSIZE(baudRateOptions), item_current_idx_2, "##combo_id_2");
			}

			{
				ImGui::Text("Parity");
				ImGui::SameLine(170);
				const char* parityOptions[] = { "None", "Even", "Odd" };
				static int item_current_idx_3 = 0; // Here we store our selection data as an index.
				CreatePortSettingOption(parityOptions, IM_ARRAYSIZE(parityOptions), item_current_idx_3, "##combo_id_3");
			}

			{
				ImGui::Text("Data Bit");
				ImGui::SameLine(170);
				const char* dataBitOptions[] = { "None", "5", "6", "7", "8" };
				static int item_current_idx_4 = 0; // Here we store our selection data as an index.
				CreatePortSettingOption(dataBitOptions, IM_ARRAYSIZE(dataBitOptions), item_current_idx_4, "##combo_id_4");
			}

			{
				ImGui::Text("Stop Bit");
				ImGui::SameLine(170);
				const char* stopBitOptions[] = { "None", "1", "2" };
				static int item_current_idx_5 = 0; // Here we store our selection data as an index.
				CreatePortSettingOption(stopBitOptions, IM_ARRAYSIZE(stopBitOptions), item_current_idx_5, "##combo_id_5");
			}
			ImGui::PopItemWidth();
		}
		ImGui::End();

		ImGui::Begin("Data Plot");
		ImGui::End();

		ImGui::Begin("Receive");
		ImGui::End();

		ImGui::Begin("Send");
		ImGui::End();
		ImGui::PopStyleVar();
		ImGui::End();
	}

	void ApplicationLayer::OnEvent(Event& e)
	{
		EventDispatcher dispatcher(e);
		dispatcher.Dispatch<KeyPressedEvent>(TM_BIND_EVENT_FN(ApplicationLayer::OnKeyPressed));
		dispatcher.Dispatch<MouseButtonPressedEvent>(TM_BIND_EVENT_FN(ApplicationLayer::OnMouseButtonPressed));
	}

	bool ApplicationLayer::OnKeyPressed(KeyPressedEvent& e)
	{
		// Shortcuts
		if (e.GetRepeatCount() > 0)
			return false;
	}

	bool ApplicationLayer::OnMouseButtonPressed(MouseButtonEvent& e)
	{
		return false;
	}

	void ApplicationLayer::CreatePortSettingOption(const char** options, int itemCount, int& currentItemIndex, const char* comboId)
	{
		const char* combo_preview_value = options[currentItemIndex];  // Pass in the preview value visible before opening the combo (it could be anything)
		if (ImGui::BeginCombo(comboId, combo_preview_value))
		{
			for (int n = 0; n < itemCount; n++)
			{
				const bool is_selected = (currentItemIndex == n);
				if (ImGui::Selectable(options[n], is_selected))
					currentItemIndex = n;

				// Set the initial focus when opening the combo (scrolling + keyboard navigation focus)
				if (is_selected)
					ImGui::SetItemDefaultFocus();
			}
			ImGui::EndCombo();
		}
	}
}
