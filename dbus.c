/* Based on testnotify.c from cups source. */

#include <cups/cups-private.h>

int main(void)
{
  ipp_t *event;
  ipp_state_t state;

  while (1) {
    event = ippNew();
    while ((state = ippReadFile(0, event)) != IPP_DATA) {
      if (state <= IPP_IDLE)
        break;
    }

    if (state <= IPP_IDLE) {
      ippDelete(event);
      return 0;
    }

    ippDelete(event);
  }
}
