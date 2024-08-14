// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2019 miya All rights reserved.

import java.lang.Math;

public class PEProgram extends AsmLib
{
  private int FIFO_ADDR;
  private int VRAM_ADDR_H;
  private int VRAM_ADDR_SHIFT;
  private int M2S_ADDR_H;
  private int M2S_ADDR_SHIFT;
  private int ITEM_COUNT_ADDR_H;
  private int ITEM_COUNT_ADDR_SHIFT;
  private int S2M_ADDR_H;
  private int S2M_ADDR_SHIFT;
  private int IMAGE_WIDTH_BITS;
  private int IMAGE_HEIGHT_BITS;
  private int IMAGE_WIDTH_HALF_BITS;
  private int IMAGE_HEIGHT_HALF_BITS;
  private int IMAGE_WIDTH;
  private int IMAGE_HEIGHT;
  private int IMAGE_WIDTH_HALF;
  private int IMAGE_HEIGHT_HALF;

  private void m_mandel_core()
  {
    int x = 11;
    int y = 12;
    int scale = 13;
    int count = 14;
    int cx = 15;
    int cy = 16;
    int a = 17;
    int b = 18;
    int aa = 19;
    int bb = 20;
    int c = 21;
    int x1 = 22;
    int y1 = 23;
    int cmask = 24;
    int max_c = 25;
    int pc = 26;
    int tmp1 = 27;
    int tmp2 = 28;
    int tmp3 = 29;
    int compare = 30;

    // const
    int FIXED_BITS = 13;
    int FIXED_BITS_M1 = 12;
    int MAX_C = 4;

    /*
    a = 0;
    b = 0;
    aa = 0;
    bb = 0;
    scale = 256;
    count = 100;
    cmask = 252;
    max_c = MAX_C << FIXED_BITS;
    x1 = ((x - IMAGE_WIDTH_HALF) * scale) + cx;
    y1 = ((y - IMAGE_HEIGHT_HALF) * scale) + cy;
    do
    {
      pc = c;
      b = ((a * b) >> FIXED_BITS_M1) - y1;
      a = aa - bb - x1;
      aa = (a * a) >> FIXED_BITS;
      bb = (b * b) >> FIXED_BITS;
      c = aa + bb;
      count--;
      x1 += scale;
      pc -= c;
      pc >>= 5;
      limit = (c < MAX_C) && (count > 0) && (pc != 0);
    } while (limit);

    as_mvi(a, 0);
    as_mvi(b, 0);
    as_mvi(aa, 0);
    as_mvi(bb, 0);
    as_mv(x1, x);
    as_mv(y1, y);
    lib_set_im(count, 100);
    lib_set_im(tmp1, IMAGE_WIDTH_HALF);
    lib_set_im(tmp2, IMAGE_HEIGHT_HALF);
    as_mvi(max_c, MAX_C);
    as_sli(max_c, FIXED_BITS);
    as_sub(x1, tmp1);
    as_sub(y1, tmp2);
    as_mul(x1, scale);
    as_mul(y1, scale);
    as_add(x1, cx);
    as_add(y1, cy);
    label("m_mandel_L_0");
    as_mv(pc, c);
    as_mul(b, a);
    as_srai(b, FIXED_BITS_M1);
    as_sub(b, y1);
    as_mv(a, aa);
    as_sub(a, bb);
    as_sub(a, x1);
    as_mv(aa, a);
    as_mul(aa, a);
    as_sri(aa, FIXED_BITS);
    as_mv(bb, b);
    as_mul(bb, b);
    as_sri(bb, FIXED_BITS);
    as_mv(c, aa);
    as_add(c, bb);
    as_subi(count, 1);
    as_add(x1, scale);
    as_mv(tmp1, max_c);
    as_sub(pc, c);
    as_sub(tmp1, c);
    as_sri(pc, 5);
    as_cnm(compare, tmp1);
    as_cnm(tmp2, count);
    as_cnz(tmp3, pc);
    as_and(compare, tmp2);
    as_and(compare, tmp3);
    lib_bc(compare, "m_mandel_L_0");
    */

    as_mv(x1, x);
    as_mv(y1, y);
    lib_set_im(tmp1, IMAGE_WIDTH_HALF);
    lib_set_im(tmp2, IMAGE_HEIGHT_HALF);
    as_mvi(max_c, MAX_C);
    as_sli(max_c, FIXED_BITS);
    as_sub(x1, tmp1);
    as_sub(y1, tmp2);
    as_mvsi(max_c, MVS_SL);
    as_mul(x1, scale);
    as_mul(y1, scale);
    as_mvi(a, 0);
    as_mvi(b, 0);
    as_mvi(aa, 0);
    as_mvi(bb, 0);
    as_mvsi(x1, MVS_MUL);
    as_mvsi(y1, MVS_MUL);
    as_add(x1, cx);
    as_add(y1, cy);
    lib_set_im(count, 100);
    label("m_mandel_core_L_0");
    as_mul(b, a);
    as_subi(count, 1);
    as_mv(pc, c);
    as_mv(a, aa);
    as_sub(a, bb);
    as_sub(a, x1);
    as_mvsi(b, MVS_MUL);
    as_srai(b, FIXED_BITS_M1);
    as_add(x1, scale);
    as_mv(aa, a);
    as_mvsi(b, MVS_SRA);
    as_sub(b, y1);
    as_mv(bb, b);
    as_mul(bb, b);
    as_mul(aa, a);
    as_mv(tmp1, max_c);
    lib_nop(3);
    as_mvsi(bb, MVS_MUL);
    as_sri(bb, FIXED_BITS);
    as_mvsi(aa, MVS_MUL);
    as_sri(aa, FIXED_BITS);
    as_mvsi(bb, MVS_SR);
    as_nop();
    as_mvsi(aa, MVS_SR);
    as_mv(c, aa);
    as_add(c, bb);
    as_sub(pc, c);
    as_sri(pc, 5);
    as_sub(tmp1, c);
    as_cnm(compare, tmp1);
    as_mvsi(pc, MVS_SR);
    as_cnm(tmp2, count);
    as_cnz(tmp3, pc);
    as_and(compare, tmp2);
    as_and(compare, tmp3);
    lib_bc(compare, "m_mandel_core_L_0");
  }

