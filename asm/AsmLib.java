// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2019 miya All rights reserved.

public class AsmLib extends Asm
{
  public int DEPTH_REG;

  public int CORES;
  public int PARALLEL;
  public int ENABLE_UART;
  public int ENABLE_SINGLE_CYCLE;

  public int WIDTH_I;
  public int DEPTH_IO_REG;
  public int WIDTH_M_D;
  public int WIDTH_P_D;
  public int DEPTH_M_I;
  public int DEPTH_M_D;
  public int DEPTH_P_I;
  public int DEPTH_P_D;
  public int DEPTH_M2S;
  public int DEPTH_S2M;
  public int DEPTH_U2M;
  public int IMAGE_WIDTH_BITS;
  public int IMAGE_HEIGHT_BITS;
  public int DEPTH_VRAM;
  public int DEPTH_B_U;
  public int DEPTH_V_U;
  public int CORE_BITS;
  public int DEPTH_B_F;
  public int DEPTH_V_F;
  public int DEPTH_B_M2S;
  public int DEPTH_V_M2S;
  public int DEPTH_B_M_W;
  public int DEPTH_V_M_W;
  public int DEPTH_B_M_R;
  public int DEPTH_V_M_R;
  public int DEPTH_B_S_R;
  public int DEPTH_V_S_R;
  public int DEPTH_B_S_W;
  public int DEPTH_V_S_W;
  public int PE_ID_START;

  public int M2S_BANK_M2S;
  public int M2S_BANK_MEM_I;
  public int PE_W_BANK_MEM_D;
  public int PE_W_BANK_FIFO;
  public int PE_R_BANK_MEM_D;
  public int PE_R_BANK_M2S;
  public int PE_R_BANK_ITEM_COUNT;

  public int MASTER_W_BANK_BC;
  public int MASTER_W_BANK_MEM_D;
  public int MASTER_W_BANK_IO_REG;
  public int MASTER_R_BANK_MEM_D;
  public int MASTER_R_BANK_IO_REG;
  public int MASTER_R_BANK_U2M;
  public int MASTER_R_BANK_S2M;
  public int UART_IO_ADDR_RESET;
  public int UART_BANK_MEM_I;
  public int UART_BANK_U2M;
  public int FIFO_BANK_S2M;
  public int FIFO_BANK_VRAM;
  public int IO_REG_R_UART_BUSY;
  public int IO_REG_R_VGA_VSYNC;
  public int IO_REG_R_VGA_VCOUNT;
  public int IO_REG_W_RESET_PE;
  public int IO_REG_W_LED;
  public int IO_REG_W_UART;
  public int IO_REG_W_SPRITE_X;
  public int IO_REG_W_SPRITE_Y;
  public int IO_REG_W_SPRITE_SCALE;

  public int REGS;
  public int SP_REG_STACK_POINTER;

  public int LREG0;
  public int LREG1;
  public int LREG2;
  public int LREG3;
  public int LREG4;
  public int LREG5;
  public int LREG6;

  public int STACK_ADDRESS;

  public static final int SP_REG_MVC = 0;
  public static final int SP_REG_MVIL = 1;
  public static final int SP_REG_LINK = 2;

  public static final int R3 = 3;
  public static final int R4 = 4;
  public static final int R5 = 5;
  public static final int R6 = 6;
  public static final int R7 = 7;
  public static final int R8 = 8;

  public static final int WAIT_DELAYSLOT = 2;

  public static final int MVIL_ADDR_LIMIT = 0x800;

  public static final int MVS_SL = 0;
  public static final int MVS_SR = 1;
  public static final int MVS_SRA = 2;
  public static final int MVS_MUL = 3;

  public GetOpt opts;

