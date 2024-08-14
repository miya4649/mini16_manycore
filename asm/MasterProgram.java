// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2019 miya All rights reserved.

import java.lang.Math;

public class MasterProgram extends AsmLib
{
  private int DEBUG = 0;
  private int WAIT_VSYNC = 0;
  private int VGA_HEIGHT_BITS = 9;

  private int M2S_BC_ADDR_H;
  private int M2S_BC_ADDR_SHIFT;
  private int S2M_ADDR_H;
  private int S2M_ADDR_SHIFT;
  private int U2M_ADDR_H;
  private int U2M_ADDR_SHIFT;
  private int IO_REG_W_ADDR_H;
  private int IO_REG_W_ADDR_SHIFT;
  private int IO_REG_R_ADDR_H;
  private int IO_REG_R_ADDR_SHIFT;

  private void f_get_m2s_bc_addr()
  {
    // output: R3:m2s_bc_addr
    int m2s_bc_addr = 3;
    // m2s_bc_addr = M2S_BC_ADDR_H << M2S_BC_ADDR_SHIFT;
    label("f_get_m2s_bc_addr");
    lib_set_im(m2s_bc_addr, M2S_BC_ADDR_H);
    as_sli(m2s_bc_addr, M2S_BC_ADDR_SHIFT);
    lib_nop(2);
    as_mvsi(m2s_bc_addr, MVS_SL);
    lib_return();
  }

  private void f_get_m2s_core_addr()
  {
    // input: R3:core id(0-(N-1))
    // output: R3:m2s_core_addr
    int core_id = 3;
    int m2s_core_addr = 3;
    int tmp0 = SP_REG_MVIL;
    // m2s_core_addr = ((core_id + PE_ID_START) << DEPTH_B_M_W) + (M2S_BANK_M2S << DEPTH_B_M2S);
    label("f_get_m2s_core_addr");
    as_addi(core_id, PE_ID_START);
    as_mvi(tmp0, M2S_BANK_M2S);
    as_sli(m2s_core_addr, DEPTH_B_M_W);
    as_sli(tmp0, DEPTH_B_M2S);
    as_nop();
    as_mvsi(m2s_core_addr, MVS_SL);
    as_mvsi(tmp0, MVS_SL);
    as_add(m2s_core_addr, tmp0);
    lib_return();
  }

  private void f_get_s2m_addr()
  {
    // output: R3:s2m_addr
    int s2m_addr = 3;
    // s2m_addr = S2M_ADDR_H << S2M_ADDR_SHIFT;
    label("f_get_s2m_addr");
    lib_set_im(s2m_addr, S2M_ADDR_H);
    as_sli(s2m_addr, S2M_ADDR_SHIFT);
    lib_nop(2);
    as_mvsi(s2m_addr, MVS_SL);
    lib_return();
  }

  private void f_get_io_reg_w_addr()
  {
    // input: R3: device reg num
    // output: R3:io_reg_w_addr
    int io_reg_w_addr = 3;
    int tmp0 = LREG0;
    // io_reg_w_addr = (IO_REG_W_ADDR_H << IO_REG_W_ADDR_SHIFT) + R3;
    label("f_get_io_reg_w_addr");
    lib_set_im(tmp0, IO_REG_W_ADDR_H);
    as_sli(tmp0, IO_REG_W_ADDR_SHIFT);
    lib_nop(2);
    as_mvsi(tmp0, MVS_SL);
    as_add(io_reg_w_addr, tmp0);
    lib_return();
  }

  private void f_get_io_reg_r_addr()
  {
    // input: R3: device reg num
    // output: R3:io_reg_r_addr
    int io_reg_r_addr = 3;
    int tmp0 = LREG0;
    // io_reg_r_addr = (IO_REG_R_ADDR_H << IO_REG_R_ADDR_SHIFT) + R3;
    label("f_get_io_reg_r_addr");
    lib_set_im(tmp0, IO_REG_R_ADDR_H);
    as_sli(tmp0, IO_REG_R_ADDR_SHIFT);
    lib_nop(2);
    as_mvsi(tmp0, MVS_SL);
    as_add(io_reg_r_addr, tmp0);
    lib_return();
  }

  private void f_get_u2m_addr()
  {
    // output: R3:u2m_addr
    int u2m_addr = 3;
    // u2m_addr = U2M_ADDR_H << U2M_ADDR_SHIFT;
    label("f_get_u2m_addr");
    lib_set_im(u2m_addr, U2M_ADDR_H);
    as_sli(u2m_addr, U2M_ADDR_SHIFT);
    lib_nop(2);
    as_mvsi(u2m_addr, MVS_SL);
    lib_return();
  }

