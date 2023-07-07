#include "MyForm.h"

int main(int argc, char** argv)
{
	gui::Application::EnableVisualStyles();
	gui::Application::SetCompatibleTextRenderingDefault(false);
	gui::Application::Run(gcnew gui::MyForm());
}

