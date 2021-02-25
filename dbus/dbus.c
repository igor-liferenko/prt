#include <cups/cups.h>
#include <cups/string-private.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

int main(int  argc, char *argv[])
{
  ipp_t			*msg;		/* Event message from scheduler */
  ipp_state_t		state;		/* IPP event state */

  while (1) {
    msg = ippNew();
    while ((state = ippReadFile(0, msg)) != IPP_DATA)
      if (state <= IPP_IDLE)
        break;
    ippDelete(msg);
    if (state <= IPP_IDLE) break;
  }

  return 0;
}