  private void example_led()
  {
    /*
    led_addr = (MASTER_W_BANK_IO_REG << DEPTH_B_M_W) + IO_REG_W_LED;
    counter = 0;
    shift = 18;
    do
    {
      led = counter >> shift;
      mem[led_addr] = led;
      counter++;
    } while (1);
    */
    int led_addr = 3;
    int counter = 4;
    int shift = 5;
    int led = 6;
    as_nop();
    lib_init_stack();
    as_mvil(IO_REG_W_LED);
    as_mv(led_addr, SP_REG_MVIL);
    lib_call("f_get_io_reg_w_addr");
    as_mvi(counter, 0);
    lib_set_im(shift, 18);
    label("example_led_L_0");
    as_mv(led, counter);
    as_sr(led, shift);
    as_addi(counter, 1);
    as_nop();
    as_mvsi(led, MVS_SR);
    as_st(led_addr, led);
    lib_ba("example_led_L_0");
    // link library
    f_get_io_reg_w_addr();
  }

  private void example_helloworld()
  {
    as_nop();
    int from_u2m = 1;
    if (from_u2m == 1)
    {
      lib_call("f_get_u2m_data");
    }
    lib_init_stack();
    as_mvi(R4, MASTER_R_BANK_MEM_D);
    as_sli(R4, DEPTH_B_M_R);
    lib_set_im(R3, addr_abs("d_helloworld"));
    as_mvsi(R4, MVS_SL);
    as_add(R3, R4);
    lib_call("f_uart_print_32");
    lib_call("f_halt");
    // link library
    f_uart_char();
    f_uart_print_32();
    f_halt();
    f_get_u2m_data();
  }

  private void example_helloworld_data()
  {
    label("d_helloworld");
    if (WIDTH_M_D == 32)
    {
      string_data32("Hello, world!\r\n");
    }
    else
    {
      string_data16("Hello, world!\r\n");
    }
  }

  private void f_reset_pe()
  {
    /*
    addr_reset = MASTER_W_BANK_IO_REG;
    addr_reset <<= DEPTH_B_M_W;
    addr_reset += IO_REG_W_RESET_PE;
    mem[addr_reset] = reset_value;
    */
    int reset_value = LREG0;
    int addr_reset = LREG1;
    label("f_reset_pe");
    as_mvi(addr_reset, MASTER_W_BANK_IO_REG);
    as_sli(addr_reset, DEPTH_B_M_W);
    lib_nop(2);
    as_mvsi(addr_reset, MVS_SL);
    as_addi(addr_reset, IO_REG_W_RESET_PE);
    as_st(addr_reset, reset_value);
    lib_return();
  }

  // copy data from U2M to MEM_D
  // call before lib_init_stack()
  public void f_get_u2m_data()
  {
    int addr_dst = LREG0;
    int addr_src = LREG1;
    int size = LREG2;
    int data = LREG3;
    int compare = LREG4;
    label("f_get_u2m_data");
    as_mvi(size, 1);
    as_mvi(addr_src, U2M_ADDR_H);
    as_sli(addr_src, U2M_ADDR_SHIFT);
    as_mvi(addr_dst, 0);
    as_sli(size, DEPTH_M_D);
    as_mvsi(addr_src, MVS_SL);
    as_nop();
    as_mvsi(size, MVS_SL);
    label("f_get_u2m_data_L_0");
    as_ld(data, addr_src);
    as_subi(size, 1);
    as_addi(addr_src, 1);
    as_ld(data, addr_src);
    as_st(addr_dst, data);
    as_cnz(compare, size);
    as_addi(addr_dst, 1);
    lib_bc(compare, "f_get_u2m_data_L_0");
    lib_return();
  }

