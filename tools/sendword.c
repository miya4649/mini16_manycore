// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2017 miya All rights reserved.

#include <fcntl.h>
#include <termios.h>
#include <stdlib.h>
#include <strings.h>
#include <unistd.h>
#include <stdio.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "uartlib.h"

void usage(char *command)
{
  printf("Usage: %s address data [UART_device]\nSupported ENV: UART_DEVICE\n", command);
  exit(EXIT_FAILURE);
}

uint32_t str2ui32(char *word)
{
  char *endptr = NULL;
  uint32_t out = (uint32_t)strtoul(word, &endptr, 0);
  if (endptr[0] != '\0')
  {
    printf("Error: input %s\n", endptr);
    out = 0;
  }
  return out;
}

int main(int argc, char *argv[])
{
  int uart;
  char *devicename;
  unsigned int address, data;

  // check opts
  if ((argc < 3) || (argc > 4))
  {
    usage(argv[0]);
  }
  devicename = getenv("UART_DEVICE");
  if (argc == 4)
  {
    devicename = argv[3];
  }
  if (devicename == NULL)
  {
    printf("Error: bad device\n");
    return -1;
  }

  address = str2ui32(argv[1]);
  data = str2ui32(argv[2]);

  uart = uart_open(devicename);
  uart_send_word(uart, address, data);
  uart_close(uart);
  return 0;
}
