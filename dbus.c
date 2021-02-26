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
  for (int c = 0; c < 5; c++) {
    event = ippNew();
    ippReadFile(0, event);
    ippDelete(event);
  }
  return 0;
}
