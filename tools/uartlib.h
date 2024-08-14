// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2017 miya All rights reserved.

#ifndef _uartlib_h
#define _uartlib_h

#include <stdint.h>

#define BAUDRATE B115200
#define SC1_START_CHAR 0xaa
#define SC1_END_CHAR 0x55

int uart_open(char *device_name);
void uart_read(int uart, uint8_t *buf, size_t count);
void uart_write(int uart, uint8_t *buf, size_t count);
void uart_send_data(int uart, int file_size, uint8_t *buffer, unsigned int offset_address);
void uart_close(int fd);
int is_little_endian();
uint32_t convert_endian(uint32_t in);
void uart_send_word(int uart, uint32_t address, uint32_t data);

#endif /* _uartlib_h */