  public void f_reset_vga()
  {
    /*
    addr_ioreg = MASTER_W_BANK_IO_REG;
    addr_ioreg <<= DEPTH_B_M_W;
    addr_sp_x = addr_ioreg;
    addr_sp_y = addr_ioreg;
    addr_sp_s = addr_ioreg;
    addr_sp_x += 3;
    addr_sp_y += 4;
    addr_sp_s += 5;
    mem[addr_sp_x] = 0;
    mem[addr_sp_y] = 0;
    mem[addr_sp_s] = 12;
    */
    int addr_ioreg = LREG0;
    int addr_sp_x = LREG1;
    int addr_sp_y = LREG2;
    int addr_sp_s = LREG3;
    int x = LREG5;
    label("f_reset_vga");
    as_mvi(addr_ioreg, MASTER_W_BANK_IO_REG);
    as_sli(addr_ioreg, DEPTH_B_M_W);
    lib_set_im(x, 64);
    as_mvsi(addr_ioreg, MVS_SL);
    as_mv(addr_sp_x, addr_ioreg);
    as_mv(addr_sp_y, addr_ioreg);
    as_mv(addr_sp_s, addr_ioreg);
    as_addi(addr_sp_x, IO_REG_W_SPRITE_X);
    as_addi(addr_sp_y, IO_REG_W_SPRITE_Y);
    as_addi(addr_sp_s, IO_REG_W_SPRITE_SCALE);
    as_st(addr_sp_x, x);
    as_sti(addr_sp_y, 0);

    if (WIDTH_P_D == 32)
    {
      as_sti(addr_sp_s, 7);
    }
    else
    {
      as_sti(addr_sp_s, 5);
    }
    lib_return();
  }

  private void f_init_core_id()
  {
    /*
      depends: f_get_m2s_core_addr()
    */
    int addr_core_id = LREG0;
    int next_core_offset = LREG1;
    int i = LREG2;
    int cores = LREG3;
    int addr_cores = LREG4;
    int para = LREG5;
    int compare = LREG6;
    /*
    R3 = cores - 1;
    lib_call("f_get_m2s_core_addr");
    addr_core_id = R3;
    addr_cores = R3 + 1;
    next_core_offset = 1 << DEPTH_B_M_W;
    i = CORES;
    para = PARALLEL;
    do
    {
      i--;
      mem[addr_core_id] = i;
      mem[addr_cores] = para;
      addr_core_id -= next_core_offset;
      addr_cores -= next_core_offset;
    } while (i != 0);
    */
    label("f_init_core_id");
    lib_push(SP_REG_LINK);
    lib_push(R3);
    lib_set_im(cores, CORES);
    lib_set_im(para, PARALLEL);
    lib_set_im(R3, CORES - 1); // cores - 1
    lib_call("f_get_m2s_core_addr");
    as_mv(addr_core_id, R3);
    as_mv(addr_cores, R3);
    as_mvi(next_core_offset, 1);
    as_sli(next_core_offset, DEPTH_B_M_W);
    as_mv(i, cores);
    as_addi(addr_cores, 1);
    as_mvsi(next_core_offset, MVS_SL);
    label("f_init_core_id_L_0");
    as_subi(i, 1);
    as_st(addr_core_id, i);
    as_st(addr_cores, para);
    as_sub(addr_core_id, next_core_offset);
    as_sub(addr_cores, next_core_offset);
    as_cnz(compare, i);
    lib_bc(compare, "f_init_core_id_L_0");
    lib_pop(R3);
    lib_pop(SP_REG_LINK);
    lib_return();
  }

  private void m_vga_flip(int reg_task_id)
  {
    int task_id = reg_task_id;
    int addr_sp_y = LREG0;
    int tmp0 = LREG1;
    int page = LREG2;

    /*
    addr_sp_y = (MASTER_W_BANK_IO_REG << DEPTH_B_M_W) + IO_REG_W_SPRITE_Y;
    page = -(((task_id & 1) ^ 1) << (IMAGE_HEIGHT_BITS + 1));
    *addr_sp_y = page;
    */

    as_mvi(addr_sp_y, MASTER_W_BANK_IO_REG);
    as_sli(addr_sp_y, DEPTH_B_M_W);
    as_mv(tmp0, task_id);
    as_andi(tmp0, 1);
    as_mvsi(addr_sp_y, MVS_SL);
    as_xori(tmp0, 1);
    // vga_height = 1 << VGA_HEIGHT_BITS
    as_sli(tmp0, VGA_HEIGHT_BITS);
    as_mvi(page, 0);
    as_addi(addr_sp_y, IO_REG_W_SPRITE_Y);
    as_mvsi(tmp0, MVS_SL);
    // sp_y = 0(page0), -vga_height(page1)
    as_sub(page, tmp0);
    as_st(addr_sp_y, page);
  }

