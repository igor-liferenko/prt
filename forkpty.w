@ @c
#include <stdio.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include <pty.h>
#include <termios.h>
#include <fcntl.h>

#include <sys/select.h>
#include <sys/wait.h>

int main()
{

    int master;
    pid_t pid;

    pid = forkpty(&master, NULL, NULL, NULL);

    // impossible to fork
    if (pid < 0) {
        return 1;
    }

    if (pid == 0) {

        char *args[] = { "bc", NULL };

        // run the BC calculator
        execv("/usr/bin/bc", args);
    }

        // remove the echo
        struct termios tios;
        tcgetattr(master, &tios);
        tios.c_lflag &= (tcflag_t)~(ECHO | ECHONL);
        tcsetattr(master, TCSAFLUSH, &tios);

        for (;;) {

            // define estruturas para o select, que serve para verificar qual
            // se tornou "pronto pra uso"
            fd_set          read_fd;
            fd_set          write_fd;
            fd_set          except_fd;

            // inicializa as estruturas
            FD_ZERO(&read_fd);
            FD_ZERO(&write_fd);
            FD_ZERO(&except_fd);

            // atribui o descritor master, obtido pelo forkpty, ao read_fd
            FD_SET(master, &read_fd);
            // atribui o stdin ao read_fd
            FD_SET(STDIN_FILENO, &read_fd);

            // o descritor tem que ser unico para o programa, a documentacao
            // recomenda um calculo entre os descritores sendo usados + 1
            select(master+1, &read_fd, &write_fd, &except_fd, NULL);

            char input;
            char output;

            // read_fd esta atribuido com read_fd?
            if (FD_ISSET(master, &read_fd))
            {
                // leia o que bc esta mandando
                if (read(master, &output, 1) != -1)
                    // e escreva isso na saida padrao
                    write(STDOUT_FILENO, &output, 1);
                else
                    break;
            }

            // read_fd esta atribuido com a entrada padrao?
            if (FD_ISSET(STDIN_FILENO, &read_fd))
            {
                // leia a entrada padrao
                read(STDIN_FILENO, &input, 1);
                // e escreva no bc
                write(master, &input, 1);
            }
        }

    return 0;
}