  public void init(String[] args)
  {
    // init: must be implemented in sub-classes
    opts = new GetOpt();
    opts.setArgs(args);
    opts.setDefault("cores", 32);
    opts.setDefault("width_m_d", 32);
    opts.setDefault("depth_m_i", 11);
    opts.setDefault("depth_m_d", 11);
    opts.setDefault("depth_u2m", 11);
    opts.setDefault("width_p_d", 32);
    opts.setDefault("depth_p_i", 10);
    opts.setDefault("depth_p_d", 8);
    opts.setDefault("depth_m2s", 8);
    opts.setDefault("image_width_bits", 8);
    opts.setDefault("image_height_bits", 8);
    opts.setDefault("vram_width_bits", 8);
    opts.setDefault("vram_height_bits", 9);
    opts.setDefault("pe_depth_reg", 5);
    opts.setDefault("lreg_start", 24);
    opts.setDefault("enable_uart", 1);

    DEPTH_REG = 5;

    CORES = opts.getIntValue("cores");
    PARALLEL = CORES;
    ENABLE_UART = opts.getIntValue("enable_uart");

    WIDTH_I = 16;
    DEPTH_IO_REG = 5;
    WIDTH_M_D = opts.getIntValue("width_m_d");
    DEPTH_M_I = opts.getIntValue("depth_m_i");
    DEPTH_M_D = opts.getIntValue("depth_m_d");
    WIDTH_P_D = opts.getIntValue("width_p_d");
    DEPTH_P_I = opts.getIntValue("depth_p_i");
    DEPTH_P_D = opts.getIntValue("depth_p_d");
    DEPTH_M2S = opts.getIntValue("depth_m2s");
    DEPTH_S2M = 9;
    DEPTH_U2M = opts.getIntValue("depth_u2m");
    IMAGE_WIDTH_BITS = opts.getIntValue("image_width_bits");
    IMAGE_HEIGHT_BITS = opts.getIntValue("image_height_bits");
    DEPTH_VRAM = opts.getIntValue("vram_width_bits") + opts.getIntValue("vram_height_bits");
    DEPTH_B_U = Integer.max(DEPTH_M_I, DEPTH_U2M);
    DEPTH_V_U = (DEPTH_B_U + 2);
    // $clog2(N) == (32 - Integer.numberOfLeadingZeros(N - 1))
    CORE_BITS = (32 - Integer.numberOfLeadingZeros((CORES + 6) - 1));
    DEPTH_B_F = Integer.max(DEPTH_VRAM, DEPTH_S2M);
    DEPTH_V_F = (DEPTH_B_F + 1);
    DEPTH_B_M2S = Integer.max(DEPTH_P_I, DEPTH_M2S);
    DEPTH_V_M2S = (DEPTH_B_M2S + 1);
    DEPTH_B_M_W = Integer.max(DEPTH_V_M2S, Integer.max(DEPTH_M_D, DEPTH_IO_REG));
    DEPTH_V_M_W = (DEPTH_B_M_W + CORE_BITS);
    DEPTH_B_M_R = Integer.max(DEPTH_M_D, Integer.max(DEPTH_IO_REG, Integer.max(DEPTH_U2M, DEPTH_S2M)));
    DEPTH_V_M_R = (DEPTH_B_M_R + 2);
    DEPTH_B_S_R = Integer.max(DEPTH_P_D, DEPTH_M2S);
    DEPTH_V_S_R = (DEPTH_B_S_R + 2);
    DEPTH_B_S_W = Integer.max(DEPTH_V_F, DEPTH_P_D);
    DEPTH_V_S_W = (DEPTH_B_S_W + 1);
    PE_ID_START = 4;

    M2S_BANK_M2S = 0;
    M2S_BANK_MEM_I = 1;
    PE_W_BANK_MEM_D = 0;
    PE_W_BANK_FIFO = 1;
    PE_R_BANK_MEM_D = 0;
    PE_R_BANK_M2S = 1;
    PE_R_BANK_ITEM_COUNT = 2;

    MASTER_W_BANK_BC = ((1 << CORE_BITS) - 1);
    MASTER_W_BANK_MEM_D = 0;
    MASTER_W_BANK_IO_REG = 1;
    MASTER_R_BANK_MEM_D = 0;
    MASTER_R_BANK_IO_REG = 1;
    MASTER_R_BANK_U2M = 2;
    MASTER_R_BANK_S2M = 3;
    UART_IO_ADDR_RESET = ((1 << DEPTH_B_U) + 0);
    UART_BANK_MEM_I = 0;
    UART_BANK_U2M = 2;
    FIFO_BANK_S2M = 0;
    FIFO_BANK_VRAM = 1;
    IO_REG_R_UART_BUSY = 0;
    IO_REG_R_VGA_VSYNC = 1;
    IO_REG_R_VGA_VCOUNT = 2;
    IO_REG_W_RESET_PE = 0;
    IO_REG_W_LED = 1;
    IO_REG_W_UART = 2;
    IO_REG_W_SPRITE_X = 3;
    IO_REG_W_SPRITE_Y = 4;
    IO_REG_W_SPRITE_SCALE = 5;

    REGS = (1 << DEPTH_REG);
    SP_REG_STACK_POINTER = (REGS - 1);

    LREG0 = 24;
    LREG1 = 25;
    LREG2 = 26;
    LREG3 = 27;
    LREG4 = 28;
    LREG5 = 29;
    LREG6 = 30;

    STACK_ADDRESS = ((1 << DEPTH_M_D) - 1);
  }

