#include "cutils.h"
#include "quickjs.h"

#define FAIL "\e[1;31m"
#define PASS "\e[1;32m"
#define OFF  "\e[m"

void setup_debug_handlers(void);

void test(const char* name, JSContext* context) {
  JSValue exception = JS_GetException(context);
  int is_error = JS_IsError(context, exception);
  if (is_error) {
    JSValue message = JS_GetPropertyStr(context, exception, "message");
    if (!JS_IsUndefined(message)) {
      const char* str = JS_ToCString(context, message);
      if (str[0] == 't' && str[1] == 'r' && str[2] == 'u' && str[3] == 'e') {
        printf("%s "PASS"%s"OFF"\n", name, "passed");
      } else {
        printf("%s "FAIL"%s"OFF"\n", name, "failed");
      }
      JS_FreeCString(context, str);
    }
    JS_FreeValue(context, message);
  }
  JS_FreeValue(context, exception);
}

void run_test(const char* name, const char* code, JSContext* context) {
  DynBuf dynbuf;
  dbuf_init(&dynbuf);

  for (const char *i = code; *i != '\0'; i++) {
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
      test(name, context);
    }
  } else {
    printf("expected eval error");
  }

  dbuf_free(&dynbuf);
  JS_FreeValue(context, value);
}

int main() {
  setup_debug_handlers();
  JSRuntime* runtime = JS_NewRuntime();
  JSContext* context = JS_NewContext(runtime);

  run_test("using large numbers", "\
    const t1 = 100000000000000000000000000; \
    const t2 = 100000000000000000000000000; \
    throw new Error(t1 === t2);", context);
  run_test("typeof", "throw new Error(typeof 1 === 'number');", context);

  return 0;
}