  private void m_fill_vram()
  {
    int MAX_ITEM = 3;
    int item_count_addr = 3;
    int task_id = 4;
    int my_core_id = 7;
    int parallel = 8;
    int vram_addr = 9;
    int i = 10;
    int page = 11;
    int item_count = 11;
    int tmp0 = 12;
    int compare = 13;
    /*
    lib_push(vram_addr);
    
    page = task_id & 1;
    i = (1 << (IMAGE_WIDTH_BITS + IMAGE_HEIGHT_BITS)) - 1 - my_core_id;
    vram_addr += (page << (IMAGE_WIDTH_BITS + IMAGE_HEIGHT_BITS)) + i;
    item_count_addr = ITEM_COUNT_ADDR_H << ITEM_COUNT_ADDR_SHIFT;
    do
    {
      // fifo full check
      do
      {
        item_count = mem[item_count_addr];
        item_count -= MAX_ITEM;
      } while (item_count >= 0);

      mem[vram_addr] = task_id;
      vram_addr -= parallel;
      i -= parallel;
    } while (i >=0);
    lib_pop(vram_addr);
    */

    lib_push(vram_addr);

    as_mvi(i, 1);
    lib_set_im(tmp0, IMAGE_WIDTH_BITS + IMAGE_HEIGHT_BITS);
    as_sl(i, tmp0);
    as_mv(page, task_id);
    as_andi(page, 1);
    as_mvsi(i, MVS_SL);
    as_sl(page, tmp0);
    as_subi(i, 1);
    as_sub(i, my_core_id);
    as_mvsi(page, MVS_SL);
    as_add(page, i);
    as_add(vram_addr, page);

    as_mvi(item_count_addr, ITEM_COUNT_ADDR_H);
    as_sli(item_count_addr, ITEM_COUNT_ADDR_SHIFT);
    lib_nop(2);
    as_mvsi(item_count_addr, MVS_SL);

    label("m_fill_vram_L_0");

    as_ld(item_count, item_count_addr);
    lib_nop(2);
    as_ld(item_count, item_count_addr);
    as_subi(item_count, MAX_ITEM);
    as_cnm(compare, item_count);
    lib_bc(compare, "m_fill_vram_L_0");

    as_st(vram_addr, task_id);
    as_sub(vram_addr, parallel);
    as_sub(i, parallel);
    as_cnm(compare, i);
    lib_bc(compare, "m_fill_vram_L_0");
    lib_pop(vram_addr);
  }