  // jump to label
  public void lib_ba(String name)
  {
    // modify: SP_REG_MVIL
    int addr = addr_abs(name);
    if (addr > MVIL_ADDR_LIMIT)
    {
      print_error("lib_ba: exceeds address limit");
    }
    as_mvil(addr);
    as_ba(SP_REG_MVIL);
    lib_wait_delay_slot();
  }

  // branch to label
  public void lib_bc(int reg, String name)
  {
    // modify: SP_REG_MVIL
    int addr = addr_abs(name);
    if (addr > MVIL_ADDR_LIMIT)
    {
      print_error("lib_bc: exceeds address limit");
    }
    as_mvil(addr);
    as_bc(reg, SP_REG_MVIL);
    lib_wait_delay_slot();
  }

  // call function
  public void lib_call(String name)
  {
    // modify: SP_REG_MVIL
    int addr = addr_abs(name);
    if (addr > MVIL_ADDR_LIMIT)
    {
      print_error("lib_call: exceeds address limit");
    }
    as_mvil(addr);
    as_bl(SP_REG_LINK, SP_REG_MVIL);
    lib_wait_delay_slot();
  }

  // initialize stack
  public void lib_init_stack()
  {
    /* prerequisite: mem_d depth <= 11 */
    as_mvil(STACK_ADDRESS);
    as_mv(SP_REG_STACK_POINTER, SP_REG_MVIL);
  }

  // load with label (no wait)
  // reg: destination register (previously loaded data)
  // name: data address label (load reservation, latency:3)
  public void lib_ld_nw(int reg, String name)
  {
    int addr = addr_abs(name);
    if (addr > MVIL_ADDR_LIMIT)
    {
      print_error("lib_ld: exceeds address limit");
    }
    as_mvil(addr);
    as_ld(reg, SP_REG_MVIL);
  }

  // load with label (with wait)
  public void lib_ld(int reg, String name)
  {
    int addr = addr_abs(name);
    if (addr > MVIL_ADDR_LIMIT)
    {
      print_error("lib_ld: exceeds address limit");
    }
    as_mvil(addr);
    as_ld(reg, SP_REG_MVIL);
    lib_nop(2);
    as_ld(reg, SP_REG_MVIL);
  }

  // store with label
  public void lib_st(String name, int reg)
  {
    int addr = addr_abs(name);
    if (addr > MVIL_ADDR_LIMIT)
    {
      print_error("lib_st: exceeds address limit");
    }
    as_mvil(addr);
    as_st(SP_REG_MVIL, reg);
  }

  // simple NOP x repeat
  public void lib_nop(int repeat)
  {
    for (int i = 0; i < repeat; i++)
    {
      as_nop();
    }
  }

  // stack: push r[reg]
  public void lib_push(int reg)
  {
    as_st(SP_REG_STACK_POINTER, reg);
    as_subi(SP_REG_STACK_POINTER, 1);
  }

  // stack: pop to r[reg]
  public void lib_pop(int reg)
  {
    as_addi(SP_REG_STACK_POINTER, 1);
    as_ld(reg, SP_REG_STACK_POINTER);
    lib_nop(2);
    as_ld(reg, SP_REG_STACK_POINTER);
  }

  // stack: push r[reg_s] ~ r[reg_s + num - 1]
  public void lib_push_regs(int reg_s, int num)
  {
    if ((reg_s < 0) || (reg_s >= LREG0))
    {
      print_error("lib_push_regs: invalid register number");
    }
    if ((num < 1) || (num > 7))
    {
      print_error("lib_push_regs: 1 <= num <= 7");
    }
    as_mv(LREG0, SP_REG_STACK_POINTER);
    for (int i = 0; i < num; i++)
    {
      as_st(SP_REG_STACK_POINTER, reg_s + i);
      as_subi(SP_REG_STACK_POINTER, 1);
    }
  }

