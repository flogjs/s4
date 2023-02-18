#include "cutils.h"
#include "quickjs.h"

static void show_error(JSContext* context) {
  JSValue exception = JS_GetException(context);
  int is_error = JS_IsError(context, exception);
  if (is_error) {
    JSValue message = JS_GetPropertyStr(context, exception, "message");
    if (!JS_IsUndefined(message)) {
      const char* str = JS_ToCString(context, message);
      printf("%s\n", str);
      JS_FreeCString(context, str);
    }
    JS_FreeValue(context, message);
    JSValue stack = JS_GetPropertyStr(context, exception, "stack");
    if (!JS_IsUndefined(stack)) {
      const char* str = JS_ToCString(context, stack);
      printf("%s\n", str);
      JS_FreeCString(context, str);
    }
    JS_FreeValue(context, stack);
  }
  JS_FreeValue(context, exception);
}

void setup_debug_handlers(void);

int main() {
  setup_debug_handlers();
  JSRuntime* runtime = JS_NewRuntime();
  JSContext* context = JS_NewContext(runtime);

  DynBuf dynbuf;
  dbuf_init(&dynbuf);
  const char* t = "const e = () => { typeof 1; return 10000000000000000; }";

  for (const char *i = t; *i != '\0'; i++) {
    dbuf_putc(&dynbuf, *i);
  }
  dbuf_putc(&dynbuf, '\0');

  char* buffer = (char*) dynbuf.buf;
  size_t size = dynbuf.size - 1;
  int flags = JS_EVAL_TYPE_MODULE | JS_EVAL_FLAG_COMPILE_ONLY;
  JSValue value = JS_Eval(context, buffer, size, "eval", flags);

  if (!JS_IsException(value)) {
    value = JS_EvalFunction(context, value);
    if (JS_IsException(value)) {
      show_error(context);
    }
  } else {
    show_error(context);
    JS_FreeValue(context, value);
    return 0;
  }

  JSModuleDef* module_def = JS_VALUE_GET_PTR(value);
  JS_FreeValue(context, value);

  return 0;
}
