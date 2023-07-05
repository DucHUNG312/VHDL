#pragma once

#include "pch.h"
#include "gui/Core/Base.h"

namespace GUI {
	// Events in GUI are currently blocking, meaning when an event occurs it
	// immediately gets dispatched and must be dealt with right then an there
	// For the future, a better strategy might be to buffer events in an event
	// bus and process them during the event part of the "update" stage

	enum class EventType
	{
		None = 0,
		WindowClose, WindowResize, WindowFocus, WindowLostFocus, WindowMoved,
		AppTick, AppUpdate, AppRender,
		KeyPressed, KeyReleased, KeyTyped,
		MouseButtonPressed, MouseButtonReleased, MouseMoved, MouseScrolled
	};

	enum EventCategory
	{
		None = 0,
		EventCategoryApplication = BIT(0),
		EventCategoryInput = BIT(1),
		EventCategoryKeyboard = BIT(2),
		EventCategoryMouse = BIT(3),
		EventCategoryMouseButton = BIT(4)
	};

	// static method GetStaticType() to return EventType of the class
	// vitual override method GetEventType() is to override the GetEventType() in the base Event class
	// vitual override method GetName() is to override the GetName() in the base Event class
#define EVENT_CLASS_TYPE(type) static EventType GetStaticType() { return EventType::type; }\
																virtual EventType GetEventType() const override { return GetStaticType(); }\
																virtual const char* GetName() const override { return #type; }
#define EVENT_CLASS_CATEGORY(category) virtual int GetCategoryFlags() const override { return category; }

	// Base Event class
	class Event
	{
	public:
		virtual ~Event() = default;

		bool Handled = false;

		virtual EventType GetEventType() const = 0;
		virtual const char* GetName() const = 0;
		virtual int GetCategoryFlags() const = 0;
		virtual std::string ToString() const { return GetName(); }

		inline bool IsInCategory(EventCategory category)
		{
			return GetCategoryFlags() & category;
		}
	};

	class EventDispatcher
	{
		// T in this case could be any event type
		// template<typename T>
		// EventFn is a standard function which take T reference and return boolean
		// using EventFn = std::function<bool(T&)>;
	public:
		// Receive event as Event reference, which it could be any type of event
		EventDispatcher(Event& event)
			: m_Event(event)
		{
		}

		template<typename T, typename F>
		bool Dispatch(const F& func)
		{
			if (m_Event.GetEventType() == T::GetStaticType())
			{
				// we can use static_cast because sure the m_Event is T type 
				m_Event.Handled |= func(static_cast<T&>(m_Event));
				return true;
			}
			return false;
		}
	private:
		Event& m_Event;
	};

	inline std::ostream& operator<<(std::ostream& os, const Event& e)
	{
		return os << e.ToString();
	}

}
