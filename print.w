\noinx
@* Intro.

Printer device file must not be created if it does not
already exist. To achieve this, we do not use |O_CREAT| in |open|.

@c
#include <fcntl.h>
#include <unistd.h>

int main(void)
{
  int fd;
  if ((fd = open("/dev/usb/lp0", O_WRONLY)) == -1)
    return 10;

  char buf[8192];
  ssize_t n, m;

  while ((n = read(STDIN_FILENO, buf, sizeof buf)) > 0) {
    m = write(fd, buf, n);
    if (m == -1) return 11;
    if (m != n) return 12;
  }
  if (n == -1) return 13;

  close(fd);
  return 0;
}