  private void m_wait_vsync()
  {
    /*
    addr_vsync = (MASTER_R_BANK_IO_REG << DEPTH_B_M_R) + IO_REG_R_VGA_VSYNC;
    vsync_pre = 0;
    do
    {
      vsync = mem[addr_vsync];
      vsync_start = ((vsync == 0) && (vsync_pre == 1));
      vsync_pre = vsync;
    } while (!vsync_start);
    (!vsync_start = ((vsync == 1) || (vsync_pre == 0)))
    */
    int addr_vsync = LREG0;
    int vsync = LREG1;
    int vsync_start = LREG2;
    int vsync_pre = LREG3;
    int compare = LREG4;
    as_mvi(addr_vsync, MASTER_R_BANK_IO_REG);
    as_sli(addr_vsync, DEPTH_B_M_R);
    as_mvi(vsync_pre, 0);
    as_nop();
    as_mvsi(addr_vsync, MVS_SL);
    as_addi(addr_vsync, IO_REG_R_VGA_VSYNC);
    as_ld(vsync, addr_vsync);
    lib_nop(2);
    label("m_wait_vsync_L_0");
    as_ld(vsync, addr_vsync);
    as_cnz(vsync_start, vsync);
    as_cnz(compare, vsync_pre);
    as_mv(vsync_pre, vsync);
    as_xori(compare, -1);
    as_or(compare, vsync_start);
    lib_bc(compare, "m_wait_vsync_L_0");
  }

  private void m_init_mandel_param()
  {
    /*
      PE m2s memory map:
      3: scale
      4: cx
      5: cy
     */
    int addr_m2s_root = 3;
    int addr_scale = LREG0;
    int addr_cx = LREG1;
    int addr_cy = LREG2;
    int scale = LREG3;
    int cx = LREG4;
    int cy = LREG5;

    as_mv(addr_scale, addr_m2s_root);
    as_mv(addr_cx, addr_m2s_root);
    as_mv(addr_cy, addr_m2s_root);
    lib_ld(scale, "d_mandel_scale");
    as_addi(addr_scale, 3);
    as_addi(addr_cx, 4);
    as_addi(addr_cy, 5);
    lib_ld(cx, "d_mandel_cx");
    lib_ld(cy, "d_mandel_cy");
    as_st(addr_scale, scale);
    as_st(addr_cx, cx);
    as_st(addr_cy, cy);
  }

  private void m_update_mandel_param()
  {
    int addr_m2s_root = 3;
    int addr_scale = LREG0;
    int scale = LREG1;
    int scale_mask = LREG2;
    int compare = LREG3;

    /*
    addr_scale = addr_m2s_root + 3;
    scale -= 1;
    if (scale == 0)
    {
      scale = 256;
    }
    m2s[addr_scale] = scale;
    mem["d_mandel_scale"] = scale;
    */

    as_mv(addr_scale, addr_m2s_root);
    lib_ld(scale, "d_mandel_scale");
    as_addi(addr_scale, 3);
    as_subi(scale, 1);
    as_cnz(compare, scale);
    as_mvil(256);
    as_mv(SP_REG_MVC, scale);
    as_xori(compare, -1);
    as_mvc(SP_REG_MVIL, compare);
    as_mv(scale, SP_REG_MVC);
    as_st(addr_scale, scale);
    lib_st("d_mandel_scale", scale);
  }

