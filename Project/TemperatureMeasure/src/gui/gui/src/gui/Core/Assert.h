#pragma once

#ifdef TM_NDEBUG
#define TM_ENABLE_ASSERTS
#endif

#define TM_ENABLE_VERIFY

#ifdef TM_ENABLE_ASSERTS
#define TM_ASSERT_NO_MESSAGE(condition) { if(!(condition)) { TM_ERROR("Assertion Failed"); __debugbreak(); } }
#define TM_ASSERT_MESSAGE(condition, ...) { if(!(condition)) { TM_ERROR("Assertion Failed: {0}", __VA_ARGS__); __debugbreak(); } }

#define TM_ASSERT_RESOLVE(arg1, arg2, macro, ...) macro
#define TM_GET_ASSERT_MACRO(...) TM_EXPAND_VARGS(TM_ASSERT_RESOLVE(__VA_ARGS__, TM_ASSERT_MESSAGE, TM_ASSERT_NO_MESSAGE))

#define TM_ASSERT(...) TM_EXPAND_VARGS( TM_GET_ASSERT_MACRO(__VA_ARGS__)(__VA_ARGS__) )
#define TM_CORE_ASSERT(...) TM_EXPAND_VARGS( TM_GET_ASSERT_MACRO(__VA_ARGS__)(__VA_ARGS__) )
#else
#define TM_ASSERT(...)
#define TM_CORE_ASSERT(...)
#endif

#ifdef TM_ENABLE_VERIFY
#define TM_VERIFY_NO_MESSAGE(condition) { if(!(condition)) { TM_ERROR("Verify Failed"); __debugbreak(); } }
#define TM_VERIFY_MESSAGE(condition, ...) { if(!(condition)) { TM_ERROR("Verify Failed: {0}", __VA_ARGS__); __debugbreak(); } }

#define TM_VERIFY_RESOLVE(arg1, arg2, macro, ...) macro
#define TM_GET_VERIFY_MACRO(...) TM_EXPAND_VARGS(TM_VERIFY_RESOLVE(__VA_ARGS__, TM_VERIFY_MESSAGE, TM_VERIFY_NO_MESSAGE))

#define TM_VERIFY(...) TM_EXPAND_VARGS( TM_GET_VERIFY_MACRO(__VA_ARGS__)(__VA_ARGS__) )
#define TM_CORE_VERIFY(...) TM_EXPAND_VARGS( TM_GET_VERIFY_MACRO(__VA_ARGS__)(__VA_ARGS__) )
#else
#define TM_VERIFY(...)
#define TM_CORE_VERIFY(...)
#endif
