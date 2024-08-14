// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2017 miya All rights reserved.

#include <fcntl.h>
#include <termios.h>
#include <stdlib.h>
#include <strings.h>
#include <unistd.h>
#include <stdio.h>
#include <signal.h>
#include <stdint.h>
#include "uartlib.h"

static int quit = 0;

void usage(char *command)
{
  printf("Usage: %s [UART_device]\nSupported ENV: UART_DEVICE\n", command);
  exit(EXIT_FAILURE);
}

void sig_handler()
{
  quit = 1;
}

int main(int argc, char *argv[])
{
  int uart;
  char *devicename;
  uint8_t data = 0;
  struct sigaction sa;

  quit = 0;
  bzero(&sa, sizeof(struct sigaction));
  sa.sa_handler = sig_handler;
  if (sigaction(SIGINT, &sa, NULL) == -1)
  {
    perror("Error: sigaction");
    return -1;
  }

  // check opts
  if (argc > 2)
  {
    usage(argv[0]);
  }
  devicename = getenv("UART_DEVICE");
  if (argc == 2)
  {
    devicename = argv[1];
  }
  if (devicename == NULL)
  {
    printf("Error: bad device\n");
    return -1;
  }

  uart = uart_open(devicename);

  while (quit == 0)
  {
    uart_read(uart, &data, 1);
    printf("%c", data);
  }

  uart_close(uart);
  printf("Exited.\n");
  return 0;
}