  private void m_mandel()
  {
    int task_id = 4;
    int m2s_addr = 5;
    int my_core_id = 7;
    int parallel = 8;
    int vram_addr = 9;
    int i = 10;
    int page = 11;
    int x = 11;
    int y = 12;
    int scale = 13;
    int count = 14;
    int cx = 15;
    int cy = 16;
    // temp
    int tmp0 = 17;
    int param_addr = 17;
    int compare = 17;
    int wait_counter = 18;
    // const
    int WAIT = 8;
    /*
    lib_push_regs(4, 6); // push R4-R9
    // get param
    scale = mem[m2s_addr + 1];
    cx = mem[m2s_addr + 2];
    cy = mem[m2s_addr + 3];
    
    page = task_id & 1;
    vram_addr += (page << (IMAGE_WIDTH_BITS + IMAGE_HEIGHT_BITS)) + (1 << (IMAGE_WIDTH_BITS + IMAGE_HEIGHT_BITS)) - 1 - my_core_id;
    i = (1 << (IMAGE_WIDTH_BITS + IMAGE_HEIGHT_BITS)) - 1 - my_core_id;
    do
    {
      x = i & ((1 << IMAGE_WIDTH_BITS) - 1);
      y = i >> IMAGE_WIDTH_BITS;
      m_mandel_core();
      mem[vram_addr] = count;
      vram_addr -= parallel;
      i -= parallel;
    } while (i >=0);
    lib_pop_regs(4, 6);
    */

    lib_push_regs(4, 6);

    // get param
    as_mv(param_addr, m2s_addr);
    as_addi(param_addr, 1);
    as_ld(scale, param_addr); // ld param_addr
    as_addi(param_addr, 1);
    as_ld(scale, param_addr); // ld param_addr+1
    as_addi(param_addr, 1);
    as_ld(scale, param_addr); // write scale, ld param_addr+2
    as_ld(cx, param_addr); // write cx, ld param_addr+2
    as_nop();
    as_ld(cy, param_addr); // write cy

    as_mvi(i, 1);
    as_mv(page, task_id);
    as_mvi(tmp0, 1);
    as_mvil(IMAGE_WIDTH_BITS + IMAGE_HEIGHT_BITS);
    as_sl(i, SP_REG_MVIL);
    as_sl(tmp0, SP_REG_MVIL);
    as_andi(page, 1);
    as_mvsi(i, MVS_SL);
    as_mvsi(tmp0, MVS_SL);
    as_subi(i, 1);
    as_sl(page, SP_REG_MVIL);
    as_sub(i, my_core_id);
    as_nop();
    as_mvsi(page, MVS_SL);
    as_add(page, tmp0);
    as_subi(page, 1);
    as_sub(page, my_core_id);
    as_add(vram_addr, page);
    label("m_mandel_L_0");

    // It has become too fast for the Harvester...
    lib_set_im(wait_counter, WAIT);
    label("m_mandel_L_1");
    as_subi(wait_counter, 1);
    as_cnm(compare, wait_counter);
    lib_bc(compare, "m_mandel_L_1");

    as_mv(x, i);
    as_mv(y, i);
    lib_set_im(tmp0, (1 << IMAGE_WIDTH_BITS) - 1);
    as_sri(y, IMAGE_WIDTH_BITS);
    as_and(x, tmp0);
    as_nop();
    as_mvsi(y, MVS_SR);

    m_mandel_core();

    as_st(vram_addr, count);
    as_sub(vram_addr, parallel);
    as_sub(i, parallel);
    as_cnm(compare, i);
    lib_bc(compare, "m_mandel_L_0");
    lib_pop_regs(4, 6);
  }

