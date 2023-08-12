       #include <errno.h>
       #include <poll.h>
       #include <stdio.h>
       #include <stdlib.h>
       #include <sys/inotify.h>
       #include <unistd.h>
#include <string.h>
       static void
       handle_events(int fd)
       {
           /* Some systems cannot read integer variables if they are not
              properly aligned. On other systems, incorrect alignment may
              decrease performance. Hence, the buffer used for reading from
              the inotify file descriptor should have the same alignment as
              struct inotify_event. */
 
           char buf[4096]
               __attribute__ ((aligned(__alignof__(struct inotify_event))));
           const struct inotify_event *event;
           ssize_t len;
 
           /* Loop while events can be read from inotify file descriptor. */
 
           for (;;) {
 
               /* Read some events. */
 
               len = read(fd, buf, sizeof(buf));
               if (len == -1 && errno != EAGAIN) {
                   perror("read");
                   exit(30);
               }
 
               /* If the nonblocking read() found no events to read, then
                  it returns -1 with errno set to EAGAIN. In that case,
                  we exit the loop. */
 
               if (len <= 0)
                   break;
 
               /* Loop over all events in the buffer */
 
               for (char *ptr = buf; ptr < buf + len;
                       ptr += sizeof(struct inotify_event) + event->len) {
 
                   event = (const struct inotify_event *) ptr;
if (event->mask & IN_ISDIR) exit(42); // proof
                   if (event->mask & IN_CLOSE_WRITE)
                       system("</home/user/0000 busybox nc 192.168.40.132 9100");
 
 
               }
           }
       }
 
 
       int
       main(void)
       {
           char buf;
           int fd, i, poll_num;
           int wd;
           nfds_t nfds;
           struct pollfd fds[1];
 
           /* Create the file descriptor for accessing the inotify API */
 
           fd = inotify_init1(IN_NONBLOCK);
           if (fd == -1) {
               perror("inotify_init1");
               exit(31);
           }
 
               wd = inotify_add_watch(fd, "/home/user/0000", IN_CLOSE);
               if (wd == -1) {
                   fprintf(stderr, "Cannot watch\n");
                   perror("inotify_add_watch");
                   exit(32);
               }
 
           /* Prepare for polling */
 
           nfds = 1;
 
           /* Inotify input */
 
           fds[0].fd = fd;
           fds[0].events = POLLIN;
 
           /* Wait for events */
 
           printf("Listening for events.\n");
           while (1) {
               poll_num = poll(fds, nfds, -1);
               if (poll_num == -1) {
                   if (errno == EINTR)
                       continue;
                   perror("poll");
                   exit(33);
               }
 
               if (poll_num > 0)
                   if (fds[0].revents & POLLIN)
                       /* Inotify events are available */
                       handle_events(fd);
           }
 
           printf("Listening for events stopped.\n");
 
           /* Close inotify file descriptor */
 
           close(fd);
 
           exit(34);
       }