  private void master_thread_manager()
  {
    /*
      PE m2s memory map:
      0: core_id
      1: parallel
      2: task_id
      user parameters
      3: scale
      4: cx
      5: cy

      s2m memory map:
      0 - PARALLEL-1: Incremented task_id from PE
     */
    int addr_m2s_root = 3;
    int addr_s2m_root = 4;
    int addr_task_id = 5;
    int addr_s2m = 6;
    int task_id = 7;
    int pe_ack = 8;
    int i = 9;
    int compare = 10;

    /*
    reset_pe(1);
    if (ENABLE_UART == 1)
    {
      lib_call("f_get_u2m_data");
    }
    f_reset_vga();
    init_core_id();
    addr_m2s_root = M2S_BC_ADDR_H << M2S_BC_ADDR_SHIFT;
    addr_task_id = addr_m2s_root + 2;
    addr_s2m_root = MASTER_R_BANK_S2M << DEPTH_B_M_R;
    m_init_mandel_param();
    task_id = 0;
    mem[addr_task_id] = task_id;
    reset_pe(0);
    do
    {
      i = PARALLEL;
      task_id++;
      addr_s2m = addr_s2m_root;
      do
      {
        i--;
        do
        {
          pe_ack = mem[addr_s2m] - task_id;
        } while (pe_ack != 0)
        addr_s2m++;
      } while (i != 0)
      m_wait_vsync();
      m_vga_flip(task_id);
      m_update_mandel_param();
      mem[addr_task_id] = task_id;
    } while (1);
    */
    as_nop();
    lib_init_stack();
    as_mvi(LREG0, 1);
    lib_call("f_reset_pe");

    if (ENABLE_UART == 1)
    {
      lib_call("f_get_u2m_data");
    }

    lib_call("f_reset_vga");
    lib_call("f_init_core_id");
    lib_set_im(addr_m2s_root, M2S_BC_ADDR_H);
    as_mvi(addr_s2m_root, MASTER_R_BANK_S2M);
    as_sli(addr_s2m_root, DEPTH_B_M_R);
    as_sli(addr_m2s_root, M2S_BC_ADDR_SHIFT);
    as_mvi(task_id, 0);
    as_mvsi(addr_s2m_root, MVS_SL);
    as_mvsi(addr_m2s_root, MVS_SL);
    m_init_mandel_param();
    as_mv(addr_task_id, addr_m2s_root);
    as_addi(addr_task_id, 2);
    as_st(addr_task_id, task_id);
    as_mvi(LREG0, 0);
    lib_call("f_reset_pe");
    label("master_thread_manager_L_0");
    lib_set_im(i, PARALLEL);
    as_addi(task_id, 1);
    as_mv(addr_s2m, addr_s2m_root);
    label("master_thread_manager_L_1");
    as_subi(i, 1);
    label("master_thread_manager_L_2");
    as_ld(pe_ack, addr_s2m);
    lib_nop(2);
    as_ld(pe_ack, addr_s2m);
    as_sub(pe_ack, task_id);

    if (WIDTH_P_D < 32)
    {
      as_andi(pe_ack, 1);
    }

    as_cnz(compare, pe_ack);
    lib_bc(compare, "master_thread_manager_L_2");
    as_addi(addr_s2m, 1);
    as_cnz(compare, i);
    lib_bc(compare, "master_thread_manager_L_1");

    m_update_mandel_param();

    if (DEBUG == 1)
    {
      lib_push(R3);
      as_mv(R3, task_id);
      lib_call("f_uart_hex_word_ln");
      as_mvi(R3, 1);
      as_mvil(21);
      as_sl(R3, SP_REG_MVIL);
      lib_nop(2);
      as_mvsi(R3, MVS_SL);
      lib_call("f_wait");
      lib_pop(R3);
    }

    if (WAIT_VSYNC == 1)
    {
      m_wait_vsync();
    }

    m_vga_flip(task_id);

    as_st(addr_task_id, task_id);

    lib_ba("master_thread_manager_L_0");

    lib_call("f_halt");

    // link library
    f_halt();
    f_init_core_id();
    f_reset_pe();
    f_get_m2s_core_addr();
    f_reset_vga();
    if (ENABLE_UART == 1)
    {
      f_get_u2m_data();
    }
    if (DEBUG == 1)
    {
      f_uart_char();
      f_uart_hex();
      f_uart_hex_word();
      f_uart_hex_word_ln();
      f_wait();
    }
  }

  @Override
  public void init(String[] args)
  {
    super.init(args);
    M2S_BC_ADDR_SHIFT = DEPTH_B_M2S;
    M2S_BC_ADDR_H = ((MASTER_W_BANK_BC << DEPTH_B_M_W) + (M2S_BANK_M2S << DEPTH_B_M2S)) >>> M2S_BC_ADDR_SHIFT;
    S2M_ADDR_H = MASTER_R_BANK_S2M;
    S2M_ADDR_SHIFT = DEPTH_B_M_R;
    U2M_ADDR_H = MASTER_R_BANK_U2M;
    U2M_ADDR_SHIFT = DEPTH_B_M_R;
    IO_REG_W_ADDR_H = MASTER_W_BANK_IO_REG;
    IO_REG_W_ADDR_SHIFT = DEPTH_B_M_W;
    IO_REG_R_ADDR_H = MASTER_R_BANK_IO_REG;
    IO_REG_R_ADDR_SHIFT = DEPTH_B_M_R;
  }

  @Override
  public void program()
  {
    set_filename("default_master_code");
    set_rom_width(WIDTH_I);
    set_rom_depth(DEPTH_M_I);
    //example_led();
    //example_helloworld();
    master_thread_manager();
  }

  @Override
  public void data()
  {
    set_filename("default_master_data");
    set_rom_width(WIDTH_M_D);
    set_rom_depth(DEPTH_M_D);
    label("d_mandel_scale");
    dat(256);
    label("d_mandel_cx");
    dat(161 << 6);
    label("d_mandel_cy");
    dat(49 << 6);
    example_helloworld_data();
  }
}