  private void pe_thread_manager()
  {
    int task_id = 4;
    int m2s_addr = 5;
    int s2m_addr = 6;
    int my_core_id = 7;
    int parallel = 8;
    int vram_addr = 9;
    // temp
    int master_task_id = 10;
    int diff = 11;
    int compare = 12;
    /*
    as_nop();
    lib_init_stack();
    m2s_addr = m_get_m2s_addr();
    vram_addr = m_get_vram_addr();
    s2m_addr = m_get_s2m_addr();
    my_core_id = mem[m2s_addr];
    s2m_addr += my_core_id;
    m2s_addr++;
    parallel = mem[m2s_addr];
    m2s_addr++;
    task_id = mem[m2s_addr];
    if (my_core_id >= parallel) goto "pe_thread_manager_L_end"
    do
    {
      task_id++;
      mem[s2m_addr] = task_id;
      do
      {
        master_task_id = mem[m2s_addr];
        diff = master_task_id - task_id;
      } while (diff != 0);
      m_mandel();
    } (1);
    */
    as_nop();
    lib_init_stack();
    // get m2s,vram,s2m addr
    as_mvi(m2s_addr, M2S_ADDR_H);
    as_sli(m2s_addr, M2S_ADDR_SHIFT);
    as_mvi(s2m_addr, S2M_ADDR_H);
    as_sli(s2m_addr, S2M_ADDR_SHIFT);
    as_mvsi(m2s_addr, MVS_SL);
    as_ld(my_core_id, m2s_addr); // 1st
    as_mvsi(s2m_addr, MVS_SL);
    as_mvi(vram_addr, VRAM_ADDR_H);
    as_sli(vram_addr, VRAM_ADDR_SHIFT);

    as_ld(my_core_id, m2s_addr); // 2nd
    as_addi(m2s_addr, 1);
    as_ld(parallel, m2s_addr); // 1st
    as_mvsi(vram_addr, MVS_SL);
    as_mv(diff, my_core_id);
    as_add(s2m_addr, my_core_id);
    as_ld(parallel, m2s_addr); // 2nd
    as_addi(m2s_addr, 1);
    as_ld(task_id, m2s_addr); // 1st
    as_sub(diff, parallel);
    as_cnm(compare, diff);
    as_ld(task_id, m2s_addr); // 2nd
    lib_bc(compare, "pe_thread_manager_L_end");
    label("pe_thread_manager_L_0");
    as_addi(task_id, 1);
    as_st(s2m_addr, task_id);
    label("pe_thread_manager_L_1");
    as_ld(master_task_id, m2s_addr); // 3rd
    as_mv(diff, master_task_id);
    as_sub(diff, task_id);
    as_cnz(compare, diff);
    lib_bc(compare, "pe_thread_manager_L_1");

    if (WIDTH_P_D == 32)
    {
      m_mandel();
    }
    else
    {
      m_fill_vram();
    }

    lib_ba("pe_thread_manager_L_0");
    label("pe_thread_manager_L_end");
    lib_call("f_halt");
    // link
    f_halt();
  }

  @Override
  public void init(String[] args)
  {
    super.init(args);
    DEPTH_REG = opts.getIntValue("pe_depth_reg");
    REGS = (1 << DEPTH_REG);
    SP_REG_STACK_POINTER = (REGS - 1);
    STACK_ADDRESS = ((1 << DEPTH_P_D) - 1);
    LREG0 = opts.getIntValue("lreg_start") + 0;
    LREG1 = opts.getIntValue("lreg_start") + 1;
    LREG2 = opts.getIntValue("lreg_start") + 2;
    LREG3 = opts.getIntValue("lreg_start") + 3;
    LREG4 = opts.getIntValue("lreg_start") + 4;
    LREG5 = opts.getIntValue("lreg_start") + 5;
    LREG6 = opts.getIntValue("lreg_start") + 6;

    FIFO_ADDR = (PE_W_BANK_FIFO << DEPTH_B_S_W);
    VRAM_ADDR_SHIFT = DEPTH_B_S_W - 3;
    VRAM_ADDR_H = ((FIFO_ADDR + (FIFO_BANK_VRAM << DEPTH_B_F)) >>> VRAM_ADDR_SHIFT);
    M2S_ADDR_H = PE_R_BANK_M2S;
    M2S_ADDR_SHIFT = DEPTH_B_S_R;
    ITEM_COUNT_ADDR_H = PE_R_BANK_ITEM_COUNT;
    ITEM_COUNT_ADDR_SHIFT = DEPTH_B_S_R;
    S2M_ADDR_SHIFT = DEPTH_B_S_W - 3;
    S2M_ADDR_H = ((FIFO_ADDR + (FIFO_BANK_S2M << DEPTH_B_F)) >>> S2M_ADDR_SHIFT);
    IMAGE_WIDTH_BITS = opts.getIntValue("image_width_bits");
    IMAGE_HEIGHT_BITS = opts.getIntValue("image_height_bits");
    IMAGE_WIDTH_HALF_BITS = (IMAGE_WIDTH_BITS - 1);
    IMAGE_HEIGHT_HALF_BITS = (IMAGE_HEIGHT_BITS - 1);
    IMAGE_WIDTH = (1 << IMAGE_WIDTH_BITS);
    IMAGE_HEIGHT = (1 << IMAGE_HEIGHT_BITS);
    IMAGE_WIDTH_HALF = (1 << IMAGE_WIDTH_HALF_BITS);
    IMAGE_HEIGHT_HALF = (1 << IMAGE_HEIGHT_HALF_BITS);
  }

  @Override
  public void program()
  {
    set_filename("default_pe_code");
    set_rom_width(WIDTH_I);
    set_rom_depth(DEPTH_P_I);
    pe_thread_manager();
  }

  @Override
  public void data()
  {
    set_filename("default_pe_data");
    set_rom_width(WIDTH_P_D);
    set_rom_depth(DEPTH_P_D);
  }
}
