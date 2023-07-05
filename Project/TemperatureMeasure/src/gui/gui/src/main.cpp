#pragma once
#include "pch.h"
#include "GUI/Core/Application.h"

int main(int argc, char** argv)
{
	GUI::Log::Init();

	auto app = GUI::CreateScope<GUI::Application>("Temperature Measure GUI");
	app->Run();
	app.reset();
}
