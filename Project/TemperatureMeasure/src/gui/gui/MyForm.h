#pragma once
#include <exception>

namespace gui {

	using namespace System;
	using namespace System::ComponentModel;
	using namespace System::Collections;
	using namespace System::Windows::Forms;
	using namespace System::Data;
	using namespace System::Drawing;
	using namespace System::IO::Ports;

	/// <summary>
	/// Summary for MyForm
	/// </summary>
	public ref class MyForm : public System::Windows::Forms::Form
	{
	public:
		MyForm(void)
		{
			InitializeComponent();
			gui::MyForm::FormBorderStyle = gui::FormBorderStyle::FixedSingle;
			gui::MyForm::MaximizeBox = false;
		}

	protected:
		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		~MyForm()
		{
			if (components)
			{
				delete components;
			}
		}
	private: System::Windows::Forms::Label^ portNameLabel;
	private: System::Windows::Forms::Label^ stopBitLabel;
	protected:


	private: System::Windows::Forms::Label^ baudRateLabel;
	private: System::Windows::Forms::Label^ parityLabel;


	private: System::Windows::Forms::Label^ dataBitLabel;

	private: System::Windows::Forms::ComboBox^ portNameOptions;
	private: System::Windows::Forms::ComboBox^ baudRateOptions;
	private: System::Windows::Forms::ComboBox^ stopBitsOptions;

	private: System::Windows::Forms::ComboBox^ parityOptions;

	private: System::Windows::Forms::ComboBox^ dataBitsOptions;
	private: System::Windows::Forms::Button^ connectButton;

	private: System::Windows::Forms::TextBox^ dataReceived;

	private: System::Windows::Forms::Label^ receiveLabel;
	private: System::Windows::Forms::Label^ plotLabel;
	private: System::Windows::Forms::Label^ groupNumberLabel;
	private: System::Windows::Forms::Label^ classNameLabel;
	private: System::Windows::Forms::TextBox^ sendData;

	private: System::Windows::Forms::Button^ sendButton;
	private: System::IO::Ports::SerialPort^ serialPort;
	private: System::Windows::Forms::DataVisualization::Charting::Chart^ dataChart;

	private: System::ComponentModel::IContainer^ components;

	protected:

	private:
		/// <summary>
		/// Required designer variable.
		/// </summary>


#pragma region Windows Form Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		void InitializeComponent(void)
		{
			this->components = (gcnew System::ComponentModel::Container());
			System::Windows::Forms::DataVisualization::Charting::ChartArea^ chartArea1 = (gcnew System::Windows::Forms::DataVisualization::Charting::ChartArea());
			System::Windows::Forms::DataVisualization::Charting::Legend^ legend1 = (gcnew System::Windows::Forms::DataVisualization::Charting::Legend());
			System::Windows::Forms::DataVisualization::Charting::Series^ series1 = (gcnew System::Windows::Forms::DataVisualization::Charting::Series());
			this->portNameLabel = (gcnew System::Windows::Forms::Label());
			this->stopBitLabel = (gcnew System::Windows::Forms::Label());
			this->baudRateLabel = (gcnew System::Windows::Forms::Label());
			this->parityLabel = (gcnew System::Windows::Forms::Label());
			this->dataBitLabel = (gcnew System::Windows::Forms::Label());
			this->portNameOptions = (gcnew System::Windows::Forms::ComboBox());
			this->baudRateOptions = (gcnew System::Windows::Forms::ComboBox());
			this->stopBitsOptions = (gcnew System::Windows::Forms::ComboBox());
			this->parityOptions = (gcnew System::Windows::Forms::ComboBox());
			this->dataBitsOptions = (gcnew System::Windows::Forms::ComboBox());
			this->connectButton = (gcnew System::Windows::Forms::Button());
			this->dataReceived = (gcnew System::Windows::Forms::TextBox());
			this->receiveLabel = (gcnew System::Windows::Forms::Label());
			this->plotLabel = (gcnew System::Windows::Forms::Label());
			this->groupNumberLabel = (gcnew System::Windows::Forms::Label());
			this->classNameLabel = (gcnew System::Windows::Forms::Label());
			this->sendData = (gcnew System::Windows::Forms::TextBox());
			this->sendButton = (gcnew System::Windows::Forms::Button());
			this->serialPort = (gcnew System::IO::Ports::SerialPort(this->components));
			this->dataChart = (gcnew System::Windows::Forms::DataVisualization::Charting::Chart());
			(cli::safe_cast<System::ComponentModel::ISupportInitialize^>(this->dataChart))->BeginInit();
			this->SuspendLayout();
			// 
			// portNameLabel
			// 
			this->portNameLabel->AutoSize = true;
			this->portNameLabel->Font = (gcnew System::Drawing::Font(L"Arial", 10));
			this->portNameLabel->ForeColor = System::Drawing::SystemColors::ActiveCaptionText;
			this->portNameLabel->Location = System::Drawing::Point(27, 23);
			this->portNameLabel->Name = L"portNameLabel";
			this->portNameLabel->Size = System::Drawing::Size(73, 16);
			this->portNameLabel->TabIndex = 0;
			this->portNameLabel->Text = L"Port Name";
			this->portNameLabel->Click += gcnew System::EventHandler(this, &MyForm::label1_Click);
			// 
			// stopBitLabel
			// 
			this->stopBitLabel->AutoSize = true;
			this->stopBitLabel->Font = (gcnew System::Drawing::Font(L"Arial", 10));
			this->stopBitLabel->ForeColor = System::Drawing::SystemColors::ActiveCaptionText;
			this->stopBitLabel->Location = System::Drawing::Point(27, 169);
			this->stopBitLabel->Name = L"stopBitLabel";
			this->stopBitLabel->Size = System::Drawing::Size(63, 16);
			this->stopBitLabel->TabIndex = 1;
			this->stopBitLabel->Text = L"Stop Bits";
			this->stopBitLabel->Click += gcnew System::EventHandler(this, &MyForm::label2_Click);
			// 
			// baudRateLabel
			// 
			this->baudRateLabel->AutoSize = true;
			this->baudRateLabel->Font = (gcnew System::Drawing::Font(L"Arial", 10));
			this->baudRateLabel->ForeColor = System::Drawing::SystemColors::ActiveCaptionText;
			this->baudRateLabel->Location = System::Drawing::Point(26, 58);
			this->baudRateLabel->Name = L"baudRateLabel";
			this->baudRateLabel->Size = System::Drawing::Size(74, 16);
			this->baudRateLabel->TabIndex = 2;
			this->baudRateLabel->Text = L"Baud Rate";
			this->baudRateLabel->Click += gcnew System::EventHandler(this, &MyForm::label3_Click);
			// 
			// parityLabel
			// 
			this->parityLabel->AutoSize = true;
			this->parityLabel->Font = (gcnew System::Drawing::Font(L"Arial", 10));
			this->parityLabel->ForeColor = System::Drawing::SystemColors::ActiveCaptionText;
			this->parityLabel->Location = System::Drawing::Point(26, 131);
			this->parityLabel->Name = L"parityLabel";
			this->parityLabel->Size = System::Drawing::Size(43, 16);
			this->parityLabel->TabIndex = 3;
			this->parityLabel->Text = L"Parity";
			// 
			// dataBitLabel
			// 
			this->dataBitLabel->AutoSize = true;
			this->dataBitLabel->Font = (gcnew System::Drawing::Font(L"Arial", 10));
			this->dataBitLabel->ForeColor = System::Drawing::SystemColors::ActiveCaptionText;
			this->dataBitLabel->Location = System::Drawing::Point(26, 93);
			this->dataBitLabel->Name = L"dataBitLabel";
			this->dataBitLabel->Size = System::Drawing::Size(64, 16);
			this->dataBitLabel->TabIndex = 4;
			this->dataBitLabel->Text = L"Data Bits";
			this->dataBitLabel->Click += gcnew System::EventHandler(this, &MyForm::dataBitLabel_Click);
			// 
			// portNameOptions
			// 
			this->portNameOptions->FormattingEnabled = true;
			this->portNameOptions->Location = System::Drawing::Point(138, 22);
			this->portNameOptions->Name = L"portNameOptions";
			this->portNameOptions->Size = System::Drawing::Size(87, 21);
			this->portNameOptions->TabIndex = 5;
			// 
			// baudRateOptions
			// 
			this->baudRateOptions->FormattingEnabled = true;
			this->baudRateOptions->Location = System::Drawing::Point(138, 58);
			this->baudRateOptions->Name = L"baudRateOptions";
			this->baudRateOptions->Size = System::Drawing::Size(87, 21);
			this->baudRateOptions->TabIndex = 6;
			// 
			// stopBitsOptions
			// 
			this->stopBitsOptions->FormattingEnabled = true;
			this->stopBitsOptions->Location = System::Drawing::Point(138, 169);
			this->stopBitsOptions->Name = L"stopBitsOptions";
			this->stopBitsOptions->Size = System::Drawing::Size(87, 21);
			this->stopBitsOptions->TabIndex = 7;
			// 
			// parityOptions
			// 
			this->parityOptions->FormattingEnabled = true;
			this->parityOptions->Location = System::Drawing::Point(138, 131);
			this->parityOptions->Name = L"parityOptions";
			this->parityOptions->Size = System::Drawing::Size(87, 21);
			this->parityOptions->TabIndex = 8;
			this->parityOptions->Text = L"None";
			// 
			// dataBitsOptions
			// 
			this->dataBitsOptions->FormattingEnabled = true;
			this->dataBitsOptions->Location = System::Drawing::Point(138, 93);
			this->dataBitsOptions->Name = L"dataBitsOptions";
			this->dataBitsOptions->Size = System::Drawing::Size(87, 21);
			this->dataBitsOptions->TabIndex = 9;
			// 
			// connectButton
			// 
			this->connectButton->Font = (gcnew System::Drawing::Font(L"Microsoft Sans Serif", 8.25F, System::Drawing::FontStyle::Regular, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(0)));
			this->connectButton->Location = System::Drawing::Point(23, 208);
			this->connectButton->Name = L"connectButton";
			this->connectButton->Size = System::Drawing::Size(77, 21);
			this->connectButton->TabIndex = 10;
			this->connectButton->Text = L"Connect";
			this->connectButton->UseVisualStyleBackColor = true;
			this->connectButton->Click += gcnew System::EventHandler(this, &MyForm::button1_Click);
			// 
			// dataReceived
			// 
			this->dataReceived->Location = System::Drawing::Point(324, 22);
			this->dataReceived->Multiline = true;
			this->dataReceived->Name = L"dataReceived";
			this->dataReceived->ReadOnly = true;
			this->dataReceived->Size = System::Drawing::Size(409, 125);
			this->dataReceived->TabIndex = 11;
			// 
			// receiveLabel
			// 
			this->receiveLabel->AutoSize = true;
			this->receiveLabel->Font = (gcnew System::Drawing::Font(L"Arial", 10));
			this->receiveLabel->ForeColor = System::Drawing::SystemColors::ActiveCaptionText;
			this->receiveLabel->Location = System::Drawing::Point(260, 22);
			this->receiveLabel->Name = L"receiveLabel";
			this->receiveLabel->Size = System::Drawing::Size(58, 16);
			this->receiveLabel->TabIndex = 13;
			this->receiveLabel->Text = L"Receive";
			this->receiveLabel->Click += gcnew System::EventHandler(this, &MyForm::receiveLabel_Click);
			// 
			// plotLabel
			// 
			this->plotLabel->AutoSize = true;
			this->plotLabel->Font = (gcnew System::Drawing::Font(L"Arial", 10));
			this->plotLabel->ForeColor = System::Drawing::SystemColors::ActiveCaptionText;
			this->plotLabel->Location = System::Drawing::Point(287, 169);
			this->plotLabel->Name = L"plotLabel";
			this->plotLabel->Size = System::Drawing::Size(31, 16);
			this->plotLabel->TabIndex = 14;
			this->plotLabel->Text = L"Plot";
			this->plotLabel->Click += gcnew System::EventHandler(this, &MyForm::plotLabel_Click);
			// 
			// groupNumberLabel
			// 
			this->groupNumberLabel->AutoSize = true;
			this->groupNumberLabel->Font = (gcnew System::Drawing::Font(L"Arial", 12, System::Drawing::FontStyle::Bold));
			this->groupNumberLabel->ForeColor = System::Drawing::SystemColors::ActiveCaptionText;
			this->groupNumberLabel->Location = System::Drawing::Point(25, 362);
			this->groupNumberLabel->Name = L"groupNumberLabel";
			this->groupNumberLabel->Size = System::Drawing::Size(90, 19);
			this->groupNumberLabel->TabIndex = 15;
			this->groupNumberLabel->Text = L"GROUP 19";
			this->groupNumberLabel->Click += gcnew System::EventHandler(this, &MyForm::label8_Click);
			// 
			// classNameLabel
			// 
			this->classNameLabel->AutoSize = true;
			this->classNameLabel->Font = (gcnew System::Drawing::Font(L"Arial", 12, System::Drawing::FontStyle::Bold));
			this->classNameLabel->ForeColor = System::Drawing::SystemColors::ActiveCaptionText;
			this->classNameLabel->Location = System::Drawing::Point(25, 407);
			this->classNameLabel->Name = L"classNameLabel";
			this->classNameLabel->Size = System::Drawing::Size(207, 19);
			this->classNameLabel->TabIndex = 16;
			this->classNameLabel->Text = L"DIGITAL SYSTEM DESIGN";
			this->classNameLabel->Click += gcnew System::EventHandler(this, &MyForm::label9_Click);
			// 
			// sendData
			// 
			this->sendData->Location = System::Drawing::Point(324, 405);
			this->sendData->Multiline = true;
			this->sendData->Name = L"sendData";
			this->sendData->Size = System::Drawing::Size(326, 21);
			this->sendData->TabIndex = 18;
			this->sendData->TextChanged += gcnew System::EventHandler(this, &MyForm::textBox1_TextChanged);
			// 
			// sendButton
			// 
			this->sendButton->Font = (gcnew System::Drawing::Font(L"Microsoft Sans Serif", 8.25F, System::Drawing::FontStyle::Regular, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(0)));
			this->sendButton->Location = System::Drawing::Point(656, 405);
			this->sendButton->Name = L"sendButton";
			this->sendButton->Size = System::Drawing::Size(77, 21);
			this->sendButton->TabIndex = 19;
			this->sendButton->Text = L"Send";
			this->sendButton->UseVisualStyleBackColor = true;
			this->sendButton->Click += gcnew System::EventHandler(this, &MyForm::button1_Click_1);
			// 
			// serialPort
			// 
			this->serialPort->PinChanged += gcnew System::IO::Ports::SerialPinChangedEventHandler(this, &MyForm::serialPort_PinChanged);
			this->serialPort->DataReceived += gcnew System::IO::Ports::SerialDataReceivedEventHandler(this, &MyForm::serialPort_DataReceived);
			// 
			// dataChart
			// 
			this->dataChart->BorderlineColor = System::Drawing::Color::Gray;
			this->dataChart->BorderlineDashStyle = System::Windows::Forms::DataVisualization::Charting::ChartDashStyle::Solid;
			chartArea1->Name = L"ChartArea1";
			this->dataChart->ChartAreas->Add(chartArea1);
			legend1->Name = L"Legend1";
			this->dataChart->Legends->Add(legend1);
			this->dataChart->Location = System::Drawing::Point(324, 169);
			this->dataChart->Margin = System::Windows::Forms::Padding(1);
			this->dataChart->Name = L"dataChart";
			series1->ChartArea = L"ChartArea1";
			series1->ChartType = System::Windows::Forms::DataVisualization::Charting::SeriesChartType::Line;
			series1->Legend = L"Legend1";
			series1->Name = L"Series1";
			this->dataChart->Series->Add(series1);
			this->dataChart->Size = System::Drawing::Size(409, 212);
			this->dataChart->TabIndex = 20;
			this->dataChart->Text = L"DataPlot";
			this->dataChart->Click += gcnew System::EventHandler(this, &MyForm::dataChart_Click);
			// 
			// MyForm
			// 
			this->AutoScaleDimensions = System::Drawing::SizeF(6, 13);
			this->AutoScaleMode = System::Windows::Forms::AutoScaleMode::Font;
			this->BackColor = System::Drawing::SystemColors::ButtonHighlight;
			this->ClientSize = System::Drawing::Size(762, 470);
			this->Controls->Add(this->dataChart);
			this->Controls->Add(this->sendButton);
			this->Controls->Add(this->sendData);
			this->Controls->Add(this->classNameLabel);
			this->Controls->Add(this->groupNumberLabel);
			this->Controls->Add(this->plotLabel);
			this->Controls->Add(this->receiveLabel);
			this->Controls->Add(this->dataReceived);
			this->Controls->Add(this->connectButton);
			this->Controls->Add(this->dataBitsOptions);
			this->Controls->Add(this->parityOptions);
			this->Controls->Add(this->stopBitsOptions);
			this->Controls->Add(this->baudRateOptions);
			this->Controls->Add(this->portNameOptions);
			this->Controls->Add(this->dataBitLabel);
			this->Controls->Add(this->parityLabel);
			this->Controls->Add(this->baudRateLabel);
			this->Controls->Add(this->stopBitLabel);
			this->Controls->Add(this->portNameLabel);
			this->Name = L"MyForm";
			this->StartPosition = System::Windows::Forms::FormStartPosition::CenterScreen;
			this->Text = L"Temperature Measure GUI";
			this->Load += gcnew System::EventHandler(this, &MyForm::MyForm_Load);
			(cli::safe_cast<System::ComponentModel::ISupportInitialize^>(this->dataChart))->EndInit();
			this->ResumeLayout(false);
			this->PerformLayout();

		}
#pragma endregion
	private: System::Void MyForm_Load(System::Object^ sender, System::EventArgs^ e) {
		array<Object^>^ comports = SerialPort::GetPortNames();
		portNameOptions->Items->AddRange(comports);
		portNameOptions->SelectedIndex = 0;

		array<Object^>^ baudRates = { 1200, 2400, 4800, 19200, 38400, 57600, 115200 };
		baudRateOptions->Items->AddRange(baudRates);
		baudRateOptions->SelectedIndex = baudRates->Length - 1;

		array<Object^>^ dataBits = { 5, 6, 7, 8 };
		dataBitsOptions->Items->AddRange(dataBits);
		dataBitsOptions->SelectedIndex = dataBits->Length - 1;

		array<Object^>^ parity = { "None", "Even", "Odd" };
		parityOptions->Items->AddRange(parity);
		parityOptions->SelectedIndex = 0;

		array<Object^>^ stopBits = { "None", "1", "1.5", "2"};
		stopBitsOptions->Items->AddRange(stopBits);
		stopBitsOptions->SelectedIndex = 0;
	}

	private: System::Void label1_Click(System::Object^ sender, System::EventArgs^ e) {
	}
	private: System::Void label3_Click(System::Object^ sender, System::EventArgs^ e) {
	}
	private: System::Void label2_Click(System::Object^ sender, System::EventArgs^ e) {
	}
	private: System::Void plotLabel_Click(System::Object^ sender, System::EventArgs^ e) {
	}
	private: System::Void label8_Click(System::Object^ sender, System::EventArgs^ e) {
	}
	private: System::Void label9_Click(System::Object^ sender, System::EventArgs^ e) {
	}
	private: System::Void dataChart_Click(System::Object^ sender, System::EventArgs^ e) {
	}

	private: System::Void button1_Click(System::Object^ sender, System::EventArgs^ e) {
		try
		{
			if (connectButton->Text == "Connect")
			{
				if (serialPort->IsOpen)
				{
					serialPort->Close();
				}
				serialPort->PortName = portNameOptions->Text;
				serialPort->BaudRate = Int32::Parse(baudRateOptions->Text);
				serialPort->DataBits = Int32::Parse(dataBitsOptions->Text);
				serialPort->Parity = ParityParseStringToEnum(parityOptions->Text);
				serialPort->StopBits = StopBitsParseStringsEnum(stopBitsOptions->Text);
				connectButton->Text = "Disconnect";
			}
			else if (connectButton->Text == "Disconnect")
			{
				serialPort->Close();
				connectButton->Text = "Connect";
			}
		}
		catch (const std::exception& e)
		{
			System::String^ errorMessage = gcnew System::String(e.what());
			MessageBox::Show(errorMessage);
		}
	}
	
	private: System::Void textBox1_TextChanged(System::Object^ sender, System::EventArgs^ e) {
	}
	private: System::Void button1_Click_1(System::Object^ sender, System::EventArgs^ e) {
		serialPort->WriteLine(sendData->Text);
	}

	private: System::Void receiveLabel_Click(System::Object^ sender, System::EventArgs^ e) {
	}

	private: System::Void dataBitLabel_Click(System::Object^ sender, System::EventArgs^ e) {
	}

	private: System::IO::Ports::Parity ParityParseStringToEnum(System::String^ string)
	{
		if (string == "None") return System::IO::Ports::Parity::None;
		if (string == "Even") return System::IO::Ports::Parity::Even;
		if (string == "Odd") return System::IO::Ports::Parity::Odd;
		else return System::IO::Ports::Parity::None;
	}

	private: System::IO::Ports::StopBits StopBitsParseStringsEnum(System::String^ string)
	{
		if (string == "None") return System::IO::Ports::StopBits::None;
		if (string == "1") return System::IO::Ports::StopBits::One;
		if (string == "1.5") return System::IO::Ports::StopBits::OnePointFive;
		if (string == "2") return System::IO::Ports::StopBits::Two;
		else return System::IO::Ports::StopBits::None;
	}

	private: System::Void serialPort_DataReceived(System::Object^ sender, System::IO::Ports::SerialDataReceivedEventArgs^ e) 
	{
		String^ receivedData = serialPort->ReadLine();
		dataReceived->AppendText(receivedData + "\n");
		dataChart->Series["Series1"]->Points->AddY(Double::Parse(receivedData));
	}

	private: System::Void serialPort_PinChanged(System::Object^ sender, System::IO::Ports::SerialPinChangedEventArgs^ e) {
		MessageBox::Show("Port Changed");
	}
};
}