  // stack: pop to r[reg_s + num - 1] ~ r[reg_s]
  public void lib_pop_regs(int reg_s, int num)
  {
    if ((reg_s < 0) || (reg_s >= LREG0))
    {
      print_error("lib_pop_regs: invalid register number");
    }
    if ((num < 1) || (num > 7))
    {
      print_error("lib_pop_regs: 1 <= num <= 7");
    }
    as_addi(SP_REG_STACK_POINTER, 1);
    as_ld(reg_s + num - 1, SP_REG_STACK_POINTER);
    for (int i = 0; i < num - 1; i++)
    {
      as_nop();
      as_addi(SP_REG_STACK_POINTER, 1);
      as_ld(reg_s + num - 1 - i, SP_REG_STACK_POINTER);
    }
    lib_nop(2);
    as_ld(reg_s, SP_REG_STACK_POINTER);
  }

  // return
  public void lib_return()
  {
    as_ba(SP_REG_LINK);
    lib_wait_delay_slot();
  }

  // Reg[reg] = value (11bit)
  public void lib_set_im(int reg, int value)
  {
    as_mvil(value);
    as_mv(reg, SP_REG_MVIL);
  }

  // wait: delay_slot
  public void lib_wait_delay_slot()
  {
    lib_nop(WAIT_DELAYSLOT);
  }

  // functions ---------------------------------------------

  public void f_halt()
  {
    // halt
    // input: none
    // output: none
    label("f_halt");
    lib_ba("f_halt");
    lib_wait_delay_slot();
  }

  public void f_memcpy()
  {
    // input: R3:dst_addr R4:src_addr R5:copy_size
    /*
    do
    {
      size -= 1;
      data = mem[addr_src];
      mem[addr_dst] = data;
      addr_src++;
      addr_dst++;
    } while (size != 0)
    mem[addr_reset] = 0;
    */
    int addr_dst = R3;
    int addr_src = R4;
    int size = R5;
    int data = LREG0;
    label("f_memcpy");
    as_ld(data, addr_src);
    as_nop();
    label("f_memcpy_L_0");
    as_addi(addr_src, 1);
    as_ld(data, addr_src);
    as_st(addr_dst, data);
    as_addi(addr_dst, 1);
    as_subi(size, 1);
    as_cnz(LREG1, size);
    lib_bc(LREG1, "f_memcpy_L_0");
    lib_return();
  }

  public void f_wait()
  {
    // simple wait ()
    // input: r3:count
    // modify: r3
    label("f_wait");
    as_subi(R3, 1);
    as_cnz(LREG0, R3);
    lib_bc(LREG0, "f_wait");
    lib_return();
  }

  public void f_uart_char()
  {
    // uart put char
    // input: r3: char to send
    // output: none
    label("f_uart_char");
    lib_push(SP_REG_LINK);
    // LREG0 = UART_BUSY addr
    //lib_set_im(LREG0, (MASTER_R_BANK_IO_REG << DEPTH_B_M_R) + IO_REG_R_UART_BUSY);
    as_mvil(MASTER_R_BANK_IO_REG);
    as_mv(LREG0, SP_REG_MVIL);
    as_mvil(DEPTH_B_M_R);
    as_sl(LREG0, SP_REG_MVIL);
    as_mvil(IO_REG_R_UART_BUSY);
    as_nop();
    as_mvsi(LREG0, MVS_SL);
    as_add(LREG0, SP_REG_MVIL);
    // LREG1 = UART TX addr
    //lib_set_im(LREG1, (MASTER_W_BANK_IO_REG << DEPTH_B_M_W) + IO_REG_W_UART);
    as_mvil(MASTER_W_BANK_IO_REG);
    as_mv(LREG1, SP_REG_MVIL);
    as_mvil(DEPTH_B_M_W);
    as_sl(LREG1, SP_REG_MVIL);
    as_mvil(IO_REG_W_UART);
    as_nop();
    as_mvsi(LREG1, MVS_SL);
    as_add(LREG1, SP_REG_MVIL);
    // while (uart busy){}
    as_ld(LREG2, LREG0);
    lib_nop(2);
    label("f_uart_char_L_0");
    as_ld(LREG2, LREG0);
    as_cnz(LREG3, LREG2);
    lib_bc(LREG3, "f_uart_char_L_0");
    as_st(LREG1, R3);
    lib_pop(SP_REG_LINK);
    lib_return();
  }

