/* Based on testnotify.c from cups source.

  check with "systemctl status cups" - only "/usr/sbin/cupsd -l" must be there
  and /var/log/cups/error_log must be empty

  install libcups2-dev
  gcc -o dbus dbus.c -lcups
*/
#include <cups/cups.h>

int main(void)
{
  ipp_t *event;
  ipp_state_t state;

  int c = 0;
  while (1) {
    c++;

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
    if (c==5) /* empirical from tests above */
      break;
  }

  return 0;
}