  public void f_uart_hex()
  {
    // uart put hex digit
    // input: r3:value(4bit)
    // output: none
    // modify: r3
    // depend: f_uart_char
    label("f_uart_hex");
    /*
    r3 = r3 & 15;
    SP_REG_MVC = 48;
    LREG1 = r3;
    LREG2 = 87;
    LREG3 = 10;
    if (LREG1 - LREG3 >= 0) {SP_REG_MVC = LREG2};
    r3 = r3 + SP_REG_MVC;
    */
    lib_push(SP_REG_LINK);
    as_andi(R3, 15);
    lib_set_im(SP_REG_MVC, 48);
    as_mv(LREG1, R3);
    as_mvi(LREG3, 10);
    lib_set_im(LREG2, 87);
    as_sub(LREG1, LREG3);
    as_cnm(LREG4, LREG1);
    as_mvc(LREG2, LREG4);
    as_add(R3, SP_REG_MVC);
    lib_call("f_uart_char");
    lib_pop(SP_REG_LINK);
    lib_return();
  }

  public void f_uart_hex_word()
  {
    // uart put hex word
    // input: r3:value
    // output: none
    // modify: r3
    // depend: f_uart_char, f_uart_hex
    label("f_uart_hex_word");
    /*
    push(r4 to r7);
    r4 = r3;
    r5 = WIDTH_M_D - 4;
    do
    {
      r6 = r4;
      r3 = r6 >> r5;
      r5 -= 4;
      call f_uart_hex;
    } while (r5 != 0)
    pop(r7 to r4);
    */
    lib_push(SP_REG_LINK);
    lib_push_regs(R4, 4);
    as_mv(R4, R3);
    lib_set_im(R5, WIDTH_M_D - 4);
    label("f_uart_hex_word_L_0");
    as_mv(R6, R4);
    as_sr(R6, R5);
    as_subi(R5, 4);
    as_nop();
    as_mvsi(R3, MVS_SR);
    lib_call("f_uart_hex");
    as_cnm(R7, R5);
    lib_bc(R7, "f_uart_hex_word_L_0");
    lib_pop_regs(R4, 4);
    lib_pop(SP_REG_LINK);
    lib_return();
  }

  public void f_uart_hex_word_ln()
  {
    // uart register monitor
    // input: r3:value
    // output: none
    // depend: f_uart_hex_word, f_uart_hex, f_uart_char
    label("f_uart_hex_word_ln");
    lib_push(SP_REG_LINK);
    lib_call("f_uart_hex_word");
    as_mvi(R3, 13);
    lib_call("f_uart_char");
    as_mvi(R3, 10);
    lib_call("f_uart_char");
    lib_pop(SP_REG_LINK);
    lib_return();
  }

  public void f_uart_memory_dump()
  {
    // uart memory dump
    // input: r3:start_address r4:dump_size(words)
    // output: none
    // depend: f_uart_char, f_uart_hex, f_uart_hex_word
    label("f_uart_memory_dump");
    /*
    push r5;
    r5 = r3;
    do
    {
      r3 = r5;
      call f_uart_hex_word (put address)
      r3 = 32;
      call f_uart_char (put space)
      r3 = mem[r5];
      r5++;
      r4--;
      call f_uart_hex_word (put data)
      r3 = 13;
      call f_uart_char (put enter)
      r3 = 10;
      call f_uart_char (put enter)
    } while (r4 != 0)
    pop r5;
     */
    lib_push(SP_REG_LINK);
    lib_push(R5);
    as_mv(R5, R3);
    label("f_uart_memory_dump_L_0");
    as_mv(R3, R5);
    lib_call("f_uart_hex_word");
    lib_set_im(R3, 32);
    lib_call("f_uart_char");
    as_ld(R3, R5);
    lib_nop(2);
    as_ld(R3, R5);
    as_addi(R5, 1);
    as_subi(R4, 1);
    lib_call("f_uart_hex_word");
    as_mvi(R3, 13);
    lib_call("f_uart_char");
    as_mvi(R3, 10);
    lib_call("f_uart_char");
    as_cnz(R3, R4);
    lib_bc(R3, "f_uart_memory_dump_L_0");
    lib_pop(R5);
    lib_pop(SP_REG_LINK);
    lib_return();
  }

  public void f_uart_print_32()
  {
    // uart print string
    // input: r3:text_start_address
    // output: none
    // depend: f_uart_char
    label("f_uart_print_32");
    /*
    addr:r4 shift:r5 char:r3
    addr = r3;
    shift = 24;
    do
    {
      char = mem[addr] >> shift;
      r3 = char & 0xff;
      if (r3 == 0) break;
      call f_uart_char;
      shift -= 8;
      if (shift < 0)
      {
        shift = 24;
        addr++;
      }
    } while (1)
    */
    int Rchar = R3;
    int Raddr = R4;
    int Rshift = R5;
    int Ri0xff = R6;
    int Ri24 = R7;
    int Rcp = R8;

    lib_push(SP_REG_LINK);
    lib_push_regs(R4, 5);
    as_mv(Raddr, R3);
    lib_set_im(Ri24, 24);
    lib_set_im(Ri0xff, 0xff);
    as_mv(Rshift, Ri24);
    label("f_uart_print_32_L_0");
    as_ld(Rchar, Raddr);
    lib_nop(2);
    as_ld(Rchar, Raddr);
    as_sr(Rchar, Rshift);
    lib_nop(2);
    as_mvsi(Rchar, MVS_SR);
    as_and(Rchar, Ri0xff);
    as_cnz(Rcp, Rchar);
    lib_bc(Rcp, "f_uart_print_32_L_1");
    lib_ba("f_uart_print_32_L_2");
    label("f_uart_print_32_L_1");
    lib_call("f_uart_char");
    as_subi(Rshift, 8);
    as_cnm(Rcp, Rshift);
    lib_bc(Rcp, "f_uart_print_32_L_0");
    as_mv(Rshift, Ri24);
    as_addi(Raddr, 1);
    lib_ba("f_uart_print_32_L_0");
    label("f_uart_print_32_L_2");
    lib_pop_regs(R4, 5);
    lib_pop(SP_REG_LINK);
    lib_return();
  }

  public void f_uart_print_16()
  {
    // uart print string
    // input: r3:text_start_address
    // output: none
    // depend: f_uart_char
    label("f_uart_print_16");
    /*
    addr:r4 shift:r5 char:r3
    addr = r3;
    shift = 8;
    do
    {
      char = mem[addr] >> shift;
      r3 = char & 0xff;
      if (r3 == 0) break;
      call f_uart_char;
      shift -= 8;
      if (shift < 0)
      {
        shift = 8;
        addr++;
      }
    } while (1)
    */
    int Rchar = R3;
    int Raddr = R4;
    int Rshift = R5;
    int Ri0xff = R6;
    int Ri8 = R7;
    int Rcp = R8;

    lib_push(SP_REG_LINK);
    lib_push_regs(R4, 5);
    as_mv(Raddr, R3);
    lib_set_im(Ri8, 8);
    lib_set_im(Ri0xff, 0xff);
    as_mv(Rshift, Ri8);
    label("f_uart_print_16_L_0");
    as_ld(Rchar, Raddr);
    lib_nop(2);
    as_ld(Rchar, Raddr);
    as_sr(Rchar, Rshift);
    lib_nop(2);
    as_mvsi(Rchar, MVS_SR);
    as_and(Rchar, Ri0xff);
    as_cnz(Rcp, Rchar);
    lib_bc(Rcp, "f_uart_print_16_L_1");
    lib_ba("f_uart_print_16_L_2");
    label("f_uart_print_16_L_1");
    lib_call("f_uart_char");
    as_subi(Rshift, 8);
    as_cnm(Rcp, Rshift);
    lib_bc(Rcp, "f_uart_print_16_L_0");
    as_mv(Rshift, Ri8);
    as_addi(Raddr, 1);
    lib_ba("f_uart_print_16_L_0");
    label("f_uart_print_16_L_2");
    lib_pop_regs(R4, 5);
    lib_pop(SP_REG_LINK);
    lib_return();
  }
}
